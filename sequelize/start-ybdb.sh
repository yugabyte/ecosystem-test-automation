#!/bin/bash
set -e

# Check if Docker installed, else exit
which docker

# Start YugabyteDB
docker run -d --name yugabyte  -p7000:7000 -p9000:9000 -p5433:5433 -p9042:9042 \
 yugabytedb/yugabyte:latest bin/yugabyted start \
 --daemon=false

# Allow some time for cluster init
sleep 5

# Verify start is clean

# Run init script
# docker exec -it yugabyte bin/ysqlsh -c "CREATE DATABASE ysql_sequelize"
