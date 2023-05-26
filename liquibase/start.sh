#!/bin/bash

printf '%s\n' "------------- START new_tool run ------------------"
TOOL_VERSION=

./do-start.sh
SUCCESS="$?"

# Tear down the setup
printf "Executing tear-down.sh ...\n"
./tear-down.sh

# Print summary
echo "Returning $SUCCESS"
summary="FAIL"
if [[ "$SUCCESS" == "0" ]]; then
  summary="PASS"
fi
printf '%s\n' $summary
printf '%s\n' "------------- END new_tool run ------------------"

exit $SUCCESS
