$domains = (Get-ADForest -Identity railsystems.kz).domains
$domains += "tower.basis.asia"
$computers = @()
foreach ($domain in $domains) {
    $computers += Get-ADComputer -Filter * -Property IPv4Address, ms-Mcs-AdmPwd -Server $domain  | Select-Object DNSHostName, IPv4Address, ms-Mcs-AdmPwd
    }
$computers | Export-Csv '\\AKKHPWS134.tower.basis.asia\d$\LAPS\Laps.csv' -Delimiter ";" -NoTypeInformation -Encoding UTF8