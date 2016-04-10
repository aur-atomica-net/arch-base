#!/bin/bash
set -e
set -x
set -o pipefail

if [[ $EUID -ne 0 ]]; then
    echo " ==> Not running as root inside of container"
    exec "$@"
fi

# Because docker pipeline will start running under a per-host
# specific uid:gid we'll need to create a user inside the container
# that matches the uid:gid of the host
USER_ID=$(stat -c "%u" .)
GROUP_ID=$(stat -c "%g" .)
HOME_DIR=$(pwd)

if [ $USER_ID == 0 ] || [ $GROUP_ID == 0 ] ; then
    echo " ==> Outside is either expecting files with root uid:gid, or our working directory isn't an external volume"
    exec "$@"
fi

# Setup our user
groupadd -r -g ${GROUP_ID} code_executor
useradd --uid ${USER_ID} --gid ${GROUP_ID} --groups wheel --shell /bin/bash --no-create-home --home-dir ${HOME_DIR} code_executor
echo 'code_executor ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

exec /usr/local/bin/gosu code_executor:code_executor "$@"
