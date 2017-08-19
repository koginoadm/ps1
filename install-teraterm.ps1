$tt_install_uri = "http://ymu.dl.osdn.jp/ttssh2/67769/teraterm-4.95.exe"
$tt_install_exe = "$env:USERPROFILE\Downloads\$(Split-Path -Path $tt_install_uri -Leaf)"
if (-Not($(Test-Path $env:USERPROFILE\Downloads)))
{
    New-Item -ItemType Directory -Path $env:USERPROFILE\Downloads
}
Invoke-WebRequest -Uri $tt_install_uri -OutFile $tt_install_exe
if ($?)
{
    Resolve-Path $tt_install_exe
    Start-Process -FilePath $tt_install_exe -Args '/silent /sp-' -PassThru -Wait
}
