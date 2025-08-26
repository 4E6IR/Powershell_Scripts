#1 Get-EventLog -LogName Security -InstanceId 4624 | Where-Object { $_.ReplacementStrings[5] -eq 'A.Gluhova' }

#2 Get-EventLog -LogName Security -InstanceId 4624 -ComputerName dc01.pmk.railsystems.kz | Where-Object { $_.ReplacementStrings[5] -eq 'A.Gluhova' } | Select-Object -First 1

#3
# Определяем контроллер домена
$DomainController = "DC1.domain.local"

# Ищем события входа (Event ID 4624)
$events = Get-EventLog -LogName Security -InstanceId 4624 -ComputerName $DomainController | 
          Where-Object { $_.Message -like "*exampleuser*" }

foreach ($event in $events) {
    $message = $event.Message
    $timestamp = $event.TimeGenerated

    # Ищем нужные строки в сообщении
    $selectedLines = $message | Select-String -Pattern "Workstation Name|Source Network Address"

    # Выводим нужные строки
    Write-Host "Timestamp: $timestamp"
    $selectedLines.Matches | ForEach-Object { $_.Value }
}