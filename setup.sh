#!/usr/bin/env bash
# ===================================================================
#    MiTV Vietnam Toolkit - 1-Click ADB Setup & Upgrade (Mobile & PC)
# ===================================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="$SCRIPT_DIR/.cache"
mkdir -p "$CACHE_DIR"

CLI_UPDATE_TARGET=""
CLI_RESTORE=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --update|-u)
            CLI_UPDATE_TARGET="$2"
            shift 2
            ;;
        --update-all)
            CLI_UPDATE_TARGET="all"
            shift 1
            ;;
        --restore)
            CLI_RESTORE=1
            shift 1
            ;;
        *)
            shift 1
            ;;
    esac
done

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}     MiTV Vietnam Toolkit - Setup & App Manager     ${NC}"
echo -e "${CYAN}====================================================${NC}"

if ! command -v adb &> /dev/null; then
    echo -e "${RED}[X] Chua cai dat adb. Vui long cai dat android-tools!${NC}"
    echo -e "    * Termux (Android): pkg install android-tools"
    echo -e "    * macOS: brew install android-platform-tools"
    echo -e "    * Ubuntu/Debian: sudo apt install adb"
    exit 1
fi

adb start-server > /dev/null 2>&1

DEVICES=$(adb devices | grep -E '\s+device$' | awk '{print $1}')
DEV_COUNT=0
if [ -n "$DEVICES" ]; then
    DEV_COUNT=$(echo "$DEVICES" | grep -c '[^[:space:]]' || true)
fi

if [ "$DEV_COUNT" -eq 1 ]; then
    TARGET_DEV="$DEVICES"
    echo -e "${GREEN}[+] Phat hien thiet bi: $TARGET_DEV${NC}"
elif [ "$DEV_COUNT" -gt 1 ]; then
    echo -e "${YELLOW}Danh sach thiet bi ket noi:${NC}"
    echo "$DEVICES"
    read -r -p "Chon thiet bi: " TARGET_DEV
else
    read -r -p "Nhap dia chi IP Tivi Xiaomi (VD: 192.168.1.50): " RAW_IP
    if [ -z "$RAW_IP" ]; then
        echo -e "${RED}[X] Chua nhap IP. Thoat.${NC}"
        exit 1
    fi
    # Chuan hoa dia chi IP cho nguoi moi (loai bo http:// va khoang trang)
    CLEAN_IP=$(echo "$RAW_IP" | sed -e 's|^https*://||' -e 's|/.*$||' | tr -d '[:space:]')
    if [[ "$CLEAN_IP" != *:* ]]; then
        TARGET_DEV="${CLEAN_IP}:5555"
    else
        TARGET_DEV="$CLEAN_IP"
    fi
    echo -e "${CYAN}[*] Dang ket noi toi $TARGET_DEV...${NC}"
    adb connect "$TARGET_DEV" >/dev/null 2>&1 || true

    # Kiem tra xac nhan tren man hinh Tivi
    IS_READY=0
    for i in {1..10}; do
        DEV_STATUS=$(adb devices | grep "$TARGET_DEV" | awk '{print $2}' || true)
        if [ "$DEV_STATUS" = "device" ]; then
            IS_READY=1
            break
        elif [ "$DEV_STATUS" = "unauthorized" ]; then
            echo -e "${YELLOW}[!] TIVI DANG CHO XAC NHAN!${NC}"
            echo -e "${YELLOW}    >> NHIN LEN MAN HINH TIVI: Bam 'Luon cho phep' bang remote! (Lan $i/10)${NC}"
            sleep 2
        else
            sleep 1
        fi
    done

    if [ "$IS_READY" -eq 0 ]; then
        echo -e "\n${RED}====================================================${NC}"
        echo -e "${RED}[X] KHONG THE KET NOI HOAC TIVI TU CHOI XAC NHAN!   ${NC}"
        echo -e "${RED}====================================================${NC}"
        echo -e "Huong dan xu ly nhanh:"
        echo -e "  1. Tivi va dien thoai phai bat CUNG 1 mang Wi-Fi."
        echo -e "  2. Kiem tra da bat 'ADB debugging' trong Cai dat nha phat trien."
        echo -e "  3. Neu man hinh Tivi hien hop thoai, hay bam 'Luon cho phep'."
        exit 1
    fi
