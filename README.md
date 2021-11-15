# Scripts to validate various tools with YugabyteDB via Jenkins pipeline

- These scripts will be run as part of a Jenkins pipeline.

- Refer to the [template directory](./template) for how to start adding scripts for your tool.

- Invoke your top-level script in [start.sh](./start.sh) so that it gets run in the Jenkins pipeline.

- The [init script](./init/init.sh) runs before the tool-specific scripts and it builds a
  Docker image off the latest master of yugabyte-db repository.
  Alternatively, one can also make it 1) use an already created Docker image of the last updated master or
  2) build and use the Docker image of a specific commit in the repository or
  3) use an existing Docker image publicly available on hub.docker.com.
  This could be specified using the environment variable `YBDB_IMAGE` either in the script itself
  via a commit or on the Jenkins Dashaboard -> Manage Jenkins -> Configure System ->
  Global properties.

  Value of this environment variable for above cases could be:
  ```
  YBDB_IMAGE=latest  # Default - Clone latest master and build a new Docker image off it
  YBDB_IMAGE=last_latest  # 1) Use the existing Docker image created off the most recent master
  YBDB_IMAGE=sha_<commit-id>  # 2) Checkout the <commit-id> of the repository and build a new Docker image 
  YBDB_IMAGE=dht_<image-tag>  # 3) Use existing public Docker image "yugabytedb/yugabyte:<image-tag>"
  ```

- Currently, a single pipeline runs all the scripts. A failed pipeline build means failure in at
  least one of the tool's scripts. A separate pipeline for each of the tools may be added in future.

- Currently, the build is trigerred like a cron job. It may be linked to a commit/PR in future.

