<#
.SYNOPSIS
    Microsoft Cloud Workshop: BCDR
.DESCRIPTION
  Install IaaS as Primary Site for Business Continuity and DR Lab
.EXAMPLE
  .\install.ps1
  Version History
  v1.0   - Initial Release
#>
#Requires -Version 5.1
#Requires -Module @{ModuleName='AzureRM.Resources'; ModuleVersion='5.0'}

Param(
  [string]$Subscription = $env:AZURE_SUBSCRIPTION,

  [string]$ResourceGroupName = "BCDRAzureAutomation",
  [string]$Location = "westcentralus"
)
. ../.env.ps1
Get-ChildItem Env:AZURE*

if ( !$Subscription) { throw "Subscription Required" }
if ( !$ResourceGroupName) { throw "ResourceGroupName Required" }
if ( !$Location) { throw "Location Required" }



###############################
## FUNCTIONS                 ##
###############################
function Write-Color([String[]]$Text, [ConsoleColor[]]$Color = "White", [int]$StartTab = 0, [int] $LinesBefore = 0, [int] $LinesAfter = 0, [string] $LogFile = "", $TimeFormat = "yyyy-MM-dd HH:mm:ss") {
    # version 0.2
    # - added logging to file
    # version 0.1
    # - first draft
    #
    # Notes:
    # - TimeFormat https://msdn.microsoft.com/en-us/library/8kb3ddd4.aspx

    $DefaultColor = $Color[0]
    if ($LinesBefore -ne 0) {  for ($i = 0; $i -lt $LinesBefore; $i++) { Write-Host "`n" -NoNewline } } # Add empty line before
    if ($StartTab -ne 0) {  for ($i = 0; $i -lt $StartTab; $i++) { Write-Host "`t" -NoNewLine } }  # Add TABS before text
    if ($Color.Count -ge $Text.Count) {
      for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
    }
    else {
      for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
      for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $DefaultColor -NoNewLine }
    }
    Write-Host
    if ($LinesAfter -ne 0) {  for ($i = 0; $i -lt $LinesAfter; $i++) { Write-Host "`n" } }  # Add empty line after
    if ($LogFile -ne "") {
      $TextToFile = ""
      for ($i = 0; $i -lt $Text.Length; $i++) {
        $TextToFile += $Text[$i]
      }
      Write-Output "[$([datetime]::Now.ToString($TimeFormat))]$TextToFile" | Out-File $LogFile -Encoding unicode -Append
    }
  }
  function Get-ScriptDirectory {
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path $Invocation.MyCommand.Path
  }
  function LoginAzure() {
    Write-Color -Text "Logging in and setting subscription..." -Color Green
    if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {
      if($env:AZURE_TENANT) {
        Login-AzureRmAccount -TenantId $env:AZURE_TENANT
      } else {
        Login-AzureRmAccount
      }
    }
    Set-AzureRmContext -SubscriptionId ${Subscription} | Out-null
  }
  function CreateResourceGroup([string]$ResourceGroupName, [string]$Location) {
    # Required Argument $1 = RESOURCE_GROUP
    # Required Argument $2 = LOCATION

    Get-AzureRmResourceGroup -Name $ResourceGroupName -ev notPresent -ea 0 | Out-null

    if ($notPresent) {

      Write-Host "Creating Resource Group $ResourceGroupName..." -ForegroundColor Yellow
      New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
    }
    else {
      Write-Color -Text "Resource Group ", "$ResourceGroupName ", "already exists." -Color Green, Red, Green
    }
  }
  function Upload-File ($ResourceGroupName, $ContainerName, $FileName, $BlobName) {

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
    Write-Output "Uploading $BlobName..."
    $UploadFile = @{
      Context   = $StorageContext;
      Container = $ContainerName;
      File      = $FileName;
      Blob      = $BlobName;
    }

    Set-AzureStorageBlobContent @UploadFile -Force;
  }

  function GetStorageAccount([string]$ResourceGroupName) {
    # Required Argument $1 = RESOURCE_GROUP

    if ( !$ResourceGroupName) { throw "ResourceGroupName Required" }

    return (Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName).StorageAccountName
  }
  function Create-Container ($ResourceGroupName, $ContainerName, $Access = "Blob") {
    # Required Argument $1 = RESOURCE_GROUP
    # Required Argument $2 = CONTAINER_NAME

    # Get Storage Account
    $StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName
    if (!$StorageAccount) {
      Write-Error -Message "Storage Account in $ResourceGroupName not found. Please fix and continue"
      return
    }

    $Keys = Get-AzureRmStorageAccountKey -Name $StorageAccount.StorageAccountName -ResourceGroupName $ResourceGroupName
    $StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey $Keys[0].Value

    $Container = Get-AzureStorageContainer -Name $ContainerName -Context $StorageContext -ErrorAction SilentlyContinue
    if (!$Container) {
      Write-Warning -Message "Storage Container $ContainerName not found. Creating the Container $ContainerName"
      New-AzureStorageContainer -Name $ContainerName -Context $StorageContext -Permission $Access
    }
  }
