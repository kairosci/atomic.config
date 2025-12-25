#!/usr/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Run this script with sudo"
	exit 1
fi

cd script/

./hide_grub.sh
./manage_system.sh
./rename_btrfs.sh
./set_flatpak.sh
./set_rpm.sh
