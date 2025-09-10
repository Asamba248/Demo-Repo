# CPU Usage
$cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
Write-Host "CPU Usage: $([math]::Round($cpuUsage,2))%"

# Memory Usage
$memAvailable = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
Write-Host "Available Memory: $memAvailable MB"

# Disk Usage
$disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
foreach ($disk in $disks) {
    $sizeGB = [math]::Round($disk.Size / 1GB, 2)
    $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    $usedGB = [math]::Round($sizeGB - $freeGB, 2)
    $usedPercent = if ($sizeGB -ne 0) { [math]::Round(($usedGB / $sizeGB) * 100, 2) } else { 0 }
    Write-Host "Drive $($disk.DeviceID): Total Size: $sizeGB GB, Used: $usedGB GB ($usedPercent%), Free: $freeGB GB"
}


#System information reporter
$sysInfo = Get-CimInstance -ClassName Win32_OperatingSystem
Write-Host "System Information:"
Write-Host "  Name: $($sysInfo.Name)"
Write-Host "  Version: $($sysInfo.Version)"
Write-Host "  Manufacturer: $($sysInfo.Manufacturer)"
Write-Host "  Architecture: $($sysInfo.OSArchitecture)"


#list all running processes and save to a text file
$processes = Get-Process | Select-Object Name, Id, WS
$processes | Export-Csv -Path "C:\ADReports\RunningProcesses_$timestamp.csv" -NoTypeInformation 

