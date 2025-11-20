#!/bin/bash
set -e

# Start YugabyteDB
$YUGABYTE_HOME_DIRECTORY/bin/yugabyted start --advertise_address=127.0.0.1
