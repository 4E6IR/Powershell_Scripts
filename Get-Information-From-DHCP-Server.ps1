# 1. Получаем список всех DHCP-серверов в лесу
$dhcpServers = Get-DhcpServerInDC

# 2. Создаем массивы для хранения данных
$allLeases = @()
$allReservations = @()

# 3. Обходим все DHCP-серверы
foreach ($server in $dhcpServers) {
    $serverName = $server.DnsName
    Write-Host "Сбор данных с DHCP-сервера: $serverName" -ForegroundColor Green

    try {
        # Получаем все ScopeId на сервере
        $scopes = Get-DhcpServerv4Scope -ComputerName $serverName

        foreach ($scope in $scopes) {
            # Получаем аренды (leases) для данного ScopeId
            $leases = Get-DhcpServerv4Lease -ComputerName $serverName -ScopeId $scope.ScopeId
            $allLeases += $leases | ForEach-Object {
                [PSCustomObject]@{
                    Server      = $serverName
                    ScopeId     = $_.ScopeId
                    IPAddress   = $_.IPAddress
                    ClientId    = $_.ClientId
                    HostName    = $_.HostName
                    AddressState = $_.AddressState
                    LeaseExpiryTime = $_.LeaseExpiryTime
                }
            }

            # Получаем зарезервированные IP
            $reservations = Get-DhcpServerv4Reservation -ComputerName $serverName -ScopeId $scope.ScopeId
            $allReservations += $reservations | ForEach-Object {
                [PSCustomObject]@{
                    Server      = $serverName
                    ScopeId     = $_.ScopeId
                    IPAddress   = $_.IPAddress
                    ClientId    = $_.ClientId
                    Name        = $_.Name
                }
            }
        }
    } catch {
        Write-Warning "Ошибка при опросе сервера $serverName : $_"
    }
}

# 4. Вывод данных в консоль (сортировка по имени хоста)
#Write-Host "`n📌 Арендованные IP-адреса (Leases):" -ForegroundColor Cyan
#$allLeases | Sort-Object HostName | Format-Table Server, ScopeId, IPAddress, ClientId, HostName, AddressState, LeaseExpiryTime -AutoSize

#Write-Host "`n📌 Зарезервированные IP-адреса (Reservations):" -ForegroundColor Cyan
#$allReservations | Sort-Object Name | Format-Table Server, ScopeId, IPAddress, ClientId, Name -AutoSize

# 5. Сохранение в файлы CSV
$allLeases | Export-Csv -Path "C:\DHCP_All_Leases.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";" 
$allReservations | Export-Csv -Path "C:\DHCP_All_Reservations.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";" 

Write-Host "`n✅ Данные сохранены в C:\DHCP_All_Leases.csv и C:\DHCP_All_Reservations.csv" -ForegroundColor Green