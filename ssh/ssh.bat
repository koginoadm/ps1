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
#     powershell.exe -Command "Invoke-RestMethod -Uri "https://raw.githubusercontent.com/koginoadm/ssh/master/ssh.bat" | Out-File -Encoding utf8 "${env:Userprofile}\ssh.bat""
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

if ($args[0])
{
    ### $args[0] = Alias. UPN notation is recommended.
    [System.String] ${sshAlias} = $args[0]

    ### Get a match with the value of $args[0] and the value of Alias in CSV.
    [System.Array] ${csvData} = Import-Csv ${csvFile} | Where-Object { $_.Alias -eq ${sshAlias} }
    
    ### If there is a match between the value of $args[0] and the value of Alias in CSV,
    if (${csvData})
    {
        ### Create arguments to pass to ttermpro.exe.
        [System.String] ${optHost} = "ssh2://" + ${csvData}[0].Hostname
        [System.String] ${optUser} = "/user=" + ${csvData}[0].Username
        [System.String] ${optAuth} = "/auth=" + ${csvData}[0].AuthType
        if (${csvData}[0].AuthType -eq "password")
        {
            [System.String] ${optValue} = "/passwd=" + ${csvData}[0].Value
        }
        elseif (${csvData}[0].AuthType -eq "publickey")
        {
            [System.String] ${optValue} = "/keyfile=${keyDir}\" + ${csvData}[0].Value
        }
        ${optDir} = "/FD=${sshDir}"
        [System.String] ${optLog} = "/L=${logDir}\teraterm_&h_" + ${csvData}[0].Username + "_%Y%m%d_%H%M%S.log"
        [System.Array] ${optArray} = @(${optHost},${optUser},${optAuth},${optValue},${optDir},${optLog},"/ssh-v","/LA=J")
    }
    ### If there is no matching match between the value of $args[0] and the value of Alias in CSV,
    else
    {
        if (Write-Output ${sshAlias} | Select-String "@" -Quiet)
        {
            [System.String] ${sshUser} = ($args[0] -split "@")[0]
            [System.String] ${sshHost} = ($args[0] -split "@")[1]
        }
        else
        {
            ${sshHost} = "${sshAlias}"
        }
        ### Create arguments to pass to ttermpro.exe.
        ${optHost} = "ssh2://${sshHost}"
        ${optDir} = "/FD=${sshDir}"
        if (${sshUser})
        {
            ${optLog} = "/L=${logDir}\teraterm_&h_${sshUser}_%Y%m%d_%H%M%S.log"
            ${optUser} = "/user=${sshUser}"
            [System.Array] ${optArray} = @(${optHost},${optUser},${optDir},${optLog},"/ssh-v","/LA=J")
        }
        else
        {
            ${optLog} = "/L=${logDir}\teraterm_&h_undefined_%Y%m%d_%H%M%S.log"
            [System.Array] ${optArray} = @(${optHost},${optDir},${optLog},"/ssh-v","/LA=J")
        }
    }
}
else
{
    ${optDir} = "/FD=${sshDir}"
    ${optLog} = "/L=${logDir}\teraterm_&h_undefined_%Y%m%d_%H%M%S.log"
    [System.Array] ${optArray} = @(${optDir},${optLog},"/ssh-v","/LA=J")
}

### Run teraterm.
Start-Process -FilePath ${sshClient} -ArgumentList ${optArray}


