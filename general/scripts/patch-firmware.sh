#!/usr/bin/env bash

for family in infinity6b0 hi3516ev200 gk7205v200
do
	sed -i -e 's/\(^CONFIG_ARM_APPENDED_DTB\)=y/# \1 is not set/' \
		-e 's/\(^CONFIG_SS_BUILTIN_DTB\)=y/# \1 is not set/' \
		-e 's/\(^CONFIG_ATAGS\)=y/# \1 is not set/' \
		-e '/CONFIG_ARM_ATAG_DTB_COMPAT/d' \
		-e '/CONFIG_SS_DTB_NAME/d' \
		br-ext-chip-*/board/$family/*.config
done

