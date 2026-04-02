$domains = (Get-ADForest).Domains
$domains += "tower.basis.asia"

# Ввод параметра поиска
$UserName = Read-Host "Введите имя, фамилию или логин пользователя"
Write-Host ""

# Фильтр поиска
$Filter = "CN -like '*$UserName*' -or SamAccountName -like '*$UserName*' -or UserPrincipalName -like '*$UserName*'"

# Формат для вывода с выравниванием
$format = "{0,-10} {1,-12} {2,-12} {3,-22} {4,-25} {5,-15} {6,-12} {7,-20} {8,-30} {9,-40}"

# Массив для хранения результатов
$results = @()

# Поиск по всем доменам
foreach ($domain in $domains) {
    try {
        $UserNameResult = Get-ADUser -Filter $Filter -Properties PasswordExpired, PasswordLastSet, LockedOut, MiddleName, EmployeeID -Server $domain -ErrorAction Stop
        if ($UserNameResult) {
            $results += $UserNameResult
        }
    }
    catch {
        Write-Warning "Ошибка при поиске пользователя в домене $domain : $($_.Exception.Message)"
    }
}

# Сортировка и вывод с отступами между строками
$results | Sort-Object SamAccountName | ForEach-Object {
    $enabledStatus  = if ($_.Enabled) { "Enabled" } else { "Disabled" }
    $lockedStatus   = if ($_.LockedOut) { "Locked" } else { "NotLocked" }
    $expiredStatus  = if ($_.PasswordExpired) { "Expired" } else { "NotExpired" }

    $passwordLastSet = if ($_.PasswordLastSet) { $_.PasswordLastSet } else { "-" * 22 }
    $name            = if ($_.Name) { $_.Name } else { "-" * 25 }
    $middleName      = if ($_.MiddleName) { $_.MiddleName } else { "-" * 15 }
    $employeeId      = if ($_.EmployeeID) { $_.EmployeeID } else { "-" * 12 }
    $samAccountName  = if ($_.SamAccountName) { $_.SamAccountName } else { "-" * 20 }
    $userPrincipal   = if ($_.UserPrincipalName) { $_.UserPrincipalName } else { "-" * 30 }
    $distinguished   = if ($_.DistinguishedName) { $_.DistinguishedName } else { "-" * 40 }

    $line = $format -f `
        $enabledStatus,
        $lockedStatus,
        $expiredStatus,
        $passwordLastSet,
        $name,
        $middleName,
        $employeeId,
        $samAccountName,
        $userPrincipal,
        $distinguished

    Write-Output $line
    Write-Output ""
}
