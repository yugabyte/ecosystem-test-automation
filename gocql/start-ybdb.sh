#!/bin/bash
set -e

# Start YugabyteDB
if [ $ENABLE_CM == "true" ]; then
  echo "Starting YugabyteDB cluster with Connection Manager..."
  enable_cm_flag=",enable_ysql_conn_mgr=true,allowed_preview_flags_csv=enable_ysql_conn_mgr"
fi

$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl create --tserver_flags="cql_nodelist_refresh_interval_secs=8$enable_cm_flag" --master_flags="tserver_unresponsive_timeout_ms=10000, partitions_vtable_cache_refresh_secs=0"
