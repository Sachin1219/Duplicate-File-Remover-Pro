<#
===============================================================================
PROJECT: Duplicate File Remover Pro (V3.3 Complete Enterprise Edition)
CHANNEL: Inside The System
AUTHOR: Sachin Kumar Dhiman
VERSION: 3.3.0 (1.1.2 Core Engine + Phase 3 + Complete Undo Rollback Engine)
DESCRIPTION: Full WinForms GUI built with custom SHA256 Hashing engine,
             Smart-Keep filters, dynamic capacity preview, transactional logging,
             CSV Audit Exporter, Windows Recycle Bin integration, and a full
             mechanical reverse-rollback system (Undo Feature for Vault moves).
===============================================================================
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic # For Windows Recycle Bin Integration

# =============================================================================
# 1. GLOBAL ENGINE MEMORY
# =============================================================================
$global:SelectedFolder = ""
$global:ScannedFilesMap = @{}      # Hash -> Array of File Paths
$global:DuplicateGroupsMap = @{}   # Hash -> Array of File Paths
$global:VaultPath = Join-Path $env:USERPROFILE "Desktop\DuplicateVault"
$global:LogPath = Join-Path $env:USERPROFILE "Desktop\DuplicateCleanupLog.txt"

# =============================================================================
# 2. APPLICATION FORMS SYSTEM SETUP (DARK MODE UI)
# =============================================================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Duplicate File Remover Pro V3.3 - Inside The System"
$form.Size = New-Object System.Drawing.Size(980, 720)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false

# Header Brand Label
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "DUPLICATE FILE REMOVER PRO // PHASE 3 ENTERPRISE V3.3"
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 162, 232)
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$lblTitle.Location = New-Object System.Drawing.Point(25, 20)
$lblTitle.AutoSize = $true
$form.Controls.Add($lblTitle)

# Target Directory Label
$lblFolderPath = New-Object System.Windows.Forms.Label
$lblFolderPath.Text = "Target Directory: No Target Folder Selected"
$lblFolderPath.ForeColor = [System.Drawing.Color]::LightGray
$lblFolderPath.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Italic)
$lblFolderPath.Location = New-Object System.Drawing.Point(25, 58)
$lblFolderPath.Width = 700
$lblFolderPath.Height = 25
$form.Controls.Add($lblFolderPath)

# =============================================================================
# 3. CONTROL PANEL BUTTONS
# =============================================================================
$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "Browse Folder"
$btnBrowse.Size = New-Object System.Drawing.Size(125, 35)
$btnBrowse.Location = New-Object System.Drawing.Point(25, 90)
$btnBrowse.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
$btnBrowse.ForeColor = [System.Drawing.Color]::White
$btnBrowse.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnBrowse.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnBrowse)

$btnScan = New-Object System.Windows.Forms.Button
$btnScan.Text = "Analyze Content"
$btnScan.Size = New-Object System.Drawing.Size(135, 35)
$btnScan.Location = New-Object System.Drawing.Point(160, 90)
$btnScan.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
$btnScan.ForeColor = [System.Drawing.Color]::White
$btnScan.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnScan.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnScan)

# Export CSV Report Button
$btnExportCSV = New-Object System.Windows.Forms.Button
$btnExportCSV.Text = "Export CSV Report"
$btnExportCSV.Size = New-Object System.Drawing.Size(145, 35)
$btnExportCSV.Location = New-Object System.Drawing.Point(305, 90)
$btnExportCSV.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 70)
$btnExportCSV.ForeColor = [System.Drawing.Color]::White
$btnExportCSV.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnExportCSV.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnExportCSV)

# Undo Reverse Session Button
$btnUndo = New-Object System.Windows.Forms.Button
$btnUndo.Text = "[UNDO] Reverse Session"
$btnUndo.Size = New-Object System.Drawing.Size(170, 35)
$btnUndo.Location = New-Object System.Drawing.Point(460, 90)
$btnUndo.BackColor = [System.Drawing.Color]::FromArgb(160, 70, 0)
$btnUndo.ForeColor = [System.Drawing.Color]::White
$btnUndo.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnUndo.FlatAppearance.BorderSize = 0
$btnUndo.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnUndo)

