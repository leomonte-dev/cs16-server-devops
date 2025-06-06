@echo off
echo Iniciando servidor CS 1.6 no Docker...

REM Puxe a imagem mais recente do Docker Hub
docker pull monte019/cs16-server:latest

REM Rode o container com a imagem puxada
docker run -d --name cs1.6_server -p 27015:27015/udp -p 27015:27015/tcp meuusuario/cs_server:latest

IF ERRORLEVEL 1 (
    echo Falha ao iniciar o container Docker.
    pause
    exit /b 1
)

echo Servidor iniciado com sucesso.
pause
