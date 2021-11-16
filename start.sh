#!/bin/bash

rm -f $HOME/jenkins/summary
if [[ -z "$YBDB_IMAGE" ]]; then
  YBDB_IMAGE=latest
fi
CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`

DOCKER_BUILD_RUN=0
dockerrun="PASS"
. ./init/init.sh

if [[ -z "$YBDB_IMAGE_PATH" ]]; then
  echo "WARNING! No Docker image was built/identified. Using the default one."
  DOCKER_BUILD_RUN=1
  dockerrun="FAIL"
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

echo "----------------------------------------------------"
echo "|                  S U M M A R Y                   |"
echo "----------------------------------------------------"
printf '|%+24s |%+24s |\n' "Docker Build" $dockerrun
cat $HOME/jenkins/summary
echo "----------------------------------------------------"

EXIT_CODE=`expr $SEQU_RUN + $GORM_RUN + $DOCKER_BUILD_RUN`
exit $EXIT_CODE
