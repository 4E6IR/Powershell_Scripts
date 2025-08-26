#Способ №1
# Показать все прямые группы пользователя
Get-ADPrincipalGroupMembership -Identity "I.Dychko"  -Server pmk.railsystems.kz| Select-Object Name | Sort-Object Name

#Способ №2
Get-ADUser -Identity "I.Dychko"  -Server pmk.railsystems.kz -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Sort-Object Name

#Способ №3. Вложенные группы: Если пользователь состоит в группе, которая сама является членом другой группы, это не всегда отображается напрямую
(Get-ADUser -Identity "I.Dychko" -Properties MemberOf -Server pmk.railsystems.kz).MemberOf | Get-ADGroup -Server pmk.railsystems.kz | Select-Object Name, DistinguishedName  | Sort-Object Name