#!/usr/bin/bash
# Clean Cross-DE Configs
# Removes config files from the unused Desktop Environment (KDE/GNOME)

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

# Constants

# Configs associated with KDE Plasma to remove when on GNOME
readonly -a KDE_CONFIGS=(
    "$HOME/.kde"
    "$HOME/.config/kde.org"
    "$HOME/.config/kde*"
    "$HOME/.config/plasma*"
    "$HOME/.config/kwin*"
    "$HOME/.config/kconf_updater"
    "$HOME/.local/share/k*"
    "$HOME/.local/share/plasma*"
    "$HOME/.cache/k*"
    "$HOME/.cache/plasma*"
)

# Configs associated with GNOME to remove when on KDE
readonly -a GNOME_CONFIGS=(
    "$HOME/.gnome"
    "$HOME/.config/gnome*"
    "$HOME/.config/goa-1.0"
    "$HOME/.config/gtk-3.0"
    "$HOME/.config/gtk-4.0"
    "$HOME/.config/dconf" # Be careful with dconf as it might hold some shared keys, but usually DE specific
    "$HOME/.local/share/gnome*"
    "$HOME/.cache/gnome*"
)

# Function: clean-paths
# Description:
#   Iterates through a list of patterns, finds matching files/dirs,
#   and asks the user for confirmation before deletion.
clean-paths() {
    local -n patterns=$1
    local de_name="$2"
    
    log-info "Searching for leftover $de_name configuration files..."
    
    local found_something=false
    
    for pattern in "${patterns[@]}"; do
        # Expand glob pattern
        for path in $pattern; do
            if [[ -e "$path" ]]; then
                echo -e "\e[33m[FOUND]\e[0m $path"
                found_something=true
                
                read -p "    Delete '$path'? [y/N] " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf "$path"
                    log-success "Deleted."
                else
                    echo "    Skipped."
                fi
            fi
        done
    done
    
    if [[ "$found_something" == "false" ]]; then
        log-info "No significant $de_name leftovers found."
    fi
}

main() {
    ensure-user
    local current_distro
    current_distro="$(detect-distro)"
    
    echo " CROSS-DE CLEANUP TOOL"
    echo " Current System: $current_distro"
    
    if [[ "$current_distro" == "silverblue" ]]; then
        log-info "You are running Silverblue (GNOME)."
        read -p "Do you want to search for and remove KDE Plasma leftovers? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            clean-paths KDE_CONFIGS "KDE Plasma"
        fi
        
    elif [[ "$current_distro" == "kionite" ]]; then
        log-info "You are running Kionite (KDE)."
        read -p "Do you want to search for and remove GNOME leftovers? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            clean-paths GNOME_CONFIGS "GNOME"
        fi
    else
        log-error "Unknown distro. Cannot safely determine what to clean."
    fi
    
    log-success "Cleanup process finished."
}

main "$@"
