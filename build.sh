#!/bin/bash
set -x # Echo?
set -e # Errors?
set -o pipefail

IMAGE_NAME="atomica/arch-base"

# Do the things that we can only do in docker build
docker build --pull --force-rm --build-arg http_proxy="${http_proxy}" --build-arg https_proxy="${https_proxy}" --tag="${IMAGE_NAME}:latest" .

# Test that it can be ran
docker run --rm "${IMAGE_NAME}:latest" /bin/env

# Push to registry if configured
if [ ! -z "${DOCKER_REGISTRY}" ]; then
    docker login --username=${DOCKER_USER} --password=${DOCKER_PASS} --email=${DOCKER_EMAIL} ${DOCKER_REGISTRY}
    docker tag "${IMAGE_NAME}:latest" "${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
    docker push "${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
fi
