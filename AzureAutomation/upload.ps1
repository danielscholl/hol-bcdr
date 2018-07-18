<# Copyright (c) 2017
.Synopsis
   Creates a Container in a storage account to hold ARM Templates
.DESCRIPTION
   This script will create a storage container for hosting ARM Templates.
.EXAMPLE
#>

#Requires -Version 3.0
#Requires -Module AzureRM.Resources

Param(
  [Parameter(Mandatory = $false)]
  [string] $ResourceGroupName = "BCDRAzureAutomation",

  [Parameter(Mandatory = $false)]
  [string] $ContainerName = "templates",

  [Parameter(Mandatory = $true)]
  [string] $Name
)

function Upload-Template ($ResourceGroupName, $ContainerName, $Name) {

  # Get Storage Account
  $StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName
  if (!$StorageAccount) {
    Write-Error -Message "Storage Account in $ResourceGroupName not found. Please fix and continue"
    return
  }

  $Keys = Get-AzureRmStorageAccountKey -Name $StorageAccount.StorageAccountName `
    -ResourceGroupName $ResourceGroupName

  $StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccount.StorageAccountName `
    -StorageAccountKey $Keys[0].Value

  ### Upload a file to the Microsoft Azure Storage Blob Container
  Write-Output "Uploading $Name..."
  $UploadFile = @{
    Context   = $StorageContext;
    Container = $ContainerName;
    File      = "templates\$Name";
    Blob      = $Name;
  }

  Set-AzureStorageBlobContent @UploadFile -Force;
}

Upload-Template $ResourceGroupName $ContainerName $Name