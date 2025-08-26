#$server=Read-Host "Сервер для поиска?"
#$Name=Read-Host "Имя юзера?"
$LastName=Read-Host "Фамилия юзера"
Get-ADUser -Filter "Surname -like '*$LastName*'" -Properties * | ft Name,OfficePhone, UserPrincipalName, Title, Department