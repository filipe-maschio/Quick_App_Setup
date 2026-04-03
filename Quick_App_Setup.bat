@echo off
title Setup Inteligente Fill v.4.4
chcp 65001 >nul

set LOGLEVEL=2

:: =========================
:: AUTO ELEVAR PARA ADMIN
:: =========================

:: Se já veio elevado → continua
if "%~1"=="admin" goto start

:: Testa privilégio admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Elevando para administrador...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -ArgumentList 'admin' -Verb RunAs"
    exit
)

:start

setlocal enabledelayedexpansion

set INSTALLED_LIST=
set SKIPPED_LIST=
set ERROR_LIST=

color 07
for /f %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"

:: Cores
:: Verde = echo %ESC%[32m[OK] %1 concluido%ESC%[0m
:: Vermelho = echo %ESC%[31m[ERRO] Falha ao instalar %1%ESC%[0m
:: Amarelo = echo %ESC%[33m[SKIP] %1 ja instalado%ESC%[0m

:: Define ponto de entrada
goto menu

:: =========================
:: FUNCAO PROGRESSO
:: =========================
:progress
setlocal enabledelayedexpansion
set bar=

for %%p in (10 20 30 40 50 60 70 80 90 100) do (
    set bar=!bar!#
    echo [!bar!] %%p%%
    timeout /t 1 >nul
)

endlocal
goto :eof

:: =========================
:: FUNCAO WINGET COM LOG LEVEL
:: =========================
:run_winget

:: LOGLEVEL vazio = silencioso
if "%LOGLEVEL%"=="" (
    winget install --id %1 -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
    goto :eof
)

:: LOG PARCIAL
if "%LOGLEVEL%"=="1" (
    winget install --id %1 -e --accept-package-agreements --accept-source-agreements --disable-interactivity
    goto :eof
)

:: LOG COMPLETO
if "%LOGLEVEL%"=="2" (
    winget install --id %1 -e --accept-package-agreements --accept-source-agreements --verbose-logs
    goto :eof
)

:: fallback (segurança)
winget install --id %1 -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
goto :eof

:: =========================
:: FUNCAO INSTALL
:: =========================
:install
echo  Instalando "%~1"...
echo  Aguarde... isso pode levar alguns minutos
echo.

:: já instalado?
winget list --id %2 -e >nul 2>&1

if %errorlevel% equ 0 (
    call :add_unique SKIPPED_LIST "%~1"
    echo %ESC%[33m   ⚠  %~1 ja instalado%ESC%[0m
    echo.
    echo ----------------------------------------
    goto :eof
)

call :run_winget %2

if %errorlevel% equ 0 (
    call :add_unique INSTALLED_LIST "%~1"
    echo.
    echo %ESC%[32m   ✔  %~1 instalado%ESC%[0m
    echo.
    echo ----------------------------------------

) else (
    call :add_unique ERROR_LIST "%~1"
    echo.
    echo %ESC%[31m   ✖  %~1 falhou%ESC%[0m
    echo.
    echo ----------------------------------------
)

goto :eof

:: =========================
:: FUNCAO ADD UNIQUE
:: =========================
:add_unique
set "var_name=%~1"
set "value=%~2"

for %%# in ("!%var_name%!") do set "current=%%~#"

echo !current! | findstr /i "%value%" >nul
if errorlevel 1 (
    set "%var_name%=!current! %value%"
)
goto :eof

:: =========================
:: FUNCAO SPINNER
:: =========================
:spinner
setlocal enabledelayedexpansion

set chars=|/-\
for /l %%i in (1,1,20) do (
    for %%c in (!chars!) do (
        <nul set /p= Instalando... %%c`r
        timeout /t 1 >nul
    )
)

endlocal
goto :eof

:: =========================
:: MENU
:: =========================
:menu
cls
echo ===============================================
echo              SETUP DE APLICATIVOS
echo ===============================================
echo                                        Fill 4.4
echo.
echo  Selecione os apps para instalar:
echo.
echo  [1] Google_Chrome
echo  [2] Tor_Browser
echo  [3] Google_Drive
echo  [4] Mega
echo  [5] Obsidian
echo  [6] Anki
echo  [7] KeePass
echo  [8] Notepad++
echo  [9] Foxit_PDF
echo  [10] WinRAR
echo  [11] PowerToys
echo  [12] Wireshark
echo.
echo  Digite varios numeros (ex: 1 5 10)
echo  [0] Sair
echo.

set /p escolha=Escolha:

if "%escolha%"=="0" exit

echo.
echo ===============================================
echo                   EXECUCAO
echo ===============================================
echo.

for %%a in (%escolha%) do (

    if %%a==1 call :install "Google_Chrome" Google.Chrome
    if %%a==2 call :install "Tor_Browser" TorProject.TorBrowser
    if %%a==3 call :install "Google_Drive" Google.Drive
    if %%a==4 call :install "Mega" Mega.MEGASync
    if %%a==5 call :install "Obsidian" Obsidian.Obsidian
    if %%a==6 call :install "Anki" Anki.Anki
    if %%a==7 call :install "KeePass" DominikReichl.KeePass
    if %%a==8 call :install "Notepad++" Notepad++.Notepad++
    if %%a==9 call :install "Foxit_PDF" Foxit.FoxitReader
    if %%a==10 call :install "WinRAR" RARLab.WinRAR
    if %%a==11 call :install "PowerToys" Microsoft.PowerToys
    if %%a==12 call :install "Wireshark" WiresharkFoundation.Wireshark

)

echo.
echo.
echo %ESC%[32m ...INSTALACOES FINALIZADAS%ESC%[0m
echo.

echo.
echo ===============================================
echo                 RESUMO FINAL
echo ===============================================
echo.

echo %ESC%[32m  ✔  INSTALADOS:%ESC%[0m
if defined INSTALLED_LIST (
    for %%i in (!INSTALLED_LIST!) do echo    - %%~i
) else (
    echo      X
)

echo.
echo %ESC%[33m  ⚠  JA EXISTIAM:%ESC%[0m
if defined SKIPPED_LIST (
    for %%i in (!SKIPPED_LIST!) do echo    - %%~i
) else (
    echo      X
)

echo.
echo %ESC%[31m  ✖  ERROS:%ESC%[0m
if defined ERROR_LIST (
    for %%i in (!ERROR_LIST!) do echo    - %%~i
) else (
    echo      X
)

echo.
echo.
echo Pressione qualquer tecla para finalizar...
pause >nul
exit