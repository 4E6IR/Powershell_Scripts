$upn = Get-Clipboard -Raw
$domain = $upn.Split('@')[-1]
$cred = Get-Credential -Message "Credentials for $domain"
$user = Get-ADUser -Filter "UserPrincipalName -eq '$upn'" -Server $domain -Credential $cred
Unlock-ADAccount -Identity $user -Server $domain -Credential $cred
if ((Read-Host 'Reset password? (Y/N)') -match '^[Yy]$') {
    Set-ADAccountPassword -Identity $user -Reset -NewPassword (Read-Host 'New password' -AsSecureString) -Server $domain -Credential $cred
    Set-ADUser -Identity $user -ChangePasswordAtLogon $true -Server $domain -Credential $cred
}