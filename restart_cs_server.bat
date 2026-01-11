@echo off
echo ========================================
echo   REINICIANDO SERVIDOR CS 1.6
echo ========================================
echo.

:: Para o servidor Docker
echo [1/3] Parando container do servidor...
docker-compose down

if errorlevel 1 (
    echo [AVISO] Erro ao parar container, continuando...
)

:: Para APENAS processos do proxy (mais específico)
echo [2/3] Parando proxy UDP...
for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq python.exe" /FO LIST ^| findstr PID') do (
    taskkill /PID %%a /F >nul 2>&1
)

:: Aguarda 3 segundos (aumentado)
echo [3/3] Aguardando limpeza...
timeout /t 3 /nobreak >nul

:: Reinicia usando o start_cs_server.bat
echo.
echo Iniciando servidor novamente...
echo.
call start_cs_server.bat

echo.
echo ========================================
echo   PROCESSO DE RESTART CONCLUIDO
echo ========================================
pause
