$domains=(Get-ADForest).domains
foreach ($domain in $domains) {
        $DomainComputers = Get-ADComputer -Filter * -Properties * -Server "$domain"  | Select Enabled, Name, DNSHostName, Description, IPv4Address, ms-Mcs-AdmPwd, LastLogonDate, OperatingSystem, DistinguishedName
        $DomainComputers | Export-Csv -Path C:\Users\a.zhanatov\Desktop\Forest_PCs.csv -Delimiter ";" -NoTypeInformation -Encoding UTF8 -Append -Force
		}