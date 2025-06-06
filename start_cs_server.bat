@echo off
setlocal

:: Valores padrão
set MAP=de_dust2
set MAXPLAYERS=12

:: Se o usuário passou parâmetros, sobrescreve
if not "%1"=="" set MAP=%1
if not "%2"=="" set MAXPLAYERS=%2

echo Iniciando servidor CS 1.6 com:
echo    Mapa: %MAP%
echo    Max Players: %MAXPLAYERS%

:: Roda o docker-compose com as variáveis
set MAXPLAYERS=%MAXPLAYERS%
set MAP=%MAP%
docker-compose up -d

if errorlevel 1 (
    echo ERRO ao iniciar o servidor.
    pause
    exit /b 1
)

echo Servidor iniciado com sucesso!
echo Para conectar, use o IP desta máquina e a porta 27015.
echo Mapa atual: %MAP%
echo Max Players: %MAXPLAYERS%
echo Use 'docker-compose down' para parar o servidor.
powershell -ExecutionPolicy Bypass -File mostrar-ip.ps1
pause
