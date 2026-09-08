# Troubleshooting & Diagnostics Guide

This document lists standard error codes, diagnostics, and step-by-step resolutions for common issues encountered during setup.

---

## Error Matrix

| Symptom / Error | Root Cause | Resolution |
| :--- | :--- | :--- |
| `adb: unable to connect to 192.168.x.x:5555: Connection refused` | ADB Debugging is not toggled on, or wrong IP entered. | 1. Double-check IP under TV Wi-Fi settings.<br>2. Confirm `ADB调试` is toggled to **开启 (On)** in TV Settings. |
| `adb: device unauthorized` | RSA key dialog was not approved on the TV screen. | Check the TV screen. A prompt *"Allow USB debugging?"* will appear. Select **Always allow from this computer** and click **OK**. |
| `adb: device offline` | Broken TCP keepalive or Wi-Fi power-save sleep on TV. | Run `adb disconnect` followed by `adb kill-server`, then reconnect. Ensure TV screen is awake. |
| `INSTALL_FAILED_INSUFFICIENT_STORAGE` | TV internal flash memory is full (< 500MB free). | Go to TV Settings -> Apps -> Uninstall unused Chinese games or clear cache. |
| `INSTALL_FAILED_OLDER_SDK` | Target application requires a higher Android API level. | Some newer apps require Android 10+. If running on older Android 8/9 devices, older APK fallbacks in `apps.json` are selected automatically. |
| Remote Home button still opens PatchWall | Accessibility service was not granted or toggled off. | Re-run script or manually toggle `Projectivy Accessibility Service` to **ON** under TV Settings -> Accessibility. |
| Script hangs during APK download | Slow international bandwidth to GitHub or APK CDN. | Use the standalone **Offline Package** (`MiTV-Vietnam-Full-Offline-v1.0.0.zip`), which installs locally without internet. |

---

## Diagnostic Commands

Run these commands in PowerShell or Terminal to inspect television state:

```bash
# 1. Check connected devices and authorization state
adb devices -l

# 2. Check TV SoC model and Android version
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release

# 3. Check free storage on TV data partition
adb shell df -h /data

# 4. Check active accessibility services
adb shell settings get secure enabled_accessibility_services

# 5. Restart ADB Server
adb kill-server
adb start-server
```
