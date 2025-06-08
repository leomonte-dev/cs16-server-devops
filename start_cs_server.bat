@echo off
setlocal enabledelayedexpansion

:: Valores padrão
set MAP=de_dust2
set MAXPLAYERS=12

:: Se o usuário passou parâmetros, sobrescreve
if not "%1"=="" set MAP=%1
if not "%2"=="" set MAXPLAYERS=%2

:: Pega o IP da interface ativa do Windows (IPv4, não localhost)
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr /v "127.0.0.1"') do (
    set ip=%%a
    goto :gotIP
)
:gotIP
:: Remove espaços no IP
set ip=%ip: =%

echo IP detectado: %ip%

:: Verifica se docker-compose.override.yml existe e lê o IP atual do arquivo
set fileIP=
if exist docker-compose.override.yml (
    for /f "tokens=2 delims=:" %%i in ('findstr /c:"+ip" docker-compose.override.yml') do (
        set fileIP=%%i
        goto :foundIP
    )
)
:foundIP
if defined fileIP (
    set fileIP=%fileIP: =%
)

:: Compara IP detectado com IP do arquivo
if "%ip%"=="%fileIP%" (
    echo IP nao mudou (%ip%), nao sobrescrevendo docker-compose.override.yml
) else (
    echo IP mudou ou arquivo nao existe. Sobrescrevendo docker-compose.override.yml com IP %ip%
    (
    echo version: "3.8"
    echo.
    echo services:
    echo.  csserver:
    echo.    command:
    echo.      - "-game"
    echo.      - "cstrike"
    echo.      - "+maxplayers"
    echo.      - "%MAXPLAYERS%"
    echo.      - "+map"
    echo.      - "%MAP%"
    echo.      - "+sv_lan"
    echo.      - "0"
    echo.      - "+ip"
    echo.      - "%ip%"
    echo.      - "+port"
    echo.      - "27015"
    echo.      - "-strictportbind"
    echo.    environment:
    echo.      MAXPLAYERS: "%MAXPLAYERS%"
    echo.      MAP: "%MAP%"
    ) > docker-compose.override.yml
)

:: Atualiza a imagem antes de rodar o container
docker-compose pull

:: Roda o docker-compose com as variáveis
docker-compose up -d

if errorlevel 1 (
    echo ERRO ao iniciar o servidor.
    pause
    exit /b 1
)

echo Servidor iniciado com sucesso!
echo Para conectar, use o IP %ip% e a porta 27015.
echo Mapa atual: %MAP%
echo Max Players: %MAXPLAYERS%
echo Use 'docker-compose down' para parar o servidor.
powershell -ExecutionPolicy Bypass -File mostrar-ip.ps1
pause
