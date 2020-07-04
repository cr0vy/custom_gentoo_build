#!/usr/bin/env sh

set -e -u

if [[ ! $EUID -eq 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

setup_env() {
    cwd=${pwd}
    wd="/var/tmp/cg_build/build"
    stage3=$(curl -Ss https://mirror.mdfnet.se/gentoo/releases/amd64/autobuilds/latest-stage3-amd64.txt | grep "stage3" | awk '{ print $1 }')
    stage3_url="https://mirror.mdfnet.se/gentoo/releases/amd64/autobuilds/"$stage3
}

install_base() {
    cd $wd
    wget $stage3_url
    tar xvpf ./stage3-*.tar.xz --xattrs-include="*.*" --numeric-owner
    rm -rf ./stage3-*.tar.xz

    mkdir $wd/etc/portage/repos.conf
    cp $wd/usr/share/portage/config/repos.conf $wd/etc/portage/repos.conf/gentoo.conf
}

chroot() {
    mount -t proc /proc $wd/proc
    mount --rbind /sys $wd/sys
    mount --make-rslave $wd/sys
    mount --rbind /dev $wd/dev
    mount --make-rslave $wd/dev
    cp --dereference /etc/resolv.conf $wd/etc/

    chroot $wd /bin/bash
    source /etc/profile
    PS1="(chroot) ${PS1}"

    emerge-webrsync
    emerge --sync --quiet
    eselect profile set 23

    emerge -auDNv @world
}

if [[ ! -d $wd ]]; then
    mkdir -p /var/tmp/cg_build/build
    mkdir -p /var/tmp/cg_build/iso
fi

cd $wd