fi

# Xu ly lenh khoi phuc ve goc
if [ "$CLI_RESTORE" -eq 1 ]; then
    echo -e "\n${YELLOW}[*] Dang khoi phuc ve giao dien PatchWall goc...${NC}"
    adb -s "$TARGET_DEV" shell cmd package set-home-activity com.mitv.tvhome/.MainActivity 2>/dev/null || true
    adb -s "$TARGET_DEV" shell settings put secure enabled_accessibility_services '""' 2>/dev/null || true
    adb -s "$TARGET_DEV" shell settings put global window_animation_scale 1.0 2>/dev/null || true
    adb -s "$TARGET_DEV" shell settings put global transition_animation_scale 1.0 2>/dev/null || true
    adb -s "$TARGET_DEV" shell settings put global animator_duration_scale 1.0 2>/dev/null || true
    adb -s "$TARGET_DEV" shell pm enable com.miui.systemAdSolution 2>/dev/null || true
    adb -s "$TARGET_DEV" shell pm enable com.xiaomi.mitv.advertise 2>/dev/null || true
    adb -s "$TARGET_DEV" shell pm enable com.miui.tv.analytics 2>/dev/null || true
    adb -s "$TARGET_DEV" shell pm enable com.xiaomi.mibox.gamecenter 2>/dev/null || true
    adb -s "$TARGET_DEV" shell am start -n com.mitv.tvhome/.MainActivity 2>/dev/null || true
    echo -e "${GREEN}[OK] Da khoi phuc xong! Tivi tro ve nguyen ban xuat xuong.${NC}"
    exit 0
fi

echo -e "\n${GREEN}[+] Danh thuc va toi uu toc do he thong...${NC}"
adb -s "$TARGET_DEV" shell input keyevent KEYCODE_WAKEUP 2>/dev/null || true
adb -s "$TARGET_DEV" shell settings put global window_animation_scale 0.5 2>/dev/null || true
adb -s "$TARGET_DEV" shell settings put global transition_animation_scale 0.5 2>/dev/null || true
adb -s "$TARGET_DEV" shell settings put global animator_duration_scale 0.5 2>/dev/null || true

echo -e "\n${GREEN}[+] Sua loi lech gio (GMT+7) & Chan quang cao rac Xiaomi...${NC}"
adb -s "$TARGET_DEV" shell settings put global ntp_server time.android.com 2>/dev/null || true
adb -s "$TARGET_DEV" shell settings put global auto_time 1 2>/dev/null || true
adb -s "$TARGET_DEV" shell setprop persist.sys.timezone "Asia/Ho_Chi_Minh" 2>/dev/null || true
adb -s "$TARGET_DEV" shell service call alarm 3 s16 "Asia/Ho_Chi_Minh" 2>/dev/null || true

adb -s "$TARGET_DEV" shell pm disable-user --user 0 com.miui.systemAdSolution 2>/dev/null || true
adb -s "$TARGET_DEV" shell pm disable-user --user 0 com.xiaomi.mitv.advertise 2>/dev/null || true
adb -s "$TARGET_DEV" shell pm disable-user --user 0 com.miui.tv.analytics 2>/dev/null || true
adb -s "$TARGET_DEV" shell pm disable-user --user 0 com.xiaomi.mibox.gamecenter 2>/dev/null || true

# Kiem tra launcher
if ! adb -s "$TARGET_DEV" shell pm list packages com.spocky.projengmenu 2>/dev/null | grep -q "com.spocky.projengmenu"; then
    echo -e "\n${GREEN}[+] Cai dat Projectivy Launcher (Chan PatchWall)...${NC}"
    PROJECTIVY_APK="$CACHE_DIR/ProjectivyLauncher.apk"
    if [ ! -f "$PROJECTIVY_APK" ]; then
        curl -L -s -o "$PROJECTIVY_APK" "https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/ProjectivyLauncher.apk"
    fi
    adb -s "$TARGET_DEV" install -r -g "$PROJECTIVY_APK" >/dev/null 2>&1 || true
    adb -s "$TARGET_DEV" shell cmd package set-home-activity com.spocky.projhost/.ui.HomeActivity 2>/dev/null || true
    adb -s "$TARGET_DEV" shell settings put secure enabled_accessibility_services com.spocky.projhost/.services.ProjectivyAccessibilityService 2>/dev/null || true
    adb -s "$TARGET_DEV" shell settings put secure accessibility_enabled 1 2>/dev/null || true
