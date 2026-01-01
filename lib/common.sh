#!/usr/bin/bash
# =============================================================================
# Kionite Common Library
# Shared functions and utilities for all Kionite scripts
# =============================================================================

# Strict mode settings
set -euo pipefail

# =============================================================================
# Constants
# =============================================================================
readonly SCRIPT_NAME="${0##*/}"

# =============================================================================
# User Detection
# =============================================================================

# Get the real user (handles sudo execution)
get-real-user() {
    echo "${SUDO_USER:-$USER}"
}

# Get the real user's home directory
get-user-home() {
    local real_user
    real_user="$(get-real-user)"
    getent passwd "$real_user" | cut -d: -f6
}

# =============================================================================
# Privilege Checks
# =============================================================================

# Verify script is running as root
require-root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "Error: $SCRIPT_NAME requires root privileges. Run with sudo." >&2
        exit 1
    fi
}

# =============================================================================
# Logging
# =============================================================================

# Print info message
log-info() {
    echo "[INFO] $*"
}

# Print warning message
log-warn() {
    echo "[WARN] $*" >&2
}

# Print error message
log-error() {
    echo "[ERROR] $*" >&2
}

# Print success message
log-success() {
    echo "[OK] $*"
}

# =============================================================================
# File Operations
# =============================================================================

# Fix file ownership for sudo-created files
fix-ownership() {
    local path="$1"
    local real_user
    real_user="$(get-real-user)"
    
    if [[ -n "${SUDO_USER:-}" ]]; then
        chown "$real_user:$real_user" "$path"
    fi
}

# Fix directory ownership recursively
fix-ownership-recursive() {
    local path="$1"
    local real_user
    real_user="$(get-real-user)"
    
    if [[ -n "${SUDO_USER:-}" ]]; then
        chown -R "$real_user:$real_user" "$path"
    fi
}

# =============================================================================
# Command Checks
# =============================================================================

# Check if command exists
command-exists() {
    command -v "$1" &>/dev/null
}

# Require a command to exist
require-command() {
    local cmd="$1"
    local msg="${2:-$cmd is required but not installed}"
    
    if ! command-exists "$cmd"; then
        log-error "$msg"
        exit 1
    fi
}
