$domains=(Get-ADForest).domains
$domains += "tower.basis.asia"
$User=Read-Host "Имя? / Фамилия? / Login?"
foreach ($domain in $domains) {
    try {
        $UserNameResult = Get-ADUser -Filter "Enabled -eq 'True' -and CN -like '*$User*' -or SamAccountName -like '*$User*' -or UserPrincipalName -like '*$User*'" -Properties PasswordExpired, MiddleName, EmployeeID, LastLogonDate, Company -Server "$domain" -ErrorAction Stop
        $UserNameResult | FT PasswordExpired, Name, MiddleName, EmployeeID, LastLogonDate, @{Name='SamAccountName'; Expression={"$domain\$($_.SamAccountName)"}}, UserPrincipalName, DistinguishedName, Company -AutoSize -Wrap -GroupBy Name
}
    catch {
        #Write-Host "Ошибка при поиске пользователя в домене $domain"
        #Write-Host $_.Exception.Message
    }
}