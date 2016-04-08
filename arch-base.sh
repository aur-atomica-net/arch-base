#!/bin/sh
set -e
set -x
set -o pipefail

# Based on: http://hoverbear.org/2014/07/14/arch-docker-baseimage/

# Setup DNS
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf

# Setup a mirror.
echo 'Server = http://mirror.lty.me/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# Setup Keys
pacman-key --init
pacman-key --populate archlinux

# Add key for aur.atomica.net
pacman-key -r 0x4466fcf875b1e1ac && pacman-key --lsign-key 0x4466fcf875b1e1ac

# Base without the following packages, to save space.
# linux jfsutils lvm2 cryptsetup groff man-db man-pages mdadm pciutils pcmciautils reiserfsprogs s-nail xfsprogs vi
pacman -Syu --noconfirm bash bzip2 coreutils device-mapper dhcpcd gcc-libs gettext glibc grep gzip inetutils iproute2 iputils less libutil-linux licenses logrotate psmisc sed shadow sysfsutils systemd-sysvcompat tar texinfo usbutils util-linux which

# Ensure locale is setup
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
