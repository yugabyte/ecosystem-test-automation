#!/bin/bash
set -e

echo "Cloning the gocql repository"
git clone git@github.com:yugabyte/gocql.git
cd gocql

echo "Running tests"

go clean -testcache

go test -v > $ARTIFACTS_PATH/gocql-TestGetKey-output.txt

# Allow some time for server init
sleep 10

! grep "FAIL" $ARTIFACTS_PATH/gocql-TestGetKey-output.txt
