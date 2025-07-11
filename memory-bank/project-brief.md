---
type: overview
domain: system-state
subject: DLS Sync Drives
status: active
summary: Core project goals, requirements, and scope for the DLS Sync Drives utility.
---
# Project Brief

## 1. Project Goal

*   **Primary Objective:** To provide a simple, reliable, and automated way to back up specified cloud drive folders to a local directory on macOS.

*   **Secondary Objectives (Optional):**
    *   To create a "set it and forget it" solution using a `launchd` agent for scheduled execution.
    *   To make the solution easily configurable via a separate configuration file.
    *   To provide a simple installation script to automate the setup process.

## 2. Core Requirements & Functionality

*   **Requirement 1:** A core shell script that performs synchronization using `rsync`.
*   **Requirement 2:** A configuration file to specify source and destination directories, making the script adaptable.
*   **Requirement 3:** An interactive installation script that places files in the correct locations, sets permissions, and optionally loads the `launchd` agent.
*   **Requirement 4:** A `launchd` property list (`.plist`) file to define the scheduled execution of the sync script.

## 3. Target Audience

*   macOS users who utilize various cloud storage services (like iCloud, Google Drive, Dropbox) and want a simple, automated method to maintain a local backup of their data on an external or internal drive.

## 4. Scope (Inclusions & Exclusions)

### In Scope:

*   Synchronization logic handled by a Bash script.
*   Configuration of source/destination paths via `sync.config`.
*   An installer script (`install.sh`) for macOS.
*   Scheduled execution via a macOS `launchd` agent.

### Out of Scope:

*   A graphical user interface (GUI).
*   Support for operating systems other than macOS.
*   Real-time (event-based) synchronization; the script runs on a defined schedule.
*   An uninstaller script (for the initial version).

## 5. Success Criteria & Key Performance Indicators (KPIs)

*   **Criteria 1:** Reliability - The script consistently and accurately backs up the specified files.
*   **Criteria 2:** Ease of Use - The user can set up the system by running a single, interactive installation script.
*   **Criteria 3:** Automation - Once installed, the system runs automatically without user intervention.

*   **KPI 1:** Successful installation and execution on a target machine.
*   **KPI 2:** Correct synchronization of files as verified by checking the destination directory.

## 6. Assumptions

*   Users are on a macOS system.
*   Users have `rsync` installed (which is standard on macOS).
*   Users are comfortable running a shell script from the terminal for installation.
*   The paths to common cloud drive services are relatively standard on macOS.

## 7. Constraints & Risks

*   **Constraint 1:** The solution is specific to the macOS ecosystem due to its reliance on `launchd`.
*   **Constraint 2:** Cloud service providers may change the default location of their sync folders, which would require users to update their `sync.config`.

*   **Risk 1:** The user might not have the correct permissions to run the installation script or to access the source/destination directories. (Mitigation: The installation script will use `sudo` for necessary steps and documentation will advise on permissions).

## 8. Stakeholders

*   **Project Sponsor:** Benjamin Pequet
*   **Product Owner:** Benjamin Pequet
*   **Lead Developer:** Benjamin Pequet
*   **Development Team Lead:** N/A
*   **Marketing Lead:** N/A
    
## Template Usage Notes

This `projectbrief.md` file, along with others in the `memory-bank/` directory, serves as a foundational part of the Memory Bank methodology. This system helps AI assistants maintain context and understanding across development sessions when working on a project initiated from this template.

