
$rootPath = ".\TestLogs"
$subfolders = @("Logs_A", "Logs_B", "Logs_C")
$fileCountPerFolder = 5


if (-Not (Test-Path -Path $rootPath)) {
  New-Item -Path $rootPath -ItemType Directory
}

foreach ($subfolder in $subfolders) {
  $folderPath = Join-Path -Path $rootPath -ChildPath $subfolder

  if (-Not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
  }

  for ($i = 1; $i -le $fileCountPerFolder; $i++) {
    $randomDaysAgo = Get-Random -Minimum 0 -Maximum 120
    $lastWriteTime = (Get-Date).AddDays(-$randomDaysAgo)

    $fileName = "LogFile_{0:yyyy-MM-dd_HHmmss}_$i.txt" -f $lastWriteTime
    $filePath = Join-Path -Path $folderPath -ChildPath $fileName

    Set-Content -Path $filePath -Value "This is a test log file. File number: $i with date: $($lastWriteTime.ToString('yyyy-MM-dd'))"

    (Get-Item $filePath).LastWriteTime = $lastWriteTime
  }
}

Write-Host "TTestfolder and files created at $rootPath."
