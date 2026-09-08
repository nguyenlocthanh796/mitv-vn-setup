@echo off
cd /d "%~dp0\.."
echo ========================================================
echo Dang day code len GitHub: nguyenlocthanh796/mitv-vn-setup
echo ========================================================
git push -u origin main
echo.
if %ERRORLEVEL% equ 0 (
    echo [OK] Day code len GitHub thanh cong!
) else (
    echo [LOI] Khong the push code. Kiem tra dang nhap GitHub.
)
pause