# Progress Layer
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(915, 15)
$progressBar.Location = New-Object System.Drawing.Point(25, 138)
$progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
$form.Controls.Add($progressBar)

# Status Engine Output
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "System Status: Ready - Enterprise V3.3 Core Engine Idle"
$lblStatus.ForeColor = [System.Drawing.Color]::DarkGray
$lblStatus.Location = New-Object System.Drawing.Point(25, 158)
$lblStatus.Width = 915
$form.Controls.Add($lblStatus)

# =============================================================================
# 4. SECURE SCANNED LIST VISUAL GRID (CHECKED LISTBOX)
# =============================================================================
$listView = New-Object System.Windows.Forms.CheckedListBox
$listView.Size = New-Object System.Drawing.Size(915, 330)
$listView.Location = New-Object System.Drawing.Point(25, 185)
$listView.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 26)
$listView.ForeColor = [System.Drawing.Color]::White
$listView.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$listView.CheckOnClick = $true
$form.Controls.Add($listView)

# =============================================================================
# 5. SMART RULE LAYER (PANEL DESIGN)
# =============================================================================
$pnlSmartRules = New-Object System.Windows.Forms.Panel
$pnlSmartRules.Size = New-Object System.Drawing.Size(915, 45)
$pnlSmartRules.Location = New-Object System.Drawing.Point(25, 530)
$pnlSmartRules.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 36)
$form.Controls.Add($pnlSmartRules)

$btnSelectAll = New-Object System.Windows.Forms.Button
$btnSelectAll.Text = "Select All Duplicates"
$btnSelectAll.Size = New-Object System.Drawing.Size(160, 30)
$btnSelectAll.Location = New-Object System.Drawing.Point(10, 7)
$btnSelectAll.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnSelectAll.ForeColor = [System.Drawing.Color]::White
$btnSelectAll.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$pnlSmartRules.Controls.Add($btnSelectAll)

$btnDeselectAll = New-Object System.Windows.Forms.Button
$btnDeselectAll.Text = "Clear Selection"
$btnDeselectAll.Size = New-Object System.Drawing.Size(140, 30)
$btnDeselectAll.Location = New-Object System.Drawing.Point(180, 7)
$btnDeselectAll.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnDeselectAll.ForeColor = [System.Drawing.Color]::White
$btnDeselectAll.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$pnlSmartRules.Controls.Add($btnDeselectAll)

$btnKeepOldest = New-Object System.Windows.Forms.Button
$btnKeepOldest.Text = "Smart: Keep Oldest"
$btnKeepOldest.Size = New-Object System.Drawing.Size(180, 30)
$btnKeepOldest.Location = New-Object System.Drawing.Point(330, 7)
$btnKeepOldest.BackColor = [System.Drawing.Color]::FromArgb(45, 65, 45)
$btnKeepOldest.ForeColor = [System.Drawing.Color]::LightGreen
$btnKeepOldest.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$pnlSmartRules.Controls.Add($btnKeepOldest)

$btnKeepNewest = New-Object System.Windows.Forms.Button
$btnKeepNewest.Text = "Smart: Keep Newest"
$btnKeepNewest.Size = New-Object System.Drawing.Size(180, 30)
$btnKeepNewest.Location = New-Object System.Drawing.Point(520, 7)
$btnKeepNewest.BackColor = [System.Drawing.Color]::FromArgb(45, 65, 45)
$btnKeepNewest.ForeColor = [System.Drawing.Color]::LightGreen
$btnKeepNewest.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$pnlSmartRules.Controls.Add($btnKeepNewest)

