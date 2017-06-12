#!/bin/bash

export kernel=Samsung
export outdir=/home/hasagi/Desolation/out/target/product/gtexswifi
export makeopts="-j$(nproc)"
export device_defconfig="gtexswifi-dt_defconfig"
export zImagePath="build/arch/arm/boot/zImage"
export KBUILD_BUILD_USER=hasagi
export KBUILD_BUILD_HOST=Master
export CROSS_COMPILE="ccache /home/hasagi/Desolation/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"
export ARCH=arm
export shouldclean="0"
export device="gtexswifi"

export version=$(cat version)
export RDIR=$(pwd)


function build() {
    if [[ $shouldclean =~ "1" ]] ; then
        rm -rf build
    fi

    mkdir -p build

    make -C ${RDIR} O=build ${makeopts} ${device_defconfig}
    make -C ${RDIR} O=build ${makeopts}
    make -C ${RDIR} O=build ${makeopts} modules
    make -C ${RDIR} O=build ${makeopts} dtbs
    
	./scripts/mkdtimg.sh -i ${RDIR}/arch/arm/boot/dts/ -o dtb
    
    if [ -a ${zImagePath} ] ; then
        cp ${zImagePath} zip/zImage
        cp arch/arm/boot/dtb zip/dtb
        mkdir -p zip/modules
        find -name '*.ko' -exec cp -av {} zip//modules/ \;
        cd zip
        zip -q -r ${kernel}-${device}-${version}.zip anykernel.sh  META-INF tools zImage dtb modules
    else
        echo -e "\n\e[31m***** Build Failed *****\e[0m\n"
    fi

    if ! [ -d ${outdir} ] ; then
        mkdir ${outdir}
    fi

    if [ -a ${kernel}-${device}-${version}.zip ] ; then
        mv -v ${kernel}-${device}-${version}.zip ${outdir}
    fi

    cd ${RDIR}

    rm -f zip/zImage
    rm -rf zip/modules/*
    rm -f zip/dtb
}

if [[ $1 =~ "clean" ]] ; then
    shouldclean="1"
fi

build
