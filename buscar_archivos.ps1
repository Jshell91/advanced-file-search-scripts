# Script PowerShell para búsqueda de archivos con informe detallado y filtros avanzados
# Versión mejorada con filtros por tamaño, fecha y tipo de archivo

param(
    [string]$Patron = "*archivo*",
    [string]$MinSize = "",          # Ej: "10MB", "500KB", "1GB"
    [string]$MaxSize = "",          # Ej: "1GB", "100MB"
    [string]$DateFrom = "",         # Fecha desde (ej: "2024-01-01")
    [string]$DateTo = "",           # Fecha hasta (ej: "2025-10-31")
    [string]$Drive = "",            # Unidad específica (ej: "C:")
    [int]$MaxResults = 1000,        # Límite máximo de archivos a mostrar
    [switch]$Quiet,                 # Modo silencioso (solo mostrar resumen)
    [switch]$ExportCSV,             # Exportar resultados a CSV
    [string[]]$FileTypes = @(),     # Ej: @("pdf","docx","xlsx")
    [string[]]$ExcludePaths = @(),  # Rutas a excluir
    [switch]$Help
)

# Función para convertir string de tamaño a bytes
function ConvertTo-Bytes {
    param([string]$sizeString)
    
    if ([string]::IsNullOrEmpty($sizeString)) { return $null }
    
    $sizeString = $sizeString.ToUpper().Trim()
    $number = [regex]::Match($sizeString, '^\d+(\.\d+)?').Value
    
    if ([string]::IsNullOrEmpty($number)) { return $null }
    
    $multiplier = 1
    if ($sizeString -match 'KB$') { $multiplier = 1KB }
    elseif ($sizeString -match 'MB$') { $multiplier = 1MB }
    elseif ($sizeString -match 'GB$') { $multiplier = 1GB }
    elseif ($sizeString -match 'TB$') { $multiplier = 1TB }
    
    return [long]([double]$number * $multiplier)
}

# Función para verificar si un archivo cumple los filtros
function Test-FileFilters {
    param(
        [System.IO.FileInfo]$fileInfo,
        [long]$minSizeBytes,
        [long]$maxSizeBytes,
        [object]$dateFrom,
        [object]$dateTo,
        [string[]]$fileTypes,
        [string[]]$excludePaths
    )
    
    # Filtro por tamaño mínimo
    if ($minSizeBytes -and $fileInfo.Length -lt $minSizeBytes) { return $false }
    
    # Filtro por tamaño máximo
    if ($maxSizeBytes -and $fileInfo.Length -gt $maxSizeBytes) { return $false }
    
    # Filtro por fecha desde
    if ($dateFrom -and $fileInfo.LastWriteTime -lt $dateFrom) { return $false }
    
    # Filtro por fecha hasta
    if ($dateTo -and $fileInfo.LastWriteTime -gt $dateTo) { return $false }
    
    # Filtro por tipos de archivo
    if ($fileTypes.Count -gt 0) {
        $extension = $fileInfo.Extension.TrimStart('.').ToLower()
        if ($extension -notin ($fileTypes | ForEach-Object { $_.ToLower() })) { return $false }
    }
    
    # Filtro por rutas excluidas
    if ($excludePaths.Count -gt 0) {
        foreach ($excludePath in $excludePaths) {
            if ($fileInfo.FullName -like "*$excludePath*") { return $false }
        }
    }
    
    return $true
}

# Función para formatear tamaño de archivo
function Format-FileSize {
    param([long]$bytes)
    
    if ($bytes -ge 1TB) { return "{0:N2} TB" -f ($bytes / 1TB) }
    elseif ($bytes -ge 1GB) { return "{0:N2} GB" -f ($bytes / 1GB) }
    elseif ($bytes -ge 1MB) { return "{0:N2} MB" -f ($bytes / 1MB) }
    elseif ($bytes -ge 1KB) { return "{0:N2} KB" -f ($bytes / 1KB) }
    else { return "$bytes bytes" }
}

