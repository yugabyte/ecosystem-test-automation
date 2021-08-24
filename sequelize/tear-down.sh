#!/bin/bash

# Cleanup any processes that are still running/hung
. ./process-cleanup.sh

# Stop the YugabyteDB cluster
#{
  docker stop yugabyte
  docker rm yugabyte
#} >> $WORKING_DIR/console.log 2>&1

# More cleanup, as needed
rm -f ./process-cleanup.sh
