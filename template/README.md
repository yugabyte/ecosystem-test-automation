

# NOTES

- The top-level script [`start.sh`](../start.sh) must work fine on your local system.

- Until you reach `tear-down.sh`, it's a good idea to exit on failure by using `set -e`.

- Ensure `tear-down.sh` is run always irrespective of the outcome of earlier scripts.

- Note, the Jenkins is running on Ubuntu 20.04 and your local system is likely a mac. So it may
  happen that your scripts fail in Jenkins pipeline even though those worked fine on your mac. You'll need to fix it.


