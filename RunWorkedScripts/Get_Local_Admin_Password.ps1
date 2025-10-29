# Запрос имени компьютера для поиска
$ComputerName = Read-Host "Имя компьютера?"

# Список доступных лесов
$Forest1 = "Tower.basis.asia"
$Forest2 = "RailSystems.kz"

# Запрос выбора леса для поиска
$ForestSelection = Read-Host "1) Tower.basis.asia
2) RailSystems.kz
Выберите лес"

# Переменная для хранения выбранного леса
$SelectedForest = ""

# Логика выбора леса
if ($ForestSelection -eq "1") {
    $SelectedForest = $Forest1
    #Write-Host "Выбран лес: $SelectedForest"
} elseif ($ForestSelection -eq "2") {
    $SelectedForest = $Forest2
    #Write-Host "Выбран лес: $SelectedForest"
} else {
    Write-Host "Неверный выбор. Завершение скрипта."
    exit
}

# Запрос учетных данных
$Credentials = Get-Credential -Message "Введите учетные данные для леса $SelectedForest"

# Получение списка всех доменов в выбранном лесу
try {
    $ForestInfo = Get-ADForest -Server $SelectedForest -Credential $Credentials
    $Domains = $ForestInfo.Domains
    #Write-Host "Найденные домены в лесу $SelectedForest: $Domains"
}
catch {
    Write-Host "Не удалось получить список доменов в лесу $SelectedForest. Ошибка: $_"
    exit
}

# Переменная для хранения результатов поиска
$ComputerFound = $null

# Поиск компьютера во всех доменах
foreach ($Domain in $Domains) {
    #Write-Host "Поиск в домене: $Domain"
    
    try {
        $Computer = Get-ADComputer -Server $Domain -Credential $Credentials -Filter { Name -eq $ComputerName } -Property ms-Mcs-AdmPwd
        
        if ($Computer) {
            Write-Host "Имя компьютера: $($Computer.DNSHostName)"
			Write-Host "Пароль администратора: $($Computer.'ms-Mcs-AdmPwd')"
            $ComputerFound = $Computer
            break # Остановка после нахождения первого совпадения
        }
    }
    catch {
        #Write-Host "Ошибка при поиске в домене $Domain: $_"
    }
}

# Проверка, был ли найден компьютер
if ($ComputerFound -eq $null) {
    Write-Host "Компьютер с именем $ComputerName не найден в лесу $SelectedForest."
}