fi

# Danh muc ung dung
APPS_LIST=(
    "smarttube:SmartTube:org.smarttube.stable:smarttube.apk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/smarttube.apk"
    "youtubetv:YouTube for TV:com.google.android.youtube.tv:com.google.android.youtube.tv.xapk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/com.google.android.youtube.tv.xapk"
    "vtvgo:VTV Go TV:vn.vtv.vtvgo:vn.vtv.vtvgo.xapk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/vn.vtv.vtvgo.xapk"
    "tv360:TV360 Smart TV:com.viettel.tv360.tv:com.viettel.tv360.tv.xapk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/com.viettel.tv360.tv.xapk"
    "fptplay:FPT Play TV:net.fptplay.ottbox:fptplay.xapk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/fptplay.xapk"
    "vieon:VieON TV:com.vieon.tv:com.vieon.tv.xapk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/com.vieon.tv.xapk"
    "cloudstream:Cloudstream TV:com.lagradost.cloudstream3.prerelease:cloudstream.apk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/cloudstream.apk"
    "stremio:Stremio TV:com.stremio.one:stremio.apk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/stremio.apk"
    "vlc:VLC for Android:org.videolan.vlc:org.videolan.vlc.apk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/org.videolan.vlc.apk"
    "sportzx:SportzX Live:com.sportzx.live:sportzx.apk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/sportzx.apk"
    "spotify:Spotify TV:com.spotify.tv.android:com.spotify.tv.android.xapk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/com.spotify.tv.android.xapk"
    "sftv:Send Files to TV:com.yablio.sendfilestotv:sftv.apk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/sftv.apk"
    "tvbro:TV Bro:com.phlox.tvwebbrowser:tvbro.apk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/tvbro.apk"
    "rsfile:RS File Manager:com.rs.explorer.filemanager:com.rs.explorer.filemanager.xapk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/com.rs.explorer.filemanager.xapk"
    "speedtest:Speedtest TV:navwonders.com.speedtest:navwonders.com.speedtest.xapk:https://github.com/nguyenlocthanh796/mitv-vn-setup/releases/download/v1.0.0/navwonders.com.speedtest.xapk"
)

IS_UPGRADE_MODE=0
INSTALL_TARGETS=()

if [ -n "$CLI_UPDATE_TARGET" ]; then
    IS_UPGRADE_MODE=1
    if [ "$CLI_UPDATE_TARGET" = "all" ]; then
        INSTALL_TARGETS=("${APPS_LIST[@]}")
    else
        for item in "${APPS_LIST[@]}"; do
            app_id=$(echo "$item" | cut -d: -f1)
            if [ "$app_id" = "$CLI_UPDATE_TARGET" ]; then
                INSTALL_TARGETS+=("$item")
            fi
        done
    fi
