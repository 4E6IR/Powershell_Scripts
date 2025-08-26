Get-ChildItem "C:\" -Directory | ForEach-Object { 
    $folder = $_.FullName
    try {
        $size = (Get-ChildItem $folder -Recurse -ErrorAction Stop | Measure-Object -Property Length -Sum).Sum
        [PSCustomObject]@{
            Folder = $folder
            SizeMB = [math]::Round($size / 1MB, 2)
        }
    } catch {
        [PSCustomObject]@{
            Folder = $folder
            SizeGB = "Не удалось подсчитать"
        }
    }
}