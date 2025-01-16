# PowerShell
PowerShell Setup and Modules

PowerShell 7.4.6
code $PROFILE
<<
set-executionPolicy -scope Process -ExecutionPolicy Bypass
Import-Module posh-git

 function Prompt {
     $currentDir = Split-Path -Leaf (Get-Location)
     "$currentDir> "
 }
  #Define your custom prompt function

 function Prompt {
     # Get the current path
     $currentPath = (Get-Location).Path
     # Return the combined prompt
     "$currentPath`nPS> "   
 }

# VS Code Preferences -
Select the Preferences: Open User Settings command in the Command Palette (Ctrl+Shift+P)
Select the User tab in the Settings editor (Ctrl+,)
Select the Preferences: Open User Settings (JSON) command in the Command Palette (Ctrl+Shift+P)
{
    "window.zoomLevel": 1,
    "editor.minimap.enabled": false,
    "editor.mouseWheelZoom": true,
    "workbench.iconTheme": "vscode-icons",
    "[xml]": {},
    "editor.stickyScroll.enabled": false,
    "python.createEnvironment.trigger": "off",
    "git.autofetch": true,
    "git.enableSmartCommit": true,
    "git.terminalGitEditor": true,
    "git.openRepositoryInParentFolders": "always",
    "workbench.colorTheme": "Visual Studio Dark"
}

%APPDATA%\Code\User\User\vsCode.zip (vsCode.zip is available in this repo)
extract vsCode.zip in to %APPDATA%\Code\User
