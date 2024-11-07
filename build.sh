#!/bin/bash -xe
set -xe

source docker/helper-functions.sh

#https://docs.google.com/document/d/16fSgYtZ7gl2XCB2GqCdq22TaWNfWx3z6tfZOKWgRaNs/edit


function fetchSources(){

    local clean="false"
	parseArgs $@
    if [[ -d sources && "${clean}" != "true" ]]; then 
        return
    fi
    rm -fr .repo
    rm -fr sources/*

    repo init -u https://git.congatec.com/arm-nxp/imx8-family/yocto/manifest-imx8-family \
        -b cgtsx8m__lf-5.15.32-2.0.0 \
        -m cgtsx8m__lf-5.15.32-2.0.0.xml
    repo sync -j$(nproc) --force-sync
    # repo sync -j1 --fail-fast

    pushd sources
    # git clone -b feature_add_congatec_support git@gitlab.com:addium/software/skala/meta-aqualab.git meta-aqualab
    # git clone -b kirkstone-working git@gitlab.com:addium/software/skala/meta-flutter.git
    git clone -b main git@gitlab.com:addium/software/skala/meta-aqualab.git meta-aqualab
    git clone -b main git@gitlab.com:addium/software/skala/meta-flutter.git
    git clone -b kirkstone git@gitlab.com:addium/software/skala/meta-swupdate.git # a fork of https://github.com/sbabic/meta-swupdate
    git clone -b kirkstone git@gitlab.com:addium/software/skala/meta-swupdate-boards.git # a fork of https://github.com/sbabic/meta-swupdate-boards.git
    popd
}

function setupBuildDir() {
    local clean="false"
	parseArgs $@
    if [[ -d sources && "${clean}" != "true" && -d _build/sstate-cache && -d _build/cache && -d _build/tmp ]]; then 
        return
    fi

    if [ -f _build/conf/local.conf ]; then
        cp -f _build/conf/local.conf _build/conf/local.conf.backup
    fi
    if [ -f _build/conf/bblayers.conf ]; then
        cp -f _build/conf/bblayers.conf _build/conf/bblayers.conf.backup
    fi

    local args="$(pwd)/config.json"
    local target_machine="$(cat ${args} | jq .target_machine -r)"
    local distro="$(cat ${args} | jq .distro -r)"
    local buildenv="$(cat ${args} | jq .buildenv -r)"
    EULA=1 MACHINE=${target_machine} DISTRO=${distro} source imx-setup-release.sh -b _build
    cd ..

    if [ -f _build/conf/local.conf.backup ]; then
        mv -f _build/conf/local.conf.backup _build/conf/local.conf
    fi
    if [ -f _build/conf/bblayers.conf.backup ]; then
        mv -f _build/conf/bblayers.conf.backup _build/conf/bblayers.conf
    fi
}

function build(){
    parseArgs $@

    local script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    local project_path="${script_dir}"
    
    # echo "$(pwd)/sources/templates" > build-imx6ul-var-dart/conf/templateconf.cfg
    sudo sysctl -n -w fs.inotify.max_user_watches=655360
    buildYoctoProject config="$(pwd)/config.json" project_path="${script_dir}" clean="${clean}"
    return
}

function flashWicToSdCard(){
    parseArgs $@

    local mmcdev=$(lsblk| grep -w mmcblk0)
    if [ "$mmcdev" == "" ]; then
        set +x
	echo "Is sd card inserted in computer? No /dev/mmcblk0 device detected."
	exit -1
    fi

    local builddir="out"
    # local image="fsl-image-gui-imx8mm-cgt-sx8m.latest.wic"
    # local image="conga-q430-dev-image-custom-congatec-eval.latest.wic"
    local image="conga-q430-release-image-custom-congatec-eval.latest.wic"
    if [ "$(mount | grep mmcblk0p1)" != "" ]; then sudo umount /dev/mmcblk0p1; fi
    if [ "$(mount | grep mmcblk0p2)" != "" ]; then sudo umount /dev/mmcblk0p2; fi
    if [ "$(mount | grep mmcblk0p3)" != "" ]; then sudo umount /dev/mmcblk0p3; fi
    if [ "$(mount | grep mmcblk0p4)" != "" ]; then sudo umount /dev/mmcblk0p4; fi
    sudo dd if=$builddir/$image bs=1M iflag=fullblock oflag=direct conv=fsync status=progress of=/dev/mmcblk0
}

function main(){
	parseArgs $@

    if [ "$(which docker)" == "" ]; then #we are inside docker container
        # fetchSources $@  #uncomment when building for the very first time
        # setupBuildDir $@ #uncomment when building for the very first time
        build $@
    else
        flashWicToSdCard 
    fi
}

time main $@

