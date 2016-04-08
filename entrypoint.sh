#!/bin/bash
set -e
set -x
set -o pipefail

if [[ $EUID -ne 0 ]]; then
    # Not running as root inside of container so lets see what happens
    exec "$@"
fi

# Because docker pipeline will start running under a per-host
# specific uid:gid we'll need to create a user inside the container
# that matches the uid:gid of the host
USER_ID=$(stat -c "%u" .)
GROUP_ID=$(stat -c "%g" .)

# Setup our user
groupadd -r -g ${GROUP_ID} code_executor
useradd --uid $USER_ID --gid ${GROUP_ID} --groups wheel --shell /bin/bash --no-create-home --home-dir $(pwd) code_executor
echo 'code_executor ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

exec /usr/bin/sudo --user=code_executor --group=code_executor "$@"
