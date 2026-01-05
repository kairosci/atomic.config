#!/usr/bin/bash
# =============================================================================
# Set GNOME Extensions
# Installs and enables extensions for Ubuntu-like experience on Silverblue
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =============================================================================
# Constants
# =============================================================================

# Extensions to enable (installed via rpm-ostree or Flatpak Extension Manager)
readonly -a GNOME_EXTENSIONS=(
    "appindicatorsupport@rgcjonas.gmail.com"     # AppIndicator/Tray icons
    "dash-to-dock@micxgx.gmail.com"               # Ubuntu-style dock
    "blur-my-shell@aunetx"                        # Blur effects
    "just-perfection-desktop@just-perfection"    # Desktop tweaks
    "caffeine@pataber.dev"                        # Prevent auto-suspend
)

# =============================================================================
# Functions
# =============================================================================

install-extension-manager() {
    log-info "Installing GNOME Extension Manager via Flatpak"
    
    if ! flatpak list --app | grep -q "com.mattjakeman.ExtensionManager"; then
        flatpak install flathub com.mattjakeman.ExtensionManager -y
        log-success "Extension Manager installed"
    else
        log-info "Extension Manager already installed"
    fi
}

enable-user-extensions() {
    log-info "Enabling GNOME user extensions"
    
    local real_user
    real_user="$(get-real-user)"
    
    # Enable user extensions globally
    dconf write /org/gnome/shell/disable-user-extensions false
    
    log-success "User extensions enabled"
}

configure-dash-to-dock() {
    log-info "Configuring Dash to Dock (Ubuntu-style)"
    
    # Set dock position to bottom (Ubuntu-style)
    dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'"
    
    # Extend dock across screen
    dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height false
    
    # Show on all monitors
    dconf write /org/gnome/shell/extensions/dash-to-dock/multi-monitor true
    
    # Auto-hide behavior
    dconf write /org/gnome/shell/extensions/dash-to-dock/intellihide-mode "'ALL_WINDOWS'"
    
    # Icon size
    dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 48
    
    # Transparency
    dconf write /org/gnome/shell/extensions/dash-to-dock/transparency-mode "'DYNAMIC'"
    
    log-success "Dash to Dock configured"
}

configure-just-perfection() {
    log-info "Configuring Just Perfection (desktop tweaks)"
    
    # Hide search on overview
    dconf write /org/gnome/shell/extensions/just-perfection/search false
    
    # Show workspaces in overview
    dconf write /org/gnome/shell/extensions/just-perfection/workspace true
    
    # Animation speed (faster)
    dconf write /org/gnome/shell/extensions/just-perfection/animation 2
    
    log-success "Just Perfection configured"
}

print-extension-instructions() {
    log-info ""
    log-info "=========================================="
    log-info "  GNOME Extensions Setup"
    log-info "=========================================="
    log-info ""
    log-info "Extensions to install manually via Extension Manager:"
    log-info ""
    for ext in "${GNOME_EXTENSIONS[@]}"; do
        log-info "  • $ext"
    done
    log-info ""
    log-info "Open Extension Manager and search for:"
    log-info "  1. AppIndicator and KStatusNotifierItem Support"
    log-info "  2. Dash to Dock"
    log-info "  3. Blur my Shell"
    log-info "  4. Just Perfection"
    log-info "  5. Caffeine"
    log-info ""
    log-info "After installing, run this script again to apply configs."
    log-info "=========================================="
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    ensure-user
    
    install-extension-manager
    enable-user-extensions
    
    # Try to configure extensions if they're installed
    if command -v dconf &>/dev/null && dconf list /org/gnome/shell/extensions/dash-to-dock/ &>/dev/null; then
        configure-dash-to-dock
    fi
    
    if command -v dconf &>/dev/null && dconf list /org/gnome/shell/extensions/just-perfection/ &>/dev/null; then
        configure-just-perfection
    fi
    
    print-extension-instructions
}

main "$@"
