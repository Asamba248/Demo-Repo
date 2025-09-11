Import-Module ActiveDirectory -ErrorAction Stop

#Define the name of OU to be created and Domain details
$OuName   = 'Paris'
$DomainDN = (Get-ADDomain).DistinguishedName
$OuDN     = "OU=$OuName,$DomainDN"

#Defines an array of users to be created
$Users = @(
  @{ First='Marie'; Last='Asamba'; Sam='masamba' }
  @{ First='John' ; Last='Doe'   ; Sam='jdoe'    }
  @{ First='Alice'; Last='Smith' ; Sam='asmith'  }
      )

#Looks up if the OU already exists, if not creates it
$ouExists = Get-ADOrganizationalUnit -LDAPFilter "(ou=$OuName)" -SearchBase $DomainDN -SearchScope OneLevel -ErrorAction SilentlyContinue
if (-not $ouExists) { New-ADOrganizationalUnit -Name $OuName -Path $DomainDN -ProtectedFromAccidentalDeletion $true }

#prepares a default password for the new users and creates them in the specified OU
$defaultPwd = ConvertTo-SecureString 'P@ssw0rd123!' -AsPlainText -Force
$dnsRoot    = (Get-ADDomain).DNSRoot

foreach ($u in $Users) {
  $sam  = $u.Sam
  $name = "$($u.First) $($u.Last)"  
  $upn  = "$sam@$dnsRoot"
  $exists = Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue
  if ($exists) { continue }
  New-ADUser -Name $name -GivenName $u.First -Surname $u.Last -SamAccountName $sam -UserPrincipalName $upn -AccountPassword $defaultPwd -ChangePasswordAtLogon $true -Enabled $true -Path $OuDN
                }

Get-ADUser -SearchBase $OuDN -LDAPFilter '(objectClass=user)' |
  Select-Object SamAccountName, Name |
  Sort-Object SamAccountName |
  Format-Table -AutoSize
