@echo off
setlocal
:: Verifica se Docker está disponível
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERRO] O Docker Desktop nao esta aberto ou nao foi iniciado corretamente.
    echo Por favor, abra o Docker Desktop e aguarde ele ficar disponivel.
    pause
    exit /b 1
)

:: Verifica se o Python está disponível
where python >nul 2>&1
if errorlevel 1 (
    echo [ERRO] O Python nao esta instalado ou nao esta no PATH.
    echo Por favor, instale o Python e adicione ao PATH do sistema.
    pause
    exit /b 1
)


:: Verifica se o script udp.py existe
if not exist udp.py (
    echo [ERRO] O script udp.py nao foi encontrado.
    echo Por favor, verifique se o arquivo esta no mesmo diretorio do script.
    pause
    exit /b 1
)

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

echo Iniciando proxy UDP para conexoes Windows ...

start "" python udp.py

:: Espera 2 segundos para o proxy subir
timeout /t 2 /nobreak >nul




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

python udp_test.py
if errorlevel 1 (
    echo [ERRO] Proxy UDP nao respondeu. Encerrando container...
    timeout /t 5 /nobreak >nul
    docker-compose down
    exit /b 1
)

pause
