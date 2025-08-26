$FolderPath = Read-Host "Укажите путь для корневой папки"
$results = Get-ChildItem -Path $FolderPath -Directory | ForEach-Object {
    $acl = Get-Acl -Path $_.FullName
    $status = if (-not $acl.AreAccessRulesProtected) { "ВКЛЮЧЕНО" } else { "ОТКЛЮЧЕНО" }
    [PSCustomObject]@{
        "Имя папки"   = $_.Name
        "Наследование" = $status
    }
}

$results | Format-Table -AutoSize