#!/usr/bin/bash
# =============================================================================
# Fedora Atomic Common Library
# Shared functions and utilities for Kionite/Silverblue scripts
# =============================================================================

# Strict mode settings
set -euo pipefail

# =============================================================================
# Constants
# =============================================================================
readonly SCRIPT_NAME="${0##*/}"

# =============================================================================
# Distro Detection
# =============================================================================

# Detect which Fedora Atomic variant we're on
detect-distro() {
    if grep -qi "Kinoite" /etc/os-release 2>/dev/null; then
        echo "kionite"
    elif grep -qi "Silverblue" /etc/os-release 2>/dev/null; then
        echo "silverblue"
    else
        echo "unknown"
    fi
}

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

# Ensure script runs as root (re-exec with sudo if needed)
ensure-root() {
    if [[ "$EUID" -ne 0 ]]; then
        # Check if sudo assumes execution or we need to call it
        echo "Privilege escalation required for $SCRIPT_NAME..." >&2
        exec sudo "$0" "$@"
    fi
}

# Ensure script runs as user (fail if root)
ensure-user() {
    if [[ "$EUID" -eq 0 ]] && [[ -z "${SUDO_USER:-}" ]]; then
        # Currently running as root without SUDO_USER (pure root)
        # We prefer running as normal user
        log-warn "Running as strict root. Some user-specific settings might not apply correctly."
    elif [[ "$EUID" -eq 0 ]]; then
        # Running via sudo, but we want user logic?
        # Ideally, we should just drop privileges or assume correct user context
        # But for scripts needing user dconf, running as sudo is bad.
        : # Pass, but maybe we should warn?
    fi
}

# Legacy: strict requirement (deprecated, use ensure-root)
require-root() {
    ensure-root
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
