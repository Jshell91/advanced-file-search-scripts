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
    [switch]$ExportHTML,            # Exportar reporte HTML con gráficos
    [switch]$ExportJSON,            # Exportar datos estructurados en formato JSON
    [switch]$NoProgress,            # Desactivar barra de progreso
    [string[]]$FileTypes = @(),     # Ej: @("pdf","docx","xlsx")
    [string[]]$ExcludePaths = @(),  # Rutas a excluir
    [switch]$Help
)

# Configurar codificación UTF-8 para mostrar correctamente acentos y caracteres especiales
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

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
    Write-Host "  -ExportHTML             Exportar reporte HTML visual con gráficos"
    Write-Host "  -ExportJSON             Exportar datos estructurados en formato JSON"
    Write-Host "  -NoProgress             Desactivar barra de progreso (modo clásico)"
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

# Función para mostrar barra de progreso
function Show-ProgressBar {
    param(
        [string]$Activity,
        [string]$Status,
        [int]$PercentComplete,
        [int]$CurrentCount,
        [int]$TotalCount,
        [TimeSpan]$ElapsedTime,
        [string]$CurrentItem = ""
    )
    # Usar tanto Write-Progress como texto visible
    $statusText = $Status
    if ($CurrentCount -ne $null -and $TotalCount -gt 0) { $statusText += " - $CurrentCount/$TotalCount" }
    if ($CurrentItem) { $statusText += " - $CurrentItem" }

    # Mostrar Write-Progress (barra en parte superior del terminal)
    Write-Progress -Activity $Activity -Status $statusText -PercentComplete $PercentComplete -Id 1
    
    # También mostrar línea de texto visible
    $barLength = 20
    $filledLength = [math]::Floor($barLength * $PercentComplete / 100)
    $emptyLength = $barLength - $filledLength
    $bar = "█" * $filledLength + "░" * $emptyLength
    $timeStr = "$(Format-Tiempo $ElapsedTime)"
    
    Write-Host "[$bar] $PercentComplete% | $Activity | $statusText | $timeStr" -ForegroundColor Cyan
}

