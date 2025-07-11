---
type: overview
domain: system-state
subject: DLS Sync Drives
status: active
summary: High-level architecture, key design decisions, and system-wide patterns for the DLS Sync Drives utility.
---
# System Patterns

## 1. System Architecture Overview

*   **Overall architecture & justification?** *(e.g., Monolithic, Microservices, Client-Server)*
    *   The project uses a simple, modular, script-based architecture. It consists of a primary orchestration script (`dls-sync-drives.sh`), two utility scripts for logging and messaging, a user-facing configuration file, and an installation script. This separation of concerns makes the system easy to understand, maintain, and configure. The architecture is justified by the project's focused scope; a more complex design would be overkill.

*   **High-Level Diagram Link (Recommended):**
    *   N/A

## 2. Key Architectural Decisions & Rationales

List significant decisions and why they were made.

*   **Decision 1:** Use `rsync` for file synchronization.
    *   **Rationale:** `rsync` is a powerful and ubiquitous tool on Unix-like systems. It is highly efficient for backups because it only transfers the differences between the source and destination (delta-transfer algorithm), saving bandwidth and time.
*   **Decision 2:** Externalize user settings into a `sync.config` file.
    *   **Rationale:** This separates the user's specific data (their directory paths) from the core application logic. This makes the script reusable for anyone and allows users to update their configuration without modifying the script itself, which also simplifies future updates to the script.
*   **Decision 3:** Use a `launchd` agent for automation on macOS.
    *   **Rationale:** `launchd` is the standard, modern way to run background services and scheduled tasks on macOS. It is more robust and efficient than older methods like `cron`. This choice firmly roots the tool in the macOS ecosystem but provides a reliable "set and forget" experience.
*   **Decision 4:** Provide a single `install.sh` script for setup.
    *   **Rationale:** To simplify the user experience. Instead of requiring the user to manually copy files, set permissions, and load the `launchd` service, a single script handles all these steps, reducing the chance of user error. The script is interactive, guiding the user and providing choices for optional components like the automation agent.
*   **Decision 5:** Refactor shared functions into utility scripts.
    *   **Rationale:** Centralizing logging and user-messaging functions into `logging_utils.sh` and `messaging_utils.sh` improves modularity and maintainability. It allows the main script to focus on the orchestration of the sync logic, making the code cleaner and easier to read.

## 3. Design Patterns in Use

List key software design patterns and where they are used.

*   **Pattern 1:** Separation of Concerns.
    *   **Example:** The project is divided into distinct components: Logic (`dls-sync-drives.sh`), Configuration (`sync.config`), and Installation (`install.sh`).
*   **Pattern 2:** Configuration File.
    *   **Example:** The `sync.config` file allows users to customize the behavior of the script without altering its source code.
*   **Pattern 3:** Modularity.
    *   **Example:** Common functions for logging and messaging are separated into utility scripts, which are then sourced by the main script.

## 4. Component Relationships & Interactions

Describe how major components interact.

*   **Interaction 1:** The `install.sh` script interactively guides the user. It sources the messaging utilities for output, copies the main script and `launchd` plist to system locations (`/usr/local/bin`, `~/Library/LaunchAgents`), and interacts with `launchctl` to optionally load and start the service.
*   **Interaction 2:** The `launchd` service, as defined by the `.plist` file, executes the `dls-sync-drives.sh` script at a scheduled interval.
*   **Interaction 3:** The `dls-sync-drives.sh` script reads the `sync.config` file to get the source and destination paths for its `rsync` command. It then executes `rsync` to perform the backup.
*   **Interaction 4:** The `dls-sync-drives.sh` script sources and calls functions from `scripts/utils/logging_utils.sh` and `scripts/utils/messaging_utils.sh` to handle all terminal output and file logging.

## 5. Data Management & Storage

*   **Primary Datastore & Rationale:**
    *   The user's local file system is the primary datastore.
        *   **Rationale:** The purpose of the application is to back up files from one location to another on the user's file system. No other database or storage system is needed.
*   **Data Schema Overview/Link:**
    *   N/A

## 6. Integration Points with External Systems

List external services/systems integrations.

*   **System 1:** The local file system, specifically the directories managed by cloud service providers (e.g., Google Drive, Dropbox, iCloud Drive). The script reads from these directories.
*   **System 2:** `launchd`, the macOS service manager. The script is managed as a service by `launchd`.

---
**How to Use This File Effectively:**
This document outlines the technical blueprint of the system. Refer to it for understanding architectural choices, design patterns, and how components interact. Update it when significant architectural decisions are made, new patterns are introduced, or data management strategies change. It is crucial for onboarding new developers and ensuring consistent technical approaches.
