<# AD DS audit and hygiene script. This script retrieves
various user account details from a specified OU in Active Directory and generates 
reports on inactive accounts, disabled accounts, locked accounts, and accounts with passwords 
expiring soon. The reports are exported to CSV files for further analysis. #>

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

# Filter inactive accounts (not logged in for 90 days)
$inactiveUsers = $users | Where-Object { $_.LastLogonDate -lt (Get-Date).AddDays(-90) -or $_.LastLogonDate -eq $null }
$inactiveUsers | Select-Object Name, SamAccountName, LastLogonDate | Export-Csv -Path $inactiveFile -NoTypeInformation

# Filter disabled accounts
$disabledUsers = $users | Where-Object { -not $_.Enabled }
$disabledUsers | Select-Object Name, Enabled, SamAccountName | Export-Csv -Path $disabledFile -NoTypeInformation

#filter locked accounts
$lockedUsers = Search-ADAccount -LockedOut | Select-Object Name, SamAccountName
$lockedUsers | Export-Csv -Path $lockedFile -NoTypeInformation

# Filter users with passwords expiring in next 15 days and export to CSV
$maxPasswordAge = 90 # days
$passwordExpiringUsers = $users | Where-Object {
    ($_.PasswordLastSet -ne $null) -and
    ($_.PasswordNeverExpires -eq $false) -and
    ($_.PasswordLastSet -lt (Get-Date).AddDays(-($maxPasswordAge - 15)))
}
$passwordExpiringUsers | Select-Object Name, SamAccountName, PasswordLastSet | Export-Csv -Path $passwordExpiringFile -NoTypeInformation 
# Summary
Write-Host "Reports generated in $reportDir"
Write-Host "- All Users: $allUsersFile"
Write-Host "- Inactive Users: $inactiveFile"
Write-Host "- Disabled Users: $disabledFile"
Write-Host "- Locked Users: $lockedFile"
Write-Host "- Passwords Expiring Soon: $passwordExpiringFile"
