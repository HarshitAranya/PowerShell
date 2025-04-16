$TaskName = "DailyBackup"
$User = $env:USERNAME
$Action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File D:\AutoBackup_v1\Code\main.ps1 -ExecutionPolicy Bypass"
$Trigger = New-ScheduledTaskTrigger -Daily -At 11:30AM
#$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Principal = New-ScheduledTaskPrincipal -UserId $User -LogonType Interactive -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
taskschd.msc