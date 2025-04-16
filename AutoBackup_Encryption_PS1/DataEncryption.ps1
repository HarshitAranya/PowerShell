
$currentDir = Get-Location
$paramsFilePath = Join-Path $currentDir "params.json"
$paramsContent = Get-Content -Path $paramsFilePath | ConvertFrom-Json

# $destination = "D:\Backup\Copy_1\DESKTOP-L5NS1V2" 
$destination = $paramsContent.DESTINATION
# $destination = "D:\Backup\Copy_1\IN-LT-18126"

if($destination){Write-Host "Destination path set as: $destination";}else{Write-Host "No destination found"; timeout 3; exit 1}

$keyPath = $paramsContent.KEYPATH
$keyFile = "$keyPath-key.bin"
$ivFile = "$keyPath-iv.bin"

if (!(Test-Path $keyFile) -or !(Test-Path $ivFile)) {
    $key = (1..32) | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }
    $iv = (1..16) | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }
    # Convert the $key and $iv to byte arrays and write them to the respective files
    [System.IO.File]::WriteAllBytes($keyFile, $key)
    [System.IO.File]::WriteAllBytes($ivFile, $iv)
} else {
    $key = Get-Content $keyFile -Encoding Byte
    $iv = Get-Content $ivFile -Encoding Byte
}

function Encrypt-File {
    param ([string]$file)
    $aes = [System.Security.Cryptography.AesManaged]::new()
    $aes.Key = $key
    $aes.IV = $iv
    $encryptor = $aes.CreateEncryptor()
    $data = [System.IO.File]::ReadAllBytes($file)
    $encryptedData = $encryptor.TransformFinalBlock($data, 0, $data.Length)
    [System.IO.File]::WriteAllBytes("$file.enc", $encryptedData)
    Remove-Item $file -Force
}

Write-Host "Applying data protection is in progress..."

# Get-ChildItem -Path $destination -File | ForEach-Object {
#     Encrypt-File $_.FullName
# }

Get-ChildItem -Path $destination -File -Recurse | ForEach-Object {
    Encrypt-File $_.FullName
}

timeout 1

# takeown /F "$destination" /A # take ownership administrators
# Apply Folder Protection
icacls "$destination" /inheritance:r
Write-Host "Removed inherited permissions. `n"

icacls "$destination" /grant "SYSTEM:(F)"
Write-Host "Granted SYSTEM full control. `n"

icacls "$destination" /setowner SYSTEM
Write-Host "Changed owner to SYSTEM. `n"

icacls "$destination" /deny Everyone:"(W,D,DE,DC)"
Write-Host "Denied Everyone write/delete permissions. `n"

attrib +h +s +r "$destination"
Write-Host "All access set as needed. `n"

Write-Host "Backup folder is now protected"
# Pause