# =============================================================================
# 6. STORAGE RECLAIM CONTROL PANEL
# =============================================================================
$lblPreviewStats = New-Object System.Windows.Forms.Label
$lblPreviewStats.Text = "Live Preview: 0 Redundant Files Marked - 0.00 MB Storage Ready to Clean"
$lblPreviewStats.ForeColor = [System.Drawing.Color]::FromArgb(255, 128, 0)
$lblPreviewStats.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$lblPreviewStats.Location = New-Object System.Drawing.Point(25, 590)
$lblPreviewStats.Width = 510
$form.Controls.Add($lblPreviewStats)

$btnQuarantine = New-Object System.Windows.Forms.Button
$btnQuarantine.Text = "[SECURE] Move to Vault"
$btnQuarantine.Size = New-Object System.Drawing.Size(180, 40)
$btnQuarantine.Location = New-Object System.Drawing.Point(545, 590)
$btnQuarantine.BackColor = [System.Drawing.Color]::FromArgb(200, 120, 0)
$btnQuarantine.ForeColor = [System.Drawing.Color]::White
$btnQuarantine.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnQuarantine.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnQuarantine)

$btnDelete = New-Object System.Windows.Forms.Button
$btnDelete.Text = "[SAFE] Trash Bin Purge"
$btnDelete.Size = New-Object System.Drawing.Size(185, 40)
$btnDelete.Location = New-Object System.Drawing.Point(755, 590)
$btnDelete.BackColor = [System.Drawing.Color]::DarkRed
$btnDelete.ForeColor = [System.Drawing.Color]::White
$btnDelete.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnDelete.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnDelete)

# =============================================================================
# 7. AUTOMATION ENGINE LOGIC EVENTS
# =============================================================================

function Update-LiveStatsDisplay {
    $totalSelectedBytes = 0
    $selectedCount = 0

    for ($i = 0; $i -lt $listView.Items.Count; $i++) {
        if ($listView.GetItemChecked($i)) {
            $itemText = $listView.Items[$i].ToString()
            if ($itemText -and -not ($itemText.StartsWith("---"))) {
                if (Test-Path $itemText) {
                    $fileObj = Get-Item -Path $itemText
                    $totalSelectedBytes += $fileObj.Length
                    $selectedCount++
                }
            }
        }
    }

    $reclaimedMB = [math]::Round($totalSelectedBytes / 1MB, 2)
    $lblPreviewStats.Text = "Live Preview: {0} Redundant Files Marked - {1} MB Ready to Clean" -f $selectedCount, $reclaimedMB
}

$listView.add_ItemCheck({
    $form.BeginInvoke([Action]{ Update-LiveStatsDisplay })
})

# Event 1: Folder Selection Dialog
$btnBrowse.Add_Click({
    $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderDialog.Description = "Select target directory for duplicate hashing analysis"
    if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:SelectedFolder = $folderDialog.SelectedPath
        $lblFolderPath.Text = "Target Directory: " + $global:SelectedFolder
        $lblStatus.Text = "System Status: Target Confirmed. Ready to run cryptographic engine."
    }
})

# Cryptographic Fingerprint Hashing Engine (V1.1.2 Stream Core)
function Get-CryptographicFingerprint($filePath) {
    try {
        $stream = [System.IO.File]::OpenRead($filePath)
        $sha = New-Object System.Security.Cryptography.SHA256Managed
        $hashBytes = $sha.ComputeHash($stream)
        $stream.Close()
        $stream.Dispose()
        return [System.BitConverter]::ToString($hashBytes).Replace("-", "")
    }
    catch {
        return $null
    }
}

