<#
.SYNOPSIS
    MiTV Vietnam Toolkit - Bộ cài đặt 1-lệnh tự động cho Tivi Xiaomi qua ADB
.DESCRIPTION
    Tự động cài đặt giao diện Projectivy Launcher, chặn PatchWall tiếng Trung,
    tối ưu hóa hoạt ảnh và cài trọn bộ ứng dụng truyền hình/giải trí Việt Nam.
#>

[CmdletBinding()]
param (
    [string]$DeviceIp = "",
    [string]$Mode = "",
    [switch]$SkipApps = $false,
    [switch]$DebloatOnly = $false
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$RepoRoot = $PSScriptRoot
if (-not $RepoRoot) {
    # Khi chạy trực tiếp qua irm ... | iex
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
    MiTV Vietnam Toolkit - 1-Click ADB Setup
    Giai phap toi uu & Viet hoa Tivi Xiaomi Noi Dia
===================================================================
"@ -ForegroundColor Magenta

# 1. Tìm hoặc tải ADB
function Get-AdbPath {
    $existing = Get-Command "adb" -ErrorAction SilentlyContinue
    if ($existing) { return $existing.Source }

    $commonPaths = @(
        "D:\tools\platform-tools\adb.exe",
        "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
        "$BinDir\platform-tools\adb.exe",
        "C:\scrcpy-win64-v4.1\adb.exe"
    )

    foreach ($p in $commonPaths) {
        if (Test-Path $p) { return $p }
    }

    Write-Step "Khong tim thay ADB tren may. Dang tai Google Platform-Tools..."
    $zipPath = Join-Path $BinDir "platform-tools.zip"
    $url = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    
    Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath $BinDir -Force
    Remove-Item $zipPath -Force

    $adb = Join-Path $BinDir "platform-tools\adb.exe"
    if (Test-Path $adb) { return $adb }
    throw "Khong the khoi tao ADB tren he thong!"
}

$Adb = Get-AdbPath
Write-Info "Su dung ADB tai: $Adb"

# 2. Kết nối tới Tivi
Write-Step "Kiem tra ket noi thiet bi ADB..."
& $Adb start-server | Out-Null

$targetDevice = ""
$devicesOutput = & $Adb devices
$lines = $devicesOutput -split "`n" | Where-Object { $_ -match "\s+device$" }

if ($DeviceIp) {
    Write-Info "Dang ket noi toi IP: $DeviceIp..."
    & $Adb connect "$DeviceIp`:5555" | Out-Null
    $targetDevice = if ($DeviceIp -match ":5555$") { $DeviceIp } else { "$DeviceIp`:5555" }
} elseif ($lines.Count -eq 1) {
    $targetDevice = ($lines[0] -split "\s+")[0]
    Write-Info "Phat hien 1 thiet bi duy nhat: $targetDevice"
} elseif ($lines.Count -gt 1) {
    Write-Host "Danh sach thiet bi dang ket noi:" -ForegroundColor Yellow
    for ($i=0; $i -lt $lines.Count; $i++) {
        $dev = ($lines[$i] -split "\s+")[0]
        Write-Host " [$i] $dev"
    }
    $choice = Read-Host "Chon so thu tu thiet bi"
    $targetDevice = ($lines[[int]$choice] -split "\s+")[0]
} else {
    Write-Warn "Chua co thiet bi nao ket noi qua USB hoac Wi-Fi!"
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

# 3. Đánh thức và kiểm tra thông tin Tivi
Write-Step "Danh thuc va kiem tra thong so Tivi..."
Run-AdbShell "input keyevent KEYCODE_WAKEUP" | Out-Null
$abi = (Run-AdbShell "getprop ro.product.cpu.abi").Trim()
$model = (Run-AdbShell "getprop ro.product.model").Trim()
$androidVer = (Run-AdbShell "getprop ro.build.version.release").Trim()

Write-Info "Model: $model | Android: $androidVer | CPU: $abi"

# 4. Tăng tốc hệ thống & Tối ưu chuyển cảnh
Write-Step "Toi uu toc do he thong & Hoat anh..."
Run-AdbShell "settings put global window_animation_scale 0.5" | Out-Null
Run-AdbShell "settings put global transition_animation_scale 0.5" | Out-Null
Run-AdbShell "settings put global animator_duration_scale 0.5" | Out-Null
Write-Info "Da dat toc do chuyen canh 0.5x (nhanh gap doi mac dinh)."

# 5. Cài đặt & Cấu hình Projectivy Launcher
Write-Step "Cai dat Projectivy Launcher (Chan PatchWall)..."
$projectivyFile = Join-Path $CacheDir "ProjectivyLauncher.apk"
$offlineProjectivy = Join-Path $ApksDir "ProjectivyLauncher.apk"

if (Test-Path $offlineProjectivy) {
    $projectivyFile = $offlineProjectivy
    Write-Info "Su dung Projectivy Launcher co san tu thu muc apks/..."
} elseif (-not (Test-Path $projectivyFile)) {
    Write-Info "Dang tim ban moi nhat tu GitHub..."
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/spocky/miproja1/releases/latest"
    $apkUrl = ($release.assets | Where-Object name -like "*.apk" | Select-Object -First 1).browser_download_url
    Write-Info "Dang tai Projectivy Launcher ($($release.tag_name))..."
    curl.exe -L -o $projectivyFile $apkUrl
}

Write-Info "Dang cai dat Projectivy vao Tivi..."
& $Adb -s $targetDevice install -r -g $projectivyFile | Out-Null

Write-Info "Cau hinh quyen Accessibility & Default Launcher..."
Run-AdbShell "cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity" | Out-Null
Run-AdbShell "settings put secure enabled_accessibility_services com.spocky.projengmenu/.services.ProjectivyAccessibilityService" | Out-Null
Run-AdbShell "settings put secure accessibility_enabled 1" | Out-Null
Run-AdbShell "settings put secure enabled_notification_listeners com.spocky.projengmenu/com.spocky.projengmenu.services.notification.NotificationListener" | Out-Null
Write-Info "Da kich hoat chan PatchWall thanh cong!"

if ($DebloatOnly) {
    Write-Step "Hoan tat che do Debloat & Launcher!"
    exit 0
}

# 6. Tải & Cài đặt bộ ứng dụng Việt Nam
if (-not $SkipApps) {
    Write-Step "Cai dat bo ung dung truyen hinh & giai tri Viet Nam..."
    
    $appsJsonLocal = Join-Path $RepoRoot "apps.json"
    $appsConfig = $null
    if (Test-Path $appsJsonLocal) {
        $appsConfig = Get-Content $appsJsonLocal -Raw | ConvertFrom-Json
    } else {
        Write-Info "Dang tai danh muc ung dung tu GitHub..."
        try {
            $remoteUrl = "https://raw.githubusercontent.com/nguyenlocthanh796/mitv-vn-setup/main/apps.json"
            $appsConfig = Invoke-RestMethod -Uri $remoteUrl
        } catch {
            Write-Warn "Khong the tai apps.json tu GitHub, su dung danh sach du phong mac dinh..."
            $appsConfig = [PSCustomObject]@{
                apps = @(
                    [PSCustomObject]@{ id="smarttube"; name="SmartTube"; package="org.smarttube.stable"; type="direct_url"; url="https://github.com/yuliskov/SmartTube/releases/download/latest/smarttube_stable.apk" },
                    [PSCustomObject]@{ id="vtvgo"; name="VTV Go TV"; package="vn.vtv.vtvgo"; type="aptoide_query"; query="vn.vtv.vtvgo" },
                    [PSCustomObject]@{ id="tv360"; name="TV360 Smart TV"; package="com.viettel.tv360.tv"; type="aptoide_query"; query="com.viettel.tv360.tv" },
                    [PSCustomObject]@{ id="spotify"; name="Spotify TV"; package="com.spotify.tv.android"; type="aptoide_query"; query="com.spotify.tv.android" },
                    [PSCustomObject]@{ id="sftv"; name="Send Files to TV"; package="com.yablio.sendfilestotv"; type="aptoide_query"; query="com.yablio.sendfilestotv" },
                    [PSCustomObject]@{ id="tvbro"; name="TV Bro"; package="com.phlox.tvwebbrowser"; type="github_release"; repo="truefedex/tv-bro"; asset_filter="generic-geckoExcluded.apk" },
                    [PSCustomObject]@{ id="youtubetv"; name="YouTube for Android TV"; package="com.google.android.youtube.tv"; type="aptoide_query"; query="com.google.android.youtube.tv" }
                )
            }
        }
    }

    # Menu chon che do cai dat ung dung
    Write-Host "`n----------------------------------------------------" -ForegroundColor Cyan
    Write-Host "       CHON CHE DO CAI DAT UNG DUNG" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------" -ForegroundColor Cyan
    Write-Host "  [1] Cai DAY DU (16 app truyen hinh, phim, Youtube)" -ForegroundColor Green
    Write-Host "  [2] Cai CO BAN (5 app nhe cho TV RAM 1GB)" -ForegroundColor Green
    Write-Host "  [3] TU CHON ung dung theo so thu tu" -ForegroundColor Green
    Write-Host "----------------------------------------------------" -ForegroundColor Cyan

    $selectedMode = "1"
    if ($Mode) {
        $selectedMode = $Mode
        Write-Info "Che do duoc chi dinh: $selectedMode"
    } else {
        Write-Host "Tu dong chon [1] sau 10 giay neu khong nhap..." -ForegroundColor Yellow
        $timeout = 10
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $inputVal = ""
        while ($stopwatch.Elapsed.TotalSeconds -lt $timeout) {
            if ([Console]::KeyAvailable) {
                $inputVal = Read-Host "Chon che do [1/2/3] (Mac dinh 1)"
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

    $targetApps = @()
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
        $targetApps = @()
        foreach ($n in $choiceNums) {
            if ($n -ge 1 -and $n -le $appsConfig.apps.Count) {
                $targetApps += $appsConfig.apps[$n - 1]
            }
        }
        if ($targetApps.Count -eq 0) {
            Write-Warn "Khong co app nao hop le duoc chon. Se cai Che do 1 (Day du)..."
            $targetApps = $appsConfig.apps
        }
    } else {
        Write-Info "Che do 1: Cai dat tron bo tat ca ung dung..."
        $targetApps = $appsConfig.apps
    }

    foreach ($app in $targetApps) {
        Write-Host "`n  --> Ung dung: $($app.name)" -ForegroundColor Yellow
        $installed = (Run-AdbShell "pm list packages $($app.package)") -match $app.package
        if ($installed) {
            Write-Info "Da cai dat tren TV. Bo qua."
            continue
        }

        $apkDest = Join-Path $CacheDir "$($app.id)"
        $offlineApk1 = Join-Path $ApksDir "$($app.id).apk"
        $offlineApk2 = Join-Path $ApksDir "$($app.package).apk"
        $offlineXapk = Join-Path $ApksDir "$($app.id).xapk"
        
        if (Test-Path $offlineApk1) {
            Write-Info "Su dung APK offline co san: $offlineApk1..."
            & $Adb -s $targetDevice install -r -g $offlineApk1 | Out-Null
            Write-Info "Cai dat $($app.name) thanh cong!"
            continue
        } elseif (Test-Path $offlineApk2) {
            Write-Info "Su dung APK offline co san: $offlineApk2..."
            & $Adb -s $targetDevice install -r -g $offlineApk2 | Out-Null
            Write-Info "Cai dat $($app.name) thanh cong!"
            continue
        } elseif (Test-Path $offlineXapk) {
            $xapkPath = $offlineXapk
        }
        if ($app.type -eq "github_release") {
            $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$($app.repo)/releases/latest"
            $targetAsset = $rel.assets | Where-Object name -like "*$($app.asset_filter)*" | Select-Object -First 1
            $downUrl = $targetAsset.browser_download_url
            $filePath = "$apkDest.apk"
            if (-not (Test-Path $filePath)) {
                Write-Info "Dang tai tu GitHub: $($targetAsset.name)..."
                curl.exe -L -o $filePath $downUrl
            }
            Write-Info "Dang cai dat qua ADB..."
            & $Adb -s $targetDevice install -r -g $filePath | Out-Null

        } elseif ($app.type -eq "direct_url") {
            $filePath = "$apkDest.apk"
            if (-not (Test-Path $filePath)) {
                Write-Info "Dang tai truc tiep..."
                curl.exe -L -o $filePath $app.url
            }
            Write-Info "Dang cai dat qua ADB..."
            & $Adb -s $targetDevice install -r -g $filePath | Out-Null

        } elseif ($app.type -eq "aptoide_query") {
            $xapkPath = "$apkDest.xapk"
            $extractFolder = "$apkDest-split"

            if (-not (Test-Path $xapkPath) -and -not (Test-Path "$apkDest.apk")) {
                Write-Info "Dang tim ban moi nhat qua Aptoide..."
                $queryRes = Invoke-RestMethod -Uri "http://ws75.aptoide.com/api/7/apps/search?query=$($app.query)"
                $item = $queryRes.datalist.list | Select-Object -First 1
                if ($item -and $item.file.path) {
                    Write-Info "Dang tai $($item.name)..."
                    curl.exe -L -o $xapkPath $item.file.path
                } else {
                    Write-Warn "Khong tim thay link tai cho $($app.name), bo qua."
                    continue
                }
            }

            # Kiểm tra xem là APK đơn hay XAPK (split)
            if (Test-Path $xapkPath) {
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                if (Test-Path $extractFolder) { Remove-Item $extractFolder -Recurse -Force }
                try {
                    [System.IO.Compression.ZipFile]::ExtractToDirectory($xapkPath, $extractFolder)
                    $splitApks = Get-ChildItem -Path $extractFolder -Filter "*.apk" | Where-Object {
                        $_.Name -match "base\.apk|$($app.package)\.apk|armeabi|xhdpi|mdpi|vi\.apk|en\.apk"
                    } | Select-Object -ExpandProperty FullName

                    if ($splitApks.Count -gt 1) {
                        Write-Info "Cai dat dang Split APKs ($($splitApks.Count) goi)..."
                        & $Adb -s $targetDevice install-multiple -r -g $splitApks | Out-Null
                    } else {
                        $singleApk = Get-ChildItem -Path $extractFolder -Filter "*.apk" | Select-Object -First 1 -ExpandProperty FullName
                        Write-Info "Cai dat APK don..."
                        & $Adb -s $targetDevice install -r -g $singleApk | Out-Null
                    }
                } catch {
                    # Neu file thuc chat la apk thuong
                    Write-Info "Thu cai dat truc tiep file APK..."
                    & $Adb -s $targetDevice install -r -g $xapkPath | Out-Null
                }
            } elseif (Test-Path "$apkDest.apk") {
                & $Adb -s $targetDevice install -r -g "$apkDest.apk" | Out-Null
            }
        }

        Write-Info "Cai dat $($app.name) thanh cong!"
    }
}

# 7. Mở Launcher hoàn thiện
Write-Step "Mo giao dien chinh Projectivy tren Tivi..."
Run-AdbShell "am start -n com.spocky.projengmenu/.ui.home.MainActivity" | Out-Null

Write-Host @"

===================================================================
    CHUC MUNG! TOI UU & CAI DAT HOAN TAT THANH CONG!
===================================================================
  [V] Giao dien: Projectivy Launcher da khoa phim Home.
  [V] He thong: Toc do hoat anh 0.5x sieu muot.
  [V] Ung dung: YouTube TV, SmartTube, VTV Go, TV360, Spotify, SFTV, TV Bro.
  
  Moi thac mac & gop y, vui long truy cap repo GitHub!
===================================================================
"@ -ForegroundColor Green
