@echo off
setlocal
rem Require administrative privileges for installation/uninstallation
>nul 2>&1 net session || (
    echo This script requires administrative privileges. Please run as Administrator.
    exit /b 1
)
rem Support a dry-run mode: pass --dryrun as the first argument to print actions instead of executing
if /I "%~1"=="--dryrun" (
    set "DRYRUN=1"
    set "CMDPREFIX=echo"
) else (
    set "CMDPREFIX="
)
set "APPNAME=ERStudio Data Architect"
set "APPVENDOR=IDERA"
set "APPVERSION=20.8.0.18022"
set "OldAppName=IDERA ERStudio Data Architect 20.0"
set "OldAppVersion=20.0.1.12769"


if /I "%~1"=="Uninstall" goto :Uninstall

REM =====================================================
REM Pre Installation
REM =====================================================
echo Checking for older versions,please wait...
REM Get the exact version using PowerShell
for /f "delims=" %%A in ('powershell -Command "(Get-Package | Where-Object { $_.Name -ieq '%OldAppName%' -and $_.Version -eq '%OldAppVersion%' }).Version.ToString()"') do (
    set "packageVersion=%%A"
)

REM Check and uninstall
if "%packageVersion%"=="%OldAppVersion%" (
    echo Found matching version. Uninstalling...
    %CMDPREFIX% "C:\ProgramData\Package Cache\{dfa0a0bc-bd96-44f6-83b3-2f3d247dcb07}\ERDA.exe" /uninstall /quiet
    if exist "C:\ProgramData\Embarcadero" %CMDPREFIX% RD /S /Q "C:\ProgramData\Embarcadero"
) else (
    echo Version not matched. Skipping uninstallation.
)

REM =====================================================
REM INSTALLATION
REM =====================================================
echo Installing %APPVENDOR% %APPNAME% v%APPVERSION%, Please wait...
%CMDPREFIX% "%~dp0ERStudio_Data_Architect_20.8.0_Windows_Client.exe" /install /quiet /norestart
set msierror=%errorlevel%
if %msierror%==0 goto :PostInstall
if %msierror%==259 goto :PostInstall
if %msierror%==1641 goto :PostInstall
if %msierror%==3010 goto :PostInstall

goto :ERROR

REM =====================================================
REM post Installation
REM =====================================================

:PostInstall
@echo Successfully Installed %APPVENDOR% %APPNAME% v%APPVERSION%.
if exist "C:\Users\Public\Desktop\ERStudio Data Architect 20.8.lnk" %CMDPREFIX% del /f /q "C:\Users\Public\Desktop\ERStudio Data Architect 20.8.lnk"
rem Ensure destination exists then copy slip files (supports dry-run)
if not exist "C:\ProgramData\Embarcadero" %CMDPREFIX% md "C:\ProgramData\Embarcadero"
%CMDPREFIX% xcopy "%~dp0concurrent_527244 (1).slip" "C:\ProgramData\Embarcadero\" /S /I /Y
%CMDPREFIX% xcopy "%~dp0concurrent_533097 (1).slip" "C:\ProgramData\Embarcadero\" /S /I /Y

goto :Einde

REM =====================================================
REM Main Uninstallation
REM =====================================================

:Uninstall

REM =====================================================
REM Pre Uninstallation
REM =====================================================
@echo off
set "processName=MyPCSelfHelp.exe"

REM Check if the process is running
tasklist /FI "IMAGENAME eq %processName%" | find /I "%processName%" >nul
if %ERRORLEVEL%==0 (
    echo %processName% is running. Attempting to terminate...
    %CMDPREFIX% taskkill /F /IM "%processName%"
) else (
    echo %processName% is not running.
)


REM =====================================================
REM Uninstallation
REM =====================================================

echo Uninstalling %APPVENDOR% %APPNAME% v%APPVERSION%, Please wait...
%CMDPREFIX% rmdir "C:\Program Files\PCT" /s /q

%CMDPREFIX% del "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\MyPCSelfHelp.lnk" /s /q

%CMDPREFIX% del "%PUBLIC%\Desktop\MyPCSelfHelp.lnk" /s /q

REM REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\EDF\PCTool" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\EDF" /f
set msierror=%errorlevel%
if %msierror%==0 goto :PostUninstall
if %msierror%==259 goto :PostUninstall
if %msierror%==1641 goto :PostUninstall
if %msierror%==3010 goto :PostUninstall

goto :ERROR

REM =====================================================
REM Post Uninstallation
REM =====================================================

:PostUninstall
@echo Successfully Uninstalled %APPVENDOR% %APPNAME% v%APPVERSION%.

goto :Einde

:Error
@echo Error Code is %msierror%
if exist "%LogFile%" type "%LogFile%"
goto :Einde

rem Preserve return code across endlocal
set "rc=%msierror%"
endlocal

:Einde
@echo Job ended at %date% %Time%
Exit /B %rc%
