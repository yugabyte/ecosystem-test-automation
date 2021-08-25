#!/bin/bash
set -e

#{
  rm -rf $WORKING_DIR/orm-examples
  git clone https://github.com/yugabyte/orm-examples.git $WORKING_DIR/orm-examples
  pushd $WORKING_DIR/orm-examples/golang/gorm
  export GO111MODULE=off
  export GOPATH=$WORKING_DIR/orm-examples/golang/gorm

  go get github.com/jinzhu/gorm
  go get github.com/jinzhu/gorm/dialects/postgres
  go get github.com/google/uuid
  go get github.com/gorilla/mux
  go get github.com/lib/pq
  go get github.com/lib/pq/hstore

  docker exec -i yugabyte ./bin/ysqlsh -c "CREATE DATABASE ysql_gorm"

#} >> $WORKING_DIR/console.log 2>&1
printf "Cloned orm-examples repo.\n"

nohup ./build-and-run.sh > $ARTIFACT_PATH/gorm-example-server-report.txt 2>&1 &
REST_PID1=`echo $!`

sleep 10

REST_PID=`pgrep -P $REST_PID1`
printf "REST server setup done. PIDs: $REST_PID1, $REST_PID\n"
ps -ef | grep $REST_PID1
echo "kill -9 $REST_PID1" >> $CURRENT_DIR_PATH/process-cleanup.sh
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
    --data '{ "userId": 1, "products": [ { "productId": 1, "units": 2 } ] }' \
    -v -X POST -H 'Content-Type:application/json' http://localhost:8080/orders
} >> $ARTIFACT_PATH/gorm-example-client-report.txt 2>&1
printf "Created/retrieved records.\n"

echo "\c ysql_gorm" > ./verify.sql
echo "SELECT * FROM products" >> ./verify.sql
docker cp ./verify.sql yugabyte:/home/yugabyte/verify.sql
docker exec -i yugabyte ./bin/ysqlsh -f /home/yugabyte/verify.sql | grep "1 row"
printf "Verified records.\n"

log "GORM REST server log" $ARTIFACT_PATH/gorm-example-server-report.txt $ARTIFACT_PATH/gorm-example-run-report.txt
log "GORM REST client log" $ARTIFACT_PATH/gorm-example-client-report.txt $ARTIFACT_PATH/gorm-example-run-report.txt
rm $ARTIFACT_PATH/gorm-example-server-report.txt $ARTIFACT_PATH/gorm-example-client-report.txt

kill -SIGKILL $REST_PID
printf "REST server stopped.\n"

popd

