#!/bin/bash
set -e

if [ $1 == "--upstream-tests" ]; then
  printf "Executing run-upstream-tests.sh ...\n"
  ./run-upstream-tests.sh
else
  # Start the test/example application and generate reports
  printf "Executing run-app.sh ...\n"
  ./run-app.sh
fi
