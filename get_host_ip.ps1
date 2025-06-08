$ip = Get-NetIPAddress -AddressFamily IPv4 |
      Where-Object {
          $_.InterfaceAlias -eq "Ethernet" -and
          $_.IPAddress -like '192.*'
      } |
      Select-Object -First 1

if ($ip) {
    Write-Output $ip.IPAddress
} else {
    Write-Output "127.0.0.1"
}
