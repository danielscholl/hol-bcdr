# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force;

#Register Chocolatly Package source
Register-PackageSource -Name chocolatey -ProviderName Chocolatey -Location http://chocolatey.org/api/v2/ -Trusted -Force

#Install packages
Install-Package -Name GoogleChrome -Source Chocolatey -Force
Install-Package -Name visualstudiocode -Source Chocolatey -Force

# Install AzureRM Powershell Module
Install-Module -Name Azure -Repository PSGallery -Force -AllowClobber
Install-Module -Name AzureRM -Repository PSGallery -Force -AllowClobber
Import-Module -Name Azure
Import-Module -Name AzureRM
