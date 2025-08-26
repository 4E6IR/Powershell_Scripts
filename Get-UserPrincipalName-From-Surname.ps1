$users = Get-Content "C:\Users\a.zhanatov\Desktop\Users.txt"

foreach ($user in $users) {
    $user = $user.Trim()  # Удаляем лишние пробелы
    if (-not $user) { continue }  # Пропускаем пустые строки

    $adUsers = Get-ADUser -Filter "Name -like '*$user*' -and Enabled -eq 'True'" -Properties UserPrincipalName -ErrorAction SilentlyContinue
    
    if ($adUsers) {
        if ($adUsers.Count -gt 1) {
            Write-Warning "Найдено несколько пользователей с именем '$user':"
        }
        foreach ($u in $adUsers) {
            Write-Output "$user : $($u.UserPrincipalName) (Name: $($u.Name), SAM: $($u.SamAccountName))"
        }
    } else {
        Write-Output "$user : не найден или учётная запись отключена"
    }
}