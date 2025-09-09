# Load AD module
Import-Module ActiveDirectory

# Define OU and output paths
$OU = "OU=IT,DC=Adatum,DC=com"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$reportDir = "C:\ADReports"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

# Define output files
$allUsersFile = "$reportDir\AllUsers_$timestamp.csv"
$inactiveFile = "$reportDir\InactiveUsers_$timestamp.csv"
$disabledFile = "$reportDir\DisabledUsers_$timestamp.csv"
$lockedFile = "$reportDir\LockedUsers_$timestamp.csv"
$passwordExpiringFile = "$reportDir\PasswordExpiringSoon_$timestamp.csv"

# Get all users in OU
$users = Get-ADUser -SearchBase $OU -Filter * -Properties Name, SamAccountName, Enabled, LastLogonDate, PasswordNeverExpires, PasswordLastSet, AccountExpirationDate

# Export all users to CSV
$users | Select-Object Name, SamAccountName, Enabled, LastLogonDate, PasswordNeverExpires, PasswordLastSet, AccountExpirationDate | Export-Csv -Path $allUsersFile -NoTypeInformation

# Filter inactive users (not logged in for 90 days)
$inactiveUsers = $users | Where-Object { $_.LastLogonDate -lt (Get-Date).AddDays(-90) -or $_.LastLogonDate -eq $null }
$inactiveUsers | Select-Object Name, SamAccountName, LastLogonDate | Export-Csv -Path $inactiveFile -NoTypeInformation

# Filter disabled users
$disabledUsers = $users | Where-Object { -not $_.Enabled }
$disabledUsers | Select-Object Name, Enabled SamAccountName | Export-Csv -Path $disabledFile -NoTypeInformation