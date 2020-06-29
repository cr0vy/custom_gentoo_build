#!/usr/bin/env zsh

set -e -u

if [[ ! $EUID -eq 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

if [[ ! -d '/var/tmp/catalyst']]; then
    mkdir /var/tmp/catalyst
fi

cp -R ./portage /var/tmp/catalyst/portage
cp -R ./builds /var/tmp/catalyst/builds

cd /var/tmp/catalyst/builds/default

stage3=$(curl -Ss https://mirror.mdfnet.se/gentoo/releases/amd64/autobuilds/latest-stage3-amd64.txt | grep stage3-amd64 | awk '{ print $1 }')
stage3_url="https://mirror.mdfnet.se/gentoo/releases/amd64/autobuilds/"$stage3

wget -O stage3-amd64-desktop-latest.tar.xz $stage3_url
catalyst -s $(date +%y.%m)

catalyst -f stage1.spec
