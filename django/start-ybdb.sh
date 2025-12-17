#!/bin/bash
set -e

# Start YugabyteDB
$YUGABYTE_HOME_DIRECTORY/bin/yugabyted start --tserver_flags "enable_ysql_conn_mgr=true" --ui false
