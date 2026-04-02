$UserName = (Get-Clipboard -Raw).Trim()
$upnDomain = ($UserName.Split('@')[-1]).ToLower()
$Credential = Get-Credential

if ($upnDomain -like '*railsystems.kz') {
    $user = Get-ADUser -Filter "UserPrincipalName -eq '$UserName'" -Server 'Railsystems.kz:3268' -Credential $Credential -Properties DistinguishedName -ErrorAction SilentlyContinue
    $domain = (( $user.DistinguishedName -split ',' ) | Where-Object { $_ -like 'DC=*' } | ForEach-Object { $_.Substring(3) }) -join '.'
    Unlock-ADAccount -Identity $user.DistinguishedName -Server $domain -Credential $Credential
}
elseif ($upnDomain -like '*tower.basis.asia') {
    $user = Get-ADUser -Filter "UserPrincipalName -eq '$UserName'" -Server 'Tower.basis.asia:3268' -Credential $Credential -Properties DistinguishedName -ErrorAction SilentlyContinue
    $domain = (( $user.DistinguishedName -split ',' ) | Where-Object { $_ -like 'DC=*' } | ForEach-Object { $_.Substring(3) }) -join '.'
    Unlock-ADAccount -Identity $user.DistinguishedName -Server $domain -Credential $Credential
}
else {
    Unlock-ADAccount -Identity $UserName -Server $upnDomain -Credential $Credential
}