else
    # Menu chon che do cai dat / nang cap
    echo -e "\n${CYAN}----------------------------------------------------${NC}"
    echo -e "${YELLOW}       CHON CHE DO CAI DAT UNG DUNG                 ${NC}"
    echo -e "${CYAN}----------------------------------------------------${NC}"
    echo -e "  ${GREEN}[1]${NC} Cai DAY DU (15 app truyen hinh, phim, Youtube)"
    echo -e "  ${GREEN}[2]${NC} Cai CO BAN (5 app nhe cho TV RAM 1GB)"
    echo -e "  ${GREEN}[3]${NC} TU CHON ung dung theo so thu tu"
    echo -e "  ${GREEN}[4]${NC} CAP NHAT / NANG CAP ung dung (giu nguyen data)"
    echo -e "  ${YELLOW}[5]${NC} KHOI PHUC giao dien PatchWall goc nha san xuat"
    echo -e "${CYAN}----------------------------------------------------${NC}"

    SELECTED_MODE="1"
    echo -e "${YELLOW}Tu dong chon [1] sau 10 giay neu khong nhap...${NC}"
    if read -t 10 -r -p "Chon che do [1/2/3/4/5] (Mac dinh 1): " USER_INPUT; then
        if [ -n "$USER_INPUT" ]; then
            SELECTED_MODE="$USER_INPUT"
        fi
    else
        echo -e "\n${GREEN}[*] Het thoi gian cho. Tu dong chon Che do 1 (Day du).${NC}"
        SELECTED_MODE="1"
    fi

    if [ "$SELECTED_MODE" = "5" ]; then
        echo -e "\n${YELLOW}[*] Dang khoi phuc ve giao dien PatchWall goc...${NC}"
        adb -s "$TARGET_DEV" shell cmd package set-home-activity com.mitv.tvhome/.MainActivity 2>/dev/null || true
        adb -s "$TARGET_DEV" shell settings put secure enabled_accessibility_services '""' 2>/dev/null || true
        adb -s "$TARGET_DEV" shell settings put global window_animation_scale 1.0 2>/dev/null || true
        adb -s "$TARGET_DEV" shell settings put global transition_animation_scale 1.0 2>/dev/null || true
        adb -s "$TARGET_DEV" shell settings put global animator_duration_scale 1.0 2>/dev/null || true
        adb -s "$TARGET_DEV" shell pm enable com.miui.systemAdSolution 2>/dev/null || true
        adb -s "$TARGET_DEV" shell pm enable com.xiaomi.mitv.advertise 2>/dev/null || true
        adb -s "$TARGET_DEV" shell pm enable com.miui.tv.analytics 2>/dev/null || true
        adb -s "$TARGET_DEV" shell pm enable com.xiaomi.mibox.gamecenter 2>/dev/null || true
        adb -s "$TARGET_DEV" shell am start -n com.mitv.tvhome/.MainActivity 2>/dev/null || true
        echo -e "${GREEN}[OK] Da khoi phuc xong! Tivi tro ve nguyen ban xuat xuong.${NC}"
        exit 0
    elif [ "$SELECTED_MODE" = "2" ]; then
        echo -e "\n${CYAN}[*] Che do 2: Cai dat 5 ung dung thiet yeu cho TV RAM 1GB...${NC}"
        for item in "${APPS_LIST[@]}"; do
            app_id=$(echo "$item" | cut -d: -f1)
            if [ "$app_id" = "smarttube" ] || [ "$app_id" = "vtvgo" ] || [ "$app_id" = "tv360" ] || [ "$app_id" = "sftv" ]; then
                INSTALL_TARGETS+=("$item")
            fi
        done
    elif [ "$SELECTED_MODE" = "3" ]; then
        echo -e "\n${CYAN}--- DANH SACH UNG DUNG (1-15) ---${NC}"
        idx=1
        for item in "${APPS_LIST[@]}"; do
            app_name=$(echo "$item" | cut -d: -f2)
            printf "  [%2d] %s\n" "$idx" "$app_name"
            idx=$((idx + 1))
        done
        echo -e "${CYAN}---------------------------------${NC}"
        read -r -p "Nhap so cac app muon cai (VD: 1 3 5 hoac 1,2,5): " CUSTOM_CHOICES
        
        CHOICES_NORMAL=$(echo "$CUSTOM_CHOICES" | tr ',' ' ')
        for num in $CHOICES_NORMAL; do
            if [ "$num" -ge 1 ] && [ "$num" -le "${#APPS_LIST[@]}" ] 2>/dev/null; then
                INSTALL_TARGETS+=("${APPS_LIST[$((num - 1))]}")
            fi
        done
    elif [ "$SELECTED_MODE" = "4" ]; then
        IS_UPGRADE_MODE=1
        echo -e "\n${CYAN}--- CHON UNG DUNG CAN CAP NHAT / NANG CAP ---${NC}"
        idx=1
        for item in "${APPS_LIST[@]}"; do
            app_name=$(echo "$item" | cut -d: -f2)
            printf "  [%2d] %s\n" "$idx" "$app_name"
            idx=$((idx + 1))
        done
        echo -e "  [ A] Cap nhat TAT CA ung dung"
        echo -e "${CYAN}---------------------------------------------${NC}"
        read -r -p "Nhap so app muon nang cap (VD: 4 hoac A): " UPGRADE_CHOICE
        
        if [ "$UPGRADE_CHOICE" = "A" ] || [ "$UPGRADE_CHOICE" = "a" ]; then
            INSTALL_TARGETS=("${APPS_LIST[@]}")
        else
            CHOICES_NORMAL=$(echo "$UPGRADE_CHOICE" | tr ',' ' ')
            for num in $CHOICES_NORMAL; do
                if [ "$num" -ge 1 ] && [ "$num" -le "${#APPS_LIST[@]}" ] 2>/dev/null; then
                    INSTALL_TARGETS+=("${APPS_LIST[$((num - 1))]}")
                fi
            done
        fi
    else
        echo -e "\n${CYAN}[*] Che do 1: Cai dat tron bo tat ca ung dung...${NC}"
        INSTALL_TARGETS=("${APPS_LIST[@]}")
    fi
fi

echo -e "\n${GREEN}[+] Bat dau xu ly (${#INSTALL_TARGETS[@]} ung dung)...${NC}"

for item in "${INSTALL_TARGETS[@]}"; do
    app_id=$(echo "$item" | cut -d: -f1)
    app_name=$(echo "$item" | cut -d: -f2)
    app_pkg=$(echo "$item" | cut -d: -f3)
    asset_name=$(echo "$item" | cut -d: -f4)
    app_url=$(echo "$item" | cut -d: -f5)

    echo -e "\n  ${YELLOW}--> $app_name ($app_pkg)${NC}"
    
    APP_EXISTS=$(adb -s "$TARGET_DEV" shell pm list packages "$app_pkg" 2>/dev/null | grep -c "$app_pkg" || true)
    
    if [ "$APP_EXISTS" -gt 0 ] && [ "$IS_UPGRADE_MODE" -eq 0 ]; then
        echo -e "      ${GREEN}[Da co tren TV] Bo qua (Chon [4] de nang cap).${NC}"
        continue
    fi

    if [ "$APP_EXISTS" -gt 0 ] && [ "$IS_UPGRADE_MODE" -eq 1 ]; then
        CUR_VER=$(adb -s "$TARGET_DEV" shell dumpsys package "$app_pkg" 2>/dev/null | grep -m1 "versionName" | cut -d= -f2 || true)
        echo -e "      Phien ban hien tai: ${CYAN}${CUR_VER:-Khong ro}${NC}"
        echo -e "      Dang tien hanh nang cap..."
    fi

    TARGET_FILE="$CACHE_DIR/$asset_name"

    if [ "$IS_UPGRADE_MODE" -eq 1 ]; then
        rm -f "$TARGET_FILE"
    fi

    if [ ! -f "$TARGET_FILE" ]; then
        echo -e "      Dang tai tu CDN GitHub Release..."
        curl -L -s -o "$TARGET_FILE" "$app_url"
    fi

    if [ -f "$TARGET_FILE" ] && [ -s "$TARGET_FILE" ]; then
        echo -e "      Dang cai dat / ghi de (giu nguyen data)..."
        if [[ "$TARGET_FILE" == *.xapk ]]; then
            XAPK_DIR="$CACHE_DIR/${app_id}_split"
            rm -rf "$XAPK_DIR" && mkdir -p "$XAPK_DIR"
            unzip -q -o "$TARGET_FILE" -d "$XAPK_DIR" 2>/dev/null || true
            split_files=("$XAPK_DIR"/*.apk)
            if [ -f "${split_files[0]}" ]; then
                adb -s "$TARGET_DEV" install-multiple -r -g "${split_files[@]}" >/dev/null 2>&1 || true
            else
                adb -s "$TARGET_DEV" install -r -d -g "$TARGET_FILE" >/dev/null 2>&1 || true
            fi
            rm -rf "$XAPK_DIR"
        else
            adb -s "$TARGET_DEV" install -r -d -g "$TARGET_FILE" >/dev/null 2>&1 || true
        fi
        echo -e "      ${GREEN}[OK] Hoan tat!${NC}"
    else
        echo -e "      ${RED}[!] Khong the tai file. Bo qua.${NC}"
    fi
done

echo -e "\n${GREEN}[+] Khoi chay giao dien Projectivy Launcher tren TV...${NC}"
adb -s "$TARGET_DEV" shell am start -n com.spocky.projhost/.ui.HomeActivity >/dev/null 2>&1 || true

echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}       HOAN TAT TIEN TRINH TREN TIVI!               ${NC}"
echo -e "${GREEN}====================================================${NC}"
