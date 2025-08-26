# Папка для сохранения отчёта
$ReportPath = "C:\Users\A860730350797\Desktop\GPO\GPO_Reports\GPO_Report.html"

# Создание объекта для отчёта в формате HTML
$HTMLContent = @()

# Получение списка всех GPO в домене
$GPOs = Get-GPO -All

# Обход всех GPO и сбор параметров
foreach ($GPO in $GPOs) {
    $GPOName = $GPO.DisplayName
    $GPOID = $GPO.Id

    # Получение настроек GPO (пользовательские и компьютерные)
    $GPOReport = Get-GPOReport -Guid $GPOID -ReportType Html

    # Добавляем HTML-содержимое в итоговый отчёт
    $HTMLContent += $GPOReport
}

# Сохранение итогового отчёта в HTML
$HTMLContent | Out-File -Encoding UTF8 $ReportPath

Write-Host "Отчёт создан: $ReportPath"

#