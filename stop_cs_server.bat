@echo off
setlocal

echo Parando servidor CS 1.6...

docker-compose down

if errorlevel 1 (
    echo ERRO ao parar o servidor.
    pause
    exit /b 1
)

echo Servidor parado com sucesso.
pause
