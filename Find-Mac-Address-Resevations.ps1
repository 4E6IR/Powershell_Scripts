# Импорт модуля DhcpServer, если он еще не загружен
Import-Module DhcpServer

# Замените "DHCP_SERVER_NAME" на имя вашего DHCP-сервера
$dhcpServer = "rws-dhcp-01"

# Замените "00-11-22-33-44-55" на MAC-адрес, который вы хотите найти
$macAddress = "9C-93-4E-7C-11-B6"

# Получаем список всех Scope областей DHCP на DHCP-сервере
$scopeIds = Get-DhcpServerv4Scope -ComputerName $dhcpServer | Select-Object -ExpandProperty ScopeId

# Проходим по каждой Scope области и ищем резервацию по MAC-адресу
foreach ($scopeId in $scopeIds) {
    $reservation = Get-DhcpServerv4Reservation -ComputerName $dhcpServer -ScopeId $scopeId -ClientId $macAddress -ErrorAction SilentlyContinue

    if ($reservation) {
        Write-Host "Найдена резервация DHCP для MAC-адреса $macAddress в области $scopeId"
        $reservation
    } else {
        Write-Host "Резервация DHCP для MAC-адреса $macAddress не найдена в области $scopeId."
    }
}