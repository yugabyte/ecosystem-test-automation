#!/bin/bash

YBDB_IMAGE=latest
CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`

pushd $CURRENT_DIR_PATH

# Sequelize
YBDB_IMAGE=latest bash ./sequelize/start.sh

# gORM
YBDB_IMAGE=latest bash ./gorm/start.sh

popd
