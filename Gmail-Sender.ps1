
#Gmail Sendor

$currentDir = Get-Location
$jsonFilePath = Join-Path $currentDir "data.json"

# Check if the file exists
if (Test-Path $jsonFilePath) {
    $jsonContent = Get-Content -Path $jsonFilePath | ConvertFrom-Json
} else {
    Write-Host "The file 'data.json' does not exist in the current folder."
}

# Define email parameters
$smtpServer = "smtp.gmail.com"
$smtpFrom = "user.name@gmail.com"
$smtpTo = "user.name@yahoo.com"
$messageSubject = "Test Email"
$messageBody = "This is a test email sent from PowerShell."

$smtpUsername = "user.name@gmail.com"
#$smtpPassword = "your-email-password"
$Attachment = "D:\Temp\day1.txt"  # Change this to your file path

# https://myaccount.google.com/apppasswords
$appPassword = $jsonContent.appPassword
# Create the credentials object
$securePassword = ConvertTo-SecureString $appPassword -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential($smtpUsername, $securePassword)
# Send the email
Send-MailMessage -From $smtpFrom -To $smtpTo -Subject $messageSubject `
-Body $messageBody -SmtpServer $smtpServer -Credential $credentials `
-Port 587 -UseSsl -Attachments $Attachment


#Send-MailMessage -From $smtpFrom -To $smtpTo -Subject $messageSubject -Body $messageBody -SmtpServer $smtpServer -Credential $credentials -Port 587 -UseSsl -Attachments $Attachment

