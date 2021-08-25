

# NOTES

- The top-level script [`start.sh`](../start.sh) must work fine on your local system.

- The top-level `start.sh` invokes the individual `start.sh` scripts one after another.

- The local [`start.sh`](./start.sh) invokes below scripts in the order given below:

  1. [`do-start.sh`](./do-start.sh): It further invokes:

    1.1 [`start-ybdb.sh`](./start-ybdb.sh): Launches the YugabyteDB Docker container.

    1.2 [`run-app.sh`](./run-app.sh): Runs the examples/tests for verifying the tool/framework. You
    can either do this directly on the host or inside a Docker container.

  2. [`tear-down.sh`](./tear-down.sh): Cleans up the setup by stopping processes, containers, etc.

- Until you reach `tear-down.sh`, it's a good idea to exit on failure by using `set -e`.

- Ensure `tear-down.sh` is run always irrespective of the outcome of earlier scripts.

- While you are free to write the scripts in a way you deeem suitable, do ensure that your scripts:

  1. generate artifacts (jars, reports) under a directory `artifacts` at this level, in the end.

  2. clean up the setup irrespective of the outcome of your scripts.

  3. return non-zero exit code on failure at any stage.

- Note, the Jenkins is running on Ubuntu 20.04 and your local system may be different (e.g. a mac).
  So it may happen that your scripts fail in Jenkins pipeline even though those worked fine on your
  mac. You'll need to fix it.


