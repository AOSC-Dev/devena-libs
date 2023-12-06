#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# expand-rootfs - automatically expand the root filesystem.

[ -e /etc/default/devena ] && source /etc/default/devena

resize_root_partition() {
	echo "[+] Expanding the root filesystem..."
	eval $(blkid -o export $ROOTPART_PATH)
	case "$TYPE" in
		ext4)
			resize2fs $ROOTPART_PATH
			;;
		xfs)
			xfs_growfs $ROOTPART_PATH
			;;
		btrfs)
			btrfs filesystem resize $ROOTPART_PATH
			;;
		*)
			echo "[!] Unsupported filesystem: $TYPE. Skipping."
			exit 0
			;;
	esac
}

if [ "$RESIZE_ROOTPART" ] && [ "$HAS_REAL_ROOTPART" == "1" ] \
	&& [ "$HAS_REAL_ROOTDEV" == "1" ] ; then
	resize_root_partition
fi