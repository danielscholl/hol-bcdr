# Hands-On-Lab Business Continuity and Disaster Recovery

In this hands-on lab, you will implement three different environments and use Azure BCDR technologies to achieve three distinct goals for each environment type. These will include a migration to Azure, Azure region to region failover, and a PaaS implementation using BCDR technologies to ensure high availability of an application.
At the end of this hands-on lab, you will be better able to build a complex and robust IaaS BCDR solution.

__Create a Lab Machine:__

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdanielscholl%2Fhol-bcdr%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

> RDP to the Lab Virtual Machine for the remaining Instructions

---------------------------------------------------------------

Open an RDP Session to the Lab Virtual Machine and execute the setup script.

__Setup the Lab Server:__

```powershell
powershell -Command "Start-Process C:\setup.ps1"
```


__Clone the Repository:__

```powershell
git clone https://github.com/danielscholl/bcdr-hol.git lab
cd lab
```

__Create the Environment Variables:__

```powershell
cp .env_sample.ps1 .env.ps1
code env.ps1
```

> Modify the file with the desired values and save it.

__Install the Azure Automation Resources:__

```powershell
. ./.env.ps1  # Source the environment variables
cd AzureAutomation
./install.ps1  # Answer the questions
  subscriptionAdmin: {your_portal_login_id}
  subscriptionPassword: {your_portal_login_pwd}
```
