@echo off
setlocal

echo Encerrando servidor CS 1.6...

docker-compose down

if errorlevel 1 (
    echo ERRO ao finalizar servidor.
    pause
    exit /b 1
)

echo Servidor finalizado com sucesso.
pause
