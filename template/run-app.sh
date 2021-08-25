#!/bin/bash
set -e

# If new_tool has an example under orm-examples repository:

# rm -rf $WORKING_DIR/orm-examples
# git clone https://github.com/yugabyte/orm-examples.git $WORKING_DIR/orm-examples
# pushd $WORKING_DIR/orm-examples/new_tool
# docker exec -i yugabyte bin/ysqlsh -c "CREATE DATABASE ysql_new_tool"
printf "Cloned orm-examples repo.\n"

# Start the REST server in the background and save the PID of the actual REST server process
# (Not of the one which starts the REST server)
# 
REST_PID=

# Allow some time for server init
sleep 10

printf "REST server setup done. PIDs: $REST_PID\n"

# Note the PIDs for cleanup later
echo "kill -9 $REST_PID" >> $CURRENT_DIR_PATH/process-cleanup.sh

log () {
  echo ""
  echo "======================================================" >> $3
  echo "  $1  " >> $3
  echo "======================================================" >> $3
  cat $2 >> $3
}

# Update the curl requests as required.
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
} >> $ARTIFACT_PATH/new_tool-orm-example-client-report.txt 2>&1
printf "Created/retrieved records.\n"

# Verify curl requests succeeded
# 
printf "Verified example output.\n"

# Consolidate logs/reports.
log "new_tool REST server log" $ARTIFACT_PATH/new_tool-orm-example-server-report.txt $ARTIFACT_PATH/new_tool-example-run-report.txt
log "new_tool REST client log" $ARTIFACT_PATH/new_tool-orm-example-client-report.txt $ARTIFACT_PATH/new_tool-example-run-report.txt
rm $ARTIFACT_PATH/new_tool-orm-example-server-report.txt $ARTIFACT_PATH/new_tool-orm-example-client-report.txt

# Attempt to stop the REST server. Also send SIGKILL to the PIDs from tear-down.sh
kill -SIGINT $REST_PID
printf "REST server stopped.\n"

# popd
# This ends running the orm example.

# Run more apps to validate the tool and generate reports.

