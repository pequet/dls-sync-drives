# DLS Sync Drives

A robust script for bi-directionally synchronizing directories between iCloud Drive and Google Drive on macOS.

## Overview

`dls-sync-drives` is a shell script designed to create and maintain a mirror of a specified directory between a user's iCloud Drive and Google Drive. It is built to be robust, configurable, and easily automated to provide a seamless "set it and forget it" file synchronization experience.

The script is self-contained. It reads its configuration from a local file and stores logs in a directory alongside the script, making it portable and transparent.

## Architectural Context

While this script is a standalone tool, its full significance is best understood as part of a larger security architecture. Each DLS script serves as the practical implementation of a core security principle, from ensuring data integrity (`dls-icloud-backup-integrity`) and managing redundancy (`dls-sync-drives`) to securing critical assets (`dls-password-backup`). 

## Features

-   **Bi-Directional Synchronization:** Employs a two-pass `rsync` process to guarantee files are synchronized in both directions, ensuring a complete mirror.
-   **Safe File Accumulation:** Files from both locations are preserved and merged. Newer files overwrite older ones, but no files are automatically deleted.
-   **Local Configuration Management:** Configuration is handled via a `sync.config` file located in the same directory as the script. A `sync.config.example` is provided as a starting point.
-   **Comprehensive Local Logging:** Generates detailed, timestamped logs in a `logs` directory alongside the script, aiding in monitoring and troubleshooting. Logs include hostname and username for enhanced clarity.
-   **Concurrency Control:** Implements a file-based lock mechanism using `flock` to prevent multiple script instances from running concurrently, critical for scheduled executions.
-   **Robust Error Handling:** Performs thorough validation of configuration files, directory paths, and external dependencies (`rsync`, `flock`) before initiating synchronization, ensuring script stability.

## How Synchronization Works

The script performs a **safe, accumulative sync** in two passes:

1. **Pass 1**: Copies newer/missing files from iCloud → Google Drive
2. **Pass 2**: Copies newer/missing files from Google Drive → iCloud

### Key Behaviors:
- **File Preservation**: All files from both locations are preserved and merged
- **Newer Files Win**: If the same file exists in both locations, the one with the newer modification time overwrites the older one
- **No Automatic Deletion**: Files are never automatically deleted. If you delete a file from one location, you must manually delete it from the other location if desired
- **Safe for Different Content**: If iCloud has files A,B,C and Google Drive has files D,E,F, both locations will end up with files A,B,C,D,E,F

### Example Scenarios:
- **Empty destination**: Gets populated with all files from the source
- **Different files**: Both locations get all files from both sources  
- **Same filename, different dates**: Newer file overwrites older file in both locations
- **Deleted files**: Remain in the other location until manually removed

## Installation

This project includes an interactive installer to handle setup, but also supports a fully manual installation for advanced users.

### Step 1: Clone the Repository

First, clone this repository to a permanent location on your machine, as the scripts will run from here.

```bash
git clone https://github.com/pequet/dls-sync-drives.git
cd dls-sync-drives
```

### Step 2: Create and Edit Configuration

Copy the example configuration file. **This step is mandatory for all installation types.**

```bash
cp scripts/sync.config.example scripts/sync.config
```

Now, open `scripts/sync.config` in a text editor and update the paths to match your system. The default `ICLOUD_DIR_BASE` is standard for most macOS systems, but you **must** update `GOOGLE_DIR_BASE` with your own email address.

```bash
# Example sync.config
ICLOUD_DIR_BASE="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
GOOGLE_DIR_BASE="$HOME/Library/CloudStorage/GoogleDrive-[your-email-here]/My Drive"
SYNC_FOLDER_NAME=".DLS"
```

### Step 3: Choose Your Installation Method

#### Automated Installation (Recommended)

The installer script will make the main script globally available, create the initial configuration file if needed, and give you the option to set up the `launchd` agent for automatic execution.

1.  **Make the installer executable:**
    ```bash
    chmod +x install.sh
    ```
2.  **Run the installer:**
    ```bash
    ./install.sh
    ```
    The script will guide you through the process, asking for your administrator password to install the script to `/usr/local/bin` and asking if you want to set up the automation agent.

#### Manual Installation

If you prefer not to use the installer, follow these steps.

**1. Make the Script Globally Available (Optional)**

To run `dls-sync-drives.sh` from any directory, create a symbolic link in `/usr/local/bin`.

```bash
# Note: Get the absolute path to the script first
SCRIPT_PATH=$(pwd)/scripts/dls-sync-drives.sh
sudo ln -sf "$SCRIPT_PATH" /usr/local/bin/dls-sync-drives.sh
```

**2. Set Up Automation (Optional)**

You can choose either `launchd` (recommended for macOS) or a traditional `cron` job.

**Option A: Manual `launchd` Setup**

`launchd` is the modern and preferred way to run scheduled tasks on macOS.

1.  **Copy the `.plist` file** to your user's LaunchAgents directory:
    ```bash
    cp assets/com.pequet.dlssyncdrives.plist ~/Library/LaunchAgents/
    ```
    *(The provided `.plist` is already configured to use the `/usr/local/bin/dls-sync-drives.sh` path, assuming you completed step 1.)*

2.  **Load the `launchd` agent** to schedule the job:
    ```bash
    launchctl load ~/Library/LaunchAgents/com.pequet.dlssyncdrives.plist
    ```
    The script will now run automatically every 2 hours. You can trigger the first run immediately with:
    ```bash
    launchctl start com.pequet.dlssyncdrives
    ```

**Option B: Manual `cron` Setup**

If you prefer `cron`, you can add a job to your crontab.

1.  **Open your crontab** for editing:
    ```bash
    crontab -e
    ```

2.  **Add the cron job.** This example runs the script every 2 hours.
    ```bash
    0 */2 * * * /usr/local/bin/dls-sync-drives.sh
    ```
    *(This assumes you have made the script globally available as described above. If not, use the full, absolute path to `scripts/dls-sync-drives.sh`.)*

3.  **Save and exit** the editor. The cron job is now active.

## Manual Usage

Once installed, the script can be executed manually at any time from any directory:

```bash
dls-sync-drives.sh
```

Monitor the synchronization process by tailing the log file:

```bash
tail -f logs/sync.log
```

## Troubleshooting

- **Configuration Issues:**  Verify that `sync.config` exists and contains correct paths for iCloud and Google Drive. Ensure the specified directories exist.
- **Dependency Errors:** The script requires `rsync` and `flock`. Install them using Homebrew if they are not already available: `brew install rsync flock`.
- **Permission Problems:**  Ensure the script has execute permissions (`chmod +x scripts/dls-sync-drives.sh`).
- **Lock File Conflicts:**  If the script fails to start due to a lock file, check `/tmp/dls-sync-drives.lock`.  If the script is not running, you can manually remove the lock file.
- **Logging:**  Consult the `logs/sync.log` file for detailed information about script execution and any errors encountered.

## License

This project is licensed under the MIT License.

## Support the Project

If you find this project useful and would like to show your appreciation, you can:

- [Buy Me a Coffee](https://buymeacoffee.com/pequet)
- [Sponsor on GitHub](https://github.com/sponsors/pequet)
- [Deploy on DigitalOcean](https://www.digitalocean.com/?refcode=51594d5c5604) (affiliate link $) 

Your support helps in maintaining and improving this project. 

