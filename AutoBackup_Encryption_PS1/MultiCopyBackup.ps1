
Write-Host "Backup is in progress..."
$currentDir = Get-Location
# Define the path to the Inventory.csv file
$csvFilePath = Join-Path $currentDir "Inventory.csv"

# function allowAccess($DataLocation){
#     attrib -h -s -r "$DataLocation"
#     icacls "$DataLocation" /grant "Administrators:(F)" /T
#     icacls "$DataLocation" /grant "${env:USERNAME}:(F)" /T
#     icacls "$DataLocation" /remove:d Everyone
#     Write-Host "Access allowed on: $DataLocation"
# }

function allowAccess($DataLocation){
    icacls "$DataLocation" /grant "Everyone:(F)" /T
    icacls "$DataLocation" /grant "${env:USERNAME}:(F)" /T
    icacls "$DataLocation" /grant "Administrators:(F)" /T
    icacls "$DataLocation" /remove:d Everyone
    attrib -h -s -r "$DataLocation"
    Write-Host "Access allowed on: $DataLocation"
}
# Check if the file exists
if (Test-Path $csvFilePath) {
    $client = Import-Csv -Path $csvFilePath
} else {
    Write-Host "The file 'Inventory.csv' does not exist in the current folder."
}

$i = 1
foreach($pc in $client[1]){
    $source = "\\" + $pc.Hostname + "\" + $pc.DataPath.Replace(":", "$")
    $copy_1 = $pc.BackupPath + "\Copy_1\"
    $copy_2 = $pc.BackupPath + "\Copy_2\"
    $copy_3 = $pc.BackupPath + "\Copy_3\"
    $copy_4 = $pc.BackupPath + "\Copy_4\"

    # Remove restrictions temporarily to allow access
    # Ensure backup folder access
    Write-Host "Updating access on backup folder..."
    $backupBase = $pc.BackupPath
    if(!(Test-Path -Path $backupBase)){Write-Host "Backup folder not found"; exit 1}

    # allowAccess -DataLocation $backupBase
    # icacls "$backupBase" /grant "Administrators:(F)"
    # icacls "$backupBase" /grant "${env:USERNAME}:(F)"
    # icacls "$backupBase" /remove:d Everyone
    <#
    if(Test-Path $copy_1){
        allowAccess -DataLocation $copy_1
        # attrib -h -s -r "$copy_1"
        # icacls "$copy_1" /grant "Administrators:(F)"
        # icacls "$copy_1" /grant "${env:USERNAME}:(F)"
        # icacls "$copy_1" /remove:d Everyone
    }
    elseif (Test-Path $copy_2) {
        allowAccess -DataLocation $copy_2
        # attrib -h -s -r "$copy_2"
        # icacls "$copy_2" /grant "Administrators:(F)"
        # icacls "$copy_2" /grant "${env:USERNAME}:(F)"
        # icacls "$copy_2" /remove:d Everyone
    }
    elseif (Test-Path $copy_3) {
        allowAccess -DataLocation $copy_3
        # attrib -h -s -r "$copy_3"
        # icacls "$copy_3" /grant "Administrators:(F)"
        # icacls "$copy_3" /grant "${env:USERNAME}:(F)"
        # icacls "$copy_3" /remove:d Everyone
    }
    elseif (Test-Path $copy_4) {
        allowAccess -DataLocation $copy_4
        # attrib -h -s -r "$copy_4"
        # icacls "$copy_4" /grant "Administrators:(F)"
        # icacls "$copy_4" /grant "${env:USERNAME}:(F)"
        # icacls "$copy_4" /remove:d Everyone
    }
    else{Write-Host "No Copy path found"}
    #>
    if (-not (Test-Path $copy_1)) {
        $destination = "$copy_1"+"$($pc.Hostname)"
        if (Test-Path $copy_2) {
            allowAccess -DataLocation $copy_2
            Remove-Item -Path $copy_2 -Recurse -Force 
        }
    }
    elseif (-not (Test-Path $copy_2)) {
        $destination = "$copy_2"+"$($pc.Hostname)"
        if (Test-Path $copy_3) { 
            allowAccess -DataLocation $copy_3
            Remove-Item -Path $copy_3 -Recurse -Force 
        }
    }
    elseif (-not (Test-Path $copy_3)) {
        $destination = "$copy_3"+"$($pc.Hostname)"
        if (Test-Path $copy_4) { 
            allowAccess -DataLocation $copy_4
            Remove-Item -Path $copy_4 -Recurse -Force 
        }
    }
    else {
        $destination = "$copy_4"+"$($pc.Hostname)"
        if (Test-Path $copy_1) { 
            allowAccess -DataLocation $copy_1
            Remove-Item -Path $copy_1 -Recurse -Force 
        }
    }

    $log = "$backupBase\Backup_Log_$($pc.Hostname)_$i.txt"
    
    if(Test-Path($source)){
        robocopy $source $destination /E /MT:8 /R:2 /W:2 /Log:$log
        Write-Output "Backup is completed from $source to $destination and log : $log" | Out-File -FilePath bkp.log -Encoding UTF8
    }else{Write-Host "Unable to connect to:", $pc.Hostname; exit 1}
    $i++
}

$paramsFilePath = Join-Path $currentDir "params.json"

if (Test-Path $paramsFilePath) {
    $paramsContent = Get-Content -Path $paramsFilePath | ConvertFrom-Json
    # Update the DESTINATION value
    $paramsContent.DESTINATION = $destination

    # Extract 'Copy_x' from the path using regular expression
    $copyPart = $destination -replace '.*\\(Copy_\d+).*', '$1'

    $ddMMyyHHmmss = (Get-Date).ToString("ddMMyyHHmmss")
    $paramsContent.KEYPATH = Join-Path $currentDir "\$copyPart`_aes_$ddMMyyHHmmss"
    # $henvContent.KEYPATH = Join-Path "D:\KeyPath" "\$copyPart`_aes_$ddMMyyHHmmss"
    
    # Save the updated content back to the JSON file
    $paramsContent | ConvertTo-Json -Depth 3 | Set-Content -Path $paramsFilePath
    # Write-Host "The params.json values are updated now."
} else {
    Write-Host "The file 'params.json' does not exist in the current folder."
    exit 1
}

# Pause