# Función para generar reporte HTML con gráficos
function Generate-HTMLReport {
    param(
        [array]$DatosArchivos,
        [hashtable]$ConteosUnidad,
        [hashtable]$TiemposUnidad,
        [string]$Patron,
        [string]$ArchivoHTML,
        [int]$TotalArchivos,
        [long]$TotalSize,
        [TimeSpan]$TiempoTotal
    )
    
    # Calcular estadísticas
    $extensiones = $DatosArchivos | Group-Object 'Extensión' | Sort-Object Count -Descending | Select-Object -First 10
    $unidadesStats = $ConteosUnidad.GetEnumerator() | Sort-Object Value -Descending
    $archivosMasGrandes = $DatosArchivos | Sort-Object 'Tamaño (Bytes)' -Descending | Select-Object -First 5
    
    # CSS y JavaScript para gráficos
    $htmlContent = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Búsqueda de Archivos - $Patron</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; text-align: center; margin-bottom: 30px; border-bottom: 3px solid #3498db; padding-bottom: 15px; }
        h2 { color: #34495e; margin-top: 30px; border-left: 4px solid #3498db; padding-left: 15px; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .stat-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px; text-align: center; }
        .stat-number { font-size: 2em; font-weight: bold; }
        .stat-label { font-size: 0.9em; opacity: 0.9; }
        .chart-container { width: 100%; height: 400px; margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #3498db; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .progress-bar { background: #ecf0f1; border-radius: 10px; overflow: hidden; height: 20px; margin: 5px 0; }
        .progress-fill { height: 100%; background: linear-gradient(90deg, #3498db, #2ecc71); transition: width 0.3s ease; }
        .file-link { color: #3498db; text-decoration: none; }
        .file-link:hover { text-decoration: underline; }
        .summary { background: #ecf0f1; padding: 20px; border-radius: 8px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 Reporte de Búsqueda de Archivos</h1>
        
        <div class="summary">
            <strong>Patrón de búsqueda:</strong> $Patron<br>
            <strong>Fecha de generación:</strong> $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')<br>
            <strong>Tiempo de búsqueda:</strong> $(Format-Tiempo $TiempoTotal)
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number">$TotalArchivos</div>
                <div class="stat-label">Archivos Encontrados</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">$(Format-FileSize $TotalSize)</div>
                <div class="stat-label">Tamaño Total</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">$($ConteosUnidad.Count)</div>
                <div class="stat-label">Unidades Procesadas</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">$(if ($TotalArchivos -gt 0) { Format-FileSize ($TotalSize / $TotalArchivos) } else { "0 bytes" })</div>
                <div class="stat-label">Tamaño Promedio</div>
            </div>
        </div>

        <h2>📊 Distribución por Tipos de Archivo</h2>
        <canvas id="extensionsChart" class="chart-container"></canvas>

        <h2>💽 Archivos por Unidad</h2>
        <canvas id="unitsChart" class="chart-container"></canvas>
"@

    # Tabla de archivos más grandes
    if ($archivosMasGrandes.Count -gt 0) {
        $htmlContent += @"
        <h2>📁 Archivos Más Grandes</h2>
        <table>
            <tr><th>Archivo</th><th>Tamaño</th><th>Fecha</th><th>Ubicación</th></tr>
"@
        foreach ($archivo in $archivosMasGrandes) {
            $rutaCompleta = $archivo.'Ruta Completa'
            $htmlContent += @"
            <tr>
                <td><a href="file:///$rutaCompleta" class="file-link">$($archivo.Nombre)</a></td>
                <td>$($archivo.'Tamaño Formateado')</td>
                <td>$($archivo.'Fecha Modificación')</td>
                <td>$($archivo.Directorio)</td>
            </tr>
"@
        }
        $htmlContent += "</table>"
    }

    # JavaScript para gráficos
    $htmlContent += @"
        <script>
        // Gráfico de extensiones
        const extCtx = document.getElementById('extensionsChart').getContext('2d');
        new Chart(extCtx, {
            type: 'pie',
            data: {
                labels: [$(($extensiones | ForEach-Object { "'$($_.Name)'" }) -join ', ')],
                datasets: [{
                    data: [$(($extensiones | ForEach-Object { $_.Count }) -join ', ')],
                    backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40', '#FF6384', '#C9CBCF', '#4BC0C0', '#FF6384']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: { display: true, text: 'Distribución por Tipo de Archivo' }
                }
            }
        });

        // Gráfico de unidades
        const unitsCtx = document.getElementById('unitsChart').getContext('2d');
        new Chart(unitsCtx, {
            type: 'bar',
            data: {
                labels: [$(($unidadesStats | ForEach-Object { "'$($_.Key)'" }) -join ', ')],
                datasets: [{
                    label: 'Archivos por Unidad',
                    data: [$(($unidadesStats | ForEach-Object { $_.Value }) -join ', ')],
                    backgroundColor: '#3498db'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: { display: true, text: 'Archivos por Unidad de Disco' }
                }
            }
        });
        </script>
    </div>
</body>
</html>
"@

    # Guardar archivo HTML
    [System.IO.File]::WriteAllText($ArchivoHTML, $htmlContent, [System.Text.Encoding]::UTF8)
}

# Función para generar reporte JSON estructurado
function Generate-JSONReport {
    param(
        [array]$DatosArchivos,
        [hashtable]$ConteosUnidad,
        [hashtable]$TiemposUnidad,
        [string]$Patron,
        [string]$ArchivoJSON,
        [int]$TotalArchivos,
        [long]$TotalSize,
        [TimeSpan]$TiempoTotal
    )
    
    # Construir estadísticas para JSON
    $extensiones = $DatosArchivos | Group-Object 'Extensión' | ForEach-Object {
        @{
            extension = $_.Name
            count = $_.Count
            percentage = [math]::Round(($_.Count / $TotalArchivos) * 100, 2)
        }
    } | Sort-Object count -Descending
    
    $unidadesStats = @()
    foreach ($unidad in $ConteosUnidad.Keys) {
        $unidadesStats += @{
            drive = $unidad
            fileCount = $ConteosUnidad[$unidad]
            searchTime = $(Format-Tiempo $TiemposUnidad[$unidad])
            searchTimeSeconds = $TiemposUnidad[$unidad].TotalSeconds
        }
    }
    
    # Archivos más grandes (top 10)
    $archivosMasGrandes = $DatosArchivos | Sort-Object 'Tamaño (Bytes)' -Descending | Select-Object -First 10 | ForEach-Object {
        @{
            name = $_.'Nombre'
            fullPath = $_.'Ruta Completa'
            directory = $_.'Directorio'
            sizeBytes = $_.'Tamaño (Bytes)'
            sizeFormatted = $_.'Tamaño Formateado'
            extension = $_.'Extensión'
            lastModified = $_.'Fecha Modificación'
        }
    }
    
    # Estructura principal del JSON
    $jsonData = @{
        metadata = @{
            generatedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ'
            searchPattern = $Patron
            generator = "Advanced File Search Scripts v2.0"
            reportType = "JSON_EXPORT"
        }
        summary = @{
            totalFiles = $TotalArchivos
            totalSizeBytes = $TotalSize
            totalSizeFormatted = Format-FileSize $TotalSize
            averageSizeBytes = if ($TotalArchivos -gt 0) { [math]::Round($TotalSize / $TotalArchivos, 2) } else { 0 }
            averageSizeFormatted = if ($TotalArchivos -gt 0) { Format-FileSize ($TotalSize / $TotalArchivos) } else { "0 bytes" }
            unitsProcessed = $ConteosUnidad.Count
            totalSearchTimeSeconds = $TiempoTotal.TotalSeconds
            totalSearchTimeFormatted = Format-Tiempo $TiempoTotal
        }
        statistics = @{
            filesByExtension = $extensiones
            filesByDrive = $unidadesStats
        }
        files = @{
            largestFiles = $archivosMasGrandes
            allFiles = $DatosArchivos | ForEach-Object {
                @{
                    name = $_.'Nombre'
                    fullPath = $_.'Ruta Completa'
                    directory = $_.'Directorio'
                    sizeBytes = $_.'Tamaño (Bytes)'
                    sizeFormatted = $_.'Tamaño Formateado'
                    extension = $_.'Extensión'
                    lastModified = $_.'Fecha Modificación'
                }
            }
        }
        performance = @{
            searchStartTime = (Get-Date).AddSeconds(-$TiempoTotal.TotalSeconds).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            searchEndTime = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            driveSearchTimes = $unidadesStats
        }
    }
    
    # Convertir a JSON con formato legible
    $jsonContent = $jsonData | ConvertTo-Json -Depth 10 -Compress:$false
    
    # Guardar archivo JSON
    $jsonContent | Out-File -FilePath $ArchivoJSON -Encoding UTF8
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

# Inicializar variables de progreso
$unidadActual = 0
$totalUnidades = $unidades.Count
$inicioGlobal = Get-Date

# Procesar cada unidad
foreach ($unidad in $unidades) {
    $unidadActual++
    
    if (-not $Quiet -and -not $NoProgress) {
        # Mostrar progreso inicial
        $tiempoTranscurrido = (Get-Date) - $inicioGlobal
        Show-ProgressBar -Activity "Iniciando busqueda en $unidad" -Status "Preparando..." -PercentComplete 0 -CurrentCount 0 -TotalCount $MaxResults -ElapsedTime $tiempoTranscurrido
    } elseif (-not $Quiet) {
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
            
            # Mostrar progreso: siempre al inicio, cada 50 archivos, y en archivos importantes
            if (-not $NoProgress -and -not $Quiet -and ($ArchivosEncontrados -eq 1 -or $ArchivosEncontrados % 50 -eq 0 -or $ArchivosEncontrados -ge $MaxResults - 5)) {
                $tiempoTranscurrido = (Get-Date) - $inicioGlobal
                $porcentaje = [math]::Min(90, ($ArchivosEncontrados * 90 / $MaxResults))
                
                Show-ProgressBar -Activity "Buscando en $unidad" -Status "Archivos procesados" -PercentComplete $porcentaje -CurrentCount $ArchivosEncontrados -TotalCount $MaxResults -ElapsedTime $tiempoTranscurrido
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
                if ($ExportCSV -or $ExportHTML -or $ExportJSON) {
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
        
        # Actualizar progreso al completar unidad
        if (-not $NoProgress -and -not $Quiet) {
            $tiempoTranscurrido = (Get-Date) - $inicioGlobal
            $porcentajeGlobal = $unidadActual * 100 / $totalUnidades
            Show-ProgressBar -Activity "Completado $unidad" -Status "Unidad procesada" -PercentComplete $porcentajeGlobal -CurrentCount $ArchivosEncontrados -TotalCount $MaxResults -ElapsedTime $tiempoTranscurrido
            Write-Host ""  # Nueva línea después de completar unidad
        }
        
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

# Mostrar progreso final al 100%
if (-not $NoProgress -and -not $Quiet) {
    $tiempoTotal = (Get-Date) - $inicioGlobal
    Show-ProgressBar -Activity "COMPLETADO - Busqueda finalizada" -Status "Procesamiento terminado" -PercentComplete 100 -CurrentCount $TotalArchivos -TotalCount $MaxResults -ElapsedTime $tiempoTotal
    Write-Host ""
    Write-Host ""
}

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

# Generar reporte HTML si se solicitó
if ($ExportHTML -and $TotalArchivos -gt 0) {
    $ArchivoHTML = "$dirReporte\reporte_busqueda_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    try {
        Generate-HTMLReport -DatosArchivos $DatosCSV -ConteosUnidad $ConteosUnidad -TiemposUnidad $TiemposUnidad -Patron $Patron -ArchivoHTML $ArchivoHTML -TotalArchivos $TotalArchivos -TotalSize $TotalSize -TiempoTotal $tiempoTotal
        Write-Host ""
        Write-Host "🌐 Reporte HTML generado: $ArchivoHTML" -ForegroundColor Green
        Write-Host "   💡 Para abrir: start '$ArchivoHTML'" -ForegroundColor Cyan
    }
    catch {
        Write-Host ""
        Write-Host "❌ Error al generar reporte HTML: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Generar reporte JSON si se solicitó
if ($ExportJSON -and $DatosCSV.Count -gt 0) {
    $ArchivoJSON = "$dirReporte\datos_busqueda_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    try {
        Generate-JSONReport -DatosArchivos $DatosCSV -ConteosUnidad $ConteosUnidad -TiemposUnidad $TiemposUnidad -Patron $Patron -ArchivoJSON $ArchivoJSON -TotalArchivos $TotalArchivos -TotalSize $TotalSize -TiempoTotal $tiempoTotal
        Write-Host ""
        Write-Host "📄 Reporte JSON generado: $ArchivoJSON" -ForegroundColor Green
        Write-Host "   💡 Datos estructurados para análisis y API" -ForegroundColor Cyan
    }
    catch {
        Write-Host ""
        Write-Host "❌ Error al generar reporte JSON: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "¡Búsqueda completada!" -ForegroundColor Green
Write-Host "  • Informe detallado: $ArchivoReporte"

if ($ExportCSV -and $DatosCSV.Count -gt 0) {
    Write-Host "  • Datos CSV: $ArchivoCSV"
}

if ($ExportHTML -and $DatosCSV.Count -gt 0) {
    Write-Host "  • Reporte HTML: $ArchivoHTML"
}

if ($ExportJSON -and $DatosCSV.Count -gt 0) {
    Write-Host "  • Reporte JSON: $ArchivoJSON"
}