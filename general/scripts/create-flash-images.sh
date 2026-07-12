#!/bin/sh

if [ $# -gt 0 ]; then
	dest=$1
else
	dest=$PWD
fi

flash_size=$((16 << 20))

for soc in `ls $dest`
do
	if [ ! -d $dest/$soc ]; then
		continue
	fi

	case $soc in
		hi351[68]ev[23]00 | gk720[25]v[23][01]0)
			;;
		*)
			# echo "Skip '$soc' dir!"
			continue
			;;
	esac

	echo "### $soc ###" | tr a-z A-Z

	plat_dir=$dest/$soc

	for uboot_image in $plat_dir/u-boot-*.bin
	do
		flash_image=$(echo $uboot_image | sed 's/u-boot/openipc/')

		if test -f $flash_image; then
			echo "Overwriting $flash_image ..."
		fi
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
