#!/bin/bash
set -e

YUGABYTE_HOME_DIRECTORY=/home/ec2-user/code/yugabyte-binary/yugabyte-2.19.0.0

# Destroy YugabyteDB cluster
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl destroy