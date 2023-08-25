ECHO OFF
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if "%errorlevel%" NEQ "0" (
	echo: Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
	echo: UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
	"%temp%\getadmin.vbs" &	exit 
)
if exist "%temp%\getadmin.vbs" del /f /q "%temp%\getadmin.vbs"
CLS
@echo off
call :_getostype %osarch
echo Rolling Back Windows 10 Spooler %osarch% files from %~dp0

for /f "tokens=2 delims=," %%i in ('wmic os get version /format:csv') do set osver=%%i
for /f "tokens=1 delims=." %%i in ("%osver%") do set osver=%%i
IF NOT "%osver%" == "10" goto :_wrongos

NET SESSION >nul 2>&1
IF NOT %ERRORLEVEL% EQU 0 goto :_norights

set "osdir=%WINDIR%\system32\"

Echo Checking for KB5006670 version 10.0.19041.1288 files
call :_checkfile "%osdir%" "localspl.dll" "10.0.19041.1288"
call :_checkfile "%osdir%" "win32spl.dll" "10.0.19041.1288"
call :_checkfile "%osdir%" "spoolsv.exe"  "10.0.19041.1288"

Echo Checking for KB5006738 version 10.0.19041.1320 files
call :_checkfile "%osdir%" "win32spl.dll" "10.0.19041.1320"
call :_checkfile "%osdir%" "spoolsv.exe"  "10.0.19041.1320"

Echo Checking for KB5006738 version 10.0.19041.1320 files
call :_checkfile "%osdir%" "win32spl.dll" "10.0.19041.1379"
call :_checkfile "%osdir%" "spoolsv.exe"  "10.0.19041.1379"

Echo Checking for KB5007186 version 10.0.19041.1387 files
call :_checkfile "%osdir%" "win32spl.dll" "10.0.19041.1387"
call :_checkfile "%osdir%" "spoolsv.exe"  "10.0.19041.1387"

goto :_end

:_checkfile 
echo Checking %~1%~2

copy  "%~dp0%osarch%\%~2" "%~1%~2.good" /Y
call :_getversion "%~1%~2" %existver
call :_getversion "%~1%~2.good" %goodver

IF %goodver%==%existver% echo "Files are the same version %goodver%" && goto :_delgood
IF "%existver%"=="%~3" echo "Existing File is a bad version %existver% and needs swapping"&& call :_swap "%~1" "%~2" "%existver%" && exit /b
echo "File is a different version %existver%, Ignoring"  
:_delgood
del "%~1%~2.good"
exit /b

:_stop_spooler
echo Stopping Spooler
net stop spooler
timeout /t 3 /nobreak > nul
set "spooler_stopped=yes"
exit /b

:_start_spooler
echo Starting Spooler
net start spooler
timeout /t 3 /nobreak > nul
set "spooler_stopped=no" 
exit /b

:_take_control
echo Taking Control of "%~1"
Takeown /A /F "%~1"
icacls  "%~1" /grant builtin\administrators:F
icacls  "%~1" /grant SYSTEM:F
exit /b

:_getversion  
SETLOCAL
set "file=%~1"
set "item1=%file:\=\\%"
for /f "usebackq delims=" %%a in (`"WMIC DATAFILE WHERE name='%item1%' get Version /format:Textvaluelist"`) do (
    for /f "delims=" %%# in ("%%a") do set "%%#")
ENDLOCAL&set %~2=%version%
exit /b

:_getostype  
SETLOCAL
for /f "usebackq delims=" %%a in (`"WMIC os get OSArchitecture /format:Textvaluelist"`) do (
    for /f "delims=" %%# in ("%%a") do set "%%#")
ENDLOCAL&set %~1=%OSArchitecture%
exit /b

:_swap
echo Swapping "%~1%~2" to "%~3"
IF NOT "%spooler_stopped%" == "yes" call :_stop_spooler
call :_take_control "%~1%~2"
IF EXIST "%~2-%~3" del "%~2-%~3"
ren  "%~1%~2" "%~2-%~3"
ren  "%~1%~2.good" "%~2"
echo Swap Completed
exit /b

:_wrongos
echo This script was intended for Windows 10.
echo It can be used on Server's but you need to source the correct bins.
pause
goto :_exit

:_norights
echo Admin Privileges required.
pause
goto :_exit

:_end
IF "%spooler_stopped%" == "yes" call :_start_spooler
echo.
echo ===================================
echo Fix Regedit
echo.
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v "RpcAuthnLevelPrivacyEnabled" /t REG_DWORD /d "0" /f
echo ====================================
echo Rolling Back Spooler files Complete.
echo.
pause
:_exit
