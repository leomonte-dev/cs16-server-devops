# mostrar-ip.ps1
$wslIp = (wsl hostname -I).Trim()
$hostIp = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.InterfaceAlias -notlike '*Loopback*' -and $_.IPAddress -like '192.*' 
}).IPAddress -join ' '  # Junta todos os IPs encontrados separados por espaço

Write-Host "`n=========== Informacoes de Conexão ===========" -ForegroundColor Cyan
Write-Host "IP do Windows: $hostIp"
Write-Host "IP do WSL2: $wslIp"

if ($hostIp -and $wslIp) {
    # Pega apenas o primeiro IP se houver múltiplos
    $firstHostIp = ($hostIp -split ' ')[0]
    $firstWslIp = ($wslIp -split ' ')[0]
    
    Write-Host "`nPara conectar ao servidor, use um dos seguintes comandos no console do CS 1.6:" -ForegroundColor Green
    Write-Host "connect $firstHostIp`:27015    (IP do Windows)" -ForegroundColor Yellow
    Write-Host "connect $firstWslIp`:27015    (IP do WSL2)`n" -ForegroundColor Magenta
} else {
    if (-not $hostIp) { Write-Host "⚠️  Não foi possível determinar o IP do Windows." -ForegroundColor Red }
    if (-not $wslIp) { Write-Host "⚠️  Não foi possível determinar o IP do WSL2." -ForegroundColor Red }
}