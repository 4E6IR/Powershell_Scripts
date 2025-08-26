$remoteComputer = "ComputerName.railsystems.kz"
>> $username = "UserName"
>>
>> Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
>>     quser
>> } | ForEach-Object {
>>     if ($_ -match $username) {
>>         $sessionID = ($_ -split "\s+")[2]
>>         $sessionID
>>     }
>> }
>>

---------------------------------- Отдельный скрипт

PS C:\Users\A860730350797> $sessionID = 3 # Замените это значение на полученное ID сессии
>> Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
>>     param ($sessionID)
>>     logoff $sessionID
>> } -ArgumentList $sessionID
>>