#!/bin/bash

if [[ -z "$YBDB_IMAGE" ]]; then
  YBDB_IMAGE=latest
fi
CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`

. ./init/init.sh

if [[ -z "$YBDB_IMAGE_PATH" ]]; then
  echo "WARNING!"
  echo "WARNING! No image was built/identified. Using the default one."
  echo "WARNING!"
  YBDB_IMAGE_PATH=yugabytedb/yugabyte:latest
fi

pushd $CURRENT_DIR_PATH

# 1. Sequelize
YBDB_IMAGE_PATH=$YBDB_IMAGE_PATH bash ./sequelize/start.sh
SEQU_RUN=$?

# 2. GORM
YBDB_IMAGE_PATH=$YBDB_IMAGE_PATH bash ./gorm/start.sh
GORM_RUN=$?

# Add your tool's start script above and save its exit code.

popd

EXIT_CODE=`expr $SEQU_RUN + $GORM_RUN`
exit $EXIT_CODE
