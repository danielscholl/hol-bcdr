<#
.SYNOPSIS
    Microsoft Cloud Workshop: BCDR
.DESCRIPTION
  Install Active Directory on a VM for Business Continuity and DR Lab
.EXAMPLE
  .\installAD.ps1
  Version History
  v1.0   - Initial Release
#>


#Configure Disk on Domain Controller
$disk = Get-Disk | where-object PartitionStyle -eq "RAW"
$disk | Initialize-Disk -PartitionStyle MBR -PassThru -confirm:$false
$partition = $disk | New-Partition -UseMaximumSize -DriveLetter F
$partition | Format-Volume -Confirm:$false -Force

#Install Domain Services and Configure New AD Forest
$password = "AzurePassword@123"
$domain = "contoso.com"
$smPassword = (ConvertTo-SecureString $password -AsPlainText -Force)

Install-WindowsFeature -Name "AD-Domain-Services" `
                       -IncludeManagementTools `
                       -IncludeAllSubFeature

Install-ADDSForest -DomainName $domain `
				  -DomainMode "Win2012" `
				  -ForestMode "Win2012" `
          -DatabasePath "C:\NTDS" `
				  -LogPath "C:\NTDS" `
          -SYSVOLPath "C:\NTDS\SYSVOL" `
				  -SafeModeAdministratorPassword $smPassword `
          -Force
