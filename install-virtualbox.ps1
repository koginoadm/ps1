#@setlocal enableextensions enabledelayedexpansion & set "PATH0=%~f0" & PowerShell.exe -Command "& (Invoke-Expression -Command ('{#' + ((Get-Content '!PATH0:'=''!') -join \"`n\") + '}'))" %* & exit /b !errorlevel!
# 
# - Name
#     install-virtualbox.ps1
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
#     2016-08-25 created by https://github.com/koginoadm.
#     2016-08-26 modified by https://github.com/koginoadm.
#     yyyy-MM-dd modified.
# 


################
# constant
################
${BASE_URI} = 'http://download.virtualbox.org/virtualbox/'
${CPU_ARCHITECTURE} = 'AMD64'
${VIRTUALBOX} = 'C:\Program Files\Oracle\VirtualBox\VirtualBox.exe'

################
# variables
################
${vTmpDir} = "$env:USERPROFILE\.tmp.vbx"; if (-Not(Test-Path -Path ${vTmpDir})) { mkdir ${vTmpDir} }
${vStableUri} = "${BASE_URI}$((Invoke-RestMethod -Uri ${BASE_URI} | %{$_ -creplace '.*href="([^"]*)".*','$1'}) -split "`n" | ?{ $_ -match "^[0-9]+`.[0-9]+`.[0-9]+/" } | select -Last 1)"
${vInstUri} = "${vStableUri}$((Invoke-RestMethod -Uri ${vStableUri} | %{$_ -creplace '.*href="([^"]*)".*','$1'}) -split "`n" | ?{ $_ -match "`.exe$" } | select -Last 1)"
${vInstExe} = "${vTmpDir}\$(Split-Path -Leaf ${vInstUri})"
${vInstTmp} = "${vInstExe}.tmp"

################
# main
################
# Check Administrator
if (-Not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
{
    Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [ERROR]: Run as Administrator."
    Start-Sleep 5
    exit 1
}

# Check PROCESSOR_ARCHITECTURE
if ("$env:PROCESSOR_ARCHITECTURE" -ne ${CPU_ARCHITECTURE})
{
    Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [ERROR]: `$env:PROCESSOR_ARCHITECTURE: $env:PROCESSOR_ARCHITECTURE"
    Start-Sleep 5
    exit 1
}


# Download Installer
if (-Not(Test-Path -Path ${vInstExe}))
{
    Invoke-RestMethod -Uri ${vInstUri} -OutFile ${vInstTmp}
    Move-Item ${vInstTmp} ${vInstExe}
}

# Install VirtualBox
if (-Not(Test-Path -Path "${VIRTUALBOX}"))
{
    # Extract package
    Start-Process -FilePath ${vInstExe} -Args "--silent --extract --path ${vTmpDir}" -PassThru -Wait
    # msiexec.exe
    [System.String] ${vVirtualBoxMsi} = Resolve-Path "${vTmpDir}\VirtualBox-*amd64.msi"
    Start-Process -FilePath msiexec.exe -Args "/i ${vVirtualBoxMsi} /quiet" -PassThru -Wait
    Remove-Item -Recurse ${vTmpDir}
}

# Start VirtualBox
Start-Process -FilePath "${VIRTUALBOX}" -PassThru

