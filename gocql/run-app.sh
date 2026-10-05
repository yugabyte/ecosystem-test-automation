#!/bin/bash
#
# Runs the gocql driver's test suites against a live YugabyteDB cluster.
#
# The driver splits its tests across four Go build tags. None of them is implied
# by another, so all four have to be invoked to cover the repository: as of the
# v2.1.2 upgrade that is 347 test functions.
#
# Each suite gets its own entry in the JSON report so a failure names the suite
# it came from.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIR="gocql"
REPORT_FILE="$WORKSPACE/artifacts/test_report_gocql.json"
ARTIFACTS="$WORKSPACE/artifacts"

# Branch or tag of yugabyte/gocql to exercise.
GOCQL_REF="${GOCQL_REF:-master}"

# Suites whose failure should not fail the job. Space separated, e.g.
# "cassandra integration ccm". Failures are still reported; this only controls
# the exit code. Keep it empty unless there is a tracked reason.
GOCQL_NONBLOCKING_SUITES="${GOCQL_NONBLOCKING_SUITES:-}"

CLUSTER_HOST="${CLUSTER_HOST:-127.0.0.1}"

# yb-ctl creates a single node, so replication factor and cluster size are 1.
# proto=4 because YCQL implements protocol versions 3 and 4 only.
CQL_FLAGS=("-gocql.timeout=60s" "-proto=4" "-rf=1" "-clusterSize=1" "-autowait=2000ms" "-cluster=$CLUSTER_HOST")

mkdir -p "$ARTIFACTS"
: > "$ARTIFACTS/temp_report.json"

# ---------------------------------------------------------------- repository

if [ -d "$DIR" ]; then
  echo "gocql repository is already present"
  cd "$DIR" || exit 1
  git fetch --all --tags --prune
  git checkout "$GOCQL_REF"
  git pull --ff-only || true   # a tag or detached ref has nothing to pull
else
  echo "Cloning the gocql repository"
  git clone git@github.com:yugabyte/gocql.git || exit 1
  cd "$DIR" || exit 1
  git checkout "$GOCQL_REF"
fi

echo "Testing $(git rev-parse --short HEAD) ($GOCQL_REF)"
go clean -testcache

# ------------------------------------------------------------------ helpers

# A suite that has run leaves keyspaces behind, and YugabyteDB refuses to drop a
# keyspace that still has tables or types in it. The driver's own test harness
# (common_test.go, createKeyspaceWithRF) panics when its DROP KEYSPACE fails,
# which aborts the next suite part way through and reports a plausible but wrong
# number. Recreating the cluster is slower than dropping keyspaces individually
# but it cannot leave anything behind.
reset_cluster() {
  echo "--- recreating the cluster so the next suite starts clean ---"
  "$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl" destroy >/dev/null 2>&1
  "$SCRIPT_DIR/start-ybdb.sh" || return 1
}

is_nonblocking() {
  case " $GOCQL_NONBLOCKING_SUITES " in
    *" $1 "*) return 0 ;;
    *) return 1 ;;
  esac
}

OVERALL=0
SUMMARY=""

# run_suite <name> <go test args...>
run_suite() {
  local name="$1"; shift
  local log="$ARTIFACTS/gocql-${name}.log"

  echo
  echo "=============== gocql suite: $name ==============="
  echo "go test $*"
  go test "$@" 2>&1 | tee "$log"
  local rc=${PIPESTATUS[0]}

  local pass fail skip panics
  pass=$(grep -cE '^(    )?--- PASS' "$log")
  fail=$(grep -cE '^(    )?--- FAIL' "$log")
  skip=$(grep -cE '^(    )?--- SKIP' "$log")
  panics=$(grep -c '^panic:' "$log")

  # A panic aborts the binary, so the counts above describe only the tests that
  # ran before it. Treat it as a failure even if nothing was marked FAIL.
  if [ "$panics" -gt 0 ]; then
    echo ">>> $name: the suite panicked and stopped early; counts are incomplete"
    rc=1
  fi

  echo "--- $name: pass=$pass fail=$fail skip=$skip panic=$panics exit=$rc"

  local result="PASSED"
  if [ "$rc" -ne 0 ]; then
    result="FAILED"
  fi

  if [ "$result" = "FAILED" ]; then
    # Keep the report small: the failing test lines and their last line of
    # output, rather than the whole log.
    grep -B1 -E '^(    )?--- FAIL' "$log" > "$ARTIFACTS/stack-${name}.log" 2>/dev/null
    grep '^panic:' "$log" >> "$ARTIFACTS/stack-${name}.log" 2>/dev/null
    python "$WORKSPACE/integrations/utils/create_json.py" \
      --test_name "$name" --script_name "gocql-$name" \
      --result FAILED --file_path "$ARTIFACTS/stack-${name}.log" >> "$ARTIFACTS/temp_report.json"
  else
    python "$WORKSPACE/integrations/utils/create_json.py" \
      --test_name "$name" --script_name "gocql-$name" \
      --result PASSED >> "$ARTIFACTS/temp_report.json"
  fi

  local gating="$result"
  if [ "$result" = "FAILED" ] && is_nonblocking "$name"; then
    gating="FAILED (not gating)"
  elif [ "$result" = "FAILED" ]; then
    OVERALL=1
  fi

  SUMMARY="$SUMMARY$(printf '\n|%+14s |%+8s |%5s pass |%5s fail |%5s skip |' "$name" "$gating" "$pass" "$fail" "$skip")"
}

# -------------------------------------------------------------------- suites

echo "[" >> "$ARTIFACTS/temp_report.json"

# ./... is required: every subpackage test file is tagged "all || unit", so with
# a bare "." they are silently skipped -- 394 tests instead of 442, missing
# internal/murmur, which is the token hashing behind partition-aware routing.
run_suite unit -tags unit -v -timeout=15m -race ./...

reset_cluster
# These two must NOT use ./...: combined with the -proto/-cluster flags, go test
# silently runs only the root package and still exits 0, because the subpackage
# test binaries do not define those flags. No subpackage has cassandra- or
# integration-tagged tests, so "." loses nothing.
run_suite cassandra -tags "cassandra gocql_debug" -v -timeout=15m "${CQL_FLAGS[@]}" .

reset_cluster
run_suite integration -tags "integration gocql_debug" -v -timeout=15m "${CQL_FLAGS[@]}" .

# The ccm suite needs Cassandra Cluster Manager, which cannot drive YugabyteDB,
# so these tests are expected to skip. The pass is still worth running: it is
# the only one that compiles those files, so a build break there is otherwise
# invisible.
run_suite ccm -tags ccm -v -timeout=5m ./...

# -------------------------------------------------------------------- report

sed -i '$ s/,$//' "$ARTIFACTS/temp_report.json"
echo "]" >> "$ARTIFACTS/temp_report.json"
sed -i 's/\t/    /g' "$ARTIFACTS/temp_report.json"
mv "$ARTIFACTS/temp_report.json" "$REPORT_FILE"

echo
echo "TEST REPORT -------------------------"
cat "$REPORT_FILE"
readlink -f "$REPORT_FILE"

echo
echo "SUITE SUMMARY -----------------------$SUMMARY"
echo
if [ -n "$GOCQL_NONBLOCKING_SUITES" ]; then
  echo "note: failures in [$GOCQL_NONBLOCKING_SUITES] were reported but did not fail the job"
fi

exit $OVERALL
