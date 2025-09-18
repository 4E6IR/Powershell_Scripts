# Запрос части имени/пути (Enter = показать все)
$FileNamePart = Read-Host "Введите часть пути к файлу (или нажмите Enter — показать все)"

# Получаем открытые файлы и фильтруем по пути (если задан)
$openFiles = Get-SmbOpenFile |
    Where-Object { [string]::IsNullOrEmpty($FileNamePart) -or ($_.Path -like "*$FileNamePart*") } |
    Sort-Object Path

if (-not $openFiles -or $openFiles.Count -eq 0) {
    Write-Host "Открытых файлов, соответствующих шаблону, не найдено." -ForegroundColor Yellow
    return
}

# Нумеруем результирующий список для удобного выбора
[int]$i = 0
$indexed = $openFiles | ForEach-Object {
    $i++
    [PSCustomObject]@{
        Index = $i
        FileId = $_.FileId
        ClientComputerName = $_.ClientComputerName
        ClientUserName = $_.ClientUserName
        Path = $_.Path
    }
}

# Показываем таблицу (можно убрать -AutoSize, если очень длинные пути)
$indexed | Format-Table Index, FileId, ClientComputerName, ClientUserName, @{Name='Path';Expression={$_.Path}} -AutoSize

# Функция для парсинга ввода: "1,3-5" и т.д.
function Parse-Indices {
    param(
        [string]$input,
        [int]$max
    )
    $result = @()
    foreach ($part in $input -split ',') {
        $p = $part.Trim()
        if ($p -match '^\d+$') {
            $n = [int]$p
            if ($n -ge 1 -and $n -le $max) { $result += $n }
        } elseif ($p -match '^(\d+)-(\d+)$') {
            $s = [int]$matches[1]; $e = [int]$matches[2]
            if ($s -gt $e) { $t=$s; $s=$e; $e=$t }
            for ($j = $s; $j -le $e; $j++) {
                if ($j -ge 1 -and $j -le $max) { $result += $j }
            }
        }
    }
    return $result | Select-Object -Unique
}

# Запрос действия
$prompt = "Выберите файлы для закрытия по индексу (пример: 1,3-5), введите 'a' — закрыть все, 'q' — выйти"
$selection = Read-Host $prompt

if ($selection -match '^\s*[qQ]\s*$') {
    Write-Host "Отмена. Выход." -ForegroundColor Cyan
    return
}

# Определяем FileId'ы для закрытия
$fileIds = @()
if ($selection -match '^\s*[aA]\s*$') {
    $fileIds = $indexed | Select-Object -ExpandProperty FileId
} else {
    $max = $indexed.Count
    $indices = Parse-Indices -input $selection -max $max
    if (-not $indices -or $indices.Count -eq 0) {
        Write-Host "Неверный выбор или индексы вне диапазона." -ForegroundColor Red
        return
    }
    foreach ($idx in $indices) {
        $row = $indexed | Where-Object { $_.Index -eq $idx }
        if ($row) { $fileIds += [uint64]$row.FileId }
    }
}

# Показываем что будет закрыто и запрашиваем подтверждение
$toClose = $indexed | Where-Object { $fileIds -contains $_.FileId }
Write-Host ("Файлов для закрытия: {0}" -f $toClose.Count) -ForegroundColor Yellow
$toClose | Format-Table Index, FileId, ClientComputerName, ClientUserName, @{Name='Path';Expression={$_.Path}} -AutoSize

$confirm = Read-Host "Подтвердите закрытие перечисленных файлов (y/n)"
if ($confirm -notmatch '^[yY]') {
    Write-Host "Действие отменено." -ForegroundColor Cyan
    return
}

# Закрываем по одному, чтобы поймать индивидуальные ошибки
foreach ($fid in $fileIds) {
    try {
        Close-SmbOpenFile -FileId $fid -Force -ErrorAction Stop
        Write-Host ("FileId {0} — закрыт." -f $fid) -ForegroundColor Green
    } catch {
        Write-Warning ("Ошибка при закрытии FileId {0}: {1}" -f $fid, $_.Exception.Message)
    }
}

Write-Host "Операция завершена." -ForegroundColor Cyan