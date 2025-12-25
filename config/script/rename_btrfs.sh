#!/usr/bin/bash
set -e

btrfs filesystem label /var fedora
btrfs filesystem label /var/home fedora
