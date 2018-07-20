# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force;

# Install AzureRM Powershell Module
Install-Module -Name Azure -Repository PSGallery -Force -AllowClobber
Install-Module -Name AzureRM -Repository PSGallery -Force -AllowClobber
Import-Module -Name Azure
Import-Module -Name AzureRM


Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
