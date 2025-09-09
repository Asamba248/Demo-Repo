# CPU Usage
$cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
Write-Host "CPU Usage: $([math]::Round($cpuUsage,2))%"

# Memory Usage
$memAvailable = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
Write-Host "Available Memory: $memAvailable MB"

# Disk Usage
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $used = ($_.Size - $_.FreeSpace) / 1GB
    $total = $_.Size / 1GB
    $percentUsed = ($used / $total) * 100
    Write-Host "$($_.DeviceID): $([math]::Round($percentUsed,2))% used ($([math]::Round($used,2))GB of $([math]::Round($total,2))GB)"
}