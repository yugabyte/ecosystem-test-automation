#!/bin/bash

# Stop the YugabyteDB cluster
#{
  docker stop yugabyte
  docker rm yugabyte
#} >> $WORKING_DIR/console.log 2>&1
