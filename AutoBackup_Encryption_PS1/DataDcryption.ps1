$backupPath = Read-Host "Enter encrypted backup location"
$ivFile = Read-Host "Enter iv.bin file full path with name"
$keyFile = Read-Host "Enter key.bin file full path with name"

# $ivFile = D:\Backup\KeyStorePath\Copy_2_aes_060325142558-iv.bin
# $keyFile = D:\Backup\KeyStorePath\Copy_2_aes_060325142558-key.bin
# $backupPath = D:\Backup\Copy_2\IN-LT-18126

if(Test-Path -Path $backupPath -AND Test-Path -Path $ivFile -AND Test-Path -Path $keyFile){
    Write-Host "Encrypted data location: $backupPath"
    Write-Host "iv File location: $ivFile"
    Write-Host "key File location: $keyFile"
}else{Write-Host "iv or key or data location not found"}

#If you need to recover your backup files, revert restrictions temporarily:
icacls "$backupPath" /grant "Everyone:(F)" /T
icacls "$backupPath" /grant "${env:USERNAME}:(F)" /T
icacls "$backupPath" /grant "Administrators:(F)" /T
icacls "$backupPath" /remove:d Everyone
attrib -h -s -r "$backupPath"

# Load AES Key & IV
# Read the binary data from the files
$key = [System.IO.File]::ReadAllBytes($keyFile)
$iv = [System.IO.File]::ReadAllBytes($ivFile)

# Function to decrypt a file
function Decrypt-File {
    param (
        [string]$file
    )
    $aes = [System.Security.Cryptography.AesManaged]::new()
    $aes.Key = $key
    $aes.IV = $iv

    $decryptor = $aes.CreateDecryptor()
    $encryptedData = [System.IO.File]::ReadAllBytes($file)
    $decryptedData = $decryptor.TransformFinalBlock($encryptedData, 0, $encryptedData.Length)

    $originalFile = $file -replace "\.enc$",""
    [System.IO.File]::WriteAllBytes($originalFile, $decryptedData)

    # Uncomment to delete encrypted file after decryption
    Remove-Item $file -Force
}

# Decrypt all .enc files in the directory
Get-ChildItem -Path $backupPath -Filter "*.enc" -File -Recurse | ForEach-Object {
    Decrypt-File $_.FullName
}

Write-Host "Decryption completed for all files in $backupPath"

# After all
#icacls "D:\SecureBackup" /deny Everyone:(W,D)