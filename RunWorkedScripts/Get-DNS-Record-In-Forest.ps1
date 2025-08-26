$Choise=Read-Host "Сделайте выбор
1)Имя ПК | 2)IP"
$domains = (Get-ADForest).domains
$domains += "tower.basis.asia"
Switch($Choise) {
    1 {
        $Hostname=Read-Host "Имя ПК"
        foreach ($domain in $domains) {
            try {
                $DNSResult = Resolve-DnsName -Name "$Hostname.$domain" -ErrorAction Stop
                # Вывод результатов разрешения DNS
                $DNSResult | Format-Table Name, IPAddress, Type -AutoSize
            }
            catch {
                # Обработка ошибок при разрешении DNS
                Write-Host "Не найдена DNS запись в домене $domain"
                #Write-Host $_.Exception.Message
            }
        }
}
    2 {
        $IP=Read-Host "IP адрес"
        foreach ($domain in $domains) {
            try {
                $DNSResult = Resolve-DnsName -Name "$IP" -Server $domain -ErrorAction Stop
                # Вывод результатов разрешения DNS
                $DNSResult | Format-Table -AutoSize 
            Break #Останавливаем выполнение скрипта
            }
            catch {
                # Обработка ошибок при разрешении DNS
                Write-Host "IP адрес не найден в домене $domain"
                #Write-Host $_.Exception.Message
            }
        }
    }
}