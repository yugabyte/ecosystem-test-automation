#!/bin/bash
set -e

if [ $ENABLE_CM == "true" ]; then
  echo "Starting YugabyteDB cluster with Connection Manager..."
  enable_cm_flag="--tserver_flags enable_ysql_conn_mgr=true,allowed_preview_flags_csv=enable_ysql_conn_mgr"
fi

# Start YugabyteDB
docker run -d --name yugabyte  -p7000:7000 -p9000:9000 -p5433:5433 -p9042:9042 \
 $YBDB_IMAGE_PATH bin/yugabyted start $enable_cm_flag \
 --background=false

# Allow some time for cluster init
sleep 10

# Verify start is clean

# Run init script
# docker exec -it yugabyte bin/ysqlsh -c "CREATE DATABASE ysql_gorm"
