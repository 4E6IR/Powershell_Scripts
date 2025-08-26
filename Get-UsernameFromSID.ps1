# Загрузка доменов и добавление кастомного домена
$domains = (Get-ADForest).domains
$domains += "tower.basis.asia"

# Путь к файлу с ObjectSID
$FilePath = Read-Host "Введите путь к txt файлу со списком ObjectSID"

# Проверка существования файла
if (-not (Test-Path $FilePath)) {
    Write-Host "Файл не найден. Завершение скрипта."
    exit
}

# Считываем все SID из файла в массив
$UserSIDs = Get-Content $FilePath

# Проверка наличия данных в файле
if (-not $UserSIDs) {
    Write-Host "Файл пуст или содержит некорректные данные. Завершение скрипта."
    exit
}

# Создаем список для накопления результатов
$Results = @()

# Цикл по каждому SID из списка
foreach ($UserSID in $UserSIDs) {
    # Поиск пользователя в каждом домене
    foreach ($domain in $domains) {
        try {
            $Filter = "ObjectSID -eq '$UserSID'"
            $UserNameResult = Get-ADUser -Filter $Filter -Properties MiddleName, EmployeeID, ObjectSID -Server "$domain" -ErrorAction Stop

            if ($UserNameResult) {
                # Добавляем найденный результат в список
                $Results += $UserNameResult
            }
        }
        catch {
            Write-Host "Ошибка при поиске пользователя в домене $domain $($_.Exception.Message)"
        }
    }
}

# Если есть результаты, выводим их единым списком без заголовков
if ($Results) {
    $Results | ForEach-Object {
        "{0} {1} {2} {3} {4}" -f `
            $_.Enabled, $_.ObjectSID, $_.SamAccountName, $_.Surname, $_.GivenName, $_.MiddleName, $_.EmployeeID
    }
} else {
    Write-Host "Ни один пользователь не был найден."
}
