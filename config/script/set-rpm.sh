#!/usr/bin/bash
# =============================================================================
# Set RPM Packages
# Manages rpm-ostree packages: removes defaults, adds repos, installs packages
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

# =============================================================================
# Constants
# =============================================================================

readonly -a PACKAGES_TO_REMOVE=(
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

readonly -a PACKAGES_TO_INSTALL=(
    "clang"
    "cmake"
    "java-latest-openjdk"
    "kalk"
    "ksshaskpass"
    "libvirt"
    "tlp"
    "tlp-rdw"
    "make"
    "ncurses-devel"
    "nodejs"
    "qemu-kvm"
    "distrobox"
    "rsms-inter-fonts"
    "breeze-gtk"
    "adw-gtk3-theme"
)

# =============================================================================
# Functions
# =============================================================================

remove-base-packages() {
    log-info "Removing base packages"
    
    local -a valid_packages=()
    local ostree_status
    ostree_status="$(rpm-ostree status)"
    
    for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
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
    log-info "Installing packages"
    
    if [[ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]]; then
        rpm-ostree install --idempotent "${PACKAGES_TO_INSTALL[@]}"
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
    remove-base-packages
    install-third-party-repos
    install-packages
    install-google-antigravity
}

main "$@"
