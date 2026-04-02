# Ввод имени пользователя
$UserName = Read-Host "Введите имя пользователя"

# Получение списка доменов
$domains = (Get-ADForest).domains + "TOWER.Basis.asia"

# Вывод списка доменов и выбор пользователем
$domains | ForEach-Object { Write-Host "$($domains.IndexOf($_) + 1). $_" }
$Server = $domains[([int](Read-Host "Введите номер сервера") - 1)]

# Запрос учётных данных
$Credential = Get-Credential

# Поиск пользователя и отключение учётной записи
Get-ADUser $UserName -Server $Server | Disable-ADAccount -Credential $Credential -Server $Server