#!/bin/bash

printf '%s\n' "------------- START GOCQL run ------------------"
TOOL_VERSION=

CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`

cd $CURRENT_DIR_PATH

printf "Python check starting\n"
ls -1 /usr/bin/python* | xargs ls -l
ls -1 /usr/local/bin/python* | xargs ls -l

printf "which pythons\n"
which python
which python3
which python3.8
which python3.9
which python3.12
python --version
printf "PATH:\n"
echo $PATH

printf "\nPython check done\n"

# Start the run
YBDB_IMAGE_PATH=$YBDB_IMAGE_PATH bash ./do-start.sh
SUCCESS="$?"

# Tear down the setup
printf "Executing tear-down.sh ...\n"
. ./tear-down.sh

# Print summary
echo "Returning $SUCCESS"
summary="FAIL"
if [[ "$SUCCESS" == "0" ]]; then
  summary="PASS"
fi
printf '|%+24s |%+24s |\n' "GOCQL" $summary >> $HOME/jenkins/summary
printf '%s\n' "------------- END GOCQL run ------------------"

exit $SUCCESS
