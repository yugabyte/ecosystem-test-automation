#!/bin/bash

YBDB_IMAGE=latest
CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`

pushd $CURRENT_DIR_PATH

# 1. Sequelize
YBDB_IMAGE=latest bash ./sequelize/start.sh
SEQU_RUN=$?

# 2. GORM
YBDB_IMAGE=latest bash ./gorm/start.sh
GORM_RUN=$?

# Add your tool's start script above and save its exit code.

popd

EXIT_CODE=`expr $SEQU_RUN + $GORM_RUN`
exit $EXIT_CODE
