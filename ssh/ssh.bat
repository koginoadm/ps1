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
#     powershell.exe -Command "Invoke-RestMethod -Uri "https://raw.githubusercontent.com/koginoadm/ps1/master/ssh/ssh.bat" | Out-File -Encoding utf8 "${env:Userprofile}\ssh.bat""
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
#     2017-12-18 modified.
#     yyyy-MM-dd modified.
# 


################
# constant
################
${ttZipUri} = "http://ymu.dl.osdn.jp/ttssh2/68252/teraterm-4.96.zip"


################
# variables
################
${ttDir}   = "${env:Userprofile}\teraterm"
${sshDir}  = "${ttDir}\ssh"
################################
# 任意のディレクトリを指定
${userSshDir} = "${env:Userprofile}\GoogleDrive\ssh"
if (Test-Path -PathType container ${userSshDir}) { ${sshDir} = "${userSshDir}" }
################################
${logDir}  = "${sshDir}\log"
${keyDir}  = "${sshDir}\key"
${csvFile} = "${sshDir}\hosts.csv"
${ttZipFile} = "${env:TEMP}\$(Split-Path -Path $(Split-Path -Path ${ttZipUri} -NoQualifier) -Leaf)" ### backport for Windows 7 (duplicate "Split-Path")


################
# function
################
function Expand-Zip {
   # Create Explorer object
   $Expcom = New-Object -ComObject Shell.Application
   # Register the zip file path of the 1st argument.
   $zipFile = $Expcom.NameSpace($args[0])
   # Register the destination directory path of the 2nd argument.
   $tgtDir = $Expcom.NameSpace($args[1])
   # Gets the object (file) list in the zip file and passes it to ForEach-Object.
   $zipFile.Items() | ForEach-Object {
      # Copy files one by one to the output directory.
      $tgtDir.CopyHere($_.path)
   }
}


################
# main
################
### Create directorys.
if ((Get-Item ${sshDir}).Mode 2>$null | Select-String -NotMatch '^d') { mkdir ${sshDir}; Start-Sleep 0.5; }
if ((Get-Item ${logDir}).Mode 2>$null | Select-String -NotMatch '^d') { mkdir ${logDir}; Start-Sleep 0.5; }
if ((Get-Item ${keyDir}).Mode 2>$null | Select-String -NotMatch '^d') { mkdir ${keyDir}; Start-Sleep 0.5; }
if (-Not (Test-Path ${csvFile}))
{
    # Generate CSV File
    Write-Output "Hostname,Username,AuthType,Value,Alias" >> ${csvFile}
    Write-Output "#~~~~~~~~ !!! DO NOT EDIT !!! ~~~~~~~~ <= In the first line, Header information is written." >> ${csvFile}
    Write-Output "" >> ${csvFile}
    Write-Output "# Please refer to the following and set it like the description example." >> ${csvFile}
    Write-Output "# Hostname[:Port],Username,AuthType[password|publickey],Value[Pass|KeyFile(InKeyDir)],Alias(UPN recommended)" >> ${csvFile}
    Write-Output "" >> ${csvFile}
    Write-Output "# description example:" >> ${csvFile}
    Write-Output "www.example.com:10022,admin,publickey,id_rsa,admin@www.example.com" >> ${csvFile}
    Write-Output "192.168.1.100,root,password,P@ssw0rd,root@TEST01" >> ${csvFile}
    # Output Logs
    Write-Output "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [NOTICE]: Check the following CSV file and set it as shown in the description example."
    Write-Output "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [NOTICE]: CSV file ... ${csvFile}"
    Write-Output "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [NOTICE]: Edit the CSV file and try again."
    # Open CSV File by notepad.exe
    Start-Process -FilePath notepad.exe -ArgumentList ${csvFile}
}

### Search for ttermpro.exe from the directory where teraterm was installed and get the full path of ttermpro.exe.
[System.String] ${sshClient} = Get-ChildItem -recurse "C:\Program Files*\teraterm" 2>$null | Where-Object { $_.Name -match "ttermpro" } | ForEach-Object { $_.FullName }
### If ttermpro.exe does not exist,
if (-Not (${sshClient}))
{
    [System.String] ${sshClient} = Get-ChildItem -recurse ${ttDir} 2>$null | Where-Object { $_.Name -match "ttermpro" } | ForEach-Object { $_.FullName }
    if (-Not (${sshClient}))
    {
        if ((Get-Item ${ttDir}).Mode 2>$null | Select-String -NotMatch '^d') { mkdir ${ttDir}; Start-Sleep 0.5; }
        Invoke-WebRequest -Uri ${ttZipUri} -OutFile ${ttZipFile}
        Expand-Zip ${ttZipFile} ${ttDir}
        [System.String] ${sshClient} = Get-ChildItem -recurse ${ttDir} | Where-Object { $_.Name -match "ttermpro" } | ForEach-Object { $_.FullName }
        if (-Not (${sshClient}))
        {
            Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [ERROR]: ttermpro.exe not found in `"C:\Program Files*`", and, failed to install teraterm to `"${ttDir}`"."
            [Console]::ReadKey() | Out-Null
            exit 1
        }
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


