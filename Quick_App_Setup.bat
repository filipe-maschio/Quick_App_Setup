@echo off
title Setup Inteligente Fill v.4.4
chcp 65001 >nul

set "LOGLEVEL=2"

:: =========================
:: AUTO ELEVAR PARA ADMIN
:: =========================

:: Se já veio elevado → continua
if "%~1"=="admin" goto start

:: Testa privilégio admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Elevando para administrador...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -ArgumentList ('admin ' + '%*') -Verb RunAs"
    exit
)

:start

setlocal enabledelayedexpansion
call :parse_args %*

set "INSTALLED_LIST="
set "SKIPPED_LIST="
set "ERROR_LIST="

color 07
for /f %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"

:: Cores
:: Verde = echo %ESC%[32m[OK] %1 concluido%ESC%[0m
:: Vermelho = echo %ESC%[31m[ERRO] Falha ao instalar %1%ESC%[0m
:: Amarelo = echo %ESC%[33m[SKIP] %1 ja instalado%ESC%[0m

call :check_prerequisites
if %errorlevel% neq 0 goto end

:: Define ponto de entrada
goto menu

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
:: FUNCAO PRE-CHECKS
:: =========================
:check_prerequisites
winget --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo %ESC%[31m  ✖  Winget nao encontrado neste sistema.%ESC%[0m
    echo %ESC%[33m  ⚠  Instale/atualize o App Installer e tente novamente.%ESC%[0m
    echo.
    exit /b 1
)
exit /b 0

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
set "token= %value% "

echo  !%var_name%!  | findstr /i /c:"%token%" >nul
if errorlevel 1 (
    set "%var_name%=!%var_name%! %value%"
)
goto :eof

:: =========================
:: FUNCAO PARSE ARGS
:: =========================
:parse_args
if "%~1"=="" goto :eof

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
    echo %%a | findstr /r "^[0-9][0-9]*$" >nul
    if errorlevel 1 (
        echo %ESC%[33m  ⚠  Opcao invalida ignorada: %%a%ESC%[0m
    ) else (
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
        if %%a lss 0 echo %ESC%[33m  ⚠  Opcao invalida ignorada: %%a%ESC%[0m
        if %%a gtr 12 echo %ESC%[33m  ⚠  Opcao invalida ignorada: %%a%ESC%[0m
    )
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
    echo      Nenhum item
)

echo.
echo %ESC%[33m  ⚠  JA EXISTIAM:%ESC%[0m
if defined SKIPPED_LIST (
    for %%i in (!SKIPPED_LIST!) do echo    - %%~i
) else (
    echo      Nenhum item
)

echo.
echo %ESC%[31m  ✖  ERROS:%ESC%[0m
if defined ERROR_LIST (
    for %%i in (!ERROR_LIST!) do echo    - %%~i
) else (
    echo      Nenhum item
)

echo.
echo.
echo Pressione qualquer tecla para finalizar...
pause >nul
:end
exit
