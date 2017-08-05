#!/bin/sh
set -o xtrace
# set -o errexit
# set -o pipefail

USER=$1
GROUP=$2
WORKING_DIR=$3

UNUSED_UID=$(($((RANDOM % 999)) + 20000))
EXPECTED_UID=$(stat -c '%u' "$WORKING_DIR")
EXISTING_USER=$(stat -c '%U' "$WORKING_DIR")

if [ ${EXPECTED_UID} -eq 0 ]; then
    exit
fi

if [ "${USER}" != "${EXISTING_USER}" ]; then
    EXISTING_UID=x$(getent passwd $EXISTING_USER | cut -d: -f1)
    if [ "$EXISTING_UID" != "x" ]; then
        usermod -o -u $UNUSED_UID $EXISTING_USER
    fi
    usermod -o -u $EXPECTED_UID $USER || true
fi

UNUSED_GID=$(($((RANDOM % 999)) + 21000))
EXPECTED_GID=$(stat -c '%g' "$WORKING_DIR")
EXISTING_GROUP=$(stat -c '%G' "$WORKING_DIR")

if [ "${GROUP}" != "${EXISTING_GROUP}" ]; then
    EXISTING_GID=x$(getent group $EXISTING_GROUP | cut -d: -f1)
    if [ "$EXISTING_GID" != "x" ]; then
        groupmod -o -g $UNUSED_GID $EXISTING_GROUP
    fi
    groupmod -o -g $EXPECTED_GID $GROUP || true
fi
