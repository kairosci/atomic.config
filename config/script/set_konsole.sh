#!/usr/bin/bash
set -e

# Detect user (if running as root via sudo)
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
KONSOLE_DIR="$USER_HOME/.local/share/konsole"
PROFILE_PATH="$KONSOLE_DIR/Kionite.profile"

check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script with sudo"
        exit 1
    fi
}

check_sudo

setup_konsole() {
    echo "Creating Konsole profile 'kionite' for user: $REAL_USER"
    
    mkdir -p "$KONSOLE_DIR"
    
    cat <<EOF > "$PROFILE_PATH"
[Appearance]
Font=Adwaita Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

[General]
Name=Kionite
Parent=FALLBACK/
EOF

    # Ensure permissions
    chown "$REAL_USER:$REAL_USER" "$KONSOLE_DIR"
    chown "$REAL_USER:$REAL_USER" "$PROFILE_PATH"
    
    echo "Konsole profile 'kionite' created successfully."
}

setup_konsole