# Event 2: System File Scanner Execution (V1.1.2 Detection Engine)
$btnScan.Add_Click({
    if (-not $global:SelectedFolder -or -not (Test-Path $global:SelectedFolder)) {
        [System.Windows.Forms.MessageBox]::Show("Operation Denied: Please map a valid folder first.", "Core Engine Error")
        return
    }

    $listView.Items.Clear()
    $global:ScannedFilesMap.Clear()
    $global:DuplicateGroupsMap.Clear()
    $lblPreviewStats.Text = "Live Preview: 0 Redundant Files Marked - 0.00 MB Storage Ready to Clean"
    
    $lblStatus.Text = "Indexing storage structures recursively..."
    [System.Windows.Forms.Application]::DoEvents()

    $allFiles = Get-ChildItem -Path $global:SelectedFolder -Recurse -File -ErrorAction SilentlyContinue
    $totalFiles = $allFiles.Count

    if ($totalFiles -eq 0) {
        $lblStatus.Text = "Scan complete: No data payloads found."
        return
    }

    $processedCount = 0

    foreach ($file in $allFiles) {
        $processedCount++
        $lblStatus.Text = "Hashing target: " + $processedCount + " / " + $totalFiles + " -> " + $file.Name
        $progressBar.Value = [math]::Round(($processedCount / $totalFiles) * 100)
        [System.Windows.Forms.Application]::DoEvents()

        if ($file.Length -eq 0) { continue } # Skip empty zero-byte files

        $fileHash = Get-CryptographicFingerprint $file.FullName
        if ($fileHash) {
            if ($global:ScannedFilesMap.ContainsKey($fileHash)) {
                $global:ScannedFilesMap[$fileHash] += $file.FullName
            } else {
                $global:ScannedFilesMap[$fileHash] = @($file.FullName)
            }
        }
    }

    # Filter maps to populate view structures
    $groupUID = 1
    foreach ($hash in $global:ScannedFilesMap.Keys) {
        if ($global:ScannedFilesMap[$hash].Count -gt 1) {
            $global:DuplicateGroupsMap[$hash] = $global:ScannedFilesMap[$hash]
            
            [void]$listView.Items.Add("--- DUPLICATE CLUSTER BLOCK #" + $groupUID + " [SHA256: " + $hash.Substring(0,8) + "...] ---")
            foreach ($filePath in $global:DuplicateGroupsMap[$hash]) {
                [void]$listView.Items.Add($filePath)
            }
            $groupUID++
        }
    }

    $lblStatus.Text = "Analysis Verified. Found " + $global:DuplicateGroupsMap.Count + " unique redundancy clusters."
    Update-LiveStatsDisplay
})

# Event 3: Selection Rules Automation Engine
$btnSelectAll.Add_Click({
    for ($i = 0; $i -lt $listView.Items.Count; $i++) {
        if (-not ($listView.Items[$i].ToString().StartsWith("---"))) {
            $listView.SetItemChecked($i, $true)
        }
    }
    Update-LiveStatsDisplay
})

$btnDeselectAll.Add_Click({
    for ($i = 0; $i -lt $listView.Items.Count; $i++) {
        $listView.SetItemChecked($i, $false)
    }
    Update-LiveStatsDisplay
})

$btnKeepOldest.Add_Click({
    for ($i = 0; $i -lt $listView.Items.Count; $i++) { $listView.SetItemChecked($i, $false) }
    
    foreach ($hash in $global:DuplicateGroupsMap.Keys) {
        $filesObjList = @()
        foreach ($p in $global:DuplicateGroupsMap[$hash]) {
            if (Test-Path $p) { $filesObjList += Get-Item -Path $p }
        }
        
        $sorted = $filesObjList | Sort-Object CreationTime
        if ($sorted.Count -gt 1) {
            for ($j = 1; $j -lt $sorted.Count; $j++) {
                $targetPath = $sorted[$j].FullName
                $idx = $listView.Items.IndexOf($targetPath)
                if ($idx -ge 0) { $listView.SetItemChecked($idx, $true) }
            }
        }
    }
    Update-LiveStatsDisplay
})

