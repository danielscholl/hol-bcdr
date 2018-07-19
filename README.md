# Hands-On-Lab Business Continuity and Disaster Recovery

In this hands-on lab, you will implement three different environments and use Azure BCDR technologies to achieve three distinct goals for each environment type. These will include a migration to Azure, Azure region to region failover, and a PaaS implementation using BCDR technologies to ensure high availability of an application.
At the end of this hands-on lab, you will be better able to build a complex and robust IaaS BCDR solution.


__Tooling Requirements:__

1. [Windows Powershell](https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-windows-powershell?view=powershell-5.1)

```powershell
  $PSVersionTable.PSVersion

  # Result
  Major  Minor  Build  Revision
  -----  -----  -----  --------
  5      1      16299  248
```

2. [Azure PowerShell Modules](https://www.powershellgallery.com/packages/Azure/5.1.1)

```powershell
  Get-Module Azure -list | Select-Object Name,Version

  # Result
  Name  Version
  ----  -------
  Azure 5.1.1
```

3. [AzureRM Powershell Modules](https://www.powershellgallery.com/packages/AzureRM/5.1.1)

```powershell
  Get-Module AzureRM.* -list | Select-Object Name,Version

  # Result
  Name                                  Version
  ----                                  -------
  AzureRM.Automation                    4.3.1
  AzureRM.Compute                       4.5.0
  AzureRM.KeyVault                      4.2.1
  AzureRM.Network                       5.4.1
  AzureRM.profile                       4.5.0
  AzureRM.Resources                     5.5.1
  AzureRM.Scheduler                     0.16.2
  AzureRM.Storage                       4.2.2
```

__Tooling Installation:__


```powershell
Install-Module Azure
Install-Module AzureRM

Import-Module Azure
Import-Module AzureRM
```

__Clone the Repository:__

```powershell
git clone https://github.com/danielscholl/bcdr-hol.git lab
cd lab
```

__Install the Azure Automation Resources:__

```powershell
. ./.env.ps1  # Source the environment variables
cd AzureAutomation
./install.ps1  # Answer the questions
  subscriptionAdmin: {your_portal_login_id}
  subscriptionPassword: {your_portal_login_pwd}

```
