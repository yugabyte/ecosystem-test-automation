#!/bin/bash
set -e

prinf "Installing cargo ...\n"
curl https://sh.rustup.rs -sSf > cargo_install.sh
chmod +x cargo_install.sh
./cargo_install.sh -y
source "$HOME/.cargo/env" 
prinf "cargo Installed ...\n"

# Start the test/example application and generate reports
printf "Executing run-app.sh ...\n"
./run-app.sh
