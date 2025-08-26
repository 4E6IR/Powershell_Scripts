$Server = 'railsystems.kz'
$Credentials = 'Tower\d830823350777'
Get-ADUser -Identity a830823350777 -Server $Server | Unlock-ADAccount -Server $Server -Credential "$Credentials"