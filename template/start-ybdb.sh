#!/bin/bash
set -e

# Check if YBDB_IMAGE is defined. If not set it to a value of your choice.
if [[ -z $YBDB_IMAGE ]]; then
  YBDB_IMAGE=latest
fi

# Start YugabyteDB
docker run -d --name yugabyte  -p7000:7000 -p9000:9000 -p5433:5433 -p9042:9042 \
 yugabytedb/yugabyte:$YBDB_IMAGE bin/yugabyted start \
 --daemon=false

# Allow some time for cluster init
sleep 10

# Verify start is clean

# Run init script
# docker exec -it yugabyte bin/ysqlsh -c "CREATE DATABASE ysql_new_tool"
