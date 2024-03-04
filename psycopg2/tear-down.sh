#!/bin/bash
set -e

deactivate
rm -rf $WORKSPACE/environments/psycopg2-test

# Destroy YugabyteDB cluster
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl destroy
