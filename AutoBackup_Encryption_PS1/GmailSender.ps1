# Gmail Sender
Write-Host "Sending keys in progress..."
# https://myaccount.google.com/apppasswords

$currentDir = Get-Location
$paramsFilePath = Join-Path $currentDir "params.json"
$userDataFilePath = Join-Path $currentDir "userData.json"
# $paramsContent = Get-Content -Path $paramsFilePath | ConvertFrom-Json
# $userDataContent = Get-Content -Path $userDataFilePath | ConvertFrom-Json

function Remove-OldFiles {
    param (
        [string]$FolderPath,   # Folder where files are stored
        [int]$Days = 4         # Number of days before deletion
    )

    # Get the cutoff date
    $CutoffDate = (Get-Date).AddDays(-$Days)

    # Get files older than the cutoff date and delete them
    Get-ChildItem -Path $FolderPath -File | Where-Object { $_.LastWriteTime -lt $CutoffDate } | Remove-Item -Force

    Write-Host "Deleted files older than $Days days from $FolderPath."
}


# Validate JSON files exist
if (!(Test-Path $paramsFilePath) -or !(Test-Path $userDataFilePath)) {
    Write-Error "Required JSON files (userData.json, params.json) are missing."
    exit 1
}

# Read JSON content
$paramsContent = Get-Content -Path $paramsFilePath | ConvertFrom-Json
$userDataContent = Get-Content -Path $userDataFilePath | ConvertFrom-Json

# Validate required JSON keys
if (-not $userDataContent.fromUser -or -not $userDataContent.toUser -or -not $userDataContent.userAccount -or -not $userDataContent.appPassword -or -not $userDataContent.messageBody) {
    Write-Error "Missing required fields in userData.json."
    exit 1
}
if (-not $paramsContent.KEYPATH) {
    Write-Error "Missing required field KEYPATH in params.json."
    exit 1
}

# Construct attachment paths
$keyPath = $paramsContent.KEYPATH
$ivFile = "$keyPath-iv.bin"
$keyFile = "$keyPath-key.bin"

# Ensure attachments exist
if (!(Test-Path $ivFile) -or !(Test-Path $keyFile)) {
    Write-Error "Attachment files ($ivFile, $keyFile) do not exist."
    exit 1
}

# Define email parameters
$smtpServer = "smtp.gmail.com"
$smtpFrom = $userDataContent.fromUser
$smtpTo = $userDataContent.toUser
$messageSubject = "Test Email"
$messageBody = $userDataContent.messageBody
$smtpUsername = $userDataContent.userAccount
$appPassword = $userDataContent.appPassword
$Attachments = @($ivFile, $keyFile)
$KEYPATH = $userDataContent.keyStorePath
# Create the credentials object
Write-Host "Updating credentials"
$securePassword = ConvertTo-SecureString $appPassword -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential($smtpUsername, $securePassword)

# Send the email
Write-Host "Sending mail..."
try {
    Send-MailMessage -From $smtpFrom -To $smtpTo -Subject $messageSubject `
        -Body $messageBody -SmtpServer $smtpServer -Credential $credentials `
        -Port 587 -UseSsl -Attachments $Attachments -WarningAction Ignore `
        -ErrorAction Stop  
        # <-- Forces PowerShell to treat failure as an exception -WarningAction Ignore 

    Write-Host "DUMMY Email sent successfully."
    
    Start-Sleep 1
    if (!(Test-Path -Path $KEYPATH)) { 
        New-Item -ItemType Directory -Path $KEYPATH }
    Move-Item -Path ".\*.bin" -Destination "$KEYPATH" -Force
    Remove-OldFiles -FolderPath "$KEYPATH" -Days 4
} catch {
    Write-Error "Failed to send email: $_"
}
# Pause