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
$vimUri = 'https://github.com/koron/vim-kaoriya/releases/download/v8.0.0596-20170502/vim80-kaoriya-win64-8.0.0596-20170502.zip'


################
# variables
################
$vimZip = "$env:TMP\$(Split-Path -Path $vimUri -Leaf)"
$vimBaseDir = "$env:ProgramFiles"


################
# main
################
### check Administrator
if (-Not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
{
    Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [WARN]: Run as Administrator."
    Start-Sleep 5
    exit 1
}

# Get vim.zip.
if (-Not(Test-Path -Path $vimZip)) { Invoke-RestMethod -Uri $vimUri -OutFile $vimZip -UseBasicParsing }

# Unzip vim.zip.
if (Test-Path -Path $vimZip)
{
    if (-Not(Test-Path -Path "$vimBaseDir\vim*\vim.exe"))
    {
        $shApp = New-Object -Com shell.application
        $unzip = $shApp.NameSpace($vimZip)
        foreach ($item in $unzip.items()) { $shApp.Namespace("$vimBaseDir").copyhere($item, 0x8); }
    }
}
else
{
    Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [ERROR]: Failed to download from Uri($vimUri)."
    exit 1
}

if (Test-Path -Path $vimZip)
{
    $vimExe = "$(Resolve-Path C:\'Program Files'\vim*)" + '\vim.exe'
    [System.String] $vimPath = Split-Path $vimExe -Parent
    [System.String] $vimDirname = Split-Path $vimPath -Leaf
    if (-Not("$env:PATH" | Select-String "$vimDirname" ))
    {
        Write-Host "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [INFO]: Add `"$vimPath`" to `"`$env:Path`")"
        [Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$vimPath", [EnvironmentVariableTarget]::User)
    }
}

# pause
Write-Host "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [INFO]: Installed $(Resolve-Path C:\"Program Files"\vim*\vim.exe)"
[Console]::ReadKey() | Out-Null
exit 0

