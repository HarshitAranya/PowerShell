@echo off
title AutoBackup
set "x=%~dp0"
cd /d "%x%"
powershell -Command "& { Set-ExecutionPolicy RemoteSigned -Scope CurrentUser; .\main.ps1;}"
@REM powershell -NoExit -Command "& { Set-ExecutionPolicy RemoteSigned -Scope CurrentUser; .\main.ps1; & cmd exit;}"