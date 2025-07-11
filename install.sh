#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# Author: Benjamin Pequet
# Purpose: Installs the DLS Sync Drives utility, including the main script
#          and an optional launchd agent for automated execution.
# Project: https://github.com/pequet/dls-sync-drives

# --- Source Utilities ---
# Resolve the true directory of this install script to find project files
INSTALL_SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${INSTALL_SCRIPT_DIR}/scripts/utils/logging_utils.sh"
source "${INSTALL_SCRIPT_DIR}/scripts/utils/messaging_utils.sh"

# Set a log file path for the installer
LOG_FILE_PATH="${INSTALL_SCRIPT_DIR}/logs/install.log"


# --- Main Installation Logic ---
main() {
    print_header "DLS Sync Drives Installer"

    # --- Define Paths ---
    # Script paths
    SOURCE_SCRIPT_NAME="dls-sync-drives.sh"
    SOURCE_SCRIPT_PATH="${INSTALL_SCRIPT_DIR}/scripts/${SOURCE_SCRIPT_NAME}"
    DEST_DIR="/usr/local/bin"
    DEST_PATH="${DEST_DIR}/${SOURCE_SCRIPT_NAME}"

    # Config paths
    CONFIG_SOURCE_PATH="${INSTALL_SCRIPT_DIR}/scripts/sync.config.example"
    CONFIG_DEST_PATH="${INSTALL_SCRIPT_DIR}/scripts/sync.config"

    # Plist paths
    PLIST_NAME="com.pequet.dlssyncdrives.plist"
    PLIST_SOURCE_PATH="${INSTALL_SCRIPT_DIR}/assets/${PLIST_NAME}"
    PLIST_DEST_DIR="${HOME}/Library/LaunchAgents"
    PLIST_DEST_PATH="${PLIST_DEST_DIR}/${PLIST_NAME}"


    # --- Step 1: Verify files ---
    print_step "Step 1: Verifying required files"
    if [[ ! -f "$SOURCE_SCRIPT_PATH" || ! -f "$PLIST_SOURCE_PATH" || ! -f "$CONFIG_SOURCE_PATH" ]]; then
        print_error "One or more required source files not found. Installation cannot proceed."
        exit 1
    fi
    print_success "All source files found."


    # --- Step 2: Set up configuration ---
    print_step "Step 2: Setting up configuration file"
    if [ ! -f "$CONFIG_DEST_PATH" ]; then
        print_step "Configuration file not found, creating from example..."
        cp "$CONFIG_SOURCE_PATH" "$CONFIG_DEST_PATH"
        print_success "Created ${CONFIG_DEST_PATH}"
        print_info "IMPORTANT: You must edit this file with your correct iCloud and Google Drive paths."
    else
        print_success "Configuration file already exists at ${CONFIG_DEST_PATH}"
        print_info "Please ensure it is configured correctly."
    fi


    # --- Step 3: Install the main script ---
    print_step "Step 3: Installing the main script"
    print_step "Attempting to create a symbolic link from ${SOURCE_SCRIPT_PATH} to ${DEST_PATH}"
    print_info "This will make the 'dls-sync-drives.sh' command available globally."
    print_info "You may be prompted for your administrator password."

    if ! sudo ln -sf "$SOURCE_SCRIPT_PATH" "$DEST_PATH"; then
        print_error "Failed to create symbolic link. Please check permissions for ${DEST_DIR}."
        exit 1
    fi
    print_success "Script installed successfully."


    # --- Step 4: Install launchd Agent for Automation ---
    print_step "Step 4: Installing Automation Agent (Optional)"
    print_info "This will install a launchd agent to run the sync script automatically every 2 hours."
    read -p "  > Do you want to install the automation agent? (y/N): " choice
    case "$choice" in
      y|Y )
        print_step "Installing launchd agent..."
        
        # Ensure destination directory exists
        mkdir -p "${PLIST_DEST_DIR}"
        
        print_step "Copying plist file to ${PLIST_DEST_PATH}"
        cp "${PLIST_SOURCE_PATH}" "${PLIST_DEST_PATH}"

        # Unload first in case it's already running from a previous installation
        print_step "Unloading existing agent (if any)..."
        launchctl unload "${PLIST_DEST_PATH}" >/dev/null 2>&1 || true

        print_step "Loading new agent..."
        if ! launchctl load "${PLIST_DEST_PATH}"; then
            print_error "Failed to load launchd agent. Please check for errors."
            exit 1
        fi
        
        print_success "Automation agent installed and loaded."
        print_info "The sync will now run automatically."
        ;;
      * )
        print_info "Skipping installation of the automation agent."
        print_info "You can run the sync manually at any time by typing: dls-sync-drives.sh"
        ;;
    esac

    print_separator
    print_completed "Installation Complete"
    print_info "Review the README.md for instructions and other details."
    print_info "Thank you for using DLS Sync Drives!"
    print_footer
}

# --- Script Entrypoint ---
main "$@" 