# Función para verificar patrones peligrosos
function Test-PatronPeligroso {
    param([string]$patron)
    
    $patronesPeligrosos = @("*", "*.*", "**", "*", "***")
    $esPatronPeligroso = $patronesPeligrosos -contains $patron
    
    if ($esPatronPeligroso) {
        Write-Host ""
        Write-Host "⚠️  ADVERTENCIA: Patrón de búsqueda masiva detectado" -ForegroundColor Red
        Write-Host "Patrón: '$patron'" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Este patrón puede encontrar MILLONES de archivos y tomar HORAS." -ForegroundColor Red
        Write-Host "Recomendaciones:" -ForegroundColor Cyan
        Write-Host "  • Use un patrón más específico (ej: '*.pdf', '*documento*')" 
        Write-Host "  • Use -Drive para limitar a una unidad (ej: -Drive 'C:')"
        Write-Host "  • Use -MaxResults para limitar resultados (ej: -MaxResults 100)"
        Write-Host ""
        
        do {
            $respuesta = Read-Host "¿Continuar de todas formas? (s/N)"
            if ($respuesta -eq "" -or $respuesta -match "^[nN]") {
                Write-Host "Búsqueda cancelada por el usuario." -ForegroundColor Green
                exit 0
            }
        } while ($respuesta -notmatch "^[sS]")
        
        Write-Host "Continuando con la búsqueda masiva..." -ForegroundColor Yellow
        Write-Host ""
    }
}

# Función para mostrar ayuda
function Show-Ayuda {
    Write-Host "BÚSQUEDA AVANZADA DE ARCHIVOS" -ForegroundColor Cyan
    Write-Host "============================="
    Write-Host ""
    Write-Host "Uso básico:" -ForegroundColor Yellow
    Write-Host "  .\buscar_archivos.ps1 [-Patron <patrón>] [opciones...]"
    Write-Host ""
    Write-Host "Parámetros:" -ForegroundColor Yellow
    Write-Host "  -Patron <texto>         Patrón de búsqueda (ej: '*.pdf', '*documento*')"
    Write-Host "  -MinSize <tamaño>       Tamaño mínimo (ej: '10MB', '500KB', '1GB')"
    Write-Host "  -MaxSize <tamaño>       Tamaño máximo (ej: '100MB', '2GB')"
    Write-Host "  -DateFrom <fecha>       Archivos modificados desde (ej: '2024-01-01')"
    Write-Host "  -DateTo <fecha>         Archivos modificados hasta (ej: '2025-10-31')"
    Write-Host "  -Drive <unidad>         Buscar solo en unidad específica (ej: 'C:', 'D:')"
    Write-Host "  -MaxResults <número>    Límite de archivos a mostrar (por defecto: 1000)"
    Write-Host "  -Quiet                  Modo silencioso (solo mostrar resumen final)"
    Write-Host "  -ExportCSV              Exportar resultados a archivo CSV"
    Write-Host "  -FileTypes <tipos>      Extensiones específicas (ej: @('pdf','docx','xlsx'))"
    Write-Host "  -ExcludePaths <rutas>   Excluir carpetas (ej: @('temp','cache','logs'))"
    Write-Host "  -Help                   Mostrar esta ayuda"
    Write-Host ""
    Write-Host "Ejemplos:" -ForegroundColor Green
    Write-Host "  .\buscar_archivos.ps1 -Patron '*.pdf' -MinSize '1MB'"
    Write-Host "  .\buscar_archivos.ps1 -Patron '*documento*' -FileTypes @('pdf','docx')"
    Write-Host "  .\buscar_archivos.ps1 -DateFrom '2024-01-01' -MaxSize '100MB'"
    Write-Host "  .\buscar_archivos.ps1 -Patron '*' -ExcludePaths @('temp','cache')"
}

