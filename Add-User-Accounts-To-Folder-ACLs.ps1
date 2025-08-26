# Перечисление путей к папкам
$folders = @("C:\Folder1", "C:\Folder2", "C:\Folder3")

# Список доменных учетных записей (замените на нужные)
$users = @("domain\user1", "domain\user2", "domain\user3")

# Устанавливаем кодировку UTF-8
chcp 65001

# Цикл для каждой папки
foreach ($folder in $folders) {
    # Цикл для каждого пользователя
    foreach ($user in $users) {
        # Назначение прав пользователю на текущую папку
        icacls $folder /grant "${user}:(OI)(CI)M" /T | Out-String
    }
}

Write-Host "Права успешно назначены для всех пользователей."
