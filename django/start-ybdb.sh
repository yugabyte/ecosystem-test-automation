#!/bin/bash
set -e

# Start YugabyteDB
if [ $ENABLE_CM == "true" ]; then
  echo "Starting YugabyteDB cluster with Connection Manager..."
  enable_cm_flag="--tserver_flags enable_ysql_conn_mgr=true,allowed_preview_flags_csv=enable_ysql_conn_mgr"
fi

$YUGABYTE_HOME_DIRECTORY/bin/yugabyted start --advertise_address=127.0.0.1 $enable_cm_flag --ui false
