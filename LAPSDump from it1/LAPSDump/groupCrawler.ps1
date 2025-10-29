$Computer = 'it1.railsystems.kz'

<#
Set-Location "C:\Temp\LAPSDump"

(Get-ADForest).Domains | %{ Get-ADComputer -Server $_ -Filter * -Property ms-Mcs-AdmPwd, ms-MCS-AdmPwdExpirationTime, Description | select Name, DNSHostName, Description, ms-Mcs-AdmPwd, @{n='AdmPwdExpirationTime';e={[DateTime]::FromFileTime($_."ms-MCS-AdmPwdExpirationTime").ToString('g')}} | Export-Csv -NoTypeInformation -UseCulture -Encoding utf8 -Path .\AdmPwd@$_.csv }
(Get-ADForest).Domains | %{ get-adgroup -Server $_ -filter * -Property distinguishedName, ms-MCS-AdmPwdExpirationTime, GroupCategory, GroupScope | ? {$_.distinguishedName -notlike "*CN=Users*" -and $_.distinguishedName -notlike "*CN=Builtin*"} | select SamAccountName, distinguishedName
(Get-ADForest).Domains | Select-Object -First 2
'concrete.railsystems.kz' | %{ get-adgroup -Server $_ -filter * -Property SamAccountName, distinguishedName, GroupCategory, GroupScope | ? {$_.distinguishedName -notlike "*CN=Users*" -and $_.distinguishedName -notlike "*CN=Builtin*"} | select SamAccountName, distinguishedName, GroupCategory, GroupScope  | Export-Csv -Append -NoTypeInformation -Delimiter ';' -Encoding utf8 -Path .\GroupMembers@$($(Get-ADDomain -Identity $_).Forest).csv }
(Get-ADForest).Domains | Select-Object -First 2 | %{ get-adgroup -Server $_ -filter * -Property SamAccountName, distinguishedName, GroupCategory, GroupScope | ? {$_.distinguishedName -notlike "*CN=Users*" -and $_.distinguishedName -notlike "*CN=Builtin*"} | select SamAccountName, distinguishedName, GroupCategory, GroupScope  | Export-Csv -Append -NoTypeInformation -Delimiter ';' -Encoding utf8 -Path .\GroupMembers@$($(Get-ADDomain -Identity $_).Forest).csv }
(Get-ADForest).Domains | Select-Object -First 1 | %{ get-adgroup -Server $_ -filter * -Property SamAccountName, distinguishedName, GroupCategory, GroupScope, Members | ? {$_.distinguishedName -notlike "*CN=Users*" -and $_.distinguishedName -notlike "*CN=Builtin*"} | select SamAccountName, distinguishedName, GroupCategory, GroupScope, Members, @{n='Identity';e={$_ + '\' + "SamAccountName"}} | Select-Object -First 1 }
(Get-ADForest).Domains | Select-Object -First 1 | %{ get-adgroup -Server $_ -filter * -Property SamAccountName, distinguishedName, GroupCategory, GroupScope, Members | ? {$_.distinguishedName -notlike "*CN=Users*" -and $_.distinguishedName -notlike "*CN=Builtin*"} | select SamAccountName, distinguishedName, GroupCategory, GroupScope, Members, @{n='Identity';e={$($(Get-ADDomain -Identity $_).Forest)}} | Select-Object -First 1 }
(Get-ADForest).Domains | Select-Object -First 1 | %{ get-adgroup -Server $_ -Identity 'AKK_Buhgalters' }
Get-ADGroup -filter * -Property SamAccountName, distinguishedName, GroupCategory, GroupScope | ? {$_.distinguishedName -notlike "*CN=Users*" -and $_.distinguishedName -notlike "*CN=Builtin*"}

Get-ADObject -Identity 'CN=Bin_service,OU=ADMINS,DC=Binding,DC=RailSystems,DC=kz' -property * | FL
Get-ADDomain -Identity 'CN=Bin_service,OU=ADMINS,DC=Binding,DC=RailSystems,DC=kz' -property *

$dn = 'CN=Bin_service,OU=ADMINS,DC=Binding,DC=RailSystems,DC=kz'
$index = $dn.indexOf(',DC=')
$tail = $dn.subString($index, $($dn.Length)-$index).ToLower()
$server = $tail.TrimStart(',dc=').Replace(',dc=', '.')

(Get-ADForest).Domains | %{ get-adgroup -Server $_ }

Get-ADForest | Select-Object -ExpandProperty Domains

https://devblogs.microsoft.com/scripting/active-directory-week-explore-group-membership-with-powershell/
#>

$Report = @()

$forest = Get-ADForest
$domains = $forest | Select-Object -ExpandProperty Domains | Get-ADDomain

foreach ($domain in $domains)
{
	$groups = Get-ADGroup -Server $domain.Name -filter * -Property SamAccountName, distinguishedName, GroupCategory, GroupScope, Members | ? {$_.distinguishedName -notlike "*CN=Users*" -and $_.distinguishedName -notlike "*CN=Builtin*"}
	foreach ($group in $groups)
	{
		$members = $group | Select-Object -ExpandProperty Members
		foreach ($member in $members)
		{
			Write-Host $group.SamAccountName$member
			try {
				$index = $member.ToLower().indexOf(',dc=')
				$tail = $member.subString($index, $($member.Length)-$index).ToLower()
				$server = $tail.TrimStart(',dc=').Replace(',dc=', '.')
				if ($server -eq $domain.Name) {
					$memberFull = Get-ADObject -Identity $member -Property SamAccountName, distinguishedName, ObjectClass
				} else {
					$memberFull = Get-ADObject -Server $server -Identity $member -Property SamAccountName, distinguishedName, ObjectClass
				}
				$Properties = [ordered]@{
					'Domain'=$domain.Name;`
					'Group'=$group.SamAccountName;`
					'GroupCategory'=$group.GroupCategory;`
					'GroupScope'=$group.GroupScope;`
					'Subject'=$memberFull.SamAccountName;`
					'SubjectClass'=$memberFull.ObjectClass;`
					'SubjectStatus'='';`
					'GroupDN'=$group.distinguishedName;`
					'SubjectDN'=$member;
				}
			}
			catch{
				$Properties = [ordered]@{
					'Domain'=$domain.Name;`
					'Group'=$group.SamAccountName;`
					'GroupCategory'=$group.GroupCategory;`
					'GroupScope'=$group.GroupScope;`
					'Subject'='';`
					'SubjectClass'='';`
					'SubjectStatus'='';`
					'GroupDN'=$group.distinguishedName;`
					'SubjectDN'=$member;
				}
			}
			
			$Report += New-Object -TypeName PSObject -Property $Properties
			#Write-Host 'test'
		}
	}
	
}


<#
foreach ($vm in $VMsName)
{
	$Properties = [ordered]@{
		'VMName'=$vm.VMName;`
		'Host'=$vm.ComputerName;`
		'State'=$vm.State;`
		'vCPU'=(Get-VMProcessor  -ComputerName $vm.ComputerName -VMName $vm.VMName | Select-Object -ExpandProperty Count);`
		'Volume'=(Get-VHD -ComputerName $vm.ComputerName -VMId (Get-VM -ComputerName $vm.ComputerName -VMName $vm.VMName | Select-Object -ExpandProperty VMId) | Select-Object -Property @{label='TotalGb';expression={$_.filesize/1gb -as [int]}} | Measure-Object TotalGb -Sum).Sum;`
        'Ready CPU migrate'=(Get-VMProcessor  -ComputerName $vm.ComputerName -VMName $vm.VMName | Select-Object -ExpandProperty CompatibilityForMigrationEnabled);`
		'Static mac-address'=(Get-VMNetworkAdapter  -ComputerName $vm.ComputerName -VMName $vm.VMName | Select-Object -First 1 -ExpandProperty DynamicMacAddressEnabled)
	}
	$Report += New-Object -TypeName PSObject -Property $Properties
}
#>
$Report | Export-Csv -path .\GroupMembers@$($forest.Name).csv -Delimiter ";" -NoTypeInformation -Encoding UTF8
<#
Copy-Item -Path "C:\Temp\LAPSDump\*.csv" -Destination $("\\$Computer\d$\_src\LAPSDump")
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