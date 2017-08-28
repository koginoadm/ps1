@echo off
rem # 
rem # - Name
rem #     edit-hosts.bat
rem # 
rem # - Contents
rem #     C:\Windows\System32\runas.exe notepad C:\Windows\System32\drivers\etc\hosts
rem # 
rem # - Install
rem #     powershell.exe -Command "Invoke-RestMethod -Uri 'https://koginoadm.github.io/ps1/edit-hosts.bat' -OutFile "$env:USERPROFILE\edit-hosts.bat""
rem # 
rem # - Revision
rem #     2017-05-10 created.
rem #     yyyy-MM-dd modified.
rem # 

start powershell.exe -Command "Start-Process -Verb RUNAS notepad C:\Windows\System32\drivers\etc\hosts"
