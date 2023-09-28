#!/bin/bash
set -e

echo "Installing Golang 1.20.8"
sudo rm -rvf /usr/local/go/
sudo wget https://go.dev/dl/go1.20.8.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.8.linux-amd64.tar.gz
sudo chown -R root:root /usr/local/go
mkdir -p $HOME/go/{bin,src}
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

echo "Cloning the driver examples repository"

git clone git@github.com:yugabyte/driver-examples.git && cd driver-examples/go/pgx
go mod init main
go mod tidy

echo "Building the example"

go build ybsql_load_balance.go ybsql_load_balance_pool.go ybsql_fallback.go

echo "Running tests"

./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY > $ARTIFACTS_PATH/pgx_connect.txt

./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY --pool > $ARTIFACTS_PATH/pgxpool_connect.txt

./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY --fallbackTest 1 > $ARTIFACTS_PATH/pgx_fallback1.txt

./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY --fallbackTest 2 > $ARTIFACTS_PATH/pgx_fallback2.txt

./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY --fallbackTest 3 > $ARTIFACTS_PATH/pgx_fallback3.txt

grep "Closing the application ..." $ARTIFACTS_PATH/pgx_connect.txt

grep "Closing the application ..." $ARTIFACTS_PATH/pgxpool_connect.txt

grep "End of checkNodeDownBehaviorMultiFallback() ..." $ARTIFACTS_PATH/pgx_fallback1.txt

grep "End of checkMultiNodeDown() ..." $ARTIFACTS_PATH/pgx_fallback2.txt

grep "End of checkNodeDownPrimary() ..." $ARTIFACTS_PATH/pgx_fallback3.txt