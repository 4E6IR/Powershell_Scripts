$Computer = 'it1.railsystems.kz'

Set-Location "C:\Temp\LAPSDump"
#(Get-ADForest).Domains | %{ Get-ADComputer -Server $_ -Filter * -Property ms-Mcs-AdmPwd, ms-MCS-AdmPwdExpirationTime, Description | select Name, DNSHostName, Description, ms-Mcs-AdmPwd, @{n='AdmPwdExpirationTime';e={[DateTime]::FromFileTime($_."ms-MCS-AdmPwdExpirationTime").ToString('g')}} | Export-Csv -NoTypeInformation -Delimiter ";" -Encoding utf8 -Path .\AdmPwd@$_.csv }
(Get-ADForest).Domains | %{ Get-ADUser -Server $_ -Filter * -Properties objectSid, samaccountname, canonicalName | Select objectsid, samaccountname, @{Name="logonName";Expression = { ($_.canonicalName -replace '^|\..*$').ToUpper()+'\'+$_.samaccountname }}, distinguishedName} | Export-Excel .\Users-objectSid.xlsx -WorksheetName 'Users'
<#
Copy-Item -Path "C:\Temp\LAPSDump\*.csv" -Destination "\\it1.railsystems.kz\d$\_src\LAPSDump"
try {
	Write-Host "Try working"
	Invoke-Command -ComputerName $Computer -ScriptBlock { git -C d:\_src\LAPSDump commit -a -m "Periodically check (scripted)" }	
}
catch
{
	Write-Host "Catch working"
	Invoke-Command -ComputerName $Computer -ScriptBlock { git -C d:\_src\LAPSDump push }
}
finally {
	Write-Host "Finally working"
	Invoke-Command -ComputerName $Computer -ScriptBlock { git -C d:\_src\LAPSDump push }
}
#>