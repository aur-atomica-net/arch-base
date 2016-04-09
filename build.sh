#!/bin/bash
set -e
set -x
set -o pipefail

IMAGE_NAME="atomica/arch-base"
MIRROR="http://mirrors.ocf.berkeley.edu/archlinux"
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

# gpg --keyserver pgp.mit.edu --recv-keys 0x7f2d434b9741e8ac
gpg --keyserver-options auto-key-retrieve --auto-key-locate pka --verify "archlinux-bootstrap-${VERSION}-x86_64.tar.gz.sig" "archlinux-bootstrap-${VERSION}-x86_64.tar.gz"

sudo rm -rf ./root.x86_64
tar xf archlinux-bootstrap-$VERSION-x86_64.tar.gz

## arch-base
cp arch-base.sh ./root.x86_64/
cp pacman.conf ./root.x86_64/etc/pacman.conf
sudo systemd-nspawn --directory=$(pwd)/root.x86_64 --bind=/var/cache/pacman --machine=arch-base-${RANDOM} /bin/sh /arch-base.sh
rm -f ./root.x86_64/arch-base.sh

# gosu
mkdir -p ./root.x86_64/usr/local/bin
curl -L https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64 -o ./root.x86_64/usr/local/bin/gosu
chmod 755 ./root.x86_64/usr/local/bin/gosu

# Entrypoint script untill we can figure out a better way to handle user/group issues
cp entrypoint.sh ./root.x86_64/entrypoint.sh

# Build base image
tar --numeric-owner -C root.x86_64 -c . | docker import - "${IMAGE_NAME}:latest"

# # Do the things that we can only do in docker build
# cat Dockerfile | docker build --force-rm --tag="${IMAGE_NAME}:latest" -

# docker rmi "${IMAGE_NAME}:staging"
