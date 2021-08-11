#!/bin/bash
set -e

YBDB_IMAGE=
TOOL_VERSION=
WORKING_DIR=$HOME/jenkins
ARTIFACT_PATH=$HOME/jenkins/artifacts/`date "+%Y%m%d%H%M%S"`
mkdir -p $ARTIFACT_PATH

CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`

pushd $CURRENT_DIR_PATH &> /dev/null

# Launch YugabyteDB
printf "Executing start-ybdb.sh ...\n"
. ./start-ybdb.sh

# Launch the tool
printf "Executing start-tool.sh ...\n"
. ./start-tool.sh

# Start the test/example application and generate reports
printf "Executing run-app.sh ...\n"
. ./run-app.sh

# Tear down the setup
printf "Executing tear-down.sh ...\n"
. ./tear-down.sh

printf "Sequelize test run was successful!\n"

popd &> /dev/null
