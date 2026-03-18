#!/bin/bash
set -e

# Start YugabyteDB
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl destroy
$YUGABYTE_HOME_DIRECTORY/bin/yugabyted destroy
# Start YugabyteDB
if [ $ENABLE_CM == "true" ]; then
  echo "Starting YugabyteDB cluster with Connection Manager..."
  enable_cm_flag="--tserver_flags enable_ysql_conn_mgr=true,allowed_preview_flags_csv=enable_ysql_conn_mgr"
fi

$YUGABYTE_HOME_DIRECTORY/bin/yugabyted start --advertise_address=127.0.0.1 $enable_cm_flag
sleep 10s
$YUGABYTE_HOME_DIRECTORY/bin/ysqlsh -c "CREATE DATABASE pgx_test;"
