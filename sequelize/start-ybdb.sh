#!/bin/bash
set -e

# Start YugabyteDB
docker run -d --name yugabyte  -p7000:7000 -p9000:9000 -p5433:5433 -p9042:9042 \
 $YBDB_IMAGE_PATH bin/yugabyted start \
 --background=false

# Allow some time for cluster init
sleep 10

# Verify start is clean

# Run init script
# docker exec -it yugabyte bin/ysqlsh -c "CREATE DATABASE ysql_sequelize"
