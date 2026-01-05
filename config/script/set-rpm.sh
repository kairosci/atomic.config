#!/usr/bin/bash
# =============================================================================
# Set RPM Packages
# Manages rpm-ostree packages for Kionite and Silverblue
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

# =============================================================================
# Constants - Kionite (KDE Plasma)
# =============================================================================

readonly -a KIONITE_PACKAGES_TO_REMOVE=(
    "ibus-typing-booster"
    "kde-connect"
    "kde-connect-libs"
    "kdeconnectd"
    "kinfocenter"
    "plasma-drkonqi"
    "plasma-welcome"
    "plasma-welcome-fedora"
    "plasma-discover"
    "plasma-discover-rpm-ostree"
    "plasma-discover-flatpak"
    "plasma-discover-notifier"
    "plasma-discover-kns"
    "kcharselect"
    "kdebugsettings"
    "khelpcenter"
    "krfb"
    "krfb-libs"
    "kjournald"
    "kjournald-libs"
    "kwalletmanager5"
    "filelight"
    "firefox"
    "firefox-langpacks"
    "toolbox"
)

readonly -a KIONITE_PACKAGES_TO_INSTALL=(
    "kalk"
    "ksshaskpass"
    "libvirt"
    "tlp"
    "tlp-rdw"
    "qemu-kvm"
    "distrobox"
    "rsms-inter-fonts"
    "google-noto-emoji-fonts"
    "breeze-gtk"
    "adw-gtk3-theme"
)

# =============================================================================
# Constants - Silverblue (GNOME)
# =============================================================================

readonly -a SILVERBLUE_PACKAGES_TO_REMOVE=(
    "gnome-software"
    "gnome-software-rpm-ostree"
    "gnome-contacts"
    "gnome-maps"
    "gnome-weather"
    "gnome-tour"
    "gnome-connections"
    "gnome-characters"
    "gnome-font-viewer"
    "gnome-logs"
    "gnome-remote-desktop"
    "simple-scan"
    "totem"
    "cheese"
    "rhythmbox"
    "yelp"
    "firefox"
    "firefox-langpacks"
    "toolbox"
)

readonly -a SILVERBLUE_PACKAGES_TO_INSTALL=(
    "libvirt"
    "tlp"
    "tlp-rdw"
    "qemu-kvm"
    "distrobox"
    "rsms-inter-fonts"
    "google-noto-emoji-fonts"
    "yaru-theme"
    "yaru-gtk3-theme"
    "yaru-gtk4-theme"
    "yaru-icon-theme"
    "yaru-sound-theme"
)

# =============================================================================
# Functions
# =============================================================================

remove-base-packages() {
    local distro="$1"
    local -n packages_ref="$2"
    
    log-info "Removing base packages for $distro"
    
    local -a valid_packages=()
    local ostree_status
    ostree_status="$(rpm-ostree status)"
    
    for pkg in "${packages_ref[@]}"; do
        if rpm -q "$pkg" &>/dev/null; then
            if echo "$ostree_status" | grep -Fq "$pkg"; then
                log-info "Skipping $pkg (already has override)"
            else
                valid_packages+=("$pkg")
            fi
        else
            log-info "Skipping $pkg (not installed)"
        fi
    done
    
    if [[ ${#valid_packages[@]} -gt 0 ]]; then
        rpm-ostree override remove "${valid_packages[@]}"
        log-success "Base packages removed"
    else
        log-info "No base packages to remove"
    fi
}

install-third-party-repos() {
    log-info "Installing third-party repositories"
    
    # Brave Browser
    if [[ ! -f /etc/yum.repos.d/brave-browser.repo ]]; then
        log-info "Adding Brave repository"
        curl -fsS https://dl.brave.com/install.sh | sh
        log-success "Brave repository added"
    else
        log-info "Brave repository already exists"
    fi
}

install-packages() {
    local -n packages_ref="$1"
    
    log-info "Installing packages"
    
    if [[ ${#packages_ref[@]} -gt 0 ]]; then
        rpm-ostree install --idempotent "${packages_ref[@]}"
        log-success "Packages installed"
    fi
}

install-google-antigravity() {
    log-info "Installing Antigravity"
    
    local repo_file="/etc/yum.repos.d/antigravity.repo"
    
    if [[ ! -f "$repo_file" ]]; then
        cat > "$repo_file" <<EOF
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOF
        log-success "Antigravity repository added"
    fi
    
    rpm-ostree install --idempotent antigravity
    log-success "Antigravity installed"
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    ensure-root
    local distro
    distro="$(detect-distro)"
    
    log-info "Detected distro: $distro"
    
    case "$distro" in
        kionite)
            remove-base-packages "Kionite" KIONITE_PACKAGES_TO_REMOVE
            install-third-party-repos
            install-packages KIONITE_PACKAGES_TO_INSTALL
            ;;
        silverblue)
            remove-base-packages "Silverblue" SILVERBLUE_PACKAGES_TO_REMOVE
            install-third-party-repos
            install-packages SILVERBLUE_PACKAGES_TO_INSTALL
            ;;
        *)
            log-error "Unknown distro: $distro"
            log-error "This script only supports Kionite and Silverblue"
            exit 1
            ;;
    esac
    
    install-google-antigravity
}

main "$@"
