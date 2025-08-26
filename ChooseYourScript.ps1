# Указываем путь к директории с PowerShell скриптами
$scriptDir = "d:\Distributive\Scripts\RunWorkedScripts\"

# Получаем список всех файлов с расширением .ps1 в папке
$scripts = Get-ChildItem -Path $scriptDir -Filter *.ps1

# Проверяем, есть ли найденные скрипты
if ($scripts.Count -eq 0) {
    Write-Host "Скрипты PowerShell не найдены в папке $scriptDir"
    exit
}

# Выводим список скриптов
Write-Host "Доступные скрипты:"
for ($i = 0; $i -lt $scripts.Count; $i++) {
    Write-Host "$($i + 1). $($scripts[$i].Name)"
}

# Спрашиваем у пользователя номер скрипта для запуска
$selection = Read-Host "Enter the number of the script to run"

# Проверяем, является ли ввод корректным числом
if (-not ($selection -as [int]) -or $selection -lt 1 -or $selection -gt $scripts.Count) {
    Write-Host "Invalid selection."
    exit
}

# Получаем полный путь к выбранному скрипту
$selectedScript = $scripts[$selection - 1].FullName

# Выводим имя запускаемого скрипта
Write-Host "Выполняется скрипт: $selectedScript"

# Выполняем выбранный скрипт в текущем сеансе с использованием точечного вызова
. "$selectedScript"