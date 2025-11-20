#!/bin/bash
set -e

# Start YugabyteDB
$YUGABYTE_HOME_DIRECTORY/bin/yugabyted start --advertise_addresses=127.0.0.1
