# Creado por DANIEL GRACIA - https://www.linkedin.com/in/daniel-gracia-palacios/
# Experto en informática en 2026

# Script de configuración de red completa
# Requiere ejecución como administrador

Write-Host "Iniciando configuración completa de red..." -ForegroundColor Yellow

# Obtener TODAS las interfaces de red
$adapters = Get-NetAdapter -IncludeHidden
$suffix = "example.com"

# 1. Deshabilitar IPv6 en TODOS los adaptadores
Write-Host "`n1. Deshabilitando IPv6 en todos los adaptadores..." -ForegroundColor Yellow
foreach ($adapter in $adapters) {
    try {
        Disable-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
        Write-Host "   [$($adapter.Name)] IPv6 deshabilitado" -ForegroundColor Green
    } catch {
        Write-Host "   [$($adapter.Name)] Error al deshabilitar IPv6: $_" -ForegroundColor Red
    }
}

# 2. Configurar DNS automático (DHCP) en TODOS los adaptadores
#Write-Host "`n2. Configurando DNS automático (DHCP)..." -ForegroundColor Yellow
#foreach ($adapter in $adapters) {
#    try {
#        Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses -ErrorAction SilentlyContinue
#        Write-Host "   [$($adapter.Name)] DNS configurado a DHCP" -ForegroundColor Green
#    } catch {
#        Write-Host "   [$($adapter.Name)] Error configurando DNS: $_" -ForegroundColor Red
#    }
#}

# 3. Establecer sufijo DNS específico en TODOS los adaptadores
Write-Host "`n3. Configurando sufijo DNS '$suffix'..." -ForegroundColor Yellow
foreach ($adapter in $adapters) {
    try {
        Set-DnsClient -InterfaceAlias $adapter.Name -ConnectionSpecificSuffix $suffix -ErrorAction SilentlyContinue
        Write-Host "   [$($adapter.Name)] Sufijo DNS establecido: $suffix" -ForegroundColor Green
    } catch {
        Write-Host "   [$($adapter.Name)] Error estableciendo sufijo: $_" -ForegroundColor Red
    }
}

