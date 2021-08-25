# Scripts to validate various tools with YugabyteDB via Jenkins pipeline

- These scripts will be run as part of a Jenkins pipeline.

- Refer to the [template directory](./template) for how to start adding scripts for your tool.

- Add your top-level script in [start.sh](./start.sh) so that it gets run in the Jenkins pipeline.

- Currently, a single pipeline runs all the scripts. A failed pipeline build means failure in at
  least one of the tool's scripts. A separate pipeline for each of the tools may be added in future.

- Currently, the build is trigerred like a cron job. It may be linked to a commit/PR in future.

