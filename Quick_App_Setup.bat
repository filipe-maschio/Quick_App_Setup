@echo off
setlocal EnableDelayedExpansion

:: Customize console window size (columns and rows)
mode con: cols=60 lines=38

timeout /t 1 >nul

powershell -NoProfile -Command ^
"$w = $Host.UI.RawUI.WindowSize.Width; ^
$Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size ($w,3000)"

title Smart Setup Fill v1.0.1
chcp 65001 >nul

set LOGLEVEL=2

:: =========================
:: AUTO ELEVATE TO ADMIN
:: =========================
if /i "%~1"=="admin" goto start

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Elevating to admin...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -ArgumentList ('admin ' + '%*') -Verb RunAs"
    exit /b
)

:start
call :parse_args %*

set "INSTALLED_LIST="
set "SKIPPED_LIST="
set "ERROR_LIST="

for /f %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"
color 07

call :seed_apps
call :check_prerequisites || goto end

:: Define entry point
goto menu


:: =========================
:: APP CATALOG
:: =========================
:seed_apps
set "APP_COUNT=0"

:: To add an app...
:: add: call :add_app "X" "Y"
:: Where: X = display name, Y = winget ID
:: Names with spaces are not supported
:: To remove, simply delete the line

call :add_app "Google_Chrome" "Google.Chrome"
call :add_app "Google_Drive" "Google.GoogleDrive"
call :add_app "MEGA" "Mega.MEGASync"
call :add_app "Dropbox" "Dropbox.Dropbox"
call :add_app "Obsidian" "Obsidian.Obsidian"
call :add_app "Notepad++" "Notepad++.Notepad++"
call :add_app "Anki" "Anki.Anki"
call :add_app "KeePassXC" "KeePassXCTeam.KeePassXC"
call :add_app "Foxit_PDF" "Foxit.FoxitReader"
call :add_app "WinRAR" "RARLab.WinRAR"
call :add_app "PowerToys" "Microsoft.PowerToys"
call :add_app "Proton_VPN" "Proton.ProtonVPN"
call :add_app "Windows_Terminal" "Microsoft.WindowsTerminal"
call :add_app "Wireshark" "WiresharkFoundation.Wireshark"
call :add_app "PatchMyPC" "PatchMyPC.PatchMyPC"
call :add_app "Miro" "Miro.Miro"
call :add_app "VLC" "VideoLAN.VLC"
call :add_app "VS_Code" "Microsoft.VisualStudioCode"
call :add_app "Python_3.11" "Python.Python.3.11"
call :add_app "Python_3.14" "Python.Python.3.14"
call :add_app "Git" "Git.Git"
call :add_app "GitHub_CLI" "GitHub.cli"

exit /b 0


