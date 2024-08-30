# ArchiveAndGenerate Utility

## Overview
`ArchiveAndGenerate.exe` is a utility designed to either generate test folders and log files or to archive and delete old files based on configuration settings.


### Usage
The utility operates in two modes:

1. **Generate Mode**: Generates test folders and log files.
2. **Archive Mode** (default): Archives old files and deletes files that have exceeded a configured expiration date.


### Command-Line Arguments

- `-mode generate` : Use this argument to generate test folders and log files under the `.\TestLogs` directory.
- `-mode archive`  : Use this argument to archive and delete old log files based on the settings specified in `config.json`.


### Examples

#### 1. Generate Test Files

To generate test folders and log files, execute:
ArchiveAndGenerate.exe -mode generate

#### 2. Archive and Delete Files
To archive and delete old files, execute:
ArchiveAndGenerate.exe -mode archive

If no mode is specified, the script defaults to **archive mode**.


### Configuration

The utility uses a JSON configuration file (`config.json`) to determine which directories to monitor and how to archive/delete files.

Here is an example of a configuration file:

```json
{
  "Paths": [
    {
      "Directory": ".\\TestLogs\\Logs_A",
      "ArchiveAfterDays": 30,
      "DeleteAfterDays": 60
    },
    {
      "Directory": ".\\TestLogs\\Logs_B",
      "ArchiveAfterDays": 45,
      "DeleteAfterDays": 90
    },
    {
      "Directory": ".\\TestLogs\\Logs_C",
      "ArchiveAfterDays": 60,
      "DeleteAfterDays": 120
    }
  ]
}
```

#### Configuration Options:
- Directory: The folder path where log files are located.
- ArchiveAfterDays: Number of days after which files should be archived.
- DeleteAfterDays: Number of days after which archived files should be deleted.

### Logs
The utility generates logs of the archiving and deleting process in an archive_log.txt file located in the same directory as the processed files.


### Requirements
The tool requires either PowerShell or the standalone .exe file created from the PowerShell script using PS2EXE.
Ensure a valid config.json file is in the same directory as the executable.
Notes
Ensure the config.json file is correctly formatted and placed in the same directory as ArchiveAndGenerate.exe.
The tool processes files older than the specified ArchiveAfterDays and DeleteAfterDays.
If running the .exe file, no PowerShell installation is required.
