$computerName=Read-Host "Имя ПК? / IP-Адрес?"
$credentials = Get-Credential
Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computerName -Credential $credentials | Select-Object UserName