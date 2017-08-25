@setlocal enableextensions enabledelayedexpansion & set "PATH0=%~f0" & PowerShell.exe -Command "& (Invoke-Expression -Command ('{#' + ((Get-Content '!PATH0:'=''!') -join \"`n\") + '}'))" %* & exit /b !errorlevel!
# 
# - Name
#     install-vim.bat
# 
# - Contents
#     Install Vim.
#
# - Install
#     powershell.exe -Command "Invoke-RestMethod -Uri "https://djeeno.github.io/ps1/install-vim.bat" -OutFile "$env:USERPROFILE\install-vim.bat""
#
# - Reference
#     Vim - KaoriYa - https://www.kaoriya.net/software/vim/
# 
# - Revision
#     2016-05-24 created.
#     2016-06-08 modified.
#     yyyy-MM-dd modified.
# 


################
# constant
################
$vBase = 'http://download.virtualbox.org/virtualbox/'

################
# variables
################
$tmpd = "$env:USERPROFILE\.tmp.vbx"; if (-Not(Test-Path -Path $tmpd)) { mkdir $tmpd }
$tmpf = "$tmpd\.tmp.virtualbox.log"
$vStableUri = "$vBase$(Invoke-RestMethod -Uri $vBase | %{$_ -creplace '.*href="([^"]*)".*','$1'} > $tmpf ; cat $tmpf | ?{ $_ -match "^[0-9]+`.[0-9]+`.[0-9]+/" } | select -Last 1; rm $tmpf)"
$vInstUri = "$vStableUri$(Invoke-RestMethod -Uri $vStableUri | %{$_ -creplace '.*href="([^"]*)".*','$1'} > $tmpf ; cat $tmpf | ?{ $_ -match "`.exe$" } | select -Last 1; rm $tmpf)"
$vInstExe = "$env:USERPROFILE\$(Split-Path -Leaf $vInstUri)"

################
# main
################
# Administrator
if (-Not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
{
    Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [ERROR]: Run as Administrator."
    Start-Sleep 5
    exit 1
}

# CPU
if ("$env:PROCESSOR_ARCHITECTURE" -ne 'AMD64')
{
    Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [ERROR]: `$env:PROCESSOR_ARCHITECTURE: $env:PROCESSOR_ARCHITECTURE"
    Start-Sleep 5
    exit 1
}


# Download Installer
Invoke-RestMethod -Uri $vInstUri -OutFile $vInstExe

# Extract package
Start-Process -FilePath $vInstExe -Args "--silent --extract --path $tmpd" -PassThru -Wait

# Install VirtualBox
[string] $msi = Resolve-Path "$tmpd\VirtualBox-*amd64.msi"
Start-Process -FilePath msiexec.exe -Args "/i $msi /quiet" -PassThru -Wait

Start-Process -FilePath "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe" -PassThru
