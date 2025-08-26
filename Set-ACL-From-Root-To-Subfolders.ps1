# Указываем корневую папку
$rootFolder = "\\Railsystems.kz\System\UF\A.Zhanatov"

# Доменная учетная запись
$user = "tower\username"

# Установка кодировки для корректного вывода в консоли
chcp 65001

# Проверяем, существует ли корневая папка
if (Test-Path $rootFolder) {
    # Получаем список только первых вложенных папок (не глубже 1 уровня)
    $subfolders = Get-ChildItem -Path $rootFolder -Directory

    foreach ($folder in $subfolders) {
        $fullPath = $folder.FullName
        Write-Host "Назначаем права на $fullPath" -ForegroundColor Yellow
        
        # Добавляем права на редактирование (Modify) только для первого уровня
        icacls $fullPath /grant: "${user}:(OI)(CI)R" /C

        if ($?) {
            Write-Host "Права успешно назначены на $fullPath" -ForegroundColor Green
        } else {
            Write-Host "Ошибка при назначении прав на $fullPath" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Папка $rootFolder не найдена." -ForegroundColor Red
}

Write-Host "Операция завершена."