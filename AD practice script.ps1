<#
.SYNOPSIS
  Builds a hands-on Active Directory practice lab (OU structure, groups, GPOs, users, delegation, home dirs).
.DESCRIPTION
  Designed for a LAB domain. Uses functions, loops, conditionals, arrays, logging, and supports -WhatIf.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
  [string]$BaseOUName = 'Paris',
  [string]$DomainDN = (Get-ADDomain).DistinguishedName
)
