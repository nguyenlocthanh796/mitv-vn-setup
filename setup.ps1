<#
.SYNOPSIS
    MiTV Vietnam Toolkit - Bo cai dat & quan ly ung dung 1-Click ADB cho Tivi Xiaomi
.DESCRIPTION
    Tu dong cai dat Projectivy Launcher, chan PatchWall, toi uu he thong,
    cai dat va nang cap tung ung dung truyen hinh/giai tri Viet Nam qua CDN GitHub Releases.
#>

[CmdletBinding()]
param (
    [string]$DeviceIp = "",
    [string]$Mode = "",
    [string]$Update = "",
    [switch]$UpdateAll = $false,
    [switch]$SkipApps = $false,
    [switch]$DebloatOnly = $false
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$RepoRoot = $PSScriptRoot
if (-not $RepoRoot) {
    $RepoRoot = Join-Path $env:TEMP "mitv-vn-setup"
}
$CacheDir = Join-Path $RepoRoot ".cache"
$BinDir   = Join-Path $RepoRoot "bin"
$ApksDir  = Join-Path $RepoRoot "apks"

if (-not (Test-Path $CacheDir)) { New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null }
if (-not (Test-Path $BinDir))   { New-Item -ItemType Directory -Path $BinDir -Force | Out-Null }
if (Test-Path $ApksDir) {
    Write-Host "[*] Phat hien goi cai dat Offline (apks/). Se uu tien su dung file san co!" -ForegroundColor Yellow
}

function Write-Step {
    param([string]$Msg)
    Write-Host "`n[+] $Msg" -ForegroundColor Green
}

function Write-Info {
    param([string]$Msg)
    Write-Host "    -> $Msg" -ForegroundColor Cyan
}

function Write-Warn {
    param([string]$Msg)
    Write-Host "    [!] $Msg" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Msg)
    Write-Host "    [X] $Msg" -ForegroundColor Red
}

Clear-Host
Write-Host @"
===================================================================
    MiTV Vietnam Toolkit - Setup & App Manager
    Giai phap toi uu & Viet hoa Tivi Xiaomi Noi Dia
===================================================================
"@ -ForegroundColor Cyan

# 1. Kiem tra va thiet lap cong cu ADB
Write-Step "Kiem tra moi truong ADB..."
$Adb = "adb"
$adbFound = Get-Command adb -ErrorAction SilentlyContinue

if (-not $adbFound) {
    $localAdb = Join-Path $BinDir "adb.exe"
    if (Test-Path $localAdb) {
        $Adb = $localAdb
        Write-Info "Su dung ADB tich hop san: $localAdb"
    } else {
        Write-Info "Dang tai Android Platform Tools ve may..."
        $adbZip = Join-Path $CacheDir "platform-tools.zip"
        curl.exe -L -o $adbZip "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($adbZip, $CacheDir)
        Copy-Item (Join-Path $CacheDir "platform-tools\adb.exe") $BinDir -Force
        Copy-Item (Join-Path $CacheDir "platform-tools\AdbWinApi.dll") $BinDir -Force
        Copy-Item (Join-Path $CacheDir "platform-tools\AdbWinUsbApi.dll") $BinDir -Force
        $Adb = $localAdb
        Write-Info "Da thiet lap ADB tai $BinDir"
    }
}

# 2. Ket noi toi Tivi Xiaomi
Write-Step "Ket noi toi Tivi Xiaomi..."
& $Adb start-server | Out-Null

$targetDevice = ""
if ($DeviceIp) {
    $targetDevice = if ($DeviceIp -match ":5555$") { $DeviceIp } else { "$DeviceIp`:5555" }
    Write-Info "Ket noi toi IP chi dinh: $targetDevice"
    & $Adb connect $targetDevice | Out-Null
} else {
    $devicesOutput = & $Adb devices
    $lines = $devicesOutput | Where-Object { $_ -match "\s+device$" }
    if ($lines.Count -eq 1) {
        $targetDevice = ($lines[0] -split "\s+")[0]
        Write-Info "Phat hien 1 thiet bi duy nhat: $targetDevice"
    } elseif ($lines.Count -gt 1) {
        Write-Host "`nDanh sach thiet bi ket noi:" -ForegroundColor Yellow
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $devName = ($lines[$i] -split "\s+")[0]
            Write-Host "  [$($i+1)] $devName"
        }
        $sel = Read-Host "Chon thiet bi (1-$($lines.Count))"
        $targetDevice = ($lines[[int]$sel - 1] -split "\s+")[0]
    }
}

