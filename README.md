# 🚀 Duplicate File Remover Pro V3.3 (Enterprise Edition)

> **Automated PowerShell WinForms GUI Tool** with SHA256 Cryptographic Fingerprinting, Smart Keep Filters, Safe Recycle Bin Purge, CSV Auditing, and Transactional Rollback Engine.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)
![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6?logo=windows)
![Version](https://img.shields.io/badge/version-3.3.0-brightgreen)

Developed by **Sachin Kumar Dhiman** for **[Inside The System](https://youtube.com)**.

---

## 🌟 Key Features

* 🔒 **100% SHA256 Cryptographic Accuracy:** Scans file bit-streams (SHA256) instead of relying on file names or extensions. Detects exact duplicates even if renamed.
* 🖤 **Modern Dark Theme WinForms GUI:** Built with a native PowerShell GUI—no third-party runtime or installer needed.
* 🧠 **Smart Auto-Select Rules:** 1-click filters to automatically preserve the **Oldest** or **Newest** file copy across all duplicate clusters.
* 📊 **Live Dynamic Capacity Preview:** Real-time calculator showing marked files and reclaimable megabytes before running any delete action.
* ♻️ **Dual Safety Mechanism:**
  * **[SAFE] Trash Bin Purge:** Integrates directly with Microsoft VisualBasic shell to send files to the native Windows Recycle Bin.
  * **[SECURE] Move to Vault:** Moves flagged duplicates to `Desktop\DuplicateVault` for quarantine.
* 🔄 **Transactional Session Undo Engine:** Built-in mechanical rollback button `$btnUndo` reads session logs to instantly restore Vault-isolated files to their original directories.
* 📑 **CSV Audit Exporter:** Exports complete duplicate cluster reports (SHA256 hashes, file paths, sizes, creation dates) to `Desktop\DuplicateAuditReport.csv`.

---

## 📸 Interface Preview

*(Upload a screenshot of your running app as `assets/app_preview.png` in your repository)*

---

## ⚡ Quick Start / Installation

### Prerequisites
* **OS:** Windows 10 / Windows 11
* **Environment:** PowerShell 5.1 or later (Pre-installed on Windows)

### Running the Tool
1. Download the latest `DuplicateRemoverPro_v3.3.ps1` from the [Releases](../../releases) section.
2. Right-click the file and select **Run with PowerShell**.
   *(If prompted with execution policy restrictions, open PowerShell as Administrator and run `Set-ExecutionPolicy Unrestricted -Scope Process`)*.
3. Select your target folder using **Browse Folder** and hit **Analyze Content**.

---

## 🛠️ How the Undo Engine Works

The V3.3 release features a full mechanical **Reverse Session Rollback**:
1. When files are quarantined using **Move to Vault**, full file tracking is appended to `Desktop\DuplicateCleanupLog.txt`.
2. Clicking **[UNDO] Reverse Session** parses the log, recreates original directory structures if missing, and moves files back to their original locations.

---

## 📋 Audit Logging

All file operations generate detailed logs on your desktop:
* **Action Logs:** `C:\Users\<User>\Desktop\DuplicateCleanupLog.txt`
* **CSV Exports:** `C:\Users\<User>\Desktop\DuplicateAuditReport.csv`

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

### 🎥 Watch Full Video Tutorial & Code Walkthrough
Check out the full episode on YouTube: **[Inside The System Channel](https://youtube.com)**
