#!/bin/bash
set -e

{
  rm -rf $WORKING_DIR/orm-examples
  git clone https://github.com/yugabyte/orm-examples.git $WORKING_DIR/orm-examples
  pushd $WORKING_DIR/orm-examples/node/sequelize
  npm install
  sudo docker exec -it yugabyte bin/ysqlsh -c "CREATE DATABASE ysql_sequelize"
} >> $WORKING_DIR/console.log 2>&1
printf "Cloned orm-examples repo.\n"

nohup npm start > $ARTIFACT_PATH/sequelize-orm-example-server-report.txt 2>&1 &
REST_PID=`echo $!`
printf "REST server setup done. PID: $REST_PID\n"
sleep 10

{
  curl --data '{ "firstName" : "John", "lastName" : "Smith", "email" : "jsmith@yb.com" }' \
    -v -X POST -H 'Content-Type:application/json' http://localhost:8080/users

  curl http://localhost:8080/users

  curl \
    --data '{ "productNiame": "Notebook", "description": "200 page notebook", "price": 7.50 }' \
    -v -X POST -H 'Content-Type:application/json' http://localhost:8080/products

  curl http://localhost:8080/products

  curl \
    --data '{ "userId": "1", "products": [ { "productId": 1, "units": 2 } ] }' \
    -v -X POST -H 'Content-Type:application/json' http://localhost:8080/orders
} >> $ARTIFACT_PATH/sequelize-orm-example-client-report.txt 2>&1
printf "Created/retrieved records.\n"

grep "Order lines created" $ARTIFACT_PATH/sequelize-orm-example-server-report.txt >> $WORKING_DIR/console.log 2>&1
printf "Verified example output.\n"

kill -SIGINT $REST_PID
printf "REST server stopped.\n"

{
  popd
#  sudo docker stop yugabyte
#  sudo docker rm yugabyte
#  . ./start-ybdb.sh
} >> $WORKING_DIR/console.log 2>&1
#printf "Restarted YugabyteDB container.\n"

{
  rm -rf $WORKING_DIR/sequelize-yugabytedb
  git clone https://github.com/yugabyte/sequelize-yugabytedb.git $WORKING_DIR/sequelize-yugabytedb
  pushd $WORKING_DIR/sequelize-yugabytedb
  sudo docker exec -it yugabyte bin/ysqlsh -c "CREATE DATABASE test_sequelize"
  npm install 
} >> $WORKING_DIR/console.log 2>&1
printf "Cloned sequelize-yugabytedb repo.\n"

npm test &> $ARTIFACT_PATH/sequelize-test-report.log
printf "Ran the tests.\n"

grep "5 passing" $ARTIFACT_PATH/sequelize-test-report.log >> $WORKING_DIR/console.log 2>&1
printf "Verified test output.\n"

popd >> $WORKING_DIR/console.log 2>&1

