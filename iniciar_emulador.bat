@echo off
title Projeto Academico FullStack - Iniciar App
cd /d "%~dp0"

set "EMULADOR=teste"
set "TEMPO_MAXIMO=60"
set "TEMPO_ATUAL=0"

echo ==========================================
echo   Verificando emulador: %EMULADOR%
echo ==========================================
echo.

call flutter emulators | findstr /C:"%EMULADOR%" >nul 2>&1

if errorlevel 1 (
    echo [ERRO] O emulador "%EMULADOR%" nao foi encontrado.
    echo.
    echo Emuladores disponiveis:
    echo ------------------------------------------
    call flutter emulators
    echo ------------------------------------------
    echo.
    echo Altere esta linha no arquivo .bat:
    echo set "EMULADOR=nome_do_emulador"
    echo.
    pause
    exit /b 1
)

echo Emulador encontrado.
echo.
echo ==========================================
echo   Iniciando emulador Android: %EMULADOR%
echo ==========================================
echo.

call flutter emulators --launch %EMULADOR%

echo.
echo Aguardando o emulador ficar disponivel...
echo Tempo limite: %TEMPO_MAXIMO% segundos.
echo.

set "ADB=adb"

where adb >nul 2>&1
if errorlevel 1 (
    if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
        set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
    ) else (
        echo.
        echo [ERRO] Nao foi possivel localizar o adb.
        echo Verifique se o Android SDK esta instalado corretamente.
        pause
        exit /b 1
    )
)

:aguardar_dispositivo
"%ADB%" devices | findstr /B "emulator-" | findstr "device" >nul 2>&1

if not errorlevel 1 goto dispositivo_encontrado

if %TEMPO_ATUAL% GEQ %TEMPO_MAXIMO% (
    echo.
    echo [ERRO] O emulador nao ficou disponivel dentro de %TEMPO_MAXIMO% segundos.
    echo.
    echo Tentando encerrar o emulador automaticamente...
    "%ADB%" emu kill >nul 2>&1
    echo.
    echo Emulador encerrado.
    echo.
    echo Verifique se:
    echo - o emulador abriu corretamente;
    echo - o Android Studio esta configurado;
    echo - o ADB esta funcionando;
    echo - o emulador nao ficou travado na inicializacao.
    echo.
    pause
    exit /b 1
)

timeout /t 2 /nobreak >nul
set /a TEMPO_ATUAL+=2
goto aguardar_dispositivo

:dispositivo_encontrado
echo Dispositivo encontrado.
echo Aguardando o Android terminar de iniciar...

set "TEMPO_ATUAL=0"

:aguardar_boot
set "BOOT="

for /f "usebackq delims=" %%A in (`"%ADB%" shell getprop sys.boot_completed 2^>nul`) do set "BOOT=%%A"

if "%BOOT%"=="1" goto boot_concluido

if %TEMPO_ATUAL% GEQ %TEMPO_MAXIMO% (
    echo.
    echo [ERRO] O dispositivo foi encontrado, mas o Android nao terminou de iniciar em %TEMPO_MAXIMO% segundos.
    echo.
    echo Tentando encerrar o emulador automaticamente...
    "%ADB%" emu kill >nul 2>&1
    echo.
    echo Emulador encerrado.
    echo Tente executar o script novamente.
    echo.
    pause
    exit /b 1
)

timeout /t 2 /nobreak >nul
set /a TEMPO_ATUAL+=2
goto aguardar_boot

:boot_concluido
echo.
echo Android iniciado com sucesso.
echo ==========================================
echo   Executando o projeto Flutter
echo ==========================================
echo.

call flutter run

echo.
echo Execucao encerrada.
pause