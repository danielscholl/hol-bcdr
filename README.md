# Hands-On-Lab Business Continuity and Disaster Recovery

In this hands-on lab, you will implement three different environments and use Azure BCDR technologies to achieve three distinct goals for each environment type. These will include a migration to Azure, Azure region to region failover, and a PaaS implementation using BCDR technologies to ensure high availability of an application.
At the end of this hands-on lab, you will be better able to build a complex and robust IaaS BCDR solution.

__Create a Lab Machine:__

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdanielscholl%2Fhol-bcdr%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


1. Open [Azure Cloud Shell](https://shell.azure.com)

1. Execute the following CLI Commands

```bash

# Set CLI to desired Subscription (optional)
az account set --subscription <your_sub_name>

# Set Name Variables
Group=LabMachine1
Location=southcentralus
Name=lab

# Set Credential Variables  *CHANGE THIS
User=azureuser              
Password=AzurePassword@123  

# Choose the right Image based on your Subscription Type
Image=MicrosoftVisualStudio:VisualStudio:VS-2017-Ent-Win10-N:Latest   # MSDN Subscription
# Image=win2016datacenter                                             # Pay-As-You-Go Subscription

# Create a resource group.
az group create -otable \
  --name ${Group} \
  --location ${Location}

# Create a virtual machine. 
az vm create -otable \
    --resource-group ${Group} \
    --name ${Name} \
    --image ${Image} \
    --admin-username $User \
    --admin-password $Password

# Open port 3389 to allow RDP traffic to host.
az vm open-port -otable \
  --resource-group ${Group} \
  --name ${Name} \
  --port 3389 

# Install Required Software to host.   --> Change to your own script if desired.
az vm extension set -otable \
  --publisher Microsoft.Compute \
  --version 1.8 \
  --name CustomScriptExtension \
  --vm-name ${Name} \
  --resource-group ${Group} \
  --settings '{"fileUris": ["https://gist.githubusercontent.com/danielscholl/fafc0ace48068d54d4c4598d37615eb4/raw/14b9a111fda0138d31078ca5c569ec460e3ccfd7/lab.ps1"], "commandToExecute":"./lab.ps1"}' 

# Retrieve the IP Address for RDP Access
IP=$(az vm list-ip-addresses -g ${Group} -n ${Name} --query [0].virtualMachine.network.publicIpAddresses[0].ipAddress -o tsv)
echo "RDP://${IP}"
```

> RDP to the Lab Server and Validate the Tooling Requirements

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
  # Install AzureRM Powershell Module
  Install-Module -Name AzureRM -Repository PSGallery -Force -AllowClobber
  Import-Module AzureRM

  Get-Module AzureRM.* -list | Select-Object Name,Version

  # Sample Result
  Name                                  Version
  ----                                  -------
  AzureRM.Automation                    5.0.2  
  AzureRM.Backup                        4.0.6  
  AzureRM.Compute                       5.3.0   
  AzureRM.ContainerInstance             0.2.6  
  AzureRM.ContainerRegistry             1.0.6  
  AzureRM.DevTestLabs                   4.0.5  
  AzureRM.KeyVault                      5.0.4  
  AzureRM.Network                       6.4.0  
  AzureRM.profile                       5.3.3  
  AzureRM.Storage                       5.0.0

```

__Tooling Installation:__


```powershell

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
