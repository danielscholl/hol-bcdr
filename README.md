# Hands-On-Lab Business Continuity and Disaster Recovery

In this hands-on lab, you will implement three different environments and use Azure BCDR technologies to achieve three distinct goals for each environment type. These will include a migration to Azure, Azure region to region failover, and a PaaS implementation using BCDR technologies to ensure high availability of an application.
At the end of this hands-on lab, you will be better able to build a complex and robust IaaS BCDR solution.

__Create a Lab Machine:__

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdanielscholl%2Fhol-bcdr%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

> RDP to the Lab Virtual Machine for the remaining Instructions

---------------------------------------------------------------

Open an RDP Session to the Lab Virtual Machine then download and execute the setup script.

__Setup the Lab Server:__

```powershell
curl https://raw.githubusercontent.com/danielscholl/hol-bcdr/master/setup.ps1 -o setup.ps1
powershell -Command "Start-Process setup.ps1"
```


__Clone the Repository:__

```powershell
git clone https://github.com/danielscholl/bcdr-hol.git lab
cd lab
```

__Create the Environment Variables:__

```powershell
# Copy the Sample Environment File to be used.
cp .env_sample.ps1 .env.ps1

# Edit the Environment file.
code .env.ps1

# Load the Environment file.
. ./.env.ps1
```

> Modify the file with the desired values and save it.

__Install the Azure Automation Resources:__

```powershell
# Load the Environment file and move to the directory
. ./.env.ps1 
cd AzureAutomation

# Run the Install Script for installing that Automation account and load the artifiacts.
./install.ps1  # Answer the questions that are presented
  subscriptionAdmin: {your_portal_login_id}
  subscriptionPassword: {your_portal_login_pwd}

cd ..
```

__Install the Azure Automation Resources:__

```powershell
# Load the Environment file and move to the directory
. ./.env.ps1 
cd IaaSPrimarySite

# Install the Infrastructure for the IaaS Primary Site
./install.ps1   # Answer the questions that are presented
  adminPassword:  {your_local_admin_password}

cd ..
```
