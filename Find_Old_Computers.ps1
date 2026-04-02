$dateLimit = Get-Date -Year 2026 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0
Get-ADComputer -Server concrete.railsystems.kz -Filter "Name -like '*' -and LastLogonDate -le '$dateLimit'" -Properties LastLogonDate |
Select-Object Enabled, DNSHostName, LastLogonDate, DistinguishedName | Sort-Object DNSHostName
#Disable-ADAccount -PassThru | Select-Object Enabled, Name | Sort Name