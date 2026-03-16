# Script de Configuración Completa de Red para Windows

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey)](https://www.microsoft.com/windows)
[![Licencia](https://img.shields.io/badge/Licencia-MIT-green)](LICENSE)

## 📋 Descripción

Este script de PowerShell automatiza la configuración avanzada de red en sistemas Windows, diseñado especialmente para entornos corporativos que requieren un control preciso sobre el comportamiento de los adaptadores de red. Aplica de forma masiva y consistente los siguientes ajustes en **todos** los adaptadores de red del sistema (incluidos los ocultos):

- Deshabilitación de IPv6
- Establecimiento de un sufijo DNS específico (`example.com`)
- Habilitación de la opción **"Usar el sufijo DNS de esta conexión para el registro en DNS"**
- Deshabilitación de NetBIOS sobre TCP/IP
- Actualización forzada de la configuración DNS (registro y limpieza de caché)
- Reinicio de servicios críticos de red (Dnscache, NlaSvc)

El script modifica directamente el registro de Windows y utiliza comandos nativos como `netsh`, `Set-DnsClient` y `Disable-NetAdapterBinding` para garantizar la máxima compatibilidad y efectividad.

## ✨ Características

- ✅ **Actúa sobre TODOS los adaptadores** (físicos, virtuales, ocultos, VPN, etc.)
- ✅ **Deshabilita IPv6** por completo en cada adaptador
- ✅ **Configura el sufijo DNS** de conexión específico (ej. `example.com`)
- ✅ **Habilita el registro DNS con el sufijo** (opción gráfica "Usar el sufijo DNS de esta conexión para el registro en DNS")
- ✅ **Deshabilita NetBIOS sobre TCP/IP** (reduce tráfico de difusión y mejora seguridad)
- ✅ **Actualiza la configuración de red** (`ipconfig /registerdns`, `ipconfig /flushdns`)
- ✅ **Verifica** los cambios aplicados y muestra un informe detallado por adaptador
- ✅ **Totalmente automatizado** y con mensajes de estado (verde/amarillo/rojo)
- ✅ **Diseñado para ejecución como Administrador**

## ⚙️ Requisitos

- **Sistema operativo:** Windows 10 / Windows 11 / Windows Server 2016 o superior (probado en versiones recientes)
- **Permisos:** Ejecución como **Administrador** (necesario para modificar el registro y la configuración de red)
- **PowerShell:** Versión 5.1 o superior (incluida por defecto en Windows)

## 🚀 Instrucciones de uso

1. **Descarga el script** o clona este repositorio:
   ```bash
   git clone https://github.com/danielgraciapalacios/DESHABILITAR-IPV6-WINS-NetBios-y-ESTABLECER-SUFIJO-DNS.git
   ```
2. Abre PowerShell como Administrador (clic derecho → "Ejecutar como administrador").
3. Navega hasta la carpeta donde se encuentra el script.
4. **Ejecutar**:
   ```bash
   powershell -ExecutionPolicy Bypass -File ".\SCRIPT IPV6, DNS y WINS-NetBios.ps1"
   ```
5. Observa la salida en pantalla. El script mostrará cada paso y al final un resumen de verificación para cada adaptador.

## 🔧 Personalización
El sufijo DNS por defecto está configurado como example.com. Para adaptarlo a tu dominio, edita la línea correspondiente en el script:
   ```bash
   $suffix = "example.com"   # Cambia por tu dominio, ej. "miempresa.local"
   ```
Si deseas modificar algún otro comportamiento (por ejemplo, no deshabilitar IPv6 en determinados adaptadores), puedes ajustar el script añadiendo condiciones sobre el nombre del adaptador ($adapter.Name).

Nota: La sección de configuración de DNS automático (DHCP) se encuentra comentada en el script. Si necesitas restablecer los servidores DNS a DHCP, descomenta las líneas correspondientes (bloque # 2. Configurar DNS automático (DHCP)).

## ⚠️ Advertencias
- El script modifica todos los adaptadores de red, incluidos los virtuales (Hyper‑V, VPN, etc.). Si necesitas excluir alguno, debes adaptar el código.
- Deshabilitar IPv6 puede afectar a ciertas aplicaciones que dependan de él. Asegúrate de que tu entorno funciona correctamente sin IPv6.
- Se recomienda realizar una copia de seguridad del registro o crear un punto de restauración antes de ejecutar el script por primera vez.
- El script fuerza el reinicio de los servicios Dnscache y NlaSvc, lo que puede causar una breve interrupción en la conectividad de red.
