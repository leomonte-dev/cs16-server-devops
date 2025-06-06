@echo off
setlocal

echo Verificando se o Docker está instalado...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERRO: Docker nao encontrado. Instale o Docker e tente novamente.
    pause
    exit /b 1
)

echo Parando container antigo (se existir)...
docker stop cs1.6_server >nul 2>&1
docker rm cs1.6_server >nul 2>&1

echo Baixando a imagem mais recente do servidor CS 1.6...
docker pull monte019/cs16-server:latest

echo Iniciando o container do servidor CS 1.6...
docker run -d --name cs1.6_server -p 27015:27015/tcp -p 27015:27015/udp monte019/cs16-server:latest

if errorlevel 1 (
    echo Falha ao iniciar o container Docker.
    pause
    exit /b 1
)

echo Servidor CS 1.6 iniciado com sucesso!
echo Para conectar, use o IP desta maquina e a porta 27015.
pause
