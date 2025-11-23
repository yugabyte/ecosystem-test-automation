#!/bin/bash
set -e

# Destroy YugabyteDB cluster
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl destroy
$YUGABYTE_HOME_DIRECTORY/bin/yugabyted destroy