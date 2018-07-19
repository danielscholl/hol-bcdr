Configuration Frontend
{

  Import-DscResource -ModuleName PSDesiredStateConfiguration

  Node Web
    {
      WindowsFeature WebServerRole
      {
        Name = "Web-Server"
        Ensure = "Present"
      }

      WindowsFeature WebManagementConsole
      {
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
      }

      Script ConfigureDisk
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
          $app = "F:\app"

          [system.io.directory]::CreateDirectory($logs)
          [system.io.directory]::CreateDirectory($app)
        }
      GetScript = {@{Result = "ConfigureDisk"}
      }
    }
  }
}
