@echo off
title Projeto Academico FullStack - Celular Fisico
cd /d "%~dp0"

set "IP_PC=SEU_IP_AQUI"

set "ADB=adb"

echo ==========================================
echo   Verificando celular fisico
echo ==========================================
echo.

where adb >nul 2>&1
if errorlevel 1 (
    if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
        set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
    ) else (
        echo.
        echo [ERRO] Nao foi possivel localizar o adb.
        echo Verifique se o Android SDK esta instalado corretamente.
        echo.
        pause
        exit /b 1
    )
)

echo Dispositivos encontrados:
echo ------------------------------------------
"%ADB%" devices
echo ------------------------------------------
echo.

"%ADB%" devices | findstr /V "emulator-" | findstr "device" >nul 2>&1

if errorlevel 1 (
    echo [ERRO] Nenhum celular fisico autorizado foi encontrado.
    echo.
    echo Verifique se:
    echo - o celular esta conectado por USB;
    echo - a Depuracao USB esta ativada;
    echo - voce autorizou este computador no celular;
    echo - o cabo USB permite transferencia de dados.
    echo.
    pause
    exit /b 1
)

echo Celular fisico encontrado.
echo.
echo IP configurado para o computador:
echo %IP_PC%
echo.
echo Backend utilizado:
echo http://%IP_PC%:8080/FastSplashWeb
echo.
echo ==========================================
echo   Executando o projeto Flutter
echo ==========================================
echo.

call flutter run --dart-define=API_BASE_URL=http://%IP_PC%:8080/FastSplashWeb

echo.
echo Execucao encerrada.
pause