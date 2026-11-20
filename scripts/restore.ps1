<#
.SYNOPSIS
Restores the mod files that were backed up by install.ps1.

.DESCRIPTION
Finds the newest overlord-preinstall-backup-* folder in the game directory and
copies its contents back over the installed files. Does not touch the game
executable, saves, or mod folders that were not backed up.
#>
[CmdletBinding()]
param([string] $GameDir = '', [string] $BackupName = '')

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($GameDir)) {
    Add-Type -AssemblyName System.Windows.Forms
    $picker = [System.Windows.Forms.FolderBrowserDialog]::new()
    $picker.Description = 'Select the game folder containing h1_sp64_ship.exe'
    if ($picker.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        throw 'No game folder selected.'
    }
    $GameDir = $picker.SelectedPath
}
$GameDir = (Resolve-Path $GameDir).Path

if ([string]::IsNullOrWhiteSpace($BackupName)) {
    $candidates = Get-ChildItem -LiteralPath $GameDir -Directory |
        Where-Object { $_.Name -like 'overlord-preinstall-backup-*' } |
        Sort-Object Name -Descending
    if (-not $candidates) { throw 'No install backup folder found.' }
    $backup = $candidates[0].FullName
} else {
    $backup = Join-Path $GameDir $BackupName
}
if (-not (Test-Path -LiteralPath $backup -PathType Container)) {
    throw "Backup folder not found: $backup"
}
Write-Host "BACKUP=$backup"

foreach ($item in Get-ChildItem -LiteralPath $backup -File) {
    Copy-Item -LiteralPath $item.FullName -Destination (Join-Path $GameDir $item.Name) -Force
    Write-Host "RESTORED=$($item.Name)"
}
foreach ($dir in Get-ChildItem -LiteralPath $backup -Directory) {
    foreach ($item in Get-ChildItem -LiteralPath $dir.FullName -File) {
        $targetDir = Join-Path $GameDir $dir.Name
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Copy-Item -LiteralPath $item.FullName -Destination (Join-Path $targetDir $item.Name) -Force
        Write-Host "RESTORED=$($dir.Name)\$($item.Name)"
    }
}

$zoneDir = Join-Path $GameDir 'zone'
$disabled = Join-Path $zoneDir '_russian'
$russian = Join-Path $zoneDir 'russian'
if ((Test-Path -LiteralPath $disabled -PathType Container) -and
    (-not (Test-Path -LiteralPath $russian -PathType Container))) {
    Rename-Item -LiteralPath $disabled -NewName 'russian'
    Write-Host 'LOCALE=restored (zone\_russian renamed back to zone\russian)'
}

Write-Host 'RESTORE_OK'