# 4. Habilitar "Usar el sufijo DNS de esta conexión para el registro en DNS"
Write-Host "`n4. Habilitando 'Usar el sufijo DNS para registro'..." -ForegroundColor Yellow
foreach ($adapter in $adapters) {
    try {
        $interfaceGuid = $adapter.InterfaceGuid
        
        if ($interfaceGuid) {
            # Esta es la ruta correcta para la configuración DNS avanzada
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$interfaceGuid"
            
            if (Test-Path $regPath) {
                # 1. Configurar el sufijo DNS
                Set-ItemProperty -Path $regPath -Name "Domain" -Value $suffix -Force
                
                # 2. Configurar para usar el sufijo en el registro DNS (esta es la clave específica)
                # Esta opción se llama "UseDomainNameDevolution" en el registro y corresponde a 
                # "Usar el sufijo DNS de esta conexión para el registro en DNS" en la interfaz gráfica
                Set-ItemProperty -Path $regPath -Name "UseDomainNameDevolution" -Value 1 -Type DWord -Force
                
                # 3. Habilitar el registro DNS para esta interfaz
                Set-ItemProperty -Path $regPath -Name "RegistrationEnabled" -Value 1 -Type DWord -Force
                
                # 4. Configurar RegisterAdapterName (importante para que funcione)
                Set-ItemProperty -Path $regPath -Name "RegisterAdapterName" -Value 1 -Type DWord -Force
                
                # 5. Configurar DomainDevolutionLevel (necesario para el funcionamiento completo)
                Set-ItemProperty -Path $regPath -Name "DomainDevolutionLevel" -Value 15 -Type DWord -Force
                
                Write-Host "   [$($adapter.Name)] 'Usar sufijo DNS para registro' HABILITADO" -ForegroundColor Green
            } else {
                Write-Host "   [$($adapter.Name)] No se encontró la clave de registro" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "   [$($adapter.Name)] Error habilitando registro DNS: $_" -ForegroundColor Red
    }
}

# 5. Deshabilitar NetBIOS sobre TCP/IP
Write-Host "`n5. Deshabilitando NetBIOS sobre TCP/IP..." -ForegroundColor Yellow
foreach ($adapter in $adapters) {
    try {
        # Método 1: Usando netsh (el más confiable)
        $adapterName = $adapter.Name
        netsh interface ipv4 set interface "$adapterName" netbios=disable 2>&1 | Out-Null
        
        # Método 2: Configurar en el registro
        $interfaceGuid = $adapter.InterfaceGuid
        if ($interfaceGuid) {
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tcpip_$interfaceGuid"
            if (Test-Path $regPath) {
                Set-ItemProperty -Path $regPath -Name "NetbiosOptions" -Value 2 -Type DWord -Force
            }
        }
        
        Write-Host "   [$($adapter.Name)] NetBIOS deshabilitado" -ForegroundColor Green
    } catch {
        Write-Host "   [$($adapter.Name)] Error deshabilitando NetBIOS: $_" -ForegroundColor Red
    }
}

# 6. Actualizar configuración de red
Write-Host "`n6. Actualizando configuración de red..." -ForegroundColor Yellow
try {
    # Forzar actualización DNS
    Start-Process -FilePath "ipconfig" -ArgumentList "/registerdns" -Wait -NoNewWindow
    Start-Process -FilePath "ipconfig" -ArgumentList "/flushdns" -Wait -NoNewWindow
    
    # Reiniciar servicios críticos
    Restart-Service -Name "Dnscache" -Force -ErrorAction SilentlyContinue
    Restart-Service -Name "NlaSvc" -Force -ErrorAction SilentlyContinue
    
    Write-Host "   Configuración actualizada" -ForegroundColor Green
} catch {
    Write-Host "   Error actualizando configuración: $_" -ForegroundColor Red
}

# 7. Verificar configuración aplicada
Write-Host "`n`nVERIFICACIÓN DE CONFIGURACIÓN:" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

foreach ($adapter in $adapters) {
    Write-Host "`nAdaptador: $($adapter.Name)" -ForegroundColor Cyan
    Write-Host "  Estado: $($adapter.Status)"
    
    # Verificar sufijo DNS
    $dnsClient = Get-DnsClient -InterfaceAlias $adapter.Name -ErrorAction SilentlyContinue
    if ($dnsClient -and $dnsClient.ConnectionSpecificSuffix) {
        Write-Host "  Sufijo DNS: $($dnsClient.ConnectionSpecificSuffix)" -ForegroundColor Green
    } else {
        Write-Host "  Sufijo DNS: NO CONFIGURADO" -ForegroundColor Red
    }
    
    # Verificar configuración de registro DNS en el registro
    $interfaceGuid = $adapter.InterfaceGuid
    if ($interfaceGuid) {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$interfaceGuid"
        if (Test-Path $regPath) {
            $domainValue = Get-ItemProperty -Path $regPath -Name "Domain" -ErrorAction SilentlyContinue
            $useDomainNameDevolution = Get-ItemProperty -Path $regPath -Name "UseDomainNameDevolution" -ErrorAction SilentlyContinue
            $registrationEnabled = Get-ItemProperty -Path $regPath -Name "RegistrationEnabled" -ErrorAction SilentlyContinue
            $registerAdapterName = Get-ItemProperty -Path $regPath -Name "RegisterAdapterName" -ErrorAction SilentlyContinue
            
            if ($domainValue.Domain -eq $suffix) {
                Write-Host "  Sufijo en registro: OK ($suffix)" -ForegroundColor Green
            } else {
                Write-Host "  Sufijo en registro: NO COINCIDE" -ForegroundColor Red
            }
            
            if ($useDomainNameDevolution.UseDomainNameDevolution -eq 1) {
                Write-Host "  'Usar sufijo para registro': HABILITADO" -ForegroundColor Green
            } else {
                Write-Host "  'Usar sufijo para registro': DESHABILITADO" -ForegroundColor Red
            }
            
            if ($registrationEnabled.RegistrationEnabled -eq 1) {
                Write-Host "  Registro DNS habilitado: SI" -ForegroundColor Green
            } else {
                Write-Host "  Registro DNS habilitado: NO" -ForegroundColor Yellow
            }
        }
    }
    
    # Verificar NetBIOS
    try {
        $config = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "Description = '$($adapter.InterfaceDescription)'" -ErrorAction SilentlyContinue
        if ($config) {
            if ($config.TcpipNetbiosOptions -eq 2) {
                Write-Host "  NetBIOS: DESHABILITADO" -ForegroundColor Green
            } else {
                Write-Host "  NetBIOS: NO DESHABILITADO (Estado: $($config.TcpipNetbiosOptions))" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "  NetBIOS: No se pudo verificar" -ForegroundColor Yellow
    }
}

Write-Host El proceso ha terminado!
