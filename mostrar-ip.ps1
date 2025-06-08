# mostrar-ip.ps1

# Pegamos o primeiro IP IPv4 válido que:
# - NÃO seja Loopback
# - NÃO seja do WSL (vEthernet)
# - NÃO seja VirtualBox
# - E esteja na faixa 192.*

$hostIp = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.InterfaceAlias -notmatch 'Loopback|vEthernet|VirtualBox|Teredo|Container' `
    -and $_.IPAddress -like '192.*'
} | Select-Object -First 1).IPAddress

# IP do WSL (interno)
$wslIp = (wsl hostname -I).Trim()

Write-Host "`n=========== Informacoes de Conexao ===========" -ForegroundColor Green
Write-Host "IP do Windows (adaptador fisico): $hostIp"
Write-Host "IP do WSL2: $wslIp"

if ($hostIp -and $wslIp) {
    Write-Host "`nPara conectar ao servidor, use um destes comandos no console do CS 1.6:" -ForegroundColor Green
    Write-Host "connect $hostIp`:28015    (IP do Windows)" -ForegroundColor Cyan
    Write-Host "connect $wslIp`:27015    (IP do WSL2)`n" -ForegroundColor Cyan
    Write-Host "Nao fechar o CMD de conexao proxy!" -ForegroundColor Yellow
} else {
    if (-not $hostIp) { Write-Host "⚠️  Não foi possível determinar o IP do Windows." -ForegroundColor Red }
    if (-not $wslIp) { Write-Host "⚠️  Não foi possível determinar o IP do WSL2." -ForegroundColor Red }
}
