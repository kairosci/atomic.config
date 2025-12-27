#!/usr/bin/bash
set -e

# Detect user (if running as root via sudo)
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script with sudo"
        exit 1
    fi
}

check_sudo

# Anchor file name
ANCHOR_FILE=".state_protected"

protect_directory_recursive() {
    local target_dir="$1"
    
    if [ ! -d "$target_dir" ]; then
        echo "Skipping missing directory: $target_dir"
        return
    fi
    
    echo "Scanning $target_dir recursively..."
    
    # Traverse the directory
    # -mount prevents descending into other filesystems (like /proc, /sys, or network mounts if mounted in home)
    find "$target_dir" -mount -type d | while read -r dir; do
        
        # Check if directory path contains a hidden component (/. something)
        # This covers .hidden_dir AND .hidden_dir/visible_subdir
        if [[ "$dir" == *"/."* ]]; then
             # Is hidden or inside hidden -> CLEANUP
             if [ -f "$dir/$ANCHOR_FILE" ]; then
                 echo "Unprotecting: $dir"
                 chattr -i "$dir/$ANCHOR_FILE" 2>/dev/null || true
                 rm -f "$dir/$ANCHOR_FILE"
             fi
        else
            # Visible path -> PROTECT
            # Check if already protected
            if [ -f "$dir/$ANCHOR_FILE" ]; then
                # Already exists, skip re-protecting logic and logging
                continue
            fi

            echo "Protecting: $dir"
            
            touch "$dir/$ANCHOR_FILE"
            chattr +i "$dir/$ANCHOR_FILE" 2>/dev/null || echo "Failed to protect $dir"
        fi
    done
}

main() {
    # Define targets
    # /home is typically a symlink to /var/home in OSTree systems.
    # We stick to USER_HOME to avoid messing with system variable state (logs, cache, containers) in /var
    TARGET_ROOTS=(
        "$USER_HOME"
    )

    for root in "${TARGET_ROOTS[@]}"; do
        if [ -d "$root" ]; then
            echo "Configuring protection for ALL visible folders in: $root"
            protect_directory_recursive "$root"
        else
            echo "Warning: Target directory not found: $root"
        fi
    done
}

main
