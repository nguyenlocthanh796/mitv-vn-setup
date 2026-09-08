<#
.SYNOPSIS
    Dong goi ban phat hanh Offline (MiTV-Vietnam-Full-Offline.zip)
.DESCRIPTION
    Script tu dong gom ma nguon, platform-tools va toan bo APKs thanh 1 file ZIP
    de dang len muc GitHub Releases.
#>

$RepoRoot = $PSScriptRoot
$ReleaseDir = Join-Path $RepoRoot "release"
$StagingDir = Join-Path $ReleaseDir "staging"
$ApksSource = "C:\Users\locthanhit\Downloads\mitv_package_apks"
$ZipOutput  = Join-Path $ReleaseDir "MiTV-Vietnam-Full-Offline-v1.0.0.zip"

Write-Host "Dang chuan bi thu muc dong goi..." -ForegroundColor Cyan
if (Test-Path $StagingDir) { Remove-Item $StagingDir -Recurse -Force }
New-Item -ItemType Directory -Path "$StagingDir\apks", "$StagingDir\bin\platform-tools" -Force | Out-Null

Write-Host "Dang sao chep tep ma nguon..." -ForegroundColor Cyan
Copy-Item "$RepoRoot\setup.bat" $StagingDir
Copy-Item "$RepoRoot\setup.ps1" $StagingDir
Copy-Item "$RepoRoot\setup.sh" $StagingDir
Copy-Item "$RepoRoot\apps.json" $StagingDir
Copy-Item "$RepoRoot\README.md" $StagingDir
Copy-Item "$RepoRoot\LICENSE" $StagingDir

Write-Host "Dang sao chep Google Platform-Tools (ADB)..." -ForegroundColor Cyan
Copy-Item "D:\tools\platform-tools\adb.exe" "$StagingDir\bin\platform-tools"
Copy-Item "D:\tools\platform-tools\AdbWinApi.dll" "$StagingDir\bin\platform-tools" -ErrorAction SilentlyContinue
Copy-Item "D:\tools\platform-tools\AdbWinUsbApi.dll" "$StagingDir\bin\platform-tools" -ErrorAction SilentlyContinue

Write-Host "Dang sao chep cac goi APKs..." -ForegroundColor Cyan
Copy-Item "$ApksSource\*" "$StagingDir\apks" -Force

Write-Host "Dang nen tep ZIP phat hanh ($ZipOutput)..." -ForegroundColor Green
if (Test-Path $ZipOutput) { Remove-Item $ZipOutput -Force }
Compress-Archive -Path "$StagingDir\*" -DestinationPath $ZipOutput -CompressionLevel Fastest

Remove-Item $StagingDir -Recurse -Force
Write-Host "Hoan tat! File zip dong goi tai: $ZipOutput" -ForegroundColor Green