$btnKeepNewest.Add_Click({
    for ($i = 0; $i -lt $listView.Items.Count; $i++) { $listView.SetItemChecked($i, $false) }
    
    foreach ($hash in $global:DuplicateGroupsMap.Keys) {
        $filesObjList = @()
        foreach ($p in $global:DuplicateGroupsMap[$hash]) {
            if (Test-Path $p) { $filesObjList += Get-Item -Path $p }
        }
        
        $sorted = $filesObjList | Sort-Object CreationTime -Descending
        if ($sorted.Count -gt 1) {
            for ($j = 1; $j -lt $sorted.Count; $j++) {
                $targetPath = $sorted[$j].FullName
                $idx = $listView.Items.IndexOf($targetPath)
                if ($idx -ge 0) { $listView.SetItemChecked($idx, $true) }
            }
        }
    }
    Update-LiveStatsDisplay
})

function Get-CheckedPaths {
    $paths = @()
    for ($i = 0; $i -lt $listView.Items.Count; $i++) {
        if ($listView.GetItemChecked($i)) {
            $line = $listView.Items[$i].ToString()
            if ($line -and -not ($line.StartsWith("---"))) { $paths += $line }
        }
    }
    return $paths
}

# Event 4: Safe Recycle Bin Purge
$btnDelete.Add_Click({
    $targets = Get-CheckedPaths
    if ($targets.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Wipe Manifest Empty. Please mark items manually or apply smart filters.", "Execution Interrupted")
        return
    }

    $msgText = "SAFETY RECYCLE PURGE: " + $targets.Count + " verified files will be safely sent to Windows Recycle Bin. Proceed?"
    $confirm = [System.Windows.Forms.MessageBox]::Show($msgText, "Confirm Storage Purge", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
        $success = 0
        $initLog = "=== RECYCLE BIN PURGE CYCLE " + (Get-Date).ToString() + " ==="
        Add-Content -Path $global:LogPath -Value $initLog
        
        foreach ($path in $targets) {
            try {
                if (Test-Path $path) {
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(
                        $path,
                        'OnlyErrorDialogs',
                        'SendToRecycleBin'
                    )
                    Add-Content -Path $global:LogPath -Value ("[RECYCLED] -> " + $path)
                    $success++
                }
            } catch {
                Add-Content -Path $global:LogPath -Value ("[CRITICAL FAILURE] -> " + $path + " | Reason: " + $_)
            }
        }
        $outMsg = "Process Complete.`nMoved to Recycle Bin: " + $success + " files.`nTracking reports updated at Desktop\DuplicateCleanupLog.txt"
        [System.Windows.Forms.MessageBox]::Show($outMsg, "Execution Summary")
        $btnScan.PerformClick()
    }
})

# Event 5: Quarantine Vault System Sequence
$btnQuarantine.Add_Click({
    $targets = Get-CheckedPaths
    if ($targets.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Vault Target Manifest Empty. Please select files first.", "Vault Suspended")
        return
    }

    if (-not (Test-Path $global:VaultPath)) {
        New-Item -ItemType Directory -Path $global:VaultPath -Force | Out-Null
    }

    $success = 0
    $initLog = "=== STORAGE VAULT QUARANTINE CYCLE " + (Get-Date).ToString() + " ==="
    Add-Content -Path $global:LogPath -Value $initLog

    foreach ($path in $targets) {
        try {
            if (Test-Path $path) {
                $fileObj = Get-Item -Path $path
                $vaultTarget = Join-Path $global:VaultPath ($fileObj.BaseName + "_" + (Get-Random).ToString() + $fileObj.Extension)
                Move-Item -Path $path -Destination $vaultTarget -Force -ErrorAction Stop
                Add-Content -Path $global:LogPath -Value ("[SUCCESS SECURED TO VAULT] -> " + $path + " moved to " + $vaultTarget)
                $success++
            }
        } catch {
            Add-Content -Path $global:LogPath -Value ("[VAULT RETRY FAILURE] -> " + $path + " | Reason: " + $_)
        }
    }
    $outMsg = "Quarantine Sequence Complete.`nIsolated: " + $success + " files inside Desktop\DuplicateVault.`nLogs saved successfully."
    [System.Windows.Forms.MessageBox]::Show($outMsg, "Vault Engine Complete")
    $btnScan.PerformClick()
})