if (-not $targetDevice) {
    $inputIp = Read-Host "Nhap dia chi IP cua Tivi Xiaomi (VD: 192.168.1.50)"
    if (-not $inputIp) { throw "Chua nhap IP. Huy tien trinh." }
    $targetDevice = if ($inputIp -match ":5555$") { $inputIp } else { "$inputIp`:5555" }
    Write-Info "Dang ket noi toi $targetDevice..."
    & $Adb connect $targetDevice | Out-Null
}

function Run-AdbShell {
    param([string]$Cmd)
    return (& $Adb -s $targetDevice shell $Cmd)
}

# 3. Kiem tra thong tin Tivi & Toi uu hoat anh
Write-Step "Danh thuc va toi uu toc do he thong..."
Run-AdbShell "input keyevent KEYCODE_WAKEUP" | Out-Null
$abi = (Run-AdbShell "getprop ro.product.cpu.abi").Trim()
$model = (Run-AdbShell "getprop ro.product.model").Trim()
$androidVer = (Run-AdbShell "getprop ro.build.version.release").Trim()
Write-Info "Model: $model | Android: $androidVer | CPU: $abi"

Run-AdbShell "settings put global window_animation_scale 0.5" | Out-Null
Run-AdbShell "settings put global transition_animation_scale 0.5" | Out-Null
Run-AdbShell "settings put global animator_duration_scale 0.5" | Out-Null

# 4. Cai dat Launcher neu chua co
$launcherInstalled = (Run-AdbShell "pm list packages com.spocky.projengmenu") -match "com.spocky.projengmenu"
if (-not $launcherInstalled) {
    Write-Step "Cai dat Projectivy Launcher (Chan PatchWall)..."
    $projectivyFile = Join-Path $CacheDir "ProjectivyLauncher.apk"
    $offlineProjectivy = Join-Path $ApksDir "ProjectivyLauncher.apk"

    if (Test-Path $offlineProjectivy) {
        $projectivyFile = $offlineProjectivy
    } elseif (-not (Test-Path $projectivyFile)) {
        Write-Info "Dang tai Projectivy Launcher tu GitHub Release..."
        curl.exe -L -s -o $projectivyFile "https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/ProjectivyLauncher.apk"
    }

    Write-Info "Dang cai dat Projectivy vao Tivi..."
    & $Adb -s $targetDevice install -r -g $projectivyFile | Out-Null
    Run-AdbShell "cmd package set-home-activity com.spocky.projhost/.ui.HomeActivity" | Out-Null
    Run-AdbShell "settings put secure enabled_accessibility_services com.spocky.projhost/.services.ProjectivyAccessibilityService" | Out-Null
    Run-AdbShell "settings put secure accessibility_enabled 1" | Out-Null
}

