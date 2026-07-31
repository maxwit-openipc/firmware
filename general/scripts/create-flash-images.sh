#!/bin/bash -e

if [ $# -gt 0 ]; then
	dest=$1
else
	dest=$PWD
fi

flash_size=$((16 << 20))

for soc in `ls $dest`
do
	if [ ! -d "$dest/$soc" ]; then
		continue
	fi

	case $soc in
		hi351[68][acde]v* | gk720[25]v* | ssc3*)
			;;
		*)
			# echo "Skip '$soc' dir!"
			continue
			;;
	esac

    echo -e "## \033[1;32m$(echo ${soc} | tr a-z A-Z)\033[0m"

	plat_dir=$dest/$soc

	for uboot_image in `ls $plat_dir/u-boot-*.bin | grep -v nand`
	do
        board=`basename ${uboot_image%.bin}`
        board=${board#u-boot-}
        echo -e "### \033[1;33m${board}\033[0m"

		flash_image=$(echo $uboot_image | sed 's/u-boot/openipc/')
		# test -f $flash_image && echo "Overwriting $flash_image ..."
		echo "Generating $uboot_image => $flash_image ..."
		python3 -c "import sys; sys.stdout.buffer.write(b'\xff' * $flash_size)" > $flash_image
		dd if=$uboot_image of=$flash_image conv=notrunc
		test -e $plat_dir/uImage.$soc && \
			dd if=$plat_dir/uImage.$soc of=$flash_image bs=512 seek=$((0x50000 / 512)) conv=notrunc
		test -e $plat_dir/rootfs.squashfs.$soc && \
			dd if=$plat_dir/rootfs.squashfs.$soc of=$flash_image bs=512 seek=$((0x350000 / 512)) conv=notrunc
		echo
	done
done
