#!/bin/sh
#set -e
#set -x
#set -o pipefail

# Based on: http://hoverbear.org/2014/07/14/arch-docker-baseimage/

# General Configuration (that we don't want to create seperate layers for)
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf
echo 'Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# aur.atomica.net package repository
cat >> /etc/pacman.conf <<DELIM
[atomica]
Server = http://aur.atomica.net/\$repo/\$arch
SigLevel = Never
DELIM

mkdir -p /usr/local/bin
curl -L https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64 -o /usr/local/bin/gosu
chmod 755 /usr/local/bin/gosu

# Setup Keys
pacman-key --init --keyserver hkp://pool.sks-keyservers.net
pacman-key --populate archlinux

# Add key for aur.atomica.net
pacman-key -r 0x4466fcf875b1e1ac && pacman-key --lsign-key 0x4466fcf875b1e1ac

# Update keyring
pacman --sync --refresh --noconfirm archlinux-keyring

# Base without the following packages, to save space.
# linux jfsutils lvm2 cryptsetup groff man-db man-pages mdadm pciutils pcmciautils reiserfsprogs s-nail xfsprogs vi
pacman --sync --force --sysupgrade --noconfirm --needed bash bzip2 coreutils device-mapper dhcpcd gcc-libs gettext glibc grep gzip inetutils iproute2 iputils less libutil-linux licenses logrotate psmisc sed shadow sysfsutils systemd-sysvcompat tar texinfo usbutils util-linux which

# Additional packages
pacman -Syu --noconfirm sudo git

# Ensure locale is setup
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen

# No longer need this file in the image
rm $0
