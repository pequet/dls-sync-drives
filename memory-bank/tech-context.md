---
type: overview
domain: system-state
subject: DLS Sync Drives
status: active
summary: Technologies, setup, and technical constraints of the DLS Sync Drives project.
---
# Technical Context

## 1. Technologies Used
List significant technologies, frameworks, libraries, tools.

*   **Core Logic:**
    *   Bash (Shell Scripting)
    *   `rsync`
*   **Automation/Scheduling:**
    *   `launchd` (macOS service manager)
    *   Property Lists (`.plist`)
*   **Installation:**
    *   Bash (Shell Scripting)
    *   Shared utilities for messaging (`messaging_utils.sh`)
*   **Version Control:**
    *   Git

## 2. Development Setup & Environment
How to set up the dev environment.

*   **Prerequisites:**
    *   A computer running macOS.
    *   Standard Unix command-line tools (which are included with macOS), especially `rsync`.
    *   A text editor for editing shell scripts and configuration files (e.g., VS Code, Sublime Text, Vim).
    *   Git for version control.
*   **Setup Steps:**
    1.  Clone the repository to a local directory.
    2.  No special dependencies need to be installed, as the installer handles setup.
    3.  Development involves editing the main scripts (`dls-sync-drives.sh`, `install.sh`), the utility scripts in `scripts/utils/`, and the `com.pequet.dlssyncdrives.plist` file.
    4.  Testing is done by running the interactive `./install.sh` script and verifying its different paths (e.g., accepting or declining the `launchd` agent installation).

## 3. Technical Constraints
List known technical limitations.

*   **Platform Dependency:** The entire solution is designed exclusively for macOS and will not work on Windows or Linux without significant modification, primarily because `launchd` is a macOS-specific technology.
*   **Path Unpredictability:** The default paths for cloud services (e.g., `~/Library/CloudStorage/`) can vary between macOS versions or user configurations, potentially requiring manual adjustments in the `sync.config` file.
*   **Error Handling:** The script has basic error handling. It might not gracefully handle all edge cases, such as a destination drive being unavailable.

## 4. Dependencies & Integrations (Technical Details)
Key technical details for dependencies/integrations.

*   **`rsync`:** The core of the sync operation. The script relies on `rsync`'s archive mode (`-a`), verbose output (`-v`), and other flags for efficient differential synchronization.
*   **`launchd`:** The macOS service manager is used for automation. The provided `.plist` file tells `launchd` to run the sync script every 7200 seconds (2 hours). This interval is a key part of the "set and forget" design.

## 5. Code & Branching Strategy
Describe the version control system, branching model, and code review process.

*   **VCS:** Git
*   **Hosting:** GitHub
*   **Branching Model:** Main branch development for a simple project like this. Feature branches can be used for significant changes.
*   **Commit Messages:** Adherence to Conventional Commits is encouraged.

## 6. Build & Deployment Process
Describe the build process, deployment pipeline, and hosting environment.

*   N/A - There is no "build" process for this project. "Deployment" is handled by the user running the `install.sh` script on their local machine.

---
**How to Use This File Effectively:**
This document details the technical landscape of your project. Use it to understand the tools, setup procedures, constraints, and deployment workflows. Keep it updated as new technologies are adopted, setup steps change, or the deployment process evolves. It's essential for developer onboarding and maintaining a shared understanding of the tech stack.
