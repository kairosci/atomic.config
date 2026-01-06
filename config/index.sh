#!/usr/bin/bash
# Fedora Atomic Configuration Index
# Main entry point for system configuration (Kionite / Silverblue)

set -euo pipefail

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "$SCRIPT_DIR/../lib/common.sh"

# Main Functions

run-scripts() {
    local distro
    distro="$(detect-distro)"
    
    log-info "Starting configuration for $distro"
    
    local scripts_dir="$SCRIPT_DIR/script"
    
    if [[ ! -d "$scripts_dir" ]]; then
        log-error "Script directory not found: $scripts_dir"
        exit 1
    fi
    
    cd "$scripts_dir"
    
    # Common scripts for all distros
    local -a common_scripts=(
        "./hide-grub.sh"
        "./rename-btrfs.sh"
        "./set-flatpak.sh"
        "./hide-urw-fonts.sh"
        "./set-rpm.sh"
        "./set-spotify-pwa.sh"
        "./set-protonmail-pwa.sh"
        "./manage-system.sh"
        "./set-safe-delete.sh"
        "./set-omb.sh"
        "./set-theme.sh"
        "./set-wallpaper.sh"
        "./set-adwaita-fonts.sh"
        "./set-font-whitelist.sh"
        "./set-apple-emojis.sh"
    )
    
    # Distro-specific scripts
    local -a distro_scripts=()
    
    case "$distro" in
        kionite)
            distro_scripts=(
                "./kionite/disable-emojier.sh"
                "./kionite/set-launcher-icon.sh"
                "./kionite/set-konsole.sh"
                "./kionite/optimize-animations.sh"
            )
            ;;
        silverblue)
            distro_scripts=(
                "./silverblue/set-extensions.sh"
                "./silverblue/optimize-animations.sh"
            )
            ;;
        *)
            log-warn "Unknown distro: $distro, running common scripts only"
            ;;
    esac
    
    # Run common scripts
    log-info "Running common scripts..."
    for script in "${common_scripts[@]}"; do
        if [[ -f "$script" ]]; then
            log-info "Executing: $script"
            "$script"
        else
            log-warn "Script not found: $script"
        fi
    done
    
    # Run distro-specific scripts
    if [[ ${#distro_scripts[@]} -gt 0 ]]; then
        log-info "Running $distro-specific scripts..."
        for script in "${distro_scripts[@]}"; do
            if [[ -f "$script" ]]; then
                log-info "Executing: $script"
                "$script"
            else
                log-warn "Script not found: $script"
            fi
        done
    fi
    
    log-success "Configuration completed for $distro"
}

# Entry Point

main() {
    # require-root (now handled per-script)
    run-scripts
}

main "$@"
