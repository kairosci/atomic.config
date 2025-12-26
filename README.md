# Kionite Configuration

This repository contains configuration scripts designed to optimize and manage **Fedora Kionite**. These scripts automate the process of cleaning up the system, removing unnecessary default packages, and installing a curated set of applications and tools.

## Scripts

The configuration is split into three main scripts, located in the `config/script/` directory.

### manage_system.sh

This script is responsible for general system maintenance and cleanup. It performs the following actions:

1.  **System Cleanup**: runs `journalctl --vacuum-files=0` to clear old journal logs and `rpm-ostree cleanup --base -m` to clean up the base system.
2.  **User Configuration Removal**: Deletes a comprehensive list of user configuration directories and files (e.g., KDE Connect config, Mozilla folders, Akonadi data, various KDE application caches) to ensure a fresh state.
3.  **System Upgrade**: Refreshes the `rpm-ostree` metadata and performs a system upgrade (`rpm-ostree upgrade`).
4.  **Flatpak Maintenance**: Uninstalls unused Flatpak runtimes and performs a general Flatpak update.

### set_rpm.sh

This script manages the base system packages using `rpm-ostree`. It handles:

1.  **Base Package Removal**: Removes a defined set of default packages, including emoji fonts, KDE Connect, Plasma Welcome, Discover, various other KDE utilities (e.g., KCalc, KMines), and **Toolbox** (replaced by Distrobox) via `rpm-ostree override remove`.
2.  **Third-Party Repositories**:
    *   Installs the Brave browser repository.
    *   Installs the Negativo17 Spotify repository.
3.  **Package Installation**: Installs a selected list of packages, including:
    *   **Distrobox**: A powerful alternative to Toolbox for containerized development.
    *   **Spotify**: Music streaming client (`spotify-client` from Negativo17).
    *   Development tools (Clang, CMake, Make, NodeJS).
    *   System utilities (Libvirt, QEMU-KVM, TLP).
    *   Other applications (Kalk, Ksshaskpass).
4.  **Google Antigravity**: Installs the `google-antigravity` package.

### set_flatpak.sh

This script manages Flatpak applications and remotes. It performs the following:

1.  **Default Application Removal**: Removes default Flatpak applications often included with the distribution (e.g., KCalc, KMahjongg, KolourPaint).
2.  **Remote Setup**: Adds the Flathub repository (`flathub.org`) if it is not already present.
3.  **Application Installation**: Installs specific Flatpak applications from Flathub, such as Discord and Kalk.

### disable_emojier.sh

This script disables the KDE Plasma emoji selector (`plasma-emojier`) which is integrated into the `plasma-desktop` package and cannot be removed directly.
*   **Action**: Hides the application from launchers by creating a local override desktop file with `Hidden=true`.
*   **Shortcut Disabling**: Disables the global keyboard shortcut for the emoji selector.
*   **Note**: The binary remains at `/usr/bin/plasma-emojier` but is not accessible via launcher or keyboard shortcuts.

### hide_grub.sh

This script reduces the boot time by hiding the GRUB menu.
*   **Action**: Sets the GRUB timeout to 0 in `/boot/grub2/grub.cfg`.
*   **Backup**: Creates a backup of the original configuration at `/boot/grub2/grub.cfg.bak`.

### rename_btrfs.sh

This script standardizes the BTRFS filesystem labels.
*   **Action**: Renames the filesystem labels for `/var` and `/var/home` to `fedora`.

## Utility Scripts

The `utils/` directory contains helper scripts.

### delete_folder.sh

An interactive script to delete directories system-wide based on a partial name match.
*   **Usage**: Prompts the user for a folder name and removes all matching directories using `find` and `rm`.
*   **Warning**: This runs with `sudo` and deletes recursively. Use with caution.

## Main Entry Point

### index.sh

Located in the `config/` directory, this is the main orchestrator script.
*   **Requirement**: Must be run with `sudo` (`sudo ./index.sh`).
*   **Execution**: Navigates to the `script/` directory and executes the following in order:
    1.  `hide_grub.sh`
    2.  `rename_btrfs.sh`
    3.  `set_flatpak.sh`
    4.  `disable_emojier.sh`
    5.  `set_rpm.sh`
    6.  `manage_system.sh`
