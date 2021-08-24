#!/bin/bash
set -e

WORKING_DIR=$HOME/jenkins
CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`
ARTIFACT_PATH=$CURRENT_DIR_PATH/artifacts

rm -rf $ARTIFACT_PATH
mkdir -p $ARTIFACT_PATH

pushd $CURRENT_DIR_PATH

# Launch YugabyteDB
printf "Executing start-ybdb.sh ...\n"
. ./start-ybdb.sh

# Start the test/example application and generate reports
printf "Executing run-app.sh ...\n"
. ./run-app.sh

printf "gORM test run was successful!\n"

popd
