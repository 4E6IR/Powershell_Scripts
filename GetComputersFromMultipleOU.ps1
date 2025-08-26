# Определяем два OU
$ou1 = "ou=workstations,ou=domain computers,dc=wheelset,dc=railsystems,dc=kz"
$ou2 = "ou=laptop,ou=domain computers,dc=wheelset,dc=railsystems,dc=kz"

# Инициализируем массив для хранения результатов
$computers = @()

# Получаем компьютеры из первого OU и добавляем их в массив
$computers += Get-ADComputer -Filter * -Server wheelset.railsystems.kz -SearchBase $ou1 -Property IPv4Address

# Получаем компьютеры из второго OU и добавляем их в массив
$computers += Get-ADComputer -Filter * -Server wheelset.railsystems.kz -SearchBase $ou2 -Property IPv4Address

$computers | select Name, DNSHostName, IPv4Address,Enabled | Export-Csv -Delimiter ";" -NoTypeInformation -Encoding UTF8 -Append -Path c:\Users\a.zhanatov\Desktop\WORK\GLPI\PCs\ALL\Domain_PCs.csv