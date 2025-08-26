$credentials = Get-Credential
$groups=@("PMK_Report_Parcel_Report_Read_only","PMK_Report_Parcel_Report_ZU_Read_only","PMK_Report_Parcel_Report_OKK_Read_only","PMK_Report_Parcel_Report_PPU_Read_only","PMK_Report_Parcel_Report_UNK_Read_only","PMK_Report_Parcel_Report_UPPO_Read_only","PMK_Report_Parcel_Report_USSOGP_Read_only","PMK_Report_Parcel_Report_UTK_Read_only")
$users=@("User1","User2")
foreach ($group in $groups) {
    Add-ADGroupMember -Identity $group -Members $users -Server pmk.railsystems.kz -Credential $credentials
}