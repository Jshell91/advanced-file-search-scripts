# Script PowerShell para búsqueda de archivos con informe detallado
# Equivalente mejorado del comando original con estadísticas y tiempos

param(
    [string]$Patron = "*archivo*",
    [switch]$Help
)

# Función para mostrar ayuda
function Show-Ayuda {
    Write-Host "Uso: .\buscar_archivos.ps1 [-Patron <patrón>] [-Help]"
    Write-Host "Ejemplo: .\buscar_archivos.ps1 -Patron '*.pdf'"
    Write-Host "Ejemplo: .\buscar_archivos.ps1 -Patron 'documento*'"
    Write-Host ""
    Write-Host "Si no se proporciona un patrón, se usará '*archivo*' por defecto"
    Write-Host "El script generará un informe detallado con tiempos y conteos por unidad"
}

# Función para formatear tiempo
function Format-Tiempo {
    param([TimeSpan]$tiempo)
    
    if ($tiempo.Hours -gt 0) {
        return "{0:00}:{1:00}:{2:00}" -f $tiempo.Hours, $tiempo.Minutes, $tiempo.Seconds
    }
    elseif ($tiempo.Minutes -gt 0) {
        return "{0:00}:{1:00}" -f $tiempo.Minutes, $tiempo.Seconds
    }
    else {
        return "$($tiempo.Seconds) segundos"
    }
}

# Mostrar ayuda si se solicita
if ($Help) {
    Show-Ayuda
    exit 0
}

# Variables para el informe
$InicioTotal = Get-Date
$ConteosUnidad = @{}
$TiemposUnidad = @{}
$TotalArchivos = 0
$ArchivoReporte = "C:\temp\busqueda_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Crear directorio si no existe
$dirReporte = Split-Path $ArchivoReporte -Parent
if (!(Test-Path $dirReporte)) {
    New-Item -ItemType Directory -Path $dirReporte -Force | Out-Null
}

# Encabezado del informe
$encabezado = @"
===================================================
INFORME DE BÚSQUEDA DE ARCHIVOS
===================================================
Patrón de búsqueda: $Patron
Fecha y hora inicio: $InicioTotal
Archivo de reporte: $ArchivoReporte
===================================================
"@

Write-Host $encabezado
$encabezado | Out-File -FilePath $ArchivoReporte -Encoding UTF8

# Obtener todas las unidades de disco
$unidades = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | Select-Object -ExpandProperty DeviceID

Write-Host ""
Write-Host "Unidades detectadas: $($unidades -join ', ')"
Write-Host ""

# Procesar cada unidad
foreach ($unidad in $unidades) {
    Write-Host "Procesando: $unidad"
    Write-Host "--------------------"
    
    $inicioUnidad = Get-Date
    $ConteosUnidad[$unidad] = 0
    
    # Escribir al reporte
    "Unidad: $unidad" | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
    "Archivos encontrados:" | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
    
    try {
        # Buscar archivos en la unidad
        $archivos = Get-ChildItem -Path "$unidad\" -Recurse -Name $Patron -ErrorAction SilentlyContinue
        
        foreach ($archivo in $archivos) {
            $rutaCompleta = "$unidad\$archivo"
            Write-Host "  $rutaCompleta"
            "  $rutaCompleta" | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
            $ConteosUnidad[$unidad]++
            $TotalArchivos++
        }
        
        # Calcular tiempo para esta unidad
        $finUnidad = Get-Date
        $TiemposUnidad[$unidad] = $finUnidad - $inicioUnidad
        
        Write-Host "Archivos en $unidad`: $($ConteosUnidad[$unidad])"
        Write-Host "Tiempo transcurrido: $(Format-Tiempo $TiemposUnidad[$unidad])"
        
        # Escribir resumen de unidad al reporte
        "Total en esta unidad: $($ConteosUnidad[$unidad]) archivos" | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
        "Tiempo: $(Format-Tiempo $TiemposUnidad[$unidad])" | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
        "" | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
    }
    catch {
        Write-Host "Error procesando $unidad`: $($_.Exception.Message)" -ForegroundColor Red
        "ERROR: $($_.Exception.Message)" | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
        $ConteosUnidad[$unidad] = 0
        $TiemposUnidad[$unidad] = New-TimeSpan
    }
    
    Write-Host ""
}

# Calcular tiempo total
$finTotal = Get-Date
$tiempoTotal = $finTotal - $InicioTotal

# Generar informe final
$informeFinal = @"

===================================================
INFORME FINAL
===================================================
Fecha y hora fin: $finTotal
Tiempo total transcurrido: $(Format-Tiempo $tiempoTotal)

DESGLOSE POR UNIDAD:
-------------------
"@

Write-Host $informeFinal

# Mostrar estadísticas por unidad
foreach ($unidad in $unidades) {
    $linea = "{0,-10}: {1,5} archivos ({2})" -f $unidad, $ConteosUnidad[$unidad], (Format-Tiempo $TiemposUnidad[$unidad])
    Write-Host $linea
}

$resumenFinal = @"

RESUMEN TOTAL:
-------------
Total de archivos encontrados: $TotalArchivos
Unidades procesadas: $($unidades.Count)
Tiempo total: $(Format-Tiempo $tiempoTotal)

Reporte detallado guardado en: $ArchivoReporte
"@

Write-Host $resumenFinal

# Escribir resumen final al archivo
$resumenCompleto = @"
===================================================
RESUMEN FINAL
===================================================
Fin: $finTotal
Tiempo total: $(Format-Tiempo $tiempoTotal)

ESTADÍSTICAS POR UNIDAD:
"@

$resumenCompleto | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8

foreach ($unidad in $unidades) {
    $linea = "{0,-10}: {1,5} archivos ({2})" -f $unidad, $ConteosUnidad[$unidad], (Format-Tiempo $TiemposUnidad[$unidad])
    $linea | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
}

@"

TOTAL GENERAL: $TotalArchivos archivos
UNIDADES PROCESADAS: $($unidades.Count)
TIEMPO TOTAL: $(Format-Tiempo $tiempoTotal)
"@ | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8

Write-Host ""
Write-Host "¡Búsqueda completada! Consulta el archivo $ArchivoReporte para el informe completo." -ForegroundColor Green