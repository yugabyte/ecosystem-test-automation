echo "Cloning the liquibase extension repository"

git clone git@github.com:liquibase/liquibase-yugabytedb.git && cd liquibase-yugabytedb

echo "Editing the config file"

rm src/test/resources/harness-config.yml && cp ../harness-config.yml src/test/resources

echo "Running tests"

mvn clean install
mvn -ntp -Dtest=FoundationalExtensionHarnessSuite test

echo "Cleanup"

cd ../ && rm -rf liquibase-yugabytedb