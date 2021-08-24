#!/bin/bash

printf '%s\n' "------------- START gORM run ------------------"
TOOL_VERSION=

CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`

cd $CURRENT_DIR_PATH

# Start the run
bash ./do-start.sh
SUCCESS="$?"

# Tear down the setup
printf "Executing tear-down.sh ...\n"
. ./tear-down.sh

printf '%s\n' "------------- END gORM run ------------------"

echo "Returning $SUCCESS"
exit $SUCCESS
