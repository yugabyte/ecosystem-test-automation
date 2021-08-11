#!/bin/bash
set -e


# Stop the tool. Bring down the container.
# no-op for sequelize

# Stop the YugabyteDB cluster
{
  docker stop yugabyte
  docker rm yugabyte
} >> $WORKING_DIR/console.log 2>&1

