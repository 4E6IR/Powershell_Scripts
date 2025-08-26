# Замените RemotePC на имя или IP целевого хоста
Get-Printer -ComputerName RemotePC | 
  Select Name, ShareName, DriverName, PortName