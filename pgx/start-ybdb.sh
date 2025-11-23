#!/bin/bash
set -e

# Start YugabyteDB
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl destroy
$YUGABYTE_HOME_DIRECTORY/bin/yugabyted destroy
$YUGABYTE_HOME_DIRECTORY/bin/yugabyted start --advertise_address=127.0.0.1
$YUGABYTE_HOME_DIRECTORY/bin/ysqlsh -c "CREATE DATABASE pgx_test;"