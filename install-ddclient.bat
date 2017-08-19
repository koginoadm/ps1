@setlocal enableextensions enabledelayedexpansion & set "PATH0=%~f0" & PowerShell.exe -Command "& (Invoke-Expression -Command ('{#' + ((Get-Content '!PATH0:'=''!') -join \"`n\") + '}'))" %* & exit /b !errorlevel!
# 
# - Name
#     install-ddclient.bat
# 
# - Contents
#     Install ddclient.exe
#
# - Install
#     powershell.exe -Command "Invoke-RestMethod -Uri "https://djeeno.github.io/ps1/install-ddclient.bat" -OutFile "$env:USERPROFILE\install-ddclient.bat""
#
# - Revision
#     2016-05-24 created.
#     yyyy-MM-dd modified.
# 


################
# constant
################
$ddclientUri = "http://www.randomnoun.com/wpf/ddclient-1.5.0.exe"


################
# variables
################
$ddclientWorkDir = "$env:USERPROFILE\Documents\ddclient_install"
$ddclientInstaller = "$ddclientWorkDir\$(Split-Path -Path $ddclientUri -Leaf)"


################
# main
################
# mkdir
if ((Get-Item $ddclientWorkDir).Mode 2>$null | Select-String -NotMatch '^d') { mkdir $ddclientWorkDir; Start-Sleep 1; }

# Download
Invoke-RestMethod -Uri $ddclientUri -OutFile $ddclientInstaller

# Install
Start-Process -FilePath $ddclientInstaller -PassThru -Wait

# Explorer
explorer (Get-Item "C:\Program Files*\ddclient").FullName

# pause
[Console]::ReadKey() | Out-Null
exit 0
