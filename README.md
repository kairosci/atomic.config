# Fedora Atomic Configuration

Configuration scripts for **Fedora Kionite** (KDE Plasma) and **Fedora Silverblue** (GNOME). The scripts automatically detect which distro you're running and apply the appropriate configuration.

## Quick Start

```bash
sudo ./setup.sh
# Restart terminal, then run:
kionite
```

## Distro Detection

All scripts automatically detect whether you're running Kionite or Silverblue by checking `/etc/os-release`.

## Scripts

### set_rpm.sh

Manages rpm-ostree packages with distro-specific configuration:

**Kionite (KDE Plasma):**

- Removes: KDE Connect, Plasma Discover, Firefox, Toolbox, etc.
- Installs: kalk, ksshaskpass, libvirt, tlp, distrobox, breeze-gtk, adw-gtk3-theme

**Silverblue (GNOME):**

- Removes: gnome-software, gnome-contacts, gnome-maps, Firefox, Toolbox, etc.
- Installs: libvirt, tlp, distrobox, **yaru-theme** (GTK, icons, sounds)

**Both:**

- Installs Brave browser repository
- Installs Antigravity

### set_flatpak.sh

Manages Flatpak applications:

- Removes default apps (KDE games for Kionite, GNOME apps for Silverblue)
- Adds Flathub repository
- Installs Discord

### manage_system.sh

System maintenance and cleanup:

- Clears journal logs
- Cleans rpm-ostree cache
- Removes distro-specific user configs
- System upgrade
- Flatpak maintenance

### Other Scripts

- `hide_grub.sh`: Sets GRUB timeout to 0
- `rename_btrfs.sh`: Standardizes BTRFS labels
- `disable_emojier.sh`: Disables Plasma emoji selector (Kionite only)

## Utilities

- `update-system.sh`: Quick system update
- `delete-folder.sh`: Interactive folder deletion
- `toggle-folder-protection.sh`: Enable/disable immutable flag

## Development Packages

> **Note:** Development tools (nodejs, clang, cmake, etc.) should be installed inside Distrobox containers, not in the base system.
