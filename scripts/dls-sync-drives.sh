#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# █████  DLS Sync Drives: Bi-directional sync for iCloud and Google Drive
# █  ██  Version: 1.0.0
# █ ███  Author: Benjamin Pequet
# █████  GitHub: https://github.com/pequet/dls-sync-drives
#
# Purpose:
#   This script performs a robust, bi-directional synchronization of a
#   specified folder (typically .DLS) between a user's local iCloud Drive
#   and Google Drive directories on macOS. It is designed to be automated
#   via launchd or cron for regular, unattended backups.
#
# Usage:
#   ./dls-sync-drives.sh
#   The script is configured via 'sync.config' in the same directory.
#
# Dependencies:
#   - rsync: Must be installed and available in the system's PATH.
#
# Support the Project:
#   - Buy Me a Coffee: https://buymeacoffee.com/pequet
#   - GitHub Sponsors: https://github.com/sponsors/pequet

# --- Global Variables ---
# Resolve the true script directory, following symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

CONFIG_FILE="${SCRIPT_DIR}/sync.config"
LOCK_DIR="/tmp/dls-sync-drives.lock.d" # Use a directory for the lock
LOG_FILE_PATH="${SCRIPT_DIR}/../logs/sync.log"  # Default, can be overridden by config

# Source shared utilities
source "${SCRIPT_DIR}/utils/logging_utils.sh"
source "${SCRIPT_DIR}/utils/messaging_utils.sh"

# --- Function Definitions ---

# *
# * Configuration Management
# *
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file not found: ${CONFIG_FILE}"
        print_error "Copy sync.config.example to sync.config and edit with your paths"
        exit 1
    fi
    
    # shellcheck source=./sync.config.example
    if ! source "$CONFIG_FILE"; then
        print_error "Failed to load configuration from ${CONFIG_FILE}"
        exit 1
    fi

    # Update log path if defined in config, then ensure directory exists
    if [[ -n "${LOG_FILE_PATH_OVERRIDE:-}" ]]; then
        LOG_FILE_PATH="$LOG_FILE_PATH_OVERRIDE"
        ensure_log_directory
    fi
}

# *
# * Dependency Validation
# *
check_dependencies() {
    if ! command -v rsync &> /dev/null; then
        print_error "rsync not found. Install with: brew install rsync"
        exit 1
    fi
}

# *
# * Concurrency Lock Management
# *
acquire_lock() {
    # Use mkdir for an atomic, dependency-free lock.
    if ! mkdir "${LOCK_DIR}" 2>/dev/null; then
        print_error "Could not acquire lock. Lock directory '${LOCK_DIR}' already exists. Another instance may be running."
        exit 1
    fi
    log_message "INFO" "Lock acquired: ${LOCK_DIR}"
}

cleanup_lock() {
    # This trap handler ensures the lock directory is removed on script exit.
    if [ -n "${LOCK_DIR:-}" ] && [ -d "${LOCK_DIR}" ]; then
        if rmdir "${LOCK_DIR}"; then
            # Log successful cleanup if logging is still available.
            log_message "INFO" "Successfully removed lock directory: ${LOCK_DIR}"
        else
            log_message "ERROR" "Failed to remove lock directory: ${LOCK_DIR}"
        fi
    fi
}

# *
# * Path Validation
# *
validate_paths() {
    print_step "Validating paths"
    
    # Construct full paths
    ICLOUD_PATH="${ICLOUD_DIR_BASE}/${SYNC_FOLDER_NAME}"
    GOOGLE_DRIVE_PATH="${GOOGLE_DIR_BASE}/${SYNC_FOLDER_NAME}"

    print_info "iCloud Path: ${ICLOUD_PATH}"
    print_info "Google Drive Path: ${GOOGLE_DRIVE_PATH}"

    if [[ ! -d "${ICLOUD_PATH}" ]]; then
        print_error "iCloud sync directory not found at ${ICLOUD_PATH}"
        exit 1
    fi
    if [[ ! -d "${GOOGLE_DRIVE_PATH}" ]]; then
        print_error "Google Drive sync directory not found at ${GOOGLE_DRIVE_PATH}"
        exit 1
    fi
}

# *
# * Synchronization Logic
# *
run_sync() {
    print_header "DLS Drive Sync"
    
    print_step "Loading configuration"
    load_config
    
    print_step "Checking dependencies"
    check_dependencies
    
    validate_paths

    print_step "Pass 1: iCloud → Google Drive"
    rsync -a --delete --exclude '.*' "${ICLOUD_PATH}/" "${GOOGLE_DRIVE_PATH}/"
    log_message "INFO" "Completed rsync from iCloud to Google Drive."

    print_step "Pass 2: Google Drive → iCloud"
    rsync -a --delete --exclude '.*' "${GOOGLE_DRIVE_PATH}/" "${ICLOUD_PATH}/"
    log_message "INFO" "Completed rsync from Google Drive to iCloud."
    
    print_completed "Synchronization completed successfully"
    print_footer
}

# *
# * Main Execution
# *
main() {
    # Ensure the lock is removed on exit
    trap 'cleanup_lock' EXIT INT TERM

    ensure_log_directory
    log_message "INFO" "=== DLS Drive Sync starting ==="
    
    acquire_lock
    run_sync
    
    log_message "INFO" "=== DLS Drive Sync finished ==="
}

# --- Script Entrypoint ---
main "$@"