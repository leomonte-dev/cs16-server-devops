@echo off
setlocal

:: Valores padrão
set MAP=de_dust2
set MAXPLAYERS=12

:: Se o usuário passou parâmetros, sobrescreve
if not "%1"=="" set MAP=%1
if not "%2"=="" set MAXPLAYERS=%2

:: Executa o script PowerShell e salva o IP no arquivo temporário
powershell -NoProfile -ExecutionPolicy Bypass -File get_host_ip.ps1 > ip_tmp.txt

:: Lê o IP do arquivo para variável
set /p HOST_IP=<ip_tmp.txt

:: Apaga arquivo temporário
del ip_tmp.txt

echo IP capturado: [%HOST_IP%]

echo Iniciando servidor CS 1.6 com:
echo    Mapa: %MAP%
echo    Max Players: %MAXPLAYERS%

:: Atualiza a imagem antes de rodar o container
docker-compose pull

:: Gera docker-compose.override.yml com IP detectado // foi para testes .
(
echo version: "3.8"
echo services:
echo   csserver:
echo     command:
echo       - "-game"
echo       - "cstrike"
echo       - "+maxplayers"
echo       - "%MAXPLAYERS%"
echo       - "+map"
echo       - "%MAP%"
echo       - "+sv_lan"
echo       - "0"
echo       - "+ip"
echo       - "0.0.0.0"
echo       - "+port"
echo       - "27015"
echo       - "-strictportbind"
echo     environment:
echo       MAXPLAYERS: "%MAXPLAYERS%"
echo       MAP: "%MAP%"
) > docker-compose.override.yml

:: Roda o docker-compose com as variáveis
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
