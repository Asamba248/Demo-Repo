# Get top 10 processes by memory usage
Get-Process | Sort-Object -Property WS -Descending | Select-Object -First 10 Name, WS , Id | Format-Table -AutoSize

# Display top 10 services with Automatic startup
Get-Service | Where-Object {$_.StartType -eq 'Automatic'} | Select-Object -First 10 Name, Status, StartType | Format-Table -AutoSize

# Find powershell version
$PSVersionTable.PSVersion

#Navigate the file system using powershell and display only log files
Get-ChildItem -Path C:\Windows -Filter *.log | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize

#Run a command using full name and alias
Get-ChildItem
dir

#Working with objects and properties
#Export the list of running processes to a CSV file, then re-import it and display it in a table format
$processes = Get-Process | Select-Object Name, Id, WS
$processes | Export-Csv -Path "C:\Temp\Processes.csv" -NoTypeInformation
$importedProcesses = Import-Csv -Path "C:\Temp\Processes.csv"
$importedProcesses | Format-Table -AutoSize

#Display all network adapters and their IP addresses, name and status
#Get-NetAdapter | Select-Object Name, Status, MacAddress, LinkSpeed , @{Name="IPAddresses";Expression={(Get-NetIPAddress -InterfaceAlias $_.Name).IPAddress}} | Format-Table -AutoSize

Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, @{Name='Status';Expression={(Get-NetAdapter -Name $_.InterfaceAlias).Status}}

#