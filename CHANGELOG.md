# Changelog

All notable changes to the **MiTV Vietnam Toolkit** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] - 2026-09-09

### Added
- **Private DNS Ad-Blocking (AdGuard DNS)**:
  - System-wide ad and telemetry blocking via `private_dns_mode hostname` and `private_dns_specifier dns.adguard-dns.com`.
  - Dedicated `-DnsOnly` switch in `setup.ps1` and `--dns-only` in `setup.sh` for fast standalone configuration.
  - Automatic restoration to default DNS mode when running with `-Restore` / `--restore`.
- **Local ADB Candidate Path Detection**:
  - Automatically detect and reuse existing local ADB binaries (including `C:\scrcpy-win64-v4.1\adb.exe`, `C:\scrcpy\adb.exe`, and Android SDK paths) before attempting network downloads.
  - Argument pass-through in `setup.bat`.

## [1.0.0] - 2026-09-08

### Added
- **1-Click Online Installer**:
  - `setup.ps1` for Windows PowerShell (`irm ... | iex`).
  - `setup.sh` for macOS, Linux, and Android Termux (`curl ... | bash`).
  - `setup.bat` double-click runner for desktop users.
- **Launcher Automation**:
  - Auto-installation and configuration of **Projectivy Launcher 4.71**.
  - Persistent Home button override via Android `ProjectivyAccessibilityService`.
  - Default Home Intent assignment via `cmd package set-home-activity`.
- **System Optimization**:
  - Real-time global animation scaling reduction (`window_animation_scale`, `transition_animation_scale`, `animator_duration_scale` set to `0.5x`).
- **Curated Application Suite (16 Apps)**:
  - Streaming & Live TV: VTV Go, TV360, FPT Play, VieON, OTT Navigator.
  - Video & Cinema: YouTube for Android TV, SmartTube, Cloudstream, Stremio, VLC.
  - Sports & Music: SportzX Live, Spotify TV.
  - Utilities: Send Files to TV, TV Bro, RS File Manager, Speedtest.
- **Offline Packaging**:
  - Full standalone offline deployment bundle (`MiTV-Vietnam-Full-Offline-v1.0.0.zip`) with embedded Google platform-tools ADB.
- **Mobile Support**:
  - Complete execution documentation for Android (Termux / Bugjaeger) and iOS (iSH Shell).
- **Engineering Architecture**:
  - Automated CI validation workflow, issue templates, security policy, and architectural specification.
