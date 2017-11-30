# ssh.bat

### install

<kbd>Windows</kbd> + <kbd>R</kbd>

```
powershell.exe -Command "Invoke-RestMethod -Uri "https://raw.githubusercontent.com/koginoadm/ssh/master/ssh.bat" | Out-File -Encoding utf8 "${env:Userprofile}\ssh.bat""
```

### run

<kbd>Windows</kbd> + <kbd>R</kbd>

```
ssh root@192.168.1.100
```

