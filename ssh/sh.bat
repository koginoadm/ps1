@setlocal enableextensions enabledelayedexpansion & set "PATH0=%~f0" & PowerShell.exe -Command "& (Invoke-Expression -Command ('{#' + ((Get-Content '!PATH0:'=''!') -join \"`n\") + '}'))" %* & exit /b !errorlevel!
# 
# - Name
#     ssh.bat
# 
# - Contents
#     Simplify SSH Connect by Tera Term.
#     <kbd>Windows</kbd> + <kbd>R</kbd> => ssh root@192.168.1.100
#
# - Install
#     powershell.exe -Command "Invoke-RestMethod -Uri "https://raw.githubusercontent.com/koginoadm/ps1/master/ssh/sh.bat" | Out-File -Encoding utf8 "${env:Userprofile}\sh.bat""
#
# - Reference
#     https://technet.microsoft.com/ja-jp/library/jj554824.aspx
#     https://technet.microsoft.com/ja-jp/library/jj613766.aspx
#     https://ja.osdn.net/projects/ttssh2/releases/
#
# - Revision
#     2016-12-28 created.
#     2017-04-14 modified.
#     2017-05-22 modified.
#     2017-06-08 modified.
#     2017-06-09 modified.
#     2017-06-24 modified.
#     2017-09-14 modified.
#     2017-09-17 modified.
#     2017-09-23 modified.
#     2017-11-30 modified.
#     yyyy-MM-dd modified.
# 


################
# constant
################
#${ttInstallUri} = "http://ymu.dl.osdn.jp/ttssh2/67179/teraterm-4.94.exe"
#${ttInstallUri} = "http://ymu.dl.osdn.jp/ttssh2/67769/teraterm-4.95.exe"
${ttInstallUri} = "http://jaist.dl.osdn.jp/ttssh2/68252/teraterm-4.96.exe"


################
# variables
################
${sshDir}  = "${env:Userprofile}\teraterm\ssh"
################################
# 任意のディレクトリを指定
${userSshDir} = "${env:Userprofile}\GoogleDrive\ssh"
if (Test-Path -PathType container ${userSshDir}) { ${sshDir} = "${userSshDir}" }
################################
${logDir}  = "${sshDir}\log"
${keyDir}  = "${sshDir}\key"
${csvFile} = "${sshDir}\hosts.csv"
${ttInstallExe} = "${env:TEMP}\$(Split-Path -Path $(Split-Path -Path ${ttInstallUri} -NoQualifier) -Leaf)" ### backport for Windows 7 (duplicate "Split-Path")


################
# main
################
### Create directorys.
if ((Get-Item ${sshDir}).Mode 2>$null | Select-String -NotMatch '^d') { mkdir ${sshDir}; Start-Sleep 1; }
if ((Get-Item ${logDir}).Mode 2>$null | Select-String -NotMatch '^d') { mkdir ${logDir}; Start-Sleep 1; }
if ((Get-Item ${keyDir}).Mode 2>$null | Select-String -NotMatch '^d') { mkdir ${keyDir}; Start-Sleep 1; }
if (-Not (Test-Path ${csvFile}))
{
    Write-Output "Hostname,Username,AuthType,Value,Alias`r`n`r`n# In the first line, Header information is written. Please do not edit!`r`n`r`n# Please refer to the following and set it like the description example.`r`n# Hostname[:Port],Username,AuthenticationType[password|publickey],Value[Passphrase|SecretKeyName],Set an alias character string as an argument of ssh command. UPN notation is recommended.`r`n`r`n# description example:`r`nwww.example.com:10022,admin,publickey,id_rsa,admin@www.example.com`r`n192.168.1.100,root,password,P@ssw0rd,root@TEST01`r`n" > ${csvFile}
    Write-Output "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [NOTICE]: Check the file( ${csvFile} ) and set it as shown in the description example."
    Write-Output "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [NOTICE]: Edit the file( ${csvFile} ) and try again."
    Start-Process -FilePath notepad.exe -ArgumentList ${csvFile}
}

### Search for ttermpro.exe from the directory where teraterm was installed and get the full path of ttermpro.exe.
[System.String] ${sshClient} = Get-ChildItem -recurse "C:\Program Files*\teraterm" 2>$null | Where-Object { $_.Name -match "ttermpro" } | ForEach-Object { $_.FullName }
### If ttermpro.exe does not exist,
if (-Not (${sshClient}))
{
    Invoke-WebRequest -Uri ${ttInstallUri} -OutFile ${ttInstallExe}
    Start-Process -FilePath ${ttInstallExe} -Args '/silent /sp-' -PassThru -Wait
    [System.String] ${sshClient} = Get-ChildItem -recurse "C:\Program Files*\teraterm" | Where-Object { $_.Name -match "ttermpro" } | ForEach-Object { $_.FullName }
    if (-Not (${sshClient}))
    {
        Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [ERROR]: ttermpro.exe not found in `"C:\Program Files*`"."
        [Console]::ReadKey() | Out-Null
        exit 1
    }
}



### Create arguments to pass to ttermpro.exe.
[System.String] ${optHost} = "ssh2://127.0.0.1:22"
[System.String] ${optUser} = "/user=root"
#[System.String] ${optAuth} = "/auth=password"
#[System.String] ${optValue} = "/passwd=P@ssw0rd"
[System.String] ${optAuth} = "/auth=publickey"
[System.String] ${optValue} = "/keyfile=${keyDir}\koginoadm.ppk"
${optDir} = "/FD=${sshDir}"
[System.String] ${optLog} = "/L=${logDir}\teraterm_&h_root_%Y%m%d_%H%M%S.log"
[System.Array] ${optArray} = @(${optHost},${optUser},${optAuth},${optValue},${optDir},${optLog},"/ssh-v","/LA=J")

### Run teraterm.
Start-Process -FilePath ${sshClient} -ArgumentList ${optArray}


