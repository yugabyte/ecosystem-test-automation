#!/bin/bash

YBDB_IMAGE=latest
CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`

pushd $CURRENT_DIR_PATH

# Sequelize
YBDB_IMAGE=latest bash ./sequelize/start.sh
SEQU_RUN=$?

# gORM
YBDB_IMAGE=latest bash ./gorm/start.sh
GORM_RUN=$?

popd

EXIT_CODE=`expr $SEQU_RUN + $GORM_RUN`
exit $EXIT_CODE
