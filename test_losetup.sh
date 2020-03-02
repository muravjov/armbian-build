#!/bin/bash

SRC="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "${SRC}"/lib/general.sh
source "${SRC}"/lib/image-helpers.sh						# helpers for OS image building

make_image()
{
    SDCARD=sdcard
    sdsize=100
	dd if=/dev/zero bs=1M status=none count=$sdsize | pv -p -b -r -s $(( $sdsize * 1024 * 1024 )) -N "[ .... ] dd" | dd status=none of=${SDCARD}.raw

    parted -s ${SDCARD}.raw -- mklabel msdos

    OFFSET=4
    BOOTSIZE=0
    
   	local bootstart=$(($OFFSET * 2048))
	local rootstart=$(($bootstart + ($BOOTSIZE * 2048)))

    parted -s ${SDCARD}.raw -- mkpart primary ext4 ${rootstart}s -1s

    LOOP=$(losetup -f)
    [[ -z $LOOP ]] && exit_with_error "Unable to find free loop device"

    losetup $LOOP ${SDCARD}.raw

    partprobe $LOOP

    local rootpart=1
    local rootdevice="${LOOP}p${rootpart}"

    mkfs.ext4 -q -m 2 -O ^64bit,^metadata_csum $rootdevice
    tune2fs -o journal_data_writeback $rootdevice > /dev/null

    MOUNT=${SDCARD}.mount
    mkdir -p $MOUNT

    mount $rootdevice $MOUNT/

    cp "${SRC}/test_losetup.sh" $MOUNT

    sync

    umount -l $MOUNT
    while grep -Eq '${MOUNT}' /proc/mounts
	do
		display_alert "Unmounting" "${MOUNT}" "info"
		sleep 5
	done

	losetup -d $LOOP
	rm -rf --one-file-system $MOUNT

    parted -s ${SDCARD}.raw print

    #rm -rf --one-file-system ${SDCARD}.raw
}

make_image