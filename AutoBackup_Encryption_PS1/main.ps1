# Set execution path to the script's location
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $PSScriptRoot

& .\MultiCopyBackup.ps1
timeout 2
& .\DataEncryption.ps1
timeout 2
& .\GmailSender.ps1
timeout 2
Write-Host "All taks have been completed"
# Pause
timeout 1
exit