# Función para formatear tiempo
function Format-Tiempo {
    param([TimeSpan]$tiempo)
    
    # Manejar valores NULL o vacíos
    if ($null -eq $tiempo -or $tiempo -eq [TimeSpan]::Zero) {
        return "00:00"
    }
    
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

# Convertir tamaños a bytes
$minSizeBytes = ConvertTo-Bytes $MinSize
$maxSizeBytes = ConvertTo-Bytes $MaxSize

# Convertir fechas
$dateFromObj = $null
$dateToObj = $null
if (![string]::IsNullOrEmpty($DateFrom)) {
    try { $dateFromObj = [datetime]::Parse($DateFrom) } catch { Write-Warning "Fecha desde inválida: $DateFrom" }
}
if (![string]::IsNullOrEmpty($DateTo)) {
    try { $dateToObj = [datetime]::Parse($DateTo) } catch { Write-Warning "Fecha hasta inválida: $DateTo" }
}

# Verificar patrones peligrosos
Test-PatronPeligroso -patron $Patron

# Variables para el informe
$InicioTotal = Get-Date
$ConteosUnidad = @{}
$TiemposUnidad = @{}
$TotalArchivos = 0
$TotalSize = 0
$ArchivosEncontrados = 0
$MaxResultsReached = $false
$ArchivoReporte = "C:\temp\busqueda_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$ArchivoCSV = "C:\temp\busqueda_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$DatosCSV = @()

# Crear directorio si no existe
$dirReporte = Split-Path $ArchivoReporte -Parent
if (!(Test-Path $dirReporte)) {
    New-Item -ItemType Directory -Path $dirReporte -Force | Out-Null
}

# Crear texto de filtros aplicados
$filtrosTexto = @()
if ($MinSize) { $filtrosTexto += "Tamaño mínimo: $MinSize" }
if ($MaxSize) { $filtrosTexto += "Tamaño máximo: $MaxSize" }
if ($dateFromObj) { $filtrosTexto += "Desde: $($dateFromObj.ToString('yyyy-MM-dd'))" }
if ($dateToObj) { $filtrosTexto += "Hasta: $($dateToObj.ToString('yyyy-MM-dd'))" }
if ($FileTypes.Count -gt 0) { $filtrosTexto += "Tipos: $($FileTypes -join ', ')" }
if ($ExcludePaths.Count -gt 0) { $filtrosTexto += "Excluir: $($ExcludePaths -join ', ')" }

# Encabezado del informe
$encabezado = @"
===================================================
INFORME DE BÚSQUEDA AVANZADA DE ARCHIVOS
===================================================
Patrón de búsqueda: $Patron
Filtros aplicados: $($filtrosTexto -join ' | ')
Fecha y hora inicio: $InicioTotal
Archivo de reporte: $ArchivoReporte
===================================================
"@

Write-Host $encabezado
$encabezado | Out-File -FilePath $ArchivoReporte -Encoding UTF8

# Obtener unidades de disco (específica o todas)
if ($Drive -ne "") {
    $unidades = @($Drive.ToUpper().TrimEnd(':') + ':')
} else {
    $unidades = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | Select-Object -ExpandProperty DeviceID
}

if (-not $Quiet) {
    Write-Host ""
    Write-Host "Unidades detectadas: $($unidades -join ', ')"
    Write-Host ""
}

# Procesar cada unidad
foreach ($unidad in $unidades) {
    if (-not $Quiet) {
        Write-Host "Procesando: $unidad"
        Write-Host "--------------------"
    }
    
    $inicioUnidad = Get-Date
    $ConteosUnidad[$unidad] = 0
    
    # Escribir al reporte
    "Unidad: $unidad" | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
    "Archivos encontrados:" | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
    
    try {
        # Buscar archivos en la unidad
        $archivos = Get-ChildItem -Path "$unidad\" -Recurse -File -ErrorAction SilentlyContinue | 
                   Where-Object { $_.Name -like $Patron }
        
        foreach ($archivo in $archivos) {
            # Verificar límite de resultados
            if ($ArchivosEncontrados -ge $MaxResults) {
                $MaxResultsReached = $true
                break
            }
            
            # Aplicar filtros
            if (Test-FileFilters -fileInfo $archivo -minSizeBytes $minSizeBytes -maxSizeBytes $maxSizeBytes -dateFrom $dateFromObj -dateTo $dateToObj -fileTypes $FileTypes -excludePaths $ExcludePaths) {
                $sizeFormatted = Format-FileSize $archivo.Length
                $dateFormatted = $archivo.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
                
                $infoLinea = "  {0} [{1}] ({2})" -f $archivo.FullName, $sizeFormatted, $dateFormatted
                
                # Solo mostrar archivos si NO está en modo silencioso
                if (-not $Quiet) {
                    Write-Host $infoLinea
                }
                $infoLinea | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
                
                # Agregar al CSV si se solicitó
                if ($ExportCSV) {
                    $DatosCSV += [PSCustomObject]@{
                        'Nombre' = $archivo.Name
                        'Ruta Completa' = $archivo.FullName
                        'Directorio' = $archivo.DirectoryName
                        'Tamaño (Bytes)' = $archivo.Length
                        'Tamaño Formateado' = $sizeFormatted
                        'Fecha Modificación' = $archivo.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
                        'Extensión' = $archivo.Extension
                        'Unidad' = $unidad
                    }
                }
                
                $ConteosUnidad[$unidad]++
                $TotalArchivos++
                $ArchivosEncontrados++
                $TotalSize += $archivo.Length
            }
        }
        
        # Calcular tiempo para esta unidad
        $finUnidad = Get-Date
        $TiemposUnidad[$unidad] = $finUnidad - $inicioUnidad
        
        if (-not $Quiet) {
            Write-Host "Archivos en $unidad`: $($ConteosUnidad[$unidad])"
            Write-Host "Tiempo transcurrido: $(Format-Tiempo $TiemposUnidad[$unidad])"
        }
        
        # Salir si se alcanzó el límite de resultados
        if ($MaxResultsReached) {
            if (-not $Quiet) {
                Write-Host "¡Límite de $MaxResults archivos alcanzado! Búsqueda detenida." -ForegroundColor Yellow
            }
            break
        }
        
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
    
    if (-not $Quiet) {
        Write-Host ""
    }
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
    $tiempo = if ($TiemposUnidad.ContainsKey($unidad)) { $TiemposUnidad[$unidad] } else { New-TimeSpan }
    $conteo = if ($ConteosUnidad.ContainsKey($unidad)) { $ConteosUnidad[$unidad] } else { 0 }
    $linea = "{0,-10}: {1,5} archivos ({2})" -f $unidad, $conteo, (Format-Tiempo $tiempo)
    Write-Host $linea
}

$resumenFinal = @"

RESUMEN TOTAL:
-------------
Total de archivos encontrados: $TotalArchivos
Tamaño total: $(Format-FileSize $TotalSize)
Tamaño promedio: $(if ($TotalArchivos -gt 0) { Format-FileSize ($TotalSize / $TotalArchivos) } else { "0 bytes" })
Unidades procesadas: $($unidades.Count)
Tiempo total: $(Format-Tiempo $tiempoTotal)
$(if ($MaxResultsReached) { "NOTA: Búsqueda limitada a $MaxResults archivos (use -MaxResults para cambiar)" } else { "" })

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
    $tiempo = if ($TiemposUnidad.ContainsKey($unidad)) { $TiemposUnidad[$unidad] } else { New-TimeSpan }
    $conteo = if ($ConteosUnidad.ContainsKey($unidad)) { $ConteosUnidad[$unidad] } else { 0 }
    $linea = "{0,-10}: {1,5} archivos ({2})" -f $unidad, $conteo, (Format-Tiempo $tiempo)
    $linea | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8
}

@"

ESTADÍSTICAS TOTALES:
--------------------
TOTAL GENERAL: $TotalArchivos archivos
TAMAÑO TOTAL: $(Format-FileSize $TotalSize)
TAMAÑO PROMEDIO: $(if ($TotalArchivos -gt 0) { Format-FileSize ($TotalSize / $TotalArchivos) } else { "0 bytes" })
UNIDADES PROCESADAS: $($unidades.Count)
TIEMPO TOTAL: $(Format-Tiempo $tiempoTotal)

FILTROS APLICADOS:
-----------------
$($filtrosTexto -join "`n")
"@ | Out-File -FilePath $ArchivoReporte -Append -Encoding UTF8

# Generar archivo CSV si se solicitó
if ($ExportCSV -and $DatosCSV.Count -gt 0) {
    $DatosCSV | Export-Csv -Path $ArchivoCSV -NoTypeInformation -Encoding UTF8
    Write-Host ""
    Write-Host "Archivo CSV generado: $ArchivoCSV" -ForegroundColor Green
}

Write-Host ""
if ($ExportCSV -and $DatosCSV.Count -gt 0) {
    Write-Host "¡Búsqueda completada!" -ForegroundColor Green
    Write-Host "  • Informe detallado: $ArchivoReporte" 
    Write-Host "  • Datos CSV: $ArchivoCSV"
} else {
    Write-Host "¡Búsqueda completada! Consulta el archivo $ArchivoReporte para el informe completo." -ForegroundColor Green
}