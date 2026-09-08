#!/usr/bin/env bash
# ===================================================================
#    MiTV Vietnam Toolkit - 1-Click ADB Setup (macOS / Linux)
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

echo -e "${CYAN}===================================================================${NC}"
echo -e "${CYAN}    MiTV Vietnam Toolkit - 1-Click ADB Setup (macOS / Linux)       ${NC}"
echo -e "${CYAN}===================================================================${NC}"

if ! command -v adb &> /dev/null; then
    echo -e "${RED}[X] Khong tim thay lệnh adb tren he thong. Vui long cai android-platform-tools truoc!${NC}"
    exit 1
fi

adb start-server > /dev/null 2>&1

DEVICES=$(adb devices | grep -E '\s+device$' | awk '{print $1}')
DEV_COUNT=$(echo "$DEVICES" | grep -v '^$' | wc -l)

if [ "$DEV_COUNT" -eq 1 ]; then
    TARGET_DEV="$DEVICES"
    echo -e "${GREEN}[+] Phat hien thiet bi: $TARGET_DEV${NC}"
elif [ "$DEV_COUNT" -gt 1 ]; then
    echo -e "${YELLOW}Danh sach thiet bi:${NC}"
    echo "$DEVICES"
    read -p "Nhap thiet bi can cai: " TARGET_DEV
else
    read -p "Nhap dia chi IP Tivi Xiaomi (VD: 192.168.1.50:5555): " TARGET_DEV
    adb connect "$TARGET_DEV"
fi

echo -e "\n${GREEN}[+] Danh thuc va toi uu Tivi...${NC}"
adb -s "$TARGET_DEV" shell input keyevent KEYCODE_WAKEUP
adb -s "$TARGET_DEV" shell settings put global window_animation_scale 0.5
adb -s "$TARGET_DEV" shell settings put global transition_animation_scale 0.5
adb -s "$TARGET_DEV" shell settings put global animator_duration_scale 0.5

echo -e "\n${GREEN}[+] Cai dat Projectivy Launcher...${NC}"
PROJECTIVY_APK="$CACHE_DIR/ProjectivyLauncher.apk"
if [ ! -f "$PROJECTIVY_APK" ]; then
    LATEST_URL=$(curl -s https://api.github.com/repos/spocky/miproja1/releases/latest | grep "browser_download_url.*apk" | cut -d : -f 2,3 | tr -d \" | head -n 1)
    curl -L -o "$PROJECTIVY_APK" $LATEST_URL
fi

adb -s "$TARGET_DEV" install -r -g "$PROJECTIVY_APK"
adb -s "$TARGET_DEV" shell cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity
adb -s "$TARGET_DEV" shell settings put secure enabled_accessibility_services com.spocky.projengmenu/.services.ProjectivyAccessibilityService
adb -s "$TARGET_DEV" shell settings put secure accessibility_enabled 1
adb -s "$TARGET_DEV" shell settings put secure enabled_notification_listeners com.spocky.projengmenu/com.spocky.projengmenu.services.notification.NotificationListener

echo -e "\n${GREEN}[+] Hoan tat thiet lap! Dang mo Projectivy Launcher tren TV...${NC}"
adb -s "$TARGET_DEV" shell am start -n com.spocky.projengmenu/.ui.home.MainActivity

echo -e "${GREEN}===================================================================${NC}"
echo -e "${GREEN}   CAI DAT VA TOI UU THANH CONG!                                   ${NC}"
echo -e "${GREEN}===================================================================${NC}"
