# read config
$config = Get-Content -Path ".\config.json" | ConvertFrom-Json

# Archiv files older than...
function ArchiveLogs {
  param (
    [string]$directory,
    [int]$archiveAfterDays,
    [int]$deleteAfterDays
  )

  # date trigger
  $archiveDateThreshold = (Get-Date).AddDays(-$archiveAfterDays)
  $deleteDateThreshold = (Get-Date).AddDays(-$deleteAfterDays)

  # log file for tracking
  $logFile = "$directory\archive_log.txt"

  # find files older than...
  $filesToArchive = Get-ChildItem -Path $directory -File -Recurse | Where-Object {
    $_.LastWriteTime -lt $archiveDateThreshold
  }

  foreach ($file in $filesToArchive) {
    $zipFilePath = "$($file.FullName).zip"

    try {
      # zip files
      Compress-Archive -Path $file.FullName -DestinationPath $zipFilePath -Force
      # verify if compression was successful before deleting
      if (Test-Path $zipFilePath) {
        Remove-Item -Path $file.FullName -Force
        # log success
        Add-Content -Path $logFile -Value "[$(Get-Date)] Archiving successful: $($file.FullName) -> $zipFilePath"
      } else {
        # log failure
        Add-Content -Path $logFile -Value "[$(Get-Date)] Archiving failed for file: $($file.FullName)"
      }
    } catch {
      # log any error
      Add-Content -Path $logFile -Value "[$(Get-Date)] Error archiving file: $($file.FullName) - $_"
    }
  }

  # delete old files
  $filesToDelete = Get-ChildItem -Path $directory -File -Recurse | Where-Object {
    $_.LastWriteTime -lt $deleteDateThreshold
  }

  foreach ($file in $filesToDelete) {
    try {
      # delete files
      Remove-Item -Path $file.FullName -Force
      # log success
      Add-Content -Path $logFile -Value "[$(Get-Date)] Deleted: $($file.FullName)"
    } catch {
      # log any error
      Add-Content -Path $logFile -Value "[$(Get-Date)] Error deleting file: $($file.FullName) - $_"
    }
  }
}

# search folders
foreach ($pathConfig in $config.Paths) {
  ArchiveLogs -directory $pathConfig.Directory `
                   -archiveAfterDays $pathConfig.ArchiveAfterDays `
                   -deleteAfterDays $pathConfig.DeleteAfterDays
}
