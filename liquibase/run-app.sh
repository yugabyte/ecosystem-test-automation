#!/bin/bash
set -e

echo "Cloning the liquibase extension repository"

git clone git@github.com:liquibase/liquibase-yugabytedb.git && cd liquibase-yugabytedb
$YUGABYTE_HOME_DIRECTORY/bin/ysqlsh -f ./src/test/resources/docker/yugabytedb-init.sql

echo "Editing the config file"

rm src/test/resources/harness-config.yml && cp $INTEGRATIONS_HOME_DIRECTORY/liquibase/harness-config.yml src/test/resources

echo "Running tests"

mvn clean install
mvn -ntp -Dtest=FoundationalExtensionHarnessSuite test > $ARTIFACTS_PATH/liquibasefoundationaltest.txt

! grep "BUILD FAILURE"