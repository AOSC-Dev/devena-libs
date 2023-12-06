#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# randomize-rootfs-uuid - Generate a new random UUID for the root filesystem

# It is necessary since modern Linux distro uses filesystem UUID to locate the
# root filesystem. Since we are using a generated image directly flashed to
# the storage device, every single one flashed the same image can have the
# same UUID. Randomize it to avoid collisions.

# NOTE we can not change the UUID of a filesystem while it is MOUNTED, so we
# need a specialized initramfs to perform the first boot setup.
# The fact we can change the UUID of an ext4 filesystem while mounted is
# pure conincidence, and it works.

# We declare that every prebuilt ready-to-flash device images should use ext4
# as the root filesystem.
# ~Mingcong Bai

[ -e /etc/default/devena ] && source /etc/default/devena

randomize_rootfs_uuid() {
	eval $(blkid -o export $ROOTPART_PATH)
	echo "[+] The filesystem UUID was $UUID."
	echo "[+] Randomizing root filesystem UUID ..."
	case "$TYPE" in
		ext4)
			tune2fs -U random $ROOTPART_PATH
			;;
		xfs)
			# Unsupported unless we have a specialized initrd
			xfs_admin -U generate $ROOTPART_PATH
			;;
		btrfs)
			# Unsupported unless we have a specialized initrd
			btrfstune -u $ROOTPART_PATH
			;;
		*)
			echo "[!] Unsupported filesystem."
			return
			;;
	esac
	eval $(lsblk -o UUID -Py $ROOTDEV_PATH)
	partprobe $ROOTDEV_PATH
	echo "[+] Finished. The new UUID is $UUID."
}

if [ "$RANDOMIZE_ROOTFS_UUID" ] && [ "$HAS_REAL_ROOTDEV" == "1" ] \
	&& [ "$HAS_REAL_ROOTPART" == "1" ] ; then
	randomize_rootfs_uuid
fi