###############################
## Azure Intialize           ##
###############################
$BASE_DIR = Get-ScriptDirectory
$DEPLOYMENT = Split-Path $BASE_DIR -Leaf
LoginAzure
CreateResourceGroup $ResourceGroupName $Location

##############################
## Deploy Template          ##
##############################
Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
Write-Color -Text "Deploying ", "StorageAccount ", "template..." -Color Green, Red, Green
Write-Color -Text "---------------------------------------------------- "-Color Yellow
New-AzureRmResourceGroupDeployment -Name "$DEPLOYMENT-Storage" `
  -TemplateFile $BASE_DIR\azuredeploy.json `
  -TemplateParameterFile $BASE_DIR\azuredeploy.parameters.json `
  -ResourceGroupName $ResourceGroupName

Write-Color -Text "Retrieving Storage Account Information..." -Color Green
$StorageAccountName = GetStorageAccount $ResourceGroupName

##############################
## Sync script artifacts    ##
##############################
$DIRECTORY = "dsc"
Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
Write-Color -Text "Uploading ", "$DEPLOYMENT-dsc ", "artifacts..." -Color Green, Red, Green
Write-Color -Text "---------------------------------------------------- "-Color Yellow

Write-Color -Text "Creating Container for $DIRECTORY..." -Color Yellow
Create-Container $ResourceGroupName $DIRECTORY

$files = @(Get-ChildItem $BASE_DIR\$DIRECTORY)
foreach ($file in $files) {
  Upload-File $ResourceGroupName $DIRECTORY $BASE_DIR\$DIRECTORY\$file
}

##############################
## Sync template artifacts  ##
##############################
$DIRECTORY = "templates"
Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
Write-Color -Text "Uploading ", "$DIRECTORY-templates ", "artifacts..." -Color Green, Red, Green
Write-Color -Text "---------------------------------------------------- "-Color Yellow

Write-Color -Text "Creating Container for $DIRECTORY..." -Color Yellow
Create-Container $ResourceGroupName $DIRECTORY

$files = @(Get-ChildItem $BASE_DIR\$DIRECTORY)
foreach ($file in $files) {
  Upload-File $ResourceGroupName $DIRECTORY $BASE_DIR\$DIRECTORY\$file
}

##############################
## Sync template artifacts  ##
##############################
$DIRECTORY = "runbooks"
Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
Write-Color -Text "Uploading ", "$DIRECTORY-runbooks ", "artifacts..." -Color Green, Red, Green
Write-Color -Text "---------------------------------------------------- "-Color Yellow

Write-Color -Text "Creating Container for $DIRECTORY..." -Color Yellow
Create-Container $ResourceGroupName $DIRECTORY

$files = @(Get-ChildItem $BASE_DIR\$DIRECTORY)
foreach ($file in $files) {
  Upload-File $ResourceGroupName $DIRECTORY $BASE_DIR\$DIRECTORY\$file
}

##############################
## Sync application artifacts  ##
##############################
$DIRECTORY = "artifacts"
Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
Write-Color -Text "Uploading ", "$DIRECTORY-artifacts ", "artifacts..." -Color Green, Red, Green
Write-Color -Text "---------------------------------------------------- "-Color Yellow

Write-Color -Text "Creating Container for $DIRECTORY..." -Color Yellow
Create-Container $ResourceGroupName $DIRECTORY

$files = @(Get-ChildItem $BASE_DIR\$DIRECTORY)
foreach ($file in $files) {
  Upload-File $ResourceGroupName $DIRECTORY $BASE_DIR\$DIRECTORY\$file
}

##############################
## Deploy Template          ##
##############################
$jobGuid1 = [guid]::NewGuid()
$jobGuid2 = [guid]::NewGuid()
$jobGuid3 = [guid]::NewGuid()

Write-Color -Text "`r`n---------------------------------------------------- "-Color Yellow
Write-Color -Text "Deploying ", "$DEPLOYMENT-Account ", "template..." -Color Green, Red, Green
Write-Color -Text "---------------------------------------------------- "-Color Yellow
New-AzureRmResourceGroupDeployment -Name "$DEPLOYMENT-Automation" `
  -TemplateFile $BASE_DIR\deployAutomation.json `
  -TemplateParameterFile $BASE_DIR\deployAutomation.parameters.json `
  -StorageAccountName $StorageAccountName `
  -jobGuid1 $jobGuid1 -jobGuid2 $jobGuid2 -jobGuid3 $jobGuid3 `
  -ResourceGroupName $ResourceGroupName
