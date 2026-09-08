# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |
| < 1.0   | :x:                |

## Architectural Safety Guarantees

The **MiTV Vietnam Toolkit** adheres strictly to the Android Open Source Project (AOSP) userland security boundary:

1. **Non-Root Operation**:
   - The toolkit operates entirely via standard Android Debug Bridge (`adb`) shell APIs.
   - It **never** executes `su`, exploits privilege escalation vulnerabilities, or unlocks device bootloaders.
2. **System Partition Immutability**:
   - No modifications are made to `/system`, `/vendor`, or `/product` partitions.
   - All app installations are routed through Android's standard Package Manager (`pm install`).
   - All launcher overrides utilize the official Android Accessibility Service (`ProjectivyAccessibilityService`) and `cmd package set-home-activity`.
3. **Data Privacy**:
   - The scripts collect **zero** telemetry, crash reports, or user information.
   - Network requests are restricted strictly to fetching verified open-source releases from GitHub and official APK mirrors.
4. **Reversibility**:
   - Performing a standard Factory Reset on the television completely clears all installed packages and restores the device to factory state.

## Reporting a Vulnerability

If you discover a security vulnerability or malicious behavior in any linked APK source:
1. Do **NOT** open a public GitHub Issue.
2. Send an email with reproduction steps to the maintainer or open a private security advisory via GitHub Security Advisories.
3. We will acknowledge receipt within 48 hours and patch affected URLs or release signatures promptly.
