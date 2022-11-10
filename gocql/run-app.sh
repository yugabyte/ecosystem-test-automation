#!/bin/bash
set -e

rm -rf $WORKING_DIR/gocql
git clone git@github.com:yugabyte/gocql.git $WORKING_DIR/gocql
pushd $WORKING_DIR/gocql
printf "Cloned gocql repo.\n"

go clean -testcache

go test -timeout 30s -run ^TestGetKey$ github.com/yugabyte/gocql > $ARTIFACT_PATH/gocql-TestGetKey-output.txt
REST_PID2=`echo $!`

# Allow some time for server init
sleep 10

grep -P "ok[ \t]+github.com" $ARTIFACT_PATH/gocql-TestGetKey-output.txt
printf "Verified example output.\n"

popd
