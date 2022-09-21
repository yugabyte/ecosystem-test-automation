#!/bin/bash
set -e

rm -rf $WORKING_DIR/gocql
git clone git@github.com:yugabyte/gocql.git -b partition_aware_policy $WORKING_DIR/gocql
pushd $WORKING_DIR/gocql
printf "Cloned gocql repo.\n"

#go test might take sometime to give the output, will that be a problem?
#go test -timeout 30s -run ^TestHostRouting$ github.com/yugabyte/gocql > $ARTIFACT_PATH/gocql-TestHostRouting-output.txt
#REST_PID1=`echo $!`

# Allow some time for server init
#sleep 10

go test -timeout 30s -run ^TestGetKey$ github.com/yugabyte/gocql > $ARTIFACT_PATH/gocql-TestGetKey-output.txt
REST_PID2=`echo $!`

# Allow some time for server init
sleep 10

#grep "ok" $ARTIFACT_PATH/gocql-TestHostRouting-output.txt
grep "ok" $ARTIFACT_PATH/gocql-TestGetKey-output.txt
printf "Verified example output.\n"

