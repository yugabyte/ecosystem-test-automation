#!/bin/bash
set -e

#{
  rm -rf $WORKING_DIR/orm-examples
  git clone https://github.com/yugabyte/orm-examples.git $WORKING_DIR/orm-examples
  pushd $WORKING_DIR/orm-examples/node/sequelize
  npm install
  docker exec -i yugabyte bin/ysqlsh -c "CREATE DATABASE ysql_sequelize"
#} >> $WORKING_DIR/console.log 2>&1
printf "Cloned orm-examples repo.\n"

nohup npm start > $ARTIFACT_PATH/sequelize-orm-example-server-report.txt 2>&1 &
REST_PID1=`echo $!`

sleep 10

REST_PID2=`pgrep -P $REST_PID1`
REST_PID=`pgrep -P $REST_PID2` || REST_PID=$REST_PID2
printf "REST server setup done. PIDs: $REST_PID1, $REST_PID2, $REST_PID\n"
ps -ef | grep $REST_PID1
ps -ef | grep $REST_PID
echo "kill -9 $REST_PID1" >> $CURRENT_DIR_PATH/process-cleanup.sh
echo "kill -9 $REST_PID2" >> $CURRENT_DIR_PATH/process-cleanup.sh
echo "kill -9 $REST_PID" >> $CURRENT_DIR_PATH/process-cleanup.sh

log () {
  echo ""
  echo "======================================================" >> $3
  echo "  $1  " >> $3
  echo "======================================================" >> $3
  cat $2 >> $3
}

{
  curl --data '{ "firstName" : "John", "lastName" : "Smith", "email" : "jsmith@yb.com" }' \
    -v -X POST -H 'Content-Type:application/json' http://localhost:8080/users

  curl http://localhost:8080/users

  curl \
    --data '{ "productName": "Notebook", "description": "200 page notebook", "price": 7.50 }' \
    -v -X POST -H 'Content-Type:application/json' http://localhost:8080/products

  curl http://localhost:8080/products

  curl \
    --data '{ "userId": "1", "products": [ { "productId": 1, "units": 2 } ] }' \
    -v -X POST -H 'Content-Type:application/json' http://localhost:8080/orders
} >> $ARTIFACT_PATH/sequelize-orm-example-client-report.txt 2>&1
printf "Created/retrieved records.\n"

grep "Order lines created" $ARTIFACT_PATH/sequelize-orm-example-server-report.txt
printf "Verified example output.\n"

log "Sequelize REST server log" $ARTIFACT_PATH/sequelize-orm-example-server-report.txt $ARTIFACT_PATH/sequelize-example-run-report.txt
log "Sequelize REST client log" $ARTIFACT_PATH/sequelize-orm-example-client-report.txt $ARTIFACT_PATH/sequelize-example-run-report.txt
rm $ARTIFACT_PATH/sequelize-orm-example-server-report.txt $ARTIFACT_PATH/sequelize-orm-example-client-report.txt

kill -SIGINT $REST_PID
printf "REST server stopped.\n"

#{
  popd
#  docker stop yugabyte
#  docker rm yugabyte
#  . ./start-ybdb.sh
#} >> $WORKING_DIR/console.log 2>&1
#printf "Restarted YugabyteDB container.\n"

#{
  rm -rf $WORKING_DIR/sequelize-yugabytedb
  git clone https://github.com/yugabyte/sequelize-yugabytedb.git $WORKING_DIR/sequelize-yugabytedb
  pushd $WORKING_DIR/sequelize-yugabytedb
  docker exec -i yugabyte bin/ysqlsh -c "CREATE DATABASE test_sequelize"
  npm install 
#} >> $WORKING_DIR/console.log 2>&1
printf "Cloned sequelize-yugabytedb repo.\n"

npm test &> $ARTIFACT_PATH/sequelize-test-report.txt
printf "Ran the tests.\n"

! grep "failing" $ARTIFACT_PATH/sequelize-test-report.txt
printf "Verified test output.\n"

popd

