#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Assign Packages to Install
$Packages = 'googlechrome', `
  'visualstudiocode', `
  'visualstudio2017community', `
  'visualstudio2017-workload-azure', `
  'visualstudio2017-workload-netweb'

#Install Packages
ForEach ($PackageName in $Packages)
{choco install $PackageName -y}

# Install AzureRM Powershell Module
Install-Module -Name Azure -Repository PSGallery -Force -AllowClobber
Install-Module -Name AzureRM -Repository PSGallery -Force -AllowClobber
Import-Module -Name Azure
Import-Module -Name AzureRM

#Reboot
Restart-Computer
