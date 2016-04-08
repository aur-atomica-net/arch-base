#!/bin/sh
set -e
set -x
set -o pipefail


BASE_IMAGE_NAME="atomica/arch"
MIRROR="http://mirror.lty.me/archlinux"
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

gpg --keyserver pgp.mit.edu --recv-keys 0x7f2d434b9741e8ac
gpg --verify "archlinux-bootstrap-${VERSION}-x86_64.tar.gz.sig" "archlinux-bootstrap-${VERSION}-x86_64.tar.gz"

sudo rm -rf ./root.x86_64
tar xf archlinux-bootstrap-$VERSION-x86_64.tar.gz

## arch-base
cp arch-base.sh ./root.x86_64/
cp pacman.conf ./root.x86_64/etc/pacman.conf
sudo systemd-nspawn --directory=$(pwd)/root.x86_64 --bind=/var/cache/pacman --machine=arch-base-${RANDOM} /bin/sh /arch-base.sh
rm -f ./root.x86_64/arch-base.sh

tar --numeric-owner -C root.x86_64 -c . | docker import - "${BASE_IMAGE_NAME}-base:latest"
