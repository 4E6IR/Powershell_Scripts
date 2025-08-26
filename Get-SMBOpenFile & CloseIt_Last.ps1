# Запрос имени компьютера и учетных данных
$ComputerName = "pmk-nas-02.pmk.railsystems.kz"
$Credential = Get-Credential

# Основная логика
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
    do {
        # Получение части имени файла от пользователя
        $FileNamePart = Read-Host "Введите часть пути к файлу (или оставьте пустым для выхода)"
        if ([string]::IsNullOrWhiteSpace($FileNamePart)) {
            Write-Host "Выход из скрипта..." -ForegroundColor Yellow
            break
        }

        # Получение открытых файлов и фильтрация по имени
        $OpenFiles = Get-SmbOpenFile | Where-Object { $_.Path -like "*$FileNamePart*" } |
                     Sort-Object Path | 
                     Select-Object @{Name = '№'; Expression = { [array]::IndexOf($OpenFiles, $_) + 1 }},
                                   FileId, ClientComputerName, ClientUserName, Path

        # Проверка на наличие результатов
        if ($OpenFiles) {
            Write-Host "`nНайденные файлы:" -ForegroundColor Cyan
            $OpenFiles | Format-Table -AutoSize

            # Запрос ID файла для закрытия
            $FileID = Read-Host "Введите ID файла для закрытия (или оставьте пустым для отмены)"
            if ([string]::IsNullOrWhiteSpace($FileID)) {
                Write-Host "Действие отменено пользователем." -ForegroundColor Yellow
                continue
            }

            # Попытка закрыть файл
            try {
                Close-SmbOpenFile -FileId $FileID -Force
                Write-Host "Файл с ID $FileID успешно закрыт." -ForegroundColor Green
            } catch {
                Write-Host "Ошибка при закрытии файла. Проверьте ID и повторите попытку." -ForegroundColor Red
            }
        } else {
            Write-Host "Файлы, соответствующие заданной части пути, не найдены." -ForegroundColor Yellow
        }
    } while ($true)
}