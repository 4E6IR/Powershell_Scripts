$Server = Read-Host "Введите имя DHCP-сервера"
$Scope  = Read-Host "Введите ScopeId (например 192.168.1.0) или оставьте пустым"
$Key    = Read-Host "Введите ключевое слово для поиска"

if ($Scope) {
    Get-DhcpServerv4Lease -ComputerName $Server -ScopeId $Scope |
    Where-Object {
        $_.IPAddress -like "*$Key*" -or
        $_.ClientId  -like "*$Key*" -or
        $_.HostName  -like "*$Key*"
    }
}
else {
    Get-DhcpServerv4Scope -ComputerName $Server |
    ForEach-Object {
        Get-DhcpServerv4Lease -ComputerName $Server -ScopeId $_.ScopeId 
    } |
    Where-Object {
        $_.IPAddress -like "*$Key*" -or
        $_.ClientId  -like "*$Key*" -or
        $_.HostName  -like "*$Key*"
    }
}