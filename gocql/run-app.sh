#!/bin/bash
set -e

DIR="driver-examples"
if [ -d "$DIR" ]; then
 echo "driver-examples repository already clonned"
 cd driver-examples
 git checkout master
 git pull
else
 echo "Cloning the driver examples repository"
 git clone git@github.com:yugabyte/driver-examples.git
 cd driver-examples
fi

cd gocql

echo "Running tests"

go clean -testcache

go test -v > $ARTIFACTS_PATH/gocql-TestGetKey-output.txt

# Allow some time for server init
sleep 10

! grep "FAIL" $ARTIFACTS_PATH/gocql-TestGetKey-output.txt