# 5. Cai dat / Cap nhat ung dung
if (-not $SkipApps -and -not $DebloatOnly) {
    $appsJsonPath = Join-Path $RepoRoot "apps.json"
    $appsConfig = $null
    if (Test-Path $appsJsonPath) {
        $appsConfig = Get-Content $appsJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
    }

    $isUpgradeMode = $false
    $targetApps = @()

    if ($UpdateAll) {
        $isUpgradeMode = $true
        $targetApps = $appsConfig.apps
    } elseif ($Update) {
        $isUpgradeMode = $true
        $targetApps = $appsConfig.apps | Where-Object { $_.id -eq $Update -or $_.package -eq $Update }
        if ($targetApps.Count -eq 0) {
            Write-Warn "Khong tim thay ung dung voi ID: $Update"
        }
    } else {
        # Menu chon che do
        Write-Host "`n----------------------------------------------------" -ForegroundColor Cyan
        Write-Host "       CHON CHE DO CAI DAT / NANG CAP UNG DUNG      " -ForegroundColor Yellow
        Write-Host "----------------------------------------------------" -ForegroundColor Cyan
        Write-Host "  [1] Cai DAY DU (15 app truyen hinh, phim, Youtube)" -ForegroundColor Green
        Write-Host "  [2] Cai CO BAN (5 app nhe cho TV RAM 1GB)" -ForegroundColor Green
        Write-Host "  [3] TU CHON ung dung theo so thu tu" -ForegroundColor Green
        Write-Host "  [4] CAP NHAT / NANG CAP ung dung (giu nguyen data)" -ForegroundColor Green
        Write-Host "----------------------------------------------------" -ForegroundColor Cyan

        $selectedMode = "1"
        if ($Mode) {
            $selectedMode = $Mode
        } else {
            Write-Host "Tu dong chon [1] sau 10 giay neu khong nhap..." -ForegroundColor Yellow
            $timeout = 10
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $inputVal = ""
            while ($stopwatch.Elapsed.TotalSeconds -lt $timeout) {
                if ([Console]::KeyAvailable) {
                    $inputVal = Read-Host "Chon che do [1/2/3/4] (Mac dinh 1)"
                    break
                }
                Start-Sleep -Milliseconds 200
            }
            if ($inputVal) {
                $selectedMode = $inputVal.Trim()
            } else {
                Write-Host "[*] Het thoi gian cho. Tu dong chon Che do 1 (Day du)." -ForegroundColor Green
                $selectedMode = "1"
            }
        }

        if ($selectedMode -eq "2" -or $selectedMode -eq "basic") {
            Write-Info "Che do 2: Cai dat 5 ung dung thiet yeu cho TV RAM 1GB..."
            $targetApps = $appsConfig.apps | Where-Object { $_.id -in @("smarttube", "vtvgo", "tv360", "sftv") }
        } elseif ($selectedMode -eq "3" -or $selectedMode -eq "custom") {
            Write-Host "`n--- DANH SACH UNG DUNG (1-$($appsConfig.apps.Count)) ---" -ForegroundColor Cyan
            for ($i = 0; $i -lt $appsConfig.apps.Count; $i++) {
                $curr = $appsConfig.apps[$i]
                Write-Host ("  [{0,2}] {1} ({2})" -f ($i + 1), $curr.name, $curr.category)
            }
            Write-Host "---------------------------------" -ForegroundColor Cyan
            $choices = Read-Host "Nhap so cac app muon cai (VD: 1 3 5 hoac 1,2,5)"
            $choiceNums = ($choices -replace ',', ' ').Split(' ') | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
            foreach ($n in $choiceNums) {
                if ($n -ge 1 -and $n -le $appsConfig.apps.Count) {
                    $targetApps += $appsConfig.apps[$n - 1]
                }
            }
        } elseif ($selectedMode -eq "4" -or $selectedMode -eq "upgrade") {
            $isUpgradeMode = $true
            Write-Host "`n--- CHON UNG DUNG CAN CAP NHAT / NANG CAP ---" -ForegroundColor Cyan
            for ($i = 0; $i -lt $appsConfig.apps.Count; $i++) {
                $curr = $appsConfig.apps[$i]
                Write-Host ("  [{0,2}] {1} (v{2})" -f ($i + 1), $curr.name, $curr.version)
            }
            Write-Host "  [ A] Cap nhat TAT CA ung dung"
            Write-Host "---------------------------------------------" -ForegroundColor Cyan
            $upChoice = Read-Host "Nhap so app muon nang cap (VD: 4 hoac A)"
            if ($upChoice -eq "A" -or $upChoice -eq "a") {
                $targetApps = $appsConfig.apps
            } else {
                $choiceNums = ($upChoice -replace ',', ' ').Split(' ') | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
                foreach ($n in $choiceNums) {
                    if ($n -ge 1 -and $n -le $appsConfig.apps.Count) {
                        $targetApps += $appsConfig.apps[$n - 1]
                    }
                }
            }
        } else {
            Write-Info "Che do 1: Cai dat tron bo tat ca ung dung..."
            $targetApps = $appsConfig.apps
        }
    }

    Write-Step "Bat dau xu ly ($($targetApps.Count) ung dung)..."

    foreach ($app in $targetApps) {
        Write-Host "`n  --> Ung dung: $($app.name)" -ForegroundColor Yellow
        $installed = (Run-AdbShell "pm list packages $($app.package)") -match $app.package

        if ($installed -and -not $isUpgradeMode) {
            Write-Info "Da co tren TV. Bo qua (Chon [4] hoac -Update de nang cap)."
            continue
        }

        if ($installed -and $isUpgradeMode) {
            $curVer = (Run-AdbShell "dumpsys package $($app.package)" | Where-Object { $_ -match "versionName" } | Select-Object -First 1)
            Write-Info "Phien ban tren TV: $($curVer.Trim())"
            Write-Info "Dang tien hanh nang cap len v$($app.version)..."
        }

        $assetFile = if ($app.asset_name) { $app.asset_name } else { "$($app.id).apk" }
        $offlineApk = Join-Path $ApksDir $assetFile
        $cachedFile = Join-Path $CacheDir $assetFile

        # Neu la che do nang cap, xoa cache de lay ban moi
        if ($isUpgradeMode -and (Test-Path $cachedFile)) {
            Remove-Item $cachedFile -Force -ErrorAction SilentlyContinue
        }

        $sourceFile = ""
        if (Test-Path $offlineApk) {
            Write-Info "Su dung file offline: $offlineApk..."
            $sourceFile = $offlineApk
        } else {
            if (-not (Test-Path $cachedFile)) {
                Write-Info "Dang tai tu CDN GitHub Release..."
                $downUrl = if ($app.download_url) { $app.download_url } else { "https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/$assetFile" }
                curl.exe -L -s -o $cachedFile $downUrl
            }
            $sourceFile = $cachedFile
        }

        if (-not (Test-Path $sourceFile) -or (Get-Item $sourceFile).Length -eq 0) {
            Write-Warn "Khong the tai file cho $($app.name). Bo qua."
            continue
        }

        Write-Info "Dang cai dat / ghi de (giu nguyen data)..."
        if ($sourceFile -like "*.xapk") {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $extractFolder = Join-Path $CacheDir "$($app.id)_split"
            if (Test-Path $extractFolder) { Remove-Item $extractFolder -Recurse -Force }
            try {
                [System.IO.Compression.ZipFile]::ExtractToDirectory($sourceFile, $extractFolder)
                $splitApks = Get-ChildItem -Path $extractFolder -Filter "*.apk" | Where-Object {
                    $_.Name -match "base\.apk|$($app.package)\.apk|armeabi|xhdpi|mdpi|vi\.apk|en\.apk"
                } | Select-Object -ExpandProperty FullName

                if ($splitApks.Count -gt 1) {
                    & $Adb -s $targetDevice install-multiple -r -g $splitApks | Out-Null
                } else {
                    $singleApk = Get-ChildItem -Path $extractFolder -Filter "*.apk" | Select-Object -First 1 -ExpandProperty FullName
                    & $Adb -s $targetDevice install -r -d -g $singleApk | Out-Null
                }
            } catch {
                & $Adb -s $targetDevice install -r -d -g $sourceFile | Out-Null
            }
            if (Test-Path $extractFolder) { Remove-Item $extractFolder -Recurse -Force }
        } else {
            & $Adb -s $targetDevice install -r -d -g $sourceFile | Out-Null
        }

        Write-Info "Hoan tat!"
    }
}

# 6. Khoi dong giao dien
Write-Step "Khoi chay giao dien Projectivy Launcher..."
Run-AdbShell "am start -n com.spocky.projhost/.ui.HomeActivity" | Out-Null

Write-Host @"
===================================================================
       HOAN TAT TIEN TRINH TREN TIVI XIAOMI!
===================================================================
"@ -ForegroundColor Green
