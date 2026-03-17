#!/bin/bash
set -e

# Destroy existing YugabyteDB cluster, if any
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl destroy

if [ $ENABLE_CM == "true" ]; then
  echo "Starting YugabyteDB cluster with Connection Manager..."
  enable_cm_flag="--tserver_flags enable_ysql_conn_mgr=true,allowed_preview_flags_csv=enable_ysql_conn_mgr"
fi

# Start a new YugabyteDB cluster
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl create $enable_cm_flag
