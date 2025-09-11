#Write a script to ping a range of IP addresses and report which are online and which are offline.
$startIP = [System.Net.IPAddress]::Parse("172.16.0.1")
$endIP = [System.Net.IPAddress]::Parse("172.16.0.40")

$pingResults = @()

for ($i = $startIP.GetAddressBytes()[3]; $i -le $endIP.GetAddressBytes()[3]; $i++) {
    $ip = "172.16.0.$i"
    $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet
    $pingResults += [PSCustomObject]@{
        IPAddress = $ip
        Status = if ($ping) { "Online" } else { "Offline" }
    }
}

$pingResults | Format-Table -AutoSize


#export network adapter information to a CSV file
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$networkAdapters = Get-NetAdapter | Select-Object Name, Status, MacAddress, LinkSpeed , @{Name="IPAddresses";Expression={(Get-NetIPAddress -InterfaceAlias $_.Name).IPAddress}}
$networkAdapters | Export-Csv -Path "C:\ADReports\NetworkAdapters_$timestamp.csv" -NoTypeInformation