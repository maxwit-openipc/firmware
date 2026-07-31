#!/usr/bin/env bash

vendor_list=${1:-"hisilicon goke sigmastar"}

# Vendor-specific Fix

for vendor in $vendor_list
do
    echo -e "## \033[1;32m$vendor\033[0m"

    for conf in br-ext-chip-$vendor/board/*/*.config
    do
        echo "Patching $conf ..."

        # to enable
        for opt in CONFIG_DEBUG_FS \
            CONFIG_NEW_LEDS CONFIG_LEDS_CLASS CONFIG_LEDS_GPIO
        do
            sed -i "s/^# $opt is not set/$opt=y/" $conf
            grep -q ^$opt $conf || echo "$opt=y" >> $conf
        done

        # to disable
        for opt in CONFIG_ARM_APPENDED_DTB \
            CONFIG_ATAGS \
            CONFIG_ARM_ATAG_DTB_COMPAT  \
            CONFIG_SS_BUILTIN_DTB \
            CONFIG_SS_DTB_NAME
        do
            sed -i "s/^$opt=y/# $opt is not set/" $conf
        done
    done

    for conf in br-ext-chip-$vendor/configs/*ultimate_defconfig # skip lite_defconfig
    do
        echo "Patching $conf ..."
        # to enable
        for opt in BR2_PACKAGE_RTL8188FU_OPENIPC=y \
            BR2_PACKAGE_LIBGPIOD=y \
            BR2_TARGET_ROOTFS_UBIFS=y \
            BR2_PACKAGE_LIBGPIOD_TOOLS=y
        do
            grep -q ^$opt $conf || echo $opt >> $conf
        done
    done

    # if [ $vendor == sigmastar ]; then
    #     sed -i 's/^\(\s\+detect_sensor\)/# \1/' \
    #         general/package/sigmastar-osdrv-infinity*/files/script/load_sigmastar
    # fi

    echo
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
