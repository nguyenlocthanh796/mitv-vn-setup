@echo off
title MiTV Vietnam Toolkit - 1-Click ADB Setup
chcp 65001 >nul
cls

echo ===================================================================
echo     MiTV Vietnam Toolkit - Khoi chay cai dat tu dong
echo ===================================================================
echo.
echo Dang khoi dong PowerShell...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %*

echo.
echo Nhan phim bat ky de thoat...
pause >nul
