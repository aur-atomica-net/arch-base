#!/bin/bash
# set -e
# set -x
# set -o pipefail

if [[ $EUID -ne 0 ]]; then
    echo " ==> Not running as root inside of container"
    exec "$@"
fi

/match-ids.sh code_executor code_executor $(pwd)

exec gosu code_executor:code_executor "$@"