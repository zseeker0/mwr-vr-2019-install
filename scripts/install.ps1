<#
.SYNOPSIS
Installs the verified 2019/1.15 Overlord mod files into a game folder.

.DESCRIPTION
Verifies the game executable, backs up existing files, copies the supplied
files, verifies their hashes, and switches the locale folder to English.
Nothing is overwritten before a backup is made.
#>
[CmdletBinding()]
param(
    [string] $GameDir = ''
)

$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$files = Join-Path $root 'files'

$expectedGameHash = '3d23e86930668244d43a026552d5e1298a7c8cc63b82a54a7ad857e7b41f9190'
$expectedGameSize = 20213128

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
Write-Host "GAME_DIR=$GameDir"

$exe = Join-Path $GameDir 'h1_sp64_ship.exe'
if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
    throw "Game executable not found: $exe"
}
$gameItem = Get-Item -LiteralPath $exe
if ($gameItem.Length -ne $expectedGameSize) {
    throw "Unexpected game executable size: $($gameItem.Length). This kit requires the 2019/1.15 build."
}
$gameHash = (Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash.ToLowerInvariant()
if ($gameHash -ne $expectedGameHash) {
    throw "Game executable hash mismatch. Expected $expectedGameHash, got $gameHash."
}
Write-Host 'GAME_IDENTITY=OK (2019/1.15)'

$stamp = Get-Date -Format 'yyyyMMddTHHmmss'
$backup = Join-Path $GameDir "overlord-preinstall-backup-$stamp"
New-Item -ItemType Directory -Path $backup | Out-Null

$rootFiles = @('overlord.exe', 'openxr_loader.dll', 'tlsdll.dll', 'overlord.vrmanifest')
foreach ($name in $rootFiles) {
    $target = Join-Path $GameDir $name
    if (Test-Path -LiteralPath $target) {
        Copy-Item -LiteralPath $target -Destination (Join-Path $backup $name) -Force
        Write-Host "BACKED_UP=$name"
    }
}

foreach ($name in $rootFiles) {
    Copy-Item -LiteralPath (Join-Path $files $name) -Destination (Join-Path $GameDir $name) -Force
    Write-Host "INSTALLED=$name"
}

foreach ($folder in @('vr_input', 'steamvr')) {
    $targetDir = Join-Path $GameDir $folder
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    $backupDir = Join-Path $backup $folder
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    foreach ($src in Get-ChildItem -LiteralPath (Join-Path $files $folder) -File) {
        $target = Join-Path $targetDir $src.Name
        if (Test-Path -LiteralPath $target) {
            Copy-Item -LiteralPath $target -Destination (Join-Path $backupDir $src.Name) -Force
        }
        Copy-Item -LiteralPath $src.FullName -Destination $target -Force
        Write-Host "INSTALLED=$folder\$($src.Name)"
    }
}

$expected = @{
    'overlord.exe'      = 'a5d5dc9c30156b3ed11bf5d9dc30180ada39341d08036b6d377ff041849d7956'
    'openxr_loader.dll' = 'a7569dc4e999e2664dd3145204e577095067ea2821de05e65fc0474a23b48e'
    'tlsdll.dll'        = 'b3aee5f09717b8570bfd2ff80a230e57abcdc6cfe85f781056b55f7558d09cd1'
}
foreach ($name in $expected.Keys) {
    $actual = (Get-FileHash -LiteralPath (Join-Path $GameDir $name) -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $expected[$name]) {
        throw "Hash verification failed for $name. Expected $($expected[$name]), got $actual."
    }
    Write-Host "VERIFIED=$name"
}

$zoneDir = Join-Path $GameDir 'zone'
$russian = Join-Path $zoneDir 'russian'
$disabled = Join-Path $zoneDir '_russian'
if (Test-Path -LiteralPath $russian -PathType Container) {
    Rename-Item -LiteralPath $russian -NewName '_russian'
    Write-Host 'LOCALE=English (zone\russian renamed to zone\_russian)'
} elseif (Test-Path -LiteralPath $disabled -PathType Container) {
    Write-Host 'LOCALE=English (already selected)'
} else {
    Write-Host 'LOCALE=unchanged (no russian folder found)'
}

Write-Host "BACKUP_DIR=$backup"
Write-Host 'INSTALL_OK'
