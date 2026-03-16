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
