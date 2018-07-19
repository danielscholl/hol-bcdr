<#
.SYNOPSIS
    Microsoft Cloud Workshop: BCDR
.DESCRIPTION
  Database DB Scro[t] for Business Continuity and DR Lab
.EXAMPLE
  .\dbConfig.ps1
  Version History
  v1.0   - Initial Release
#>

Configuration Main
{
  Param ( [string] $nodeName )

  Import-DscResource -ModuleName PSDesiredStateConfiguration

  Node $nodeName
    {
      Script ConfigureSql
      {
        TestScript = {
          return $false
        }
        SetScript = {
          $disk = Get-Disk | where-object PartitionStyle -eq "RAW"
          $disk | Initialize-Disk -PartitionStyle MBR -PassThru -confirm:$false
          $partition = $disk | New-Partition -UseMaximumSize -DriveLetter F
          $partition | Format-Volume -Confirm:$false -Force

          Start-Sleep -Seconds 60

          $logs = "F:\Logs"
          $data = "F:\Data"
          $backups = "F:\Backup"
          [system.io.directory]::CreateDirectory($logs)
          [system.io.directory]::CreateDirectory($data)
          [system.io.directory]::CreateDirectory($backups)

      }
      GetScript = {@{Result = "ConfigureSql"}
      }
    }
  }
}
