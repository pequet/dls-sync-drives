---
type: overview
domain: system-state
subject: DLS Sync Drives
status: active
summary: The problem, proposed solution, and user experience goals for the DLS Sync Drives utility.
---
# Product Context

## 1. Problem Statement

*   **Problem being solved for target audience?** *(Be specific)*
    *   Managing local backups for multiple cloud storage services (like iCloud, Google Drive, Dropbox) on macOS is a manual and often-forgotten task. Users need a simple, automated way to ensure their important cloud files are consistently backed up to a separate local or external drive.

*   **Importance/benefits of solving it?**
    *   Solving this provides data redundancy and peace of mind. It protects against data loss from accidental cloud deletion, account issues, or lack of internet access. It also simplifies the management of disparate cloud services into a single, unified backup location.

## 2. Proposed Solution

*   **How will this project solve the problem(s)?** *(Core concept)*
    *   This project provides a lightweight, script-based solution for macOS. It uses a core `rsync`-based shell script to efficiently mirror files from specified cloud drive directories to a single backup location. The process is automated via a `launchd` agent, making it a "set and forget" utility.

*   **Key features delivering the solution?**
    *   An `rsync`-powered script for efficient, differential backups.
    *   A simple, plain-text configuration file for defining source and destination paths.
    *   A `launchd` agent for scheduled, automated execution without user intervention.
    *   A one-step, interactive installation script (`install.sh`) to handle setup, permissions, and optional service loading.

## 3. How It Should Work (User Experience Goals)

*   **Ideal user experience?** *(What should it feel like?)*
    *   The user experience should feel simple and reliable. A user should be able to run a single command (`./install.sh`) which guides them through a clear, interactive setup. After that, it should work silently and efficiently in the background, giving them confidence that their files are being backed up without needing to think about it.

*   **Non-negotiable UX principles?**
    *   **Simplicity:** The installation and configuration process must be straightforward, requiring minimal technical knowledge beyond using the terminal.
    *   **Automation:** Once installed, the system must be fully automated. No daily user interaction should be required.
    *   **Transparency:** The scripts and configuration should be easy to read and understand for users who wish to inspect or modify them.

## 4. Unique Selling Proposition (USP)

*   **What makes this different or better than existing solutions?**
    *   Unlike complex, commercial backup software, this solution is free, open-source, and extremely lightweight. It leverages standard, reliable Unix tools (`rsync`, `launchd`) that are native to macOS, avoiding the need for heavy third-party applications. Its simplicity is its core strength.

*   **Core value proposition for the user?**
    *   A simple, free, and automated way to maintain local backups of your essential cloud drive data on macOS.

## 5. Assumptions About Users

*   **Assumptions about users' tech skills, motivations, technology access?**
    *   Users are on a macOS system.
    *   Users are comfortable opening the terminal and running a shell script for installation.
    *   Users are motivated to have local backups of their cloud data for security and accessibility.
    *   Users can edit a simple text file to configure their backup paths if the defaults are not suitable.

## 6. Success Metrics (Product-Focused)

*   **How to measure product's success in solving user problems?** *(User-centric KPIs)*
    *   **Adoption:** The tool is successfully installed and used by its target audience.
    *   **Reliability:** Users report that the backups run consistently as scheduled and correctly mirror their data.
    *   **Low Friction:** Few support requests related to installation or configuration issues.

---
**How to Use This File Effectively:**
This document defines *why* the product is being built and *what* it aims to achieve for the user. Update it when the understanding of the user problem, proposed solution, or core value proposition evolves. It provides crucial context for feature development and design decisions.
