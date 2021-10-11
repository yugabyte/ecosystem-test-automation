#!/bin/bash

# Check if Docker image tag input provided.
if [ -z $YBDB_IMAGE ]; then
  echo "No YBDB_IMAGE provided. Using the latest master..."
  YBDB_IMAGE=latest
fi

YBDB_IMAGE_PREFIX=yugabyte/ecosys-yugabyte:
YBDB_IMAGE_PATH=
PHABRICATOR_ID=
# YBDB_CLONE_DIR is provided by Jenkins configuration
YBDB_CLONE_DIR=/var/lib/jenkins/code/yugabyte-db


# Construct the Docker image path from the input or the default value and check if it exists. Exit if yes.
case $YBDB_IMAGE in
  latest)
    echo "Using the latest master to build the image ..." 
  ;;
  sha_*)
    SHA_COMMIT="${YBDB_IMAGE:4}"
    # Or ${YBDB_IMAGE#sha_}
    echo "Using the SHA commit $SHA_COMMIT to build the image ..." 
  ;;
  phd_*)
    PHABRICATOR_ID="${YBDB_IMAGE:4}"
    echo "Using phabricator diff id $PHABRICATOR_ID to build the image ..." 
  ;;
  ght_*)
    YBDB_IMAGE_PATH=yugabytedb/yugabyte:${YBDB_IMAGE:4}
    echo "Using Docker Hub image $YBDB_IMAGE_PATH ..."
    return 0
  ;;
  *)
    echo "Invalid YBDB_IMAGE value: $YBDB_IMAGE. Using the latest master build ..."
    YBDB_IMAGE=latest
  ;;
esac


cd $YBDB_CLONE_DIR
git fetch

if [ ! -z "$SHA_COMMIT" ]; then
  git checkout $SHA_COMMIT
  echo "Cloned the commit $SHA_COMMIT"
else
  git pull
  echo "Cloned latest master of yugabyte-db repository"
fi

LATEST=$(git log --pretty=format:"%h" -1)
TAG_SUFFIX=$LATEST
if [ ! -z ${PHABRICATOR_ID} ]; then
  TAG_SUFFIX=$LATEST-${PHABRICATOR_ID}
fi
echo "Tag suffix: $TAG_SUFFIX"

YBDB_IMAGE_PATH=$(docker image list --filter=reference="${YBDB_IMAGE_PREFIX}*${TAG_SUFFIX}" --format "{{.Repository}}:{{.Tag}}")
if [ ! -z $YBDB_IMAGE_PATH ]; then
  echo "Image built with the given commit exists already: $YB_IMAGE_PATH"
else
  echo "Running yb_build.sh ..."
  ./yb_build.sh --clean
  echo "Running yb_release ..."
  ./yb_release > release.log

  # Find and note the path/name of the generated tar.gz file.
  GENERATED_TAR=$(grep "Generated a package at" release.log | grep -o "/var/lib/jenkins/code/yugabyte-db/build/.*.tar.gz")
  if [ -z $GENERATED_TAR ]; then
    echo "Could not generate the yugabyte-db package (.tar.gz) file."
    # return 1
  else
    GENERATED_TAR_NAME=${GENERATED_TAR:40}
    TAG_VERSION=$(echo $GENERATED_TAR_NAME | awk -F[--] '{print $2}')
    echo "Tag version: $TAG_VERSION"
    # rm release.log

    # Build the Docker image.
    cd ../devops
    # ./bin/install_python_requirements.sh
    # ./bin/install_ansible_requirements.sh
    cd docker/images/yugabyte
    mkdir -p packages
    rm -f packages/*
    cp $GENERATED_TAR packages/yugabyte-$TAG_VERSION-$TAG_SUFFIX-centos-x86_64.tar.gz
    # Dockerfile is already modified to replace /home/yugabyte with actual path.
    echo "Building the docker image ..."
    docker build -t yugabyte/ecosys-yugabyte:$TAG_VERSION-$TAG_SUFFIX .

    YBDB_IMAGE_PATH=yugabyte/ecosys-yugabyte:$TAG_VERSION-$TAG_SUFFIX
  fi
fi