:: =========================
:: PRE-CHECKS
:: =========================
:check_prerequisites
winget --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo %ESC%[31m  ✖  Winget not found on this system.%ESC%[0m
    echo %ESC%[33m  ⚠  Install or update App Installer and try again.%ESC%[0m
    echo.
    exit /b 1
)
exit /b 0

:: =========================
:: PARSE ARGS
:: =========================
:parse_args
if "%~1"=="" exit /b 0

if /i "%~1"=="admin" (
    shift
    goto parse_args
)

if /i "%~1"=="--log" (
    if not "%~2"=="" (
        set "LOGLEVEL=%~2"
        shift
    )
)

shift
goto parse_args


:: =========================
:: EXECUTE WINGET BASED ON LOG LEVEL
:: =========================
:run_winget
set "winget_id=%~1"

:: =========================
:: FIRST ATTEMPT
:: =========================
if "%LOGLEVEL%"=="" (
    winget install --id "%winget_id%" -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
) else if "%LOGLEVEL%"=="2" (
    winget install --id "%winget_id%" -e --accept-package-agreements --accept-source-agreements --disable-interactivity
) else if "%LOGLEVEL%"=="3" (
    winget install --id "%winget_id%" -e --accept-package-agreements --accept-source-agreements --verbose-logs
) else (
    winget install --id "%winget_id%" -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
)

:: =========================
:: RETRY LOGIC
:: =========================
if %errorlevel% neq 0 (
    echo %ESC%[33m  ⚠  First attempt failed. Retrying...%ESC%[0m
    timeout /t 2 >nul

    if "%LOGLEVEL%"=="" (
        winget install --id "%winget_id%" -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
    ) else if "%LOGLEVEL%"=="2" (
        winget install --id "%winget_id%" -e --accept-package-agreements --accept-source-agreements --disable-interactivity
    ) else if "%LOGLEVEL%"=="3" (
        winget install --id "%winget_id%" -e --accept-package-agreements --accept-source-agreements --verbose-logs
    ) else (
        winget install --id "%winget_id%" -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
    )
)

exit /b %errorlevel%


:: =========================
:: REMOVE DUPLICATES FROM LIST
:: =========================
:add_unique
set "var_name=%~1"
set "value=%~2"
set "token= %value% "

echo !%var_name%! | findstr /i /c:"%token%" >nul
if errorlevel 1 set "%var_name%=!%var_name%! %value%"
exit /b 0


:: =========================
:: PROCESS USER SELECTION
:: =========================
:process_choice
set "opt=%~1"

if not defined opt (
    echo %ESC%[33m  ⚠  Invalid option ignored: %~1%ESC%[0m
    exit /b 1
)

if defined SEEN_%opt% (
    echo %ESC%[33m  ⚠  Duplicate option ignored: %opt%%ESC%[0m
    exit /b 0
)

call set "app_label=%%APP_%opt%_LABEL%%"
call set "app_id=%%APP_%opt%_ID%%"

if not defined app_id (
    echo %ESC%[33m  ⚠  Invalid option ignored: %opt%%ESC%[0m
    exit /b 1
)

set "SEEN_%opt%=1"

call :install "%app_label%" "%app_id%"
exit /b 0


:: =========================
:: APP INSTALLATION
:: =========================
:install
set "app_label=%~1"
set "app_id=%~2"

echo  Installing "%app_label%"...
timeout /t 1 /nobreak >nul
echo  Please wait... this may take a few minutes
echo.
timeout /t 1 /nobreak >nul


if /i "%app_id%"=="Git.Git" (
    git --version >nul 2>&1
) else (
    winget list --id "%app_id%" -e >nul 2>&1
)

if %errorlevel% equ 0 (
    call :add_unique SKIPPED_LIST "%app_label%"
    echo %ESC%[33m   ⚠  %app_label% already installed%ESC%[0m
    echo.
    echo ----------------------------------------
    exit /b 0
)

call :run_winget "%app_id%"

winget list --id "%app_id%" -e >nul 2>&1
if %errorlevel% equ 0 (
    call :add_unique INSTALLED_LIST "%app_label%"
    echo.
    echo %ESC%[32m   ✔  %app_label% installed%ESC%[0m
    echo.
    echo ----------------------------------------
    exit /b 0
)

call :add_unique ERROR_LIST "%app_label%"
echo.
echo %ESC%[31m   ✖  %app_label% failed%ESC%[0m
echo.
echo ----------------------------------------
exit /b 1


:: =========================
:: MENU
:: =========================
:menu
cls
echo =========================================================
echo                   QUICK_APP_SETUP V.1.0.1
echo =========================================================
echo.
echo  Select the applications to install:
echo.
for /L %%i in (1,1,%APP_COUNT%) do (
    call echo  [%%i] %%APP_%%i_LABEL%%
)
echo.
echo  Enter multiple numbers (1 2 6 10), then press ENTER
echo  [0] Exit
echo.

set /p escolha=Select:
if "%escolha%"=="0" goto end

echo.
echo =========================================================
echo                        EXECUTION
echo =========================================================
echo.

set "START_TIME=%time%"

for %%a in (%escolha%) do call :process_choice %%a

echo.
echo.
echo %ESC%[32m ...INSTALLATIONS COMPLETED%ESC%[0m
echo.
echo.
timeout /t 2 /nobreak >nul

set "END_TIME=%time%"
call :CalculateElapsedTime "%START_TIME%" "%END_TIME%"


echo =========================================================
echo                        FINAL SUMMARY
echo ---------------------------------------------------------
echo                 Execution time: %ELAPSED_FORMATTED%
echo =========================================================

echo.

echo %ESC%[32m  ✔  INSTALLED:%ESC%[0m
echo.
if defined INSTALLED_LIST (
    for %%i in (!INSTALLED_LIST!) do echo    - %%~i
) else (
    echo      No items
)

echo.
echo %ESC%[33m  ⚠  ALREADY INSTALLED:%ESC%[0m
echo.
if defined SKIPPED_LIST (
    for %%i in (!SKIPPED_LIST!) do echo    - %%~i
) else (
    echo      No items
)

echo.
echo %ESC%[31m  ✖  ERRORS:%ESC%[0m
echo.
if defined ERROR_LIST (
    for %%i in (!ERROR_LIST!) do echo    - %%~i
) else (
    echo      No items
)

echo.
echo.
echo Press any key to exit...
pause >nul
goto end

:CalculateElapsedTime
set "start=%~1"
set "end=%~2"

for /f "tokens=1-4 delims=:., " %%a in ("%start%") do (
    set /a "start_sec=(((1%%a%%100)*60)+(1%%b%%100))*60+(1%%c%%100)"
)
for /f "tokens=1-4 delims=:., " %%a in ("%end%") do (
    set /a "end_sec=(((1%%a%%100)*60)+(1%%b%%100))*60+(1%%c%%100)"
)

set /a "elapsed=end_sec-start_sec"
if %elapsed% lss 0 set /a "elapsed+=86400"

set /a "mins=elapsed/60"
set /a "secs=elapsed%%60"

set "ELAPSED_FORMATTED=%mins%m %secs%s"
exit /b

:add_app
set /a APP_COUNT+=1
set "APP_%APP_COUNT%_LABEL=%~1"
set "APP_%APP_COUNT%_ID=%~2"
exit /b

:end
exit /b