#!/usr/bin/bash
set -e

cp /boot/grub2/grub.cfg /boot/grub2/grub.cfg.bak
sed -i 's/^set timeout=.*/set timeout=0/' /boot/grub2/grub.cfg
chmod 444 /boot/grub2/grub.cfg
