# Перечисление путей к папкам
$folders = @("d:\Delete\TestFolder\")

# Доменная учетная запись (замените на нужную)
$user = "railsystems\t.abekov"

chcp 65001

# Цикл для назначения прав на каждую папку
foreach ($folder in $folders) {
    icacls $folder /grant "${user}:(OI)(CI)M" /T
}

Write-Host "Права успешно назначены."