# Event 6: CSV Audit Report Export
$btnExportCSV.Add_Click({
    if ($global:DuplicateGroupsMap.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No duplicate analysis data to export. Run an analysis scan first.", "Export Error")
        return
    }

    $csvPath = Join-Path $env:USERPROFILE "Desktop\DuplicateAuditReport.csv"
    $reportData = @()

    foreach ($hash in $global:DuplicateGroupsMap.Keys) {
        foreach ($filePath in $global:DuplicateGroupsMap[$hash]) {
            if (Test-Path $filePath) {
                $f = Get-Item $filePath
                $reportData += [PSCustomObject]@{
                    SHA256Hash   = $hash
                    FileName     = $f.Name
                    FilePath     = $f.FullName
                    SizeBytes    = $f.Length
                    SizeMB       = [math]::Round($f.Length / 1MB, 2)
                    CreatedTime  = $f.CreationTime
                    LastModified = $f.LastWriteTime
                }
            }
        }
    }

    $reportData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    [System.Windows.Forms.MessageBox]::Show("Audit Manifest Exported Successfully!`nSaved to: $csvPath", "Phase 3 Export Complete")
})

# Event 7: Transactional Session Rollback (Undo Engine)
$btnUndo.Add_Click({
    if (-not (Test-Path $global:LogPath)) {
        [System.Windows.Forms.MessageBox]::Show("No action log found at Desktop\DuplicateCleanupLog.txt. Nothing to undo.", "Undo Engine Notice")
        return
    }

    $logLines = Get-Content -Path $global:LogPath
    $vaultEntries = $logLines | Where-Object { $_ -like "*[SUCCESS SECURED TO VAULT]*" }

    if (-not $vaultEntries -or $vaultEntries.Count -eq 0) {
        $msg = "No recoverable Vault entries found in log.`n`nNote: Files moved to Windows Recycle Bin must be restored manually from the Recycle Bin."
        [System.Windows.Forms.MessageBox]::Show($msg, "Undo Engine Notice")
        return
    }

    $confirmMsg = "Found " + $vaultEntries.Count + " Vault-isolated files in log history.`nDo you want to restore them to their original paths?"
    $confirm = [System.Windows.Forms.MessageBox]::Show($confirmMsg, "Confirm Session Rollback", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

    if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
        $restoredCount = 0
        $failedCount = 0

        foreach ($entry in $vaultEntries) {
            # Parse pattern: [SUCCESS SECURED TO VAULT] -> C:\Original\Path.ext moved to C:\Desktop\DuplicateVault\Path_123.ext
            if ($entry -match '\[SUCCESS SECURED TO VAULT\] -> (.*) moved to (.*)') {
                $originalPath = $matches[1].Trim()
                $vaultFilePath = $matches[2].Trim()

                if (Test-Path $vaultFilePath) {
                    try {
                        # Re-create parent directory structure if missing
                        $targetDir = [System.IO.Path]::GetDirectoryName($originalPath)
                        if (-not (Test-Path $targetDir)) {
                            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                        }

                        Move-Item -Path $vaultFilePath -Destination $originalPath -Force -ErrorAction Stop
                        $restoredCount++
                    } catch {
                        $failedCount++
                    }
                }
            }
        }

        # Log rollback execution details
        Add-Content -Path $global:LogPath -Value ("=== SESSION ROLLBACK EXECUTED AT " + (Get-Date).ToString() + " | Restored: " + $restoredCount + " ===")

        $resultMsg = "Rollback Execution Complete!`n`nSuccessfully Restored: " + $restoredCount + " files"
        if ($failedCount -gt 0) {
            $resultMsg += "`nFailed / Missing in Vault: " + $failedCount + " files"
        }
        [System.Windows.Forms.MessageBox]::Show($resultMsg, "Undo Complete")

        # Refresh scan if target folder is mapped
        if ($global:SelectedFolder -and (Test-Path $global:SelectedFolder)) {
            $btnScan.PerformClick()
        }
    }
})

# Environment Boot Frame
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()