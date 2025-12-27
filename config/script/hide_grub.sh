#!/usr/bin/bash
set -e

# Function to hide GRUB menu
hide_grub() {
    echo "Hiding GRUB"
    cp /boot/grub2/grub.cfg /boot/grub2/grub.cfg.bak
    sed -i 's/^set timeout=.*/set timeout=0/' /boot/grub2/grub.cfg
    chmod 444 /boot/grub2/grub.cfg
    echo "Done"
}

# Main execution
main() {
    hide_grub
}

main
