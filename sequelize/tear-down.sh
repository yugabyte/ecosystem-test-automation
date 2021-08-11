#!/bin/bash
set -e


# Stop the tool. Bring down the container.
# no-op for sequelize

# Stop the YugabyteDB cluster
{
  sudo docker stop yugabyte
  sudo docker rm yugabyte
} >> $WORKING_DIR/console.log 2>&1

