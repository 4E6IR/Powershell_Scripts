$groups=@("group1","group2","group3")
$users=@("user1","user2","user3")
$credentials = Get-Credential
foreach ($group in $groups) {
    Add-ADGroupMember -Identity $group -Members $users -Server server.domain.local -Credential $credentials
}