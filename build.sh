#!/bin/bash
set -x # Echo?
set -e # Errors?
set -o pipefail

IMAGE_NAME="atomica/arch-base"
MIRROR="http://mirrors.kernel.org/archlinux"
VERSION=$(curl ${MIRROR}/iso/latest/ | grep -Poh '(?<=archlinux-bootstrap-)\d*\.\d*\.\d*(?=\-x86_64)' | head -n 1)

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if [[ ! -f "archlinux-bootstrap-${VERSION}-x86_64.tar.gz" ]]; then
    curl -O -L "${MIRROR}/iso/${VERSION}/archlinux-bootstrap-${VERSION}-x86_64.tar.gz"
fi
if [[ ! -f "archlinux-bootstrap-${VERSION}-x86_64.tar.gz.sig" ]]; then
    curl -O -L "${MIRROR}/iso/${VERSION}/archlinux-bootstrap-${VERSION}-x86_64.tar.gz.sig"
fi

gpg --keyserver-options auto-key-retrieve --auto-key-locate pka --verify "archlinux-bootstrap-${VERSION}-x86_64.tar.gz.sig" "archlinux-bootstrap-${VERSION}-x86_64.tar.gz"

sudo rm -rf ./root.x86_64
tar xf archlinux-bootstrap-${VERSION}-x86_64.tar.gz

# General Configuration
echo 'nameserver 8.8.8.8' > ./root.x86_64/etc/resolv.conf
echo 'nameserver 8.8.4.4' >> ./root.x86_64/etc/resolv.conf
echo 'en_US.UTF-8 UTF-8' > ./root.x86_64/etc/locale.gen
echo 'Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch' > ./root.x86_64/etc/pacman.d/mirrorlist

# aur.atomica.net package repository
cat >> ./root.x86_64/etc/pacman.conf <<DELIM
[atomica]
Server = http://aur.atomica.net/\$repo/\$arch
SigLevel = Never
DELIM

# arch-base
cp arch-base.sh ./root.x86_64/
sudo systemd-nspawn --directory=$(pwd)/root.x86_64 --machine=arch-base-${RANDOM} --setenv=http_proxy="${http_proxy}" --setenv=https_proxy="${https_proxy}" /bin/sh /arch-base.sh
rm -f ./root.x86_64/arch-base.sh

# gosu
mkdir -p ./root.x86_64/usr/local/bin
curl -L https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64 -o ./root.x86_64/usr/local/bin/gosu
chmod 755 ./root.x86_64/usr/local/bin/gosu

# Entrypoint script untill we can figure out a better way to handle user/group issues
cp entrypoint.sh ./root.x86_64/entrypoint.sh

# Build base image
tar --numeric-owner -C root.x86_64 -c . | docker import - "${IMAGE_NAME}:staging"

# Do the things that we can only do in docker build
cat Dockerfile | docker build --build-arg http_proxy="${http_proxy}" --build-arg https_proxy="${https_proxy}" --force-rm --tag="${IMAGE_NAME}:latest" -

# Remove the staging image
docker rmi "${IMAGE_NAME}:staging"

# Test that it can be ran
docker run --rm "${IMAGE_NAME}:latest" /bin/env
