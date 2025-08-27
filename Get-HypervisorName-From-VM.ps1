Invoke-Command -ComputerName rws-probe-01.railsystems.kz -ScriptBlock {Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters" -Name HostName} -Credential(Get-Credential) | fl Hostname
#
#
#
