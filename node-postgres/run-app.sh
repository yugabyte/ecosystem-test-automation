#!/bin/bash
set -e

echo "Installing node-postgres smart driver package"

npm install @yugabytedb/pg

echo "Installing node-postgres smart driver pool package"

npm install @yugabytedb/pg-pool

echo "Installing winston logging package"

npm install winston

DIR="driver-examples"
REPORT_FILE="$WORKSPACE/artifacts/test_report_node_postgres.json"
OVERALL_STATUS=0

if [ -d "$DIR" ]; then
 echo "driver-examples repository is already present"
 cd driver-examples
 git checkout main
 git pull
else
 echo "Cloning the driver examples repository"
 git clone git@github.com:yugabyte/driver-examples.git
 cd driver-examples
 git checkout main
fi

# Function to run individual test cases and capture their results
# Usage: run_test <test_name> <script_name> [run_command] [success_marker]
# run_command defaults to running <test_name>.js with node, and success_marker
# defaults to the "Test Completed" message printed by those tests.
run_test() {
    local test_name=$1
    local script_name=$2
    local run_command=${3:-"node $test_name.js"}
    local success_marker=${4:-"Test Completed"}
    echo "Running $test_name from $script_name..."

    # Run the specific test case and capture errors
    eval "$run_command" 2>&1 | tee ${test_name}.log
    if ! grep "$success_marker" ${test_name}.log; then
      if grep "Verification failed:" ${test_name}.log; then
         # Get the lines after 'Verification failed:' which is the stack trace
        sed -n '/Verification failed:/,$p' "${test_name}.log" > stack4json.log
      else
        # Cluster creation or cleanup failed, get the last 10 lines 
        tail -n 10 ${test_name}.log > stack4json.log
      fi
      python $WORKSPACE/integrations/utils/create_json.py --test_name $test_name --script_name $script_name --result FAILED --file_path stack4json.log >> temp_report.json
      OVERALL_STATUS=1
    else
      echo "Test $test_name completed"
      python $WORKSPACE/integrations/utils/create_json.py --test_name $test_name --script_name $script_name --result PASSED >> temp_report.json
    fi
}

cd nodejs
npm install

echo "Exporting environment variable YB_PATH with the value of the path of the YugabyteDB installation directory."

export YB_PATH="$YUGABYTE_HOME_DIRECTORY"
export ENABLE_CM="$ENABLE_CM"

echo "Exporting log level."

export LOG_LEVEL="silly"

# Initialize the JSON report
echo "[" > temp_report.json

echo "Running tests"

run_test "yb-fallback-star-1" "node-postgres/start.sh"

run_test "yb-fallback-star-2" "node-postgres/start.sh"

run_test "yb-fallback-test-1" "node-postgres/start.sh"

run_test "yb-fallback-test-2" "node-postgres/start.sh"

run_test "yb-fallback-test-3" "node-postgres/start.sh"

run_test "yb-fallback-topology-aware-1" "node-postgres/start.sh"

run_test "yb-fallback-topology-aware-2" "node-postgres/start.sh"

run_test "yb-fallback-topology-aware-3" "node-postgres/start.sh"

run_test "yb-load-balance-with-add-node" "node-postgres/start.sh"

run_test "yb-load-balance-with-stop-node" "node-postgres/start.sh"

run_test "yb-pooling-with-load-balance" "node-postgres/start.sh"

run_test "yb-pooling-with-topology-aware" "node-postgres/start.sh"

run_test "yb-topology-aware-with-add-node" "node-postgres/start.sh"

run_test "yb-topology-aware-with-stop-node" "node-postgres/start.sh"

# The Prisma ORM example lives in its own package and is written in TypeScript,
# so it needs its own dependencies and a generated Prisma client before it runs.
PRISMA_TEST_NAME="prisma-orm-yb-load-balance-test"
PRISMA_SETUP_LOG="$PRISMA_TEST_NAME-setup.log"
PRISMA_NODE_VERSION=22
NVM_VERSION="v0.40.3"

setup_prisma() {
    # Prisma 6 needs Node.js >= 18.18 while the agents still default to an older
    # node, so switch to a supported version through nvm just for this test.
    local node_major
    node_major=`node -v 2>/dev/null | sed 's/^v//' | cut -d. -f1`
    if [ -z "$node_major" ] || [ "$node_major" -lt 18 ]; then
      echo "node `node -v 2>/dev/null` is too old for Prisma, switching to node $PRISMA_NODE_VERSION via nvm"
      export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
      if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        echo "Installing nvm $NVM_VERSION"
        curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash || return 1
      fi
      . "$NVM_DIR/nvm.sh" || return 1
      nvm install "$PRISMA_NODE_VERSION" || return 1
      nvm use "$PRISMA_NODE_VERSION" || return 1
      echo "Now using node `node -v`"
    fi

    echo "Installing prisma-orm example dependencies"
    ( cd prisma-orm && npm install && npx prisma generate ) || return 1

    # DATABASE_URL lives in the example's .env, which only the Prisma CLI picks
    # up automatically. Export it so the test process sees it as well.
    set -a
    . ./prisma-orm/.env
    set +a
    echo "Using DATABASE_URL=$DATABASE_URL for the prisma-orm test"
}

# Redirect instead of pipe, so that the environment set up above (the nvm PATH
# and DATABASE_URL) survives, and do not let a setup failure abort the run,
# otherwise the report for all the tests above is never written.
set +e
setup_prisma > "$PRISMA_SETUP_LOG" 2>&1
PRISMA_SETUP_STATUS=$?
set -e
cat "$PRISMA_SETUP_LOG"

if [ "$PRISMA_SETUP_STATUS" -ne 0 ]; then
  echo "Setting up the prisma-orm example failed, skipping $PRISMA_TEST_NAME"
  tail -n 10 "$PRISMA_SETUP_LOG" > stack4json.log
  python $WORKSPACE/integrations/utils/create_json.py --test_name $PRISMA_TEST_NAME --script_name "node-postgres/start.sh" --result FAILED --file_path stack4json.log >> temp_report.json
  OVERALL_STATUS=1
else
  run_test "$PRISMA_TEST_NAME" "node-postgres/start.sh" \
    "(cd prisma-orm && npx tsx yb-load-balance-test.ts)" "Warm-up complete."
fi

# Finalize the JSON report
sed -i '$ s/,$//' temp_report.json # Remove trailing comma from the last JSON object
echo "]" >> temp_report.json
sed -i 's/\t/    /g' temp_report.json # Replace tabs with spaces

# Move the temporary report to the final report file
mv temp_report.json "$REPORT_FILE"

# Display the JSON report
echo "TEST REPORT -------------------------"
cat "$REPORT_FILE"

readlink -f "$REPORT_FILE"

# Exit with the overall status
exit $OVERALL_STATUS
