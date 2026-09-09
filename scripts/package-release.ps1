<#
.SYNOPSIS
    Dong goi ban phat hanh Offline (MiTV-Vietnam-Full-Offline.zip)
.DESCRIPTION
    Script tu dong gom ma nguon, platform-tools va toan bo APKs thanh 1 file ZIP
    de dang len muc GitHub Releases.
#>

[CmdletBinding()]
param (
    [string]$Version = "v1.0.0"
)

$ScriptDir = $PSScriptRoot
$RepoRoot = (Get-Item $ScriptDir).Parent.FullName
$ReleaseDir = Join-Path $RepoRoot "release"
$StagingDir = Join-Path $ReleaseDir "staging"
$ApksSource = "C:\Users\locthanhit\Downloads\mitv_package_apks"
$ZipOutput  = Join-Path $ReleaseDir "MiTV-Vietnam-Full-Offline-$Version.zip"

Write-Host "Dang chuan bi thu muc dong goi..." -ForegroundColor Cyan
if (Test-Path $StagingDir) { Remove-Item $StagingDir -Recurse -Force }
New-Item -ItemType Directory -Path "$StagingDir\apks", "$StagingDir\bin\platform-tools", "$StagingDir\docs" -Force | Out-Null

Write-Host "Dang sao chep tep ma nguon..." -ForegroundColor Cyan
Copy-Item "$RepoRoot\setup.bat" $StagingDir
Copy-Item "$RepoRoot\setup.ps1" $StagingDir
Copy-Item "$RepoRoot\setup.sh" $StagingDir
Copy-Item "$RepoRoot\apps.json" $StagingDir
Copy-Item "$RepoRoot\README.md" $StagingDir
Copy-Item "$RepoRoot\LICENSE" $StagingDir
Copy-Item "$RepoRoot\docs\*" "$StagingDir\docs" -Recurse

Write-Host "Dang sao chep Google Platform-Tools (ADB)..." -ForegroundColor Cyan
$adbCandidates = @(
    "D:\tools\platform-tools",
    "C:\scrcpy-win64-v4.1",
    "C:\scrcpy"
)
$foundDir = $adbCandidates | Where-Object { Test-Path (Join-Path $_ "adb.exe") } | Select-Object -First 1
if ($foundDir) {
    Copy-Item (Join-Path $foundDir "adb.exe") "$StagingDir\bin\platform-tools"
    Copy-Item (Join-Path $foundDir "AdbWinApi.dll") "$StagingDir\bin\platform-tools" -ErrorAction SilentlyContinue
    Copy-Item (Join-Path $foundDir "AdbWinUsbApi.dll") "$StagingDir\bin\platform-tools" -ErrorAction SilentlyContinue
} else {
    Write-Host "Dang tai platform-tools tu Google..." -ForegroundColor Cyan
    $cacheDir = Join-Path $RepoRoot ".cache"
    if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null }
    $toolsZip = Join-Path $cacheDir "platform-tools.zip"
    if (-not (Test-Path $toolsZip)) {
        curl.exe -L -o $toolsZip "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    }
    Expand-Archive -Path $toolsZip -DestinationPath $cacheDir -Force
    Copy-Item (Join-Path $cacheDir "platform-tools\adb.exe") "$StagingDir\bin\platform-tools"
    Copy-Item (Join-Path $cacheDir "platform-tools\AdbWinApi.dll") "$StagingDir\bin\platform-tools" -ErrorAction SilentlyContinue
    Copy-Item (Join-Path $cacheDir "platform-tools\AdbWinUsbApi.dll") "$StagingDir\bin\platform-tools" -ErrorAction SilentlyContinue
}

if (Test-Path $ApksSource) {
    Write-Host "Dang sao chep cac goi APKs..." -ForegroundColor Cyan
    Copy-Item "$ApksSource\*" "$StagingDir\apks" -Force
}

Write-Host "Dang nen tep ZIP phat hanh ($ZipOutput)..." -ForegroundColor Green
if (-not (Test-Path $ReleaseDir)) { New-Item -ItemType Directory -Path $ReleaseDir -Force | Out-Null }
if (Test-Path $ZipOutput) { Remove-Item $ZipOutput -Force }
Compress-Archive -Path "$StagingDir\*" -DestinationPath $ZipOutput -CompressionLevel Fastest

# Copy sang thu muc goc de release.yml de dang nhan dien
Copy-Item $ZipOutput $RepoRoot -Force

Remove-Item $StagingDir -Recurse -Force
Write-Host "Hoan tat! File zip dong goi tai: $ZipOutput" -ForegroundColor Green
