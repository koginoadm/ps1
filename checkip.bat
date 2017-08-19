@echo off
rem # 
rem # - Name
rem #     checkip.bat
rem # 
rem # - Contents
rem #     checkip
rem # 
rem # - Install
rem #     powershell.exe -Command "Invoke-RestMethod -Uri "https://djeeno.github.io/ps1/checkip.bat" -OutFile "$env:USERPROFILE\checkip.bat""
rem #
rem # - Revision
rem #     2017-07-14 created.
rem #     yyyy-MM-dd modified.
rem # 

cmd.exe /k powershell.exe -Command "Invoke-RestMethod -Uri http://checkip.amazonaws.com/"

