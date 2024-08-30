param (
  [string]$mode = "archive"  # Default is to archive, unless "generate" is passed
)

# Function to generate test folders and log files
function GenerateTestFolders {
  $rootPath = ".\TestLogs"
  $subfolders = @("Logs_A", "Logs_B", "Logs_C")
  $fileCountPerFolder = 5

  # Create root folder if it doesn't exist
  if (-Not (Test-Path -Path $rootPath)) {
    New-Item -Path $rootPath -ItemType Directory
  }

  # Create subfolders and generate log files
  foreach ($subfolder in $subfolders) {
    $folderPath = Join-Path -Path $rootPath -ChildPath $subfolder

    if (-Not (Test-Path -Path $folderPath)) {
      New-Item -Path $folderPath -ItemType Directory
    }

    for ($i = 1; $i -le $fileCountPerFolder; $i++) {
      # Generate random date within the last 120 days
      $randomDaysAgo = Get-Random -Minimum 0 -Maximum 360
      $lastWriteTime = (Get-Date).AddDays(-$randomDaysAgo)

      # Create a unique file name with timestamp
      $fileName = "LogFile_{0:yyyy-MM-dd_HHmmss}_$i.txt" -f $lastWriteTime
      $filePath = Join-Path -Path $folderPath -ChildPath $fileName

      # Write sample content to the log file
      Set-Content -Path $filePath -Value "This is a test log file. File number: $i with date: $($lastWriteTime.ToString('yyyy-MM-dd'))"

      # Set the file's LastWriteTime to simulate the random creation date
      (Get-Item $filePath).LastWriteTime = $lastWriteTime
    }
  }

  Write-Host "Test folders and files created at $rootPath."
}

# Function to archive and delete old log files
function ArchiveLogs {
  param (
    [string]$directory,
    [int]$archiveAfterDays,
    [int]$deleteAfterDays
  )

  # Calculate the date thresholds for archiving and deleting
  $archiveDateThreshold = (Get-Date).AddDays(-$archiveAfterDays)
  $deleteDateThreshold = (Get-Date).AddDays(-$deleteAfterDays)

  # Log file for tracking archive and delete operations
  $logFile = "$directory\archive_log.txt"

  # Find files older than the archive threshold
  $filesToArchive = Get-ChildItem -Path $directory -File -Recurse | Where-Object {
    $_.LastWriteTime -lt $archiveDateThreshold
  }

  # Archive and remove files
  foreach ($file in $filesToArchive) {
    $zipFilePath = "$($file.FullName).zip"

    try {
      # Compress files into a ZIP archive
      Compress-Archive -Path $file.FullName -DestinationPath $zipFilePath -Force

      # Verify if compression was successful before deleting
      if (Test-Path $zipFilePath) {
        Remove-Item -Path $file.FullName -Force
        # Log success
        Add-Content -Path $logFile -Value "[$(Get-Date)] Archiving successful: $($file.FullName) -> $zipFilePath"
      } else {
        # Log failure
        Add-Content -Path $logFile -Value "[$(Get-Date)] Archiving failed for file: $($file.FullName)"
      }
    } catch {
      # Log any error that occurs during archiving
      Add-Content -Path $logFile -Value "[$(Get-Date)] Error archiving file: $($file.FullName) - $_"
    }
  }

  # Find and delete files older than the delete threshold
  $filesToDelete = Get-ChildItem -Path $directory -File -Recurse | Where-Object {
    $_.LastWriteTime -lt $deleteDateThreshold
  }

  # Delete files
  foreach ($file in $filesToDelete) {
    try {
      Remove-Item -Path $file.FullName -Force
      # Log success
      Add-Content -Path $logFile -Value "[$(Get-Date)] Deleted: $($file.FullName)"
    } catch {
      # Log any error that occurs during deletion
      Add-Content -Path $logFile -Value "[$(Get-Date)] Error deleting file: $($file.FullName) - $_"
    }
  }
}

# Main logic based on the passed argument
if ($mode -eq "generate") {
  # If "generate" is passed as argument, generate test data
  GenerateTestFolders
} else {
  # Otherwise, perform archiving by default
  # Load the JSON configuration
  $config = Get-Content -Path ".\config.json" | ConvertFrom-Json

  # Process each path from the configuration
  foreach ($pathConfig in $config.Paths) {
    ArchiveLogs -directory $pathConfig.Directory `
                     -archiveAfterDays $pathConfig.ArchiveAfterDays `
                     -deleteAfterDays $pathConfig.DeleteAfterDays
  }
}
