#!/usr/bin/bash
set -e

# Detect user (if running as root via sudo)
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
BASHRC="$USER_HOME/.bashrc"

check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script with sudo"
        exit 1
    fi
}

check_sudo

setup_alias() {
    echo "Configuring Safe Delete for user: $REAL_USER"
    
    if [ ! -f "$BASHRC" ]; then
        echo "Error: .bashrc not found at $BASHRC"
        return
    fi
    
    # Check if gio is present (it should be)
    if ! command -v gio &> /dev/null; then
        echo "Warning: 'gio' command not found. Cannot configure safe delete."
        return
    fi

    # Append aliases if not already present
    if ! grep -q "alias rm='gio trash'" "$BASHRC"; then
        echo "Adding safe delete aliases to $BASHRC..."
        
        {
            echo ""
            echo "# Safe Delete Configuration (Kionite Setup)"
            echo "alias rm='gio trash 2>/dev/null || /usr/bin/rm'"
            echo "alias rmp='/usr/bin/rm'"
        } >> "$BASHRC"
        
        # Correct ownership if we wrote as root
        chown "$REAL_USER:$REAL_USER" "$BASHRC"
        
        echo "Done. Please restart your terminal or run 'source ~/.bashrc' to apply."
    else
        echo "Safe delete aliases already configured."
    fi
}

main() {
    setup_alias
}

main
