#@setlocal enableextensions enabledelayedexpansion & set "PATH0=%~f0" & PowerShell.exe -Command "& (Invoke-Expression -Command ('{#' + ((Get-Content '!PATH0:'=''!') -join \"`n\") + '}'))" %* & exit /b !errorlevel!
# 
# - Name
#     install-vim.bat
# 
# - Contents
#     Install Vim.
#
# - Run
#     powershell.exe -Command "Start-Process -FilePath powershell.exe -Args '-Command "Invoke-RestMethod -Uri https://koginoadm.github.io/ps1/install-virtualbox.ps1 | powershell.exe -"' -Verb RUNAS"
#
# - Reference
#     https://www.virtualbox.org/wiki/Downloads
# 
# - Revision
#     2016-08-25 created.
#     2016-08-26 modified.
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
$vInstExe = "$tmpd\$(Split-Path -Leaf $vInstUri)"
$vInstTmp = "$vInstExe.tmp"

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
if (-Not(Test-Path -Path $vInstExe))
{
    Invoke-RestMethod -Uri $vInstUri -OutFile $vInstTmp
    Move-Item $vInstTmp $vInstExe
}

# Install VirtualBox
if (-Not(Test-Path -Path "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe"))
{
    # Extract package
    Start-Process -FilePath $vInstExe -Args "--silent --extract --path $tmpd" -PassThru -Wait
    # msiexec.exe
    [string] $msi = Resolve-Path "$tmpd\VirtualBox-*amd64.msi"
    Start-Process -FilePath msiexec.exe -Args "/i $msi /quiet" -PassThru -Wait
    Remove-Item -Recurse $tmpd
}

# Start VirtualBox
Start-Process -FilePath "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe" -PassThru


