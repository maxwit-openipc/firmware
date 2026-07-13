#!/usr/bin/env bash

vendor_list=${1:-"hisilicon goke sigmastar"}

# Vendor-specific Fix

for vendor in $vendor_list
do
    sed -i -e 's/\(^CONFIG_ARM_APPENDED_DTB\)=y/# \1 is not set/' \
        -e 's/\(^CONFIG_SS_BUILTIN_DTB\)=y/# \1 is not set/' \
        -e 's/\(^CONFIG_ATAGS\)=y/# \1 is not set/' \
        -e '/CONFIG_ARM_ATAG_DTB_COMPAT/d' \
        -e '/CONFIG_SS_DTB_NAME/d' \
        br-ext-chip-$vendor/board/*/*.config

    for conf in br-ext-chip-$vendor/configs/*ultimate_defconfig # skip lite_defconfig
    do
        for xc in BR2_PACKAGE_RTL8188FU_OPENIPC=y \
            BR2_PACKAGE_LIBGPIOD=y \
            BR2_PACKAGE_LIBGPIOD_TOOLS=y
        do
            grep -q ^$xc $conf || echo $xc >> $conf
        done

        xc="BR2_TARGET_ROOTFS_UBIFS=y"
        grep -q ^$xc $conf || sed -i '/^BR2_TARGET_ROOTFS_CPIO=y/a BR2_TARGET_ROOTFS_UBIFS=y' $conf
    done

    # if [ $vendor == sigmastar ]; then
    #     sed -i 's/^\(\s\+detect_sensor\)/# \1/' \
    #         general/package/sigmastar-osdrv-infinity*/files/script/load_sigmastar
    # fi
done

# Common Fix

xc='$MODALIAS=usb:v0BDApF179d0000dc00dsc00dp00icFFiscFFipFFin00 root:root 660 @modprobe $MODALIAS'
conf=general/overlay/etc/mdev.conf
grep -q v0BDApF179 $conf || echo -e "\n$xc" >> $conf

sed -i 's/\(^[^#]*ifconfig.*fw_printenv -n ipaddr.*\)/# \1/' general/overlay/usr/share/udhcpc/default.script

grep -q BR2_PACKAGE_MDNSD general/openipc.fragment || cat >> general/openipc.fragment << __EOF__

BR2_PACKAGE_MDNSD_OPENIPC=y
BR2_PACKAGE_MDNSD_MQUERY_OPENIPC=y
__EOF__

# .github/workflows/build.yml
# general/overlay/etc/init.d/S40network
# general/overlay/lib/modules/4.9.84/sigmastar/sensor_jxq03_mipi.ko
# general/overlay/usr/sbin/sysupgrade
# general/package/quirc-openipc/files/qrscan.sh
