param([string]$InputFile)
$c = Get-Credential
Get-Content $InputFile | % { Unlock-ADAccount -Server railsystems.kz -Identity $_ -Credential $c -ErrorAction SilentlyContinue }