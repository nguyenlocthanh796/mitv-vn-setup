#!/usr/bin/env bash
# ===================================================================
#    MiTV Vietnam Toolkit - 1-Click ADB Setup (Mobile & PC)
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

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}     MiTV Vietnam Toolkit - 1-Click ADB Setup       ${NC}"
echo -e "${CYAN}====================================================${NC}"

if ! command -v adb &> /dev/null; then
    echo -e "${RED}[X] Chua cai dat adb. Vui long cai android-platform-tools!${NC}"
    exit 1
fi

adb start-server > /dev/null 2>&1

DEVICES=$(adb devices | grep -E '\s+device$' | awk '{print $1}')
DEV_COUNT=$(echo "$DEVICES" | grep -v '^$' | wc -l)

if [ "$DEV_COUNT" -eq 1 ]; then
    TARGET_DEV="$DEVICES"
    echo -e "${GREEN}[+] Phat hien thiet bi: $TARGET_DEV${NC}"
elif [ "$DEV_COUNT" -gt 1 ]; then
    echo -e "${YELLOW}Danh sach thiet bi ket noi:${NC}"
    echo "$DEVICES"
    read -r -p "Chon thiet bi: " TARGET_DEV
else
    read -r -p "Nhap dia chi IP Tivi Xiaomi (VD: 192.168.1.50:5555): " TARGET_DEV
    adb connect "$TARGET_DEV"
fi

echo -e "\n${GREEN}[+] Danh thuc va toi uu toc do he thong...${NC}"
adb -s "$TARGET_DEV" shell input keyevent KEYCODE_WAKEUP 2>/dev/null || true
adb -s "$TARGET_DEV" shell settings put global window_animation_scale 0.5
adb -s "$TARGET_DEV" shell settings put global transition_animation_scale 0.5
adb -s "$TARGET_DEV" shell settings put global animator_duration_scale 0.5

echo -e "\n${GREEN}[+] Cai dat Projectivy Launcher (Chặn PatchWall)...${NC}"
PROJECTIVY_APK="$CACHE_DIR/ProjectivyLauncher.apk"
if [ ! -f "$PROJECTIVY_APK" ]; then
    LATEST_URL=$(curl -s https://api.github.com/repos/spocky/miproja1/releases/latest | grep "browser_download_url.*apk" | cut -d : -f 2,3 | tr -d \" | head -n 1)
    if [ -z "$LATEST_URL" ]; then
        LATEST_URL="https://github.com/spocky/miproja1/releases/download/v4.71/Projectivy_Launcher_4.71.apk"
    fi
    curl -L -o "$PROJECTIVY_APK" "$LATEST_URL"
fi

adb -s "$TARGET_DEV" install -r -g "$PROJECTIVY_APK" >/dev/null 2>&1 || true
adb -s "$TARGET_DEV" shell cmd package set-home-activity com.spocky.projhost/.ui.HomeActivity 2>/dev/null || true
adb -s "$TARGET_DEV" shell settings put secure enabled_accessibility_services com.spocky.projhost/.services.ProjectivyAccessibilityService 2>/dev/null || true
adb -s "$TARGET_DEV" shell settings put secure accessibility_enabled 1 2>/dev/null || true

# -------------------------------------------------------------
# MENU CHỌN CHẾ ĐỘ CÀI ĐẶT ỨNG DỤNG (MOBILE OPTIMIZED)
# -------------------------------------------------------------
echo -e "\n${CYAN}----------------------------------------------------${NC}"
echo -e "${YELLOW}       CHON CHE DO CAI DAT UNG DUNG                 ${NC}"
echo -e "${CYAN}----------------------------------------------------${NC}"
echo -e "  ${GREEN}[1]${NC} Cai DAY DU (16 app truyen hinh, phim, Youtube)"
echo -e "  ${GREEN}[2]${NC} Cai CO BAN (5 app nhe cho TV RAM 1GB)"
echo -e "  ${GREEN}[3]${NC} TU CHON ung dung theo so thu tu"
echo -e "${CYAN}----------------------------------------------------${NC}"

SELECTED_MODE="1"
echo -e "${YELLOW}Tu dong chon [1] sau 10 giay neu khong nhap...${NC}"
if read -t 10 -r -p "Chon che do [1/2/3] (Mac dinh 1): " USER_INPUT; then
    if [ -n "$USER_INPUT" ]; then
        SELECTED_MODE="$USER_INPUT"
    fi
else
    echo -e "\n${GREEN}[*] Het thoi gian cho. Tu dong chon Che do 1 (Day du).${NC}"
    SELECTED_MODE="1"
fi

# Load danh muc ung dung
APPS_LIST=(
    "smarttube:SmartTube:org.smarttube.stable:https://github.com/yuliskov/SmartTube/releases/download/latest/smarttube_stable.apk"
    "vtvgo:VTV Go TV:vn.vtv.vtvgo:aptoide"
    "tv360:TV360 Smart TV:com.viettel.tv360.tv:aptoide"
    "fptplay:FPT Play TV:net.fptplay.ottbox:aptoide"
    "vieon:VieON TV:com.vieon.tv:aptoide"
    "sftv:Send Files to TV:com.yablio.sendfilestotv:aptoide"
    "youtubetv:YouTube for TV:com.google.android.youtube.tv:aptoide"
    "cloudstream:Cloudstream TV:com.lagradost.cloudstream3.prerelease:https://github.com/recloudstream/cloudstream/releases/download/v4.4.2/Cloudstream-v4.4.2.apk"
    "stremio:Stremio TV:com.stremio.one:https://dl.strem.io/four/v1.6.12/stremio-1.6.12-arm.apk"
    "vlc:VLC for Android:org.videolan.vlc:aptoide"
    "sportzx:SportzX Live:com.sportzx.live:https://sportzx.app/download/SportzX_new_2.6v.apk"
    "spotify:Spotify TV:com.spotify.tv.android:aptoide"
    "ottnavigator:OTT Navigator:studio.scillarium.ottnavigator:aptoide"
    "tvbro:TV Bro:com.phlox.tvwebbrowser:github_tvbro"
    "rsfile:RS File Manager:com.rs.explorer.filemanager:aptoide"
    "speedtest:Speedtest TV:navwonders.com.speedtest:aptoide"
)

INSTALL_TARGETS=()

if [ "$SELECTED_MODE" = "2" ]; then
    echo -e "\n${CYAN}[*] Che do 2: Cai dat 5 ung dung thiet yeu nhat cho TV RAM 1GB...${NC}"
    for item in "${APPS_LIST[@]}"; do
        app_id=$(echo "$item" | cut -d: -f1)
        if [ "$app_id" = "smarttube" ] || [ "$app_id" = "vtvgo" ] || [ "$app_id" = "tv360" ] || [ "$app_id" = "sftv" ]; then
            INSTALL_TARGETS+=("$item")
        fi
    done
elif [ "$SELECTED_MODE" = "3" ]; then
    echo -e "\n${CYAN}--- DANH SACH UNG DUNG (1-16) ---${NC}"
    idx=1
    for item in "${APPS_LIST[@]}"; do
        app_name=$(echo "$item" | cut -d: -f2)
        printf "  [%2d] %s\n" "$idx" "$app_name"
        idx=$((idx + 1))
    done
    echo -e "${CYAN}---------------------------------${NC}"
    read -r -p "Nhap so cac app muon cai (VD: 1 3 5 hoac 1,2,5): " CUSTOM_CHOICES
    
    # Chuan hoa chuoi phan cach
    CHOICES_NORMAL=$(echo "$CUSTOM_CHOICES" | tr ',' ' ')
    for num in $CHOICES_NORMAL; do
        if [ "$num" -ge 1 ] && [ "$num" -le "${#APPS_LIST[@]}" ] 2>/dev/null; then
            INSTALL_TARGETS+=("${APPS_LIST[$((num - 1))]}")
        fi
    done
else
    echo -e "\n${CYAN}[*] Che do 1: Cai dat tron bo tat ca ung dung...${NC}"
    INSTALL_TARGETS=("${APPS_LIST[@]}")
fi

echo -e "\n${GREEN}[+] Bat dau cai dat cac ung dung da chon (${#INSTALL_TARGETS[@]} ung dung)...${NC}"

for item in "${INSTALL_TARGETS[@]}"; do
    app_id=$(echo "$item" | cut -d: -f1)
    app_name=$(echo "$item" | cut -d: -f2)
    app_pkg=$(echo "$item" | cut -d: -f3)
    app_source=$(echo "$item" | cut -d: -f4)

    echo -e "\n  ${YELLOW}--> $app_name ($app_pkg)${NC}"
    
    # Kiem tra da cai chua
    if adb -s "$TARGET_DEV" shell pm list packages "$app_pkg" 2>/dev/null | grep -q "$app_pkg"; then
        echo -e "      ${GREEN}[Da co tren TV] Bo qua.${NC}"
        continue
    fi

    TARGET_FILE="$CACHE_DIR/$app_id.apk"

    if [ ! -f "$TARGET_FILE" ]; then
        if [[ "$app_source" =~ ^http.*\.apk$ ]]; then
            echo -e "      Dang tai truc tiep..."
            curl -L -s -o "$TARGET_FILE" "$app_source"
        elif [ "$app_source" = "github_tvbro" ]; then
            echo -e "      Dang tai ban moi nhat tu GitHub..."
            DOWN_URL=$(curl -s https://api.github.com/repos/truefedex/tv-bro/releases/latest | grep "browser_download_url.*generic-geckoExcluded.apk" | cut -d : -f 2,3 | tr -d \" | head -n 1)
            curl -L -s -o "$TARGET_FILE" "$DOWN_URL"
        elif [ "$app_source" = "aptoide" ]; then
            echo -e "      Dang tim kiem ban TV qua Aptoide..."
            APTOIDE_PATH=$(curl -s "http://ws75.aptoide.com/api/7/apps/search?query=$app_pkg" | grep -o '"path":"[^"]*"' | head -n 1 | cut -d\" -f4)
            if [ -n "$APTOIDE_PATH" ]; then
                curl -L -s -o "$TARGET_FILE" "$APTOIDE_PATH"
            fi
        fi
    fi

    if [ -f "$TARGET_FILE" ] && [ -s "$TARGET_FILE" ]; then
        echo -e "      Dang cai dat qua ADB..."
        adb -s "$TARGET_DEV" install -r -g "$TARGET_FILE" >/dev/null 2>&1 || true
        echo -e "      ${GREEN}[OK] Da cai dat thanh cong!${NC}"
    else
        echo -e "      ${RED}[!] Khong the tai goi APK. Bo qua.${NC}"
    fi
done

echo -e "\n${GREEN}[+] Khoi chay giao dien Projectivy Launcher tren TV...${NC}"
adb -s "$TARGET_DEV" shell am start -n com.spocky.projhost/.ui.HomeActivity >/dev/null 2>&1 || true

echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}       HOAN TAT CAI DAT VA TOI UU TIVI!             ${NC}"
echo -e "${GREEN}====================================================${NC}"
