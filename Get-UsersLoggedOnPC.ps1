<#
.SYNOPSIS
  Получает активных пользователей на всех компьютерах выбранного домена в лесу.
#>

# Импорт модуля Active Directory
Import-Module ActiveDirectory -ErrorAction Stop

# Получаем список доменов леса
$domains = (Get-ADForest).Domains
Write-Host "Доступные домены леса:" -ForegroundColor Cyan
for ($i = 0; $i -lt $domains.Count; $i++) {
    Write-Host "[$($i+1)] $($domains[$i])"
}
# Выбор домена
do {
    $input = Read-Host "Выберите номер домена (1..$($domains.Count))"
} while (-not [int]::TryParse($input, [ref]$sel) -or $sel -lt 1 -or $sel -gt $domains.Count)
$domainDns = $domains[$sel - 1]

# Получаем список включенных компьютеров из выбранного домена
Write-Host "Получаем список включенных компьютеров из $domainDns..." -ForegroundColor Gray
$computers = Get-ADComputer -Filter 'Enabled -eq $true' -Server $domainDns -Properties Name |
             Select-Object -ExpandProperty Name

if (-not $computers) {
    Write-Error "В домене $domainDns не найдено включенных компьютеров."
    exit
}

# Учетные данные для опроса удаленных систем
$credentials = Get-Credential

# Подготовка коллекции результатов
$results = @()

foreach ($computer in $computers) {
    $displayCN = "$computer.$domainDns"
    Write-Host "\n--> Опрос $displayCN" -ForegroundColor Gray
    # Пытаемся CIM/WinRM
    try {
        $session = New-CimSession -ComputerName $displayCN -Credential $credentials -ErrorAction Stop
        $cs = Get-CimInstance -CimSession $session -ClassName Win32_ComputerSystem -ErrorAction Stop
        Remove-CimSession $session
    }
    catch {
        # При неудаче пробуем WMI DCOM
        try {
            $cs = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer -Credential $credentials -ErrorAction Stop
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-Warning "Не удалось опросить $displayCN : $errorMsg"
            $results += [PSCustomObject]@{ ComputerName = $displayCN; User = "Ошибка: $errorMsg" }
            continue
        }
    }
    # Формируем вывод
    if ($cs.UserName) {
        # cs.UserName возвращает DOMAIN\\User
        $user = $cs.UserName
    }
    else {
        $user = 'Нет активного пользователя'
    }
    $results += [PSCustomObject]@{ ComputerName = $displayCN; User = $user }
}

# Отображаем результаты
$results | Format-Table -AutoSize

# Для экспорта:
# $results | Export-Csv -Path "Users_$($domainDns)_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation
