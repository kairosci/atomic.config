#!/usr/bin/bash
set -e

# Detect user (if running as root via sudo)
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
BASHRC="$USER_HOME/.bashrc"
OMB_DIR="$USER_HOME/.oh-my-bash"

check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script with sudo"
        exit 1
    fi
}

check_sudo

setup_omb() {
    echo "Configuring Oh My Bash for user: $REAL_USER"
    
    # 1. Install Oh My Bash if missing
    if [ ! -d "$OMB_DIR" ]; then
        echo "Installing Oh My Bash..."
        # Install unattended
        # We fetch the script and run it as the user
        curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh | sudo -u "$REAL_USER" bash -s -- --unattended
    else
        echo "Oh My Bash is already installed."
    fi

    # 2. Configure Theme (vscode)
    if [ -f "$BASHRC" ]; then
        if grep -q 'OSH_THEME="vscode"' "$BASHRC"; then
             echo "Theme is already set to 'vscode'. Skipping configuration."
        else
            echo "Setting theme to 'vscode' in .bashrc..."
            # Replace existing theme line
            sed -i 's/^OSH_THEME=".*"/OSH_THEME="vscode"/' "$BASHRC"
            
            # If the line wasn't there (failed substitution), append it
            if ! grep -q 'OSH_THEME=' "$BASHRC"; then
                 echo 'OSH_THEME="vscode"' >> "$BASHRC"
            fi
            
            # Ensure permissions
            chown "$REAL_USER:$REAL_USER" "$BASHRC"
            echo "Theme updated. Please restart your terminal."
        fi
    fi
}

main() {
    # Check dependencies
    if ! command -v git &> /dev/null; then
        echo "Error: git is required for Oh My Bash installation."
        exit 1
    fi
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is required for Oh My Bash installation."
        exit 1
    fi

    setup_omb
}

main
