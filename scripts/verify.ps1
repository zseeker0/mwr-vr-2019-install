<#
.SYNOPSIS
Checks that the verified 2019/1.15 mod files are installed correctly.
#>
[CmdletBinding()]
param([string] $GameDir = '')

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

$failures = 0

$game = Join-Path $GameDir 'h1_sp64_ship.exe'
if (Test-Path -LiteralPath $game -PathType Leaf) {
    $hash = (Get-FileHash -LiteralPath $game -Algorithm SHA256).Hash.ToLowerInvariant()
    $ok = $hash -eq '3d23e86930668244d43a026552d5e1298a7c8cc63b82a54a7ad857e7b41f9190'
    Write-Host "$(if ($ok) { 'PASS' } else { 'FAIL' })  game executable identity"
    if (-not $ok) { $failures++ }
} else {
    Write-Host 'FAIL  game executable missing'
    $failures++
}

$expected = @{
    'overlord.exe'      = 'a5d5dc9c30156b3ed11bf5d9dc30180ada39341d08036b6d377ff041849d7956'
    'openxr_loader.dll' = 'a7569dc4e999e2664dd3145204e577095067ea2821de05e65fc0474a23b48e'
    'tlsdll.dll'        = 'b3aee5f09717b8570bfd2ff80a230e57abcdc6cfe85f781056b55f7558d09cd1'
}
foreach ($name in $expected.Keys) {
    $path = Join-Path $GameDir $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Write-Host "FAIL  $name missing"
        $failures++
        continue
    }
    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    $ok = $hash -eq $expected[$name]
    Write-Host "$(if ($ok) { 'PASS' } else { 'FAIL' })  $name hash"
    if (-not $ok) { $failures++ }
}

$russian = Join-Path $GameDir 'zone\russian'
$disabled = Join-Path $GameDir 'zone\_russian'
if ((-not (Test-Path -LiteralPath $russian)) -and (Test-Path -LiteralPath $disabled)) {
    Write-Host 'PASS  English locale selected'
} else {
    Write-Host 'WARN  Russian locale folder is still active'
}

if ($failures -gt 0) {
    Write-Host "VERIFY_FAILED count=$failures"
    exit 1
}
Write-Host 'VERIFY_OK'
