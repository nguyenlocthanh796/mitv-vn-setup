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
    [switch]$Restore = $false,
    [switch]$SkipApps = $false,
    [switch]$DebloatOnly = $false,
    [switch]$DnsOnly = $false
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
$LastDeviceFile = Join-Path $CacheDir "last_device.txt"

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

function Test-AdbPort {
    param([string]$Ip, [int]$TimeoutMs = 1000)
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $task = $tcp.ConnectAsync($Ip, 5555)
        if ($task.Wait($TimeoutMs)) {
            $tcp.Close()
            return $true
        }
        $tcp.Close()
        return $false
    } catch {
        return $false
    }
}

function Discover-TvDevice {
    param([string]$CacheFile)

    # 1. Thu ket noi lai IP cu da luu trong cache
    if ($CacheFile -and (Test-Path $CacheFile)) {
        $lastIp = (Get-Content $CacheFile -Raw).Trim()
        if ($lastIp) {
            $checkIp = ($lastIp -split ':')[0]
            Write-Info "Thu ket noi lai thiet bi gan nhat: $lastIp..."
            if (Test-AdbPort $checkIp 1000) {
                Write-Info "Phat hien thiet bi cu dang online!"
                return $lastIp
            }
        }
    }

    # 2. Quet nhanh bang ARP tim thiet bi mo cong ADB 5555
    Write-Info "Dang tu dong quet mang LAN tim Tivi Xiaomi (port 5555)..."
    $arpOutput = arp -a
    $candidateIps = @()
    foreach ($line in ($arpOutput -split "`r?`n")) {
        if ($line -match "^\s*([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\s+") {
            $ip = $matches[1]
            if (($ip -match '^192\.168\.' -or $ip -match '^10\.' -or $ip -match '^172\.') -and $ip -notmatch '\.255$' -and $ip -notmatch '\.1$') {
                $candidateIps += $ip
            }
        }
    }

    $candidateIps = $candidateIps | Select-Object -Unique
    $foundList = @()
    foreach ($ip in $candidateIps) {
        if (Test-AdbPort $ip 800) {
            $foundList += "$($ip):5555"
        }
    }

    if ($foundList.Count -eq 1) {
        Write-Info "Tu dong tim thay Tivi tai: $($foundList[0])"
        return $foundList[0]
    } elseif ($foundList.Count -gt 1) {
        Write-Host "`nTim thay nhieu thiet bi ADB trong mang LAN:" -ForegroundColor Yellow
        for ($i = 0; $i -lt $foundList.Count; $i++) {
            Write-Host "  [$($i+1)] $($foundList[$i])"
        }
        $sel = Read-Host "Chon thiet bi (1-$($foundList.Count))"
        if ($sel -match '^\d+$' -and [int]$sel -ge 1 -and [int]$sel -le $foundList.Count) {
            return $foundList[[int]$sel - 1]
        }
    }

    return $null
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
    $candidatePaths = @(
        $localAdb,
        "C:\scrcpy-win64-v4.1\adb.exe",
        "C:\scrcpy\adb.exe",
        (Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"),
        (Join-Path $env:ProgramFiles "scrcpy\adb.exe")
    )
    $foundCandidate = $candidatePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($foundCandidate) {
        $Adb = $foundCandidate
        Write-Info "Su dung ADB co san: $foundCandidate"
    } else {
        Write-Info "Dang tai Android Platform Tools ve may..."
        $adbZip = Join-Path $CacheDir "platform-tools.zip"
        curl.exe -L --progress-bar -o $adbZip "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
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
    $cleanIp = $DeviceIp.Trim() -replace '^https?://', '' -replace '/.*$', ''
    $targetDevice = if ($cleanIp -match ':\d+$') { $cleanIp } else { "$cleanIp`:5555" }
    Write-Info "Ket noi toi IP chi dinh: $targetDevice"
    & $Adb connect $targetDevice | Out-Null
} else {
    $devicesOutput = & $Adb devices
    $lines = @($devicesOutput | Where-Object { $_ -match "\s+device$" })
    $realDevices = @($lines | Where-Object { ($_ -split "\s+")[0] -notmatch '^emulator-\d+' })

    if ($LastDeviceFile -and (Test-Path $LastDeviceFile)) {
        $lastDev = (Get-Content $LastDeviceFile -Raw).Trim()
        if ($lastDev -and ($lines | Where-Object { $_ -match [regex]::Escape($lastDev) })) {
            $targetDevice = $lastDev
            Write-Info "Tu dong chon thiet bi gan nhat: $targetDevice"
        }
    }

    if (-not $targetDevice) {
        if ($realDevices.Count -eq 1) {
            $targetDevice = ($realDevices[0] -split "\s+")[0]
            Write-Info "Phat hien thiet bi san co: $targetDevice"
        } elseif ($realDevices.Count -gt 1) {
            Write-Host "`nDanh sach thiet bi ket noi:" -ForegroundColor Yellow
            for ($i = 0; $i -lt $realDevices.Count; $i++) {
                $devName = ($realDevices[$i] -split "\s+")[0]
                Write-Host "  [$($i+1)] $devName"
            }
            $sel = Read-Host "Chon thiet bi (1-$($realDevices.Count))"
            if ($sel -match '^\d+$' -and [int]$sel -ge 1 -and [int]$sel -le $realDevices.Count) {
                $targetDevice = ($realDevices[[int]$sel - 1] -split "\s+")[0]
            }
        } else {
            # Khong co thiet bi thuc nao dang ket noi -> Quet mang LAN
            $autoDev = Discover-TvDevice -CacheFile $LastDeviceFile
            if ($autoDev) {
                $targetDevice = $autoDev
                & $Adb connect $targetDevice | Out-Null
            }
        }
    }
}

if (-not $targetDevice) {
    $inputIp = Read-Host "Nhap dia chi IP cua Tivi Xiaomi (VD: 192.168.1.50)"
    if (-not $inputIp) { throw "Chua nhap IP. Huy tien trinh." }
    $cleanIp = $inputIp.Trim() -replace '^https?://', '' -replace '/.*$', ''
    $targetDevice = if ($cleanIp -match ':\d+$') { $cleanIp } else { "$cleanIp`:5555" }
    Write-Info "Dang ket noi toi $targetDevice..."
    & $Adb connect $targetDevice | Out-Null
}

# Kiem tra xac nhan tren man hinh Tivi
$isReady = $false
for ($i = 1; $i -le 10; $i++) {
    $devLine = (& $Adb devices) | Where-Object { $_ -match [regex]::Escape($targetDevice) }
    if ($devLine -match "\s+device$") {
        $isReady = $true
        Set-Content -Path $LastDeviceFile -Value $targetDevice -Force
        break
    } elseif ($devLine -match "\s+unauthorized$") {
        Write-Warn "TIVI DANG CHO XAC NHAN!"
        Write-Host "    >> NHIN LEN MAN HINH TIVI: Tich 'Luon cho phep' va bam OK bang remote! ($i/10)" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    } else {
        Start-Sleep -Seconds 1
    }
}

if (-not $isReady) {
    Write-Err "KHONG THE KET NOI HOAC TIVI TU CHOI XAC NHAN!"
    Write-Host @"
Huong dan xu ly:
  1. Dam bao Tivi va May tinh ket noi CUNG 1 ten Wi-Fi.
  2. Kiem tra da bat 'Go loi USB (ADB Debugging)' trong Cai dat nha phat trien.
  3. Neu Tivi hien hop thoai xac nhan, hay dung remote bam 'Luon cho phep'.
"@ -ForegroundColor Yellow
    exit 1
}

function Run-AdbShell {
    param([string]$Cmd)
    return (& $Adb -s $targetDevice shell $Cmd)
}

# Xu ly lenh kich hoat DNS neu co tham so -DnsOnly
if ($DnsOnly) {
    Write-Step "Kich hoat Private DNS chan quang cao (AdGuard)..."
    Run-AdbShell "settings put global private_dns_mode hostname" | Out-Null
    Run-AdbShell "settings put global private_dns_specifier dns.adguard-dns.com" | Out-Null
    Write-Host "[OK] Da kich hoat Private DNS AdGuard (dns.adguard-dns.com) thanh cong!" -ForegroundColor Green
    exit 0
}

# Xu ly lenh khoi phuc ve goc neu co tham so -Restore
if ($Restore) {
    Write-Host "`n[*] Dang khoi phuc ve giao dien PatchWall goc..." -ForegroundColor Yellow
    Run-AdbShell "cmd package set-home-activity com.mitv.tvhome/.MainActivity" | Out-Null
    Run-AdbShell "settings put secure enabled_accessibility_services '""""'" | Out-Null
    Run-AdbShell "settings put global window_animation_scale 1.0" | Out-Null
    Run-AdbShell "settings put global transition_animation_scale 1.0" | Out-Null
    Run-AdbShell "settings put global animator_duration_scale 1.0" | Out-Null
    Run-AdbShell "settings put global private_dns_mode off" | Out-Null
    Run-AdbShell "settings delete global private_dns_specifier" | Out-Null
    Run-AdbShell "pm enable com.miui.systemAdSolution" | Out-Null
    Run-AdbShell "pm enable com.xiaomi.mitv.advertise" | Out-Null
    Run-AdbShell "pm enable com.miui.tv.analytics" | Out-Null
    Run-AdbShell "pm enable com.xiaomi.mibox.gamecenter" | Out-Null
    Run-AdbShell "pm enable com.sohu.inputmethod.sogou.tv" | Out-Null
    Run-AdbShell "settings put secure default_input_method '""""'" | Out-Null
    Run-AdbShell "am start -n com.mitv.tvhome/.MainActivity" | Out-Null
    Write-Host "[OK] Da khoi phuc xong! Tivi tro ve nguyen ban nha san xuat." -ForegroundColor Green
    exit 0
}

# 3. Kiem tra thong tin Tivi & Toi uu hoat anh
Write-Step "Danh thuc va toi uu toc do he thong..."
Run-AdbShell "input keyevent KEYCODE_WAKEUP" | Out-Null
$abi = (Run-AdbShell "getprop ro.product.cpu.abi")
$model = (Run-AdbShell "getprop ro.product.model")
$androidVer = (Run-AdbShell "getprop ro.build.version.release")
Write-Info "Model: $($model.Trim()) | Android: $($androidVer.Trim()) | CPU: $($abi.Trim())"

Run-AdbShell "settings put global window_animation_scale 0.5" | Out-Null
Run-AdbShell "settings put global transition_animation_scale 0.5" | Out-Null
Run-AdbShell "settings put global animator_duration_scale 0.5" | Out-Null

Write-Step "Sua loi lech gio (GMT+7) & Chan quang cao rac Xiaomi..."
Run-AdbShell "settings put global ntp_server time.android.com" | Out-Null
Run-AdbShell "settings put global auto_time 1" | Out-Null
Run-AdbShell "service call alarm 3 s16 Asia/Ho_Chi_Minh" | Out-Null
Run-AdbShell "settings put global private_dns_mode hostname" | Out-Null
Run-AdbShell "settings put global private_dns_specifier dns.adguard-dns.com" | Out-Null
Write-Info "Da kich hoat Private DNS chan quang cao AdGuard (dns.adguard-dns.com)."

$installedPkgs = Run-AdbShell "pm list packages"
$bloatPackages = @(
    "com.miui.systemAdSolution",
    "com.xiaomi.mitv.advertise",
    "com.miui.tv.analytics",
    "com.xiaomi.mibox.gamecenter",
    "com.xiaomi.voicecontrol",
    "com.xiaomi.tweather",
    "com.xiaomi.setupwizard",
    "com.xiaomi.mitv.shop",
    "com.xiaomi.mitv.handbook",
    "com.xiaomi.mitv.calendar",
    "com.xiaomi.mitv.appstore",
    "com.mitv.cloudcontrol",
    "com.duokan.videodaily",
    "com.xiaomi.mitv.karaoke.service"
)
foreach ($bp in $bloatPackages) {
    if ($installedPkgs -match "package:$bp") {
        Run-AdbShell "pm disable-user --user 0 $bp" | Out-Null
    }
}
Write-Info "Da dat may chu gio GMT+7 (time.android.com) va don dep bloatware."

# 4. Viet hoa he thong (Locale vi-VN) & Bo go Tieng Viet
Write-Step "Viet hoa he thong (Locale vi-VN) & Cai bo go Tieng Viet..."
$curLocale = (Run-AdbShell "getprop persist.sys.locale")
if ($curLocale -notmatch "vi") {
    Write-Info "Dang thiet lap ngon ngu Tieng Viet (vi-VN)..."
    $appiumApk = Join-Path $CacheDir "Appium.apk"
    if (-not (Test-Path $appiumApk)) {
        curl.exe -L -s -o $appiumApk "https://raw.githubusercontent.com/vinh97/CAI-TIENG-VIET-TV-XIAOMI/main/lang/Appium.apk"
    }
    if (Test-Path $appiumApk) {
        & $Adb -s $targetDevice install -r -g $appiumApk 2>&1 | Out-Null
        Run-AdbShell "pm grant io.appium.settings android.permission.CHANGE_CONFIGURATION" | Out-Null
        Run-AdbShell "am broadcast -a io.appium.settings.locale -n io.appium.settings/.receivers.LocaleSettingReceiver --es lang vi --es country VN" | Out-Null
        Run-AdbShell "pm uninstall io.appium.settings" | Out-Null
        Write-Info "Da chuyen ngon ngu he thong sang Tieng Viet!"
    }
} else {
    Write-Info "Ngon ngu he thong: Tieng Viet ($($curLocale.Trim()))."
}

# Bo go Tieng Viet LeanKey Keyboard
$imeInstalled = (Run-AdbShell "pm list packages com.liskovsoft.leankeyboard") -match "com.liskovsoft.leankeyboard"
if (-not $imeInstalled) {
    Write-Info "Dang tai va cai dat bo go LeanKey Keyboard Tieng Viet..."
    $leanKeyApk = Join-Path $CacheDir "LeanKey.apk"
    if (-not (Test-Path $leanKeyApk)) {
        curl.exe -L -s -o $leanKeyApk "https://raw.githubusercontent.com/vinh97/CAI-TIENG-VIET-TV-XIAOMI/main/lang/LeanKey.apk"
    }
    if (Test-Path $leanKeyApk) {
        & $Adb -s $targetDevice install -r -g $leanKeyApk 2>&1 | Out-Null
    }
}
Run-AdbShell "ime enable com.liskovsoft.leankeyboard/.ime.LeanbackImeService" | Out-Null
Run-AdbShell "ime set com.liskovsoft.leankeyboard/.ime.LeanbackImeService" | Out-Null
Run-AdbShell "settings put secure default_input_method com.liskovsoft.leankeyboard/.ime.LeanbackImeService" | Out-Null

if ($installedPkgs -match "com.sohu.inputmethod.sogou.tv") {
    Run-AdbShell "pm disable-user --user 0 com.sohu.inputmethod.sogou.tv" | Out-Null
    Write-Info "Da vo hieu hoa bo go goc tieng Trung Sogou."
}
Write-Info "Da kich hoat bo go Tieng Viet LeanKey mac dinh."

# 5. Cai dat Launcher neu chua co
$launcherInstalled = (Run-AdbShell "pm list packages com.spocky.projengmenu") -match "com.spocky.projengmenu"
if (-not $launcherInstalled) {
    Write-Step "Cai dat Projectivy Launcher (Chan PatchWall)..."
    $projectivyFile = Join-Path $CacheDir "ProjectivyLauncher.apk"
    $offlineProjectivy = Join-Path $ApksDir "ProjectivyLauncher.apk"

    if (Test-Path $offlineProjectivy) {
        $projectivyFile = $offlineProjectivy
    } elseif (-not (Test-Path $projectivyFile)) {
        Write-Info "Dang tai Projectivy Launcher tu GitHub Release..."
        curl.exe -L --progress-bar -o $projectivyFile "https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/ProjectivyLauncher.apk"
    }

    Write-Info "Dang cai dat Projectivy vao Tivi..."
    & $Adb -s $targetDevice install -r -g $projectivyFile | Out-Null
    Run-AdbShell "cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity" | Out-Null
    Run-AdbShell "settings put secure enabled_accessibility_services com.spocky.projengmenu/.services.ProjectivyAccessibilityService" | Out-Null
    Run-AdbShell "settings put secure accessibility_enabled 1" | Out-Null
}

# 5. Cai dat / Cap nhat ung dung
if (-not $SkipApps -and -not $DebloatOnly) {
    $appsJsonPath = Join-Path $RepoRoot "apps.json"
    if (-not (Test-Path $appsJsonPath)) {
        Write-Info "Dang tai danh muc apps.json tu GitHub..."
        curl.exe -L -s -o $appsJsonPath "https://raw.githubusercontent.com/nguyenlocthanh796/mitv-vn-setup/main/apps.json"
    }
    $appsConfig = $null
    if (Test-Path $appsJsonPath) {
        $appsConfig = Get-Content $appsJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
    }

    $isUpgradeMode = $false
    $targetApps = @()

    if ($UpdateAll) {
        $isUpgradeMode = $true
        $targetApps = @($appsConfig.apps)
    } elseif ($Update) {
        $isUpgradeMode = $true
        $targetApps = @($appsConfig.apps | Where-Object { $_.id -eq $Update -or $_.package -eq $Update })
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
        Write-Host "  [5] KHOI PHUC giao dien PatchWall goc nha san xuat" -ForegroundColor Yellow
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
                    $inputVal = Read-Host "Chon che do [1/2/3/4/5] (Mac dinh 1)"
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

        if ($selectedMode -eq "5" -or $selectedMode -eq "restore") {
            Write-Host "`n[*] Dang khoi phuc ve giao dien PatchWall goc..." -ForegroundColor Yellow
            Run-AdbShell "cmd package set-home-activity com.mitv.tvhome/.MainActivity" | Out-Null
            Run-AdbShell "settings put secure enabled_accessibility_services '""""'" | Out-Null
            Run-AdbShell "settings put global window_animation_scale 1.0" | Out-Null
            Run-AdbShell "settings put global transition_animation_scale 1.0" | Out-Null
            Run-AdbShell "settings put global animator_duration_scale 1.0" | Out-Null
            Run-AdbShell "settings put global private_dns_mode off" | Out-Null
            Run-AdbShell "settings delete global private_dns_specifier" | Out-Null
            Run-AdbShell "pm enable com.miui.systemAdSolution" | Out-Null
            Run-AdbShell "pm enable com.xiaomi.mitv.advertise" | Out-Null
            Run-AdbShell "pm enable com.miui.tv.analytics" | Out-Null
            Run-AdbShell "pm enable com.xiaomi.mibox.gamecenter" | Out-Null
            Run-AdbShell "am start -n com.mitv.tvhome/.MainActivity" | Out-Null
            Write-Host "[OK] Da khoi phuc xong! Tivi tro ve nguyen ban nha san xuat." -ForegroundColor Green
            exit 0
        } elseif ($selectedMode -eq "2" -or $selectedMode -eq "basic") {
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

    Write-Step "Bat dau xu ly ($(@($targetApps).Count) ung dung)..."

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
                curl.exe -L --progress-bar -o $cachedFile $downUrl
            }
            $sourceFile = $cachedFile
        }

        if (-not (Test-Path $sourceFile) -or (Get-Item $sourceFile).Length -eq 0) {
            Write-Warn "Khong the tai file cho $($app.name). Bo qua."
            continue
        }

        Write-Info "Dang nap vao TV qua mang Wi-Fi (giu nguyen data)..."
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
                    & $Adb -s $targetDevice install-multiple -r -d -g $splitApks 2>&1 | Out-Null
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
Run-AdbShell "am start -n com.spocky.projengmenu/.ui.home.MainActivity" | Out-Null

Write-Host @"
===================================================================
       HOAN TAT TIEN TRINH TREN TIVI XIAOMI!
===================================================================
"@ -ForegroundColor Green
