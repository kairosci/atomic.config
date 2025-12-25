#!/usr/bin/bash
set -e

# Function to rename BTRFS labels
rename_btrfs_labels() {
    echo "Renaming BTRFS labels..."
    btrfs filesystem label /var fedora
    btrfs filesystem label /var/home fedora
    echo "BTRFS labels renamed."
}

# Main execution
main() {
    rename_btrfs_labels
}

main
