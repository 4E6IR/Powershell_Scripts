$PCName=Read-Host "PC -> Wi-Fi?"
Add-ADGroupMember -Identity CMP_Wi-FI_Enabled -Members $PCName -Credential(Get-Credential)