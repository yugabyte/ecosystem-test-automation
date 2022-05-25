#!/bin/sh
echo "------------- Start HashiCorp Vault YSQL Plugin run ------------- "
#   Create a directory named as test_plugin
mkdir test_plugin
cd test_plugin
pwd
echo "------------- Cloning the repositry -------------"
#   Clone the repositories required
##  Yugabytedb plugin for HashiCorp Vault
git clone  https://github.com/yugabyte/hashicorp-vault-ysql-plugin.git  
cd hashicorp-vault-ysql-plugin
pwd
echo "------------- Running the test -------------"
#   Run the test
export LOGDATA=$(go test)
grep -q "FAIL" <<< "$LOGDATA";
if [ $? -eq 0 ] 
then 
echo -e "Test Failed \n $LOGDATA"
else 
echo -e "Test Passed \n $LOGDATA"
fi

#   Delete the test repository
cd ../.. && rm -rf test_plugin

echo "------------- End HashiCorp Vault YSQL Plugin run ------------- "