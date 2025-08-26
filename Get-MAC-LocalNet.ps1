$network = "172.16.9"
1..254 | ForEach-Object {
    $ip = "$network.$_"
    $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet
    if ($ping) {
        $mac = (arp -a $ip) -match '([0-9a-f]{2}-){5}[0-9a-f]{2}'
        [pscustomobject]@{
            IPAddress = $ip
            MACAddress = $mac
        }
    }
} | Format-Table -AutoSize
