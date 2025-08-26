
Invoke-Command -ComputerName pmk-nas-02.pmk.railsystems.kz -Credential (Get-Credential) -ScriptBlock{
$FileNamePart = Read-Host "Введите часть пути к файлу"

# Получение открытых файлов и фильтрация по имени
Get-SmbOpenFile | Where-Object { $_.Path -like "*$FileNamePart*" } |
Sort-Object Path | 
Select-Object FileId, ClientComputerName, ClientUserName, Path}

#Close-SmbOpenFile -FileId 154350579785 -Force