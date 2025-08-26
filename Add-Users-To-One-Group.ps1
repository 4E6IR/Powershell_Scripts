$groupName="GroupName"
$users=@("user1","user2","user3")
Add-ADGroupMember -Identity $groupName -Members $users -Server ServerName.railsystems.kz