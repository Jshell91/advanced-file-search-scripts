#!/usr/bin/env pwsh
# 🎯 DEMOSTRACIÓN COMPLETA - Advanced File Search Scripts v2.0
# Ejecuta una serie de ejemplos para mostrar todas las capacidades del sistema

# Función para pausar entre demostraciones
function Wait-Demo {
    param([string]$Message = "Presiona Enter para continuar...")
    Write-Host $Message -ForegroundColor Yellow
    Read-Host | Out-Null
    Write-Host ""
}

Write-Host "🚀 DEMOSTRACIÓN AVANZADA DE BÚSQUEDA DE ARCHIVOS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Demo 1: Búsqueda básica
    Write-Host "📂 DEMO 1: Búsqueda básica de archivos PowerShell" -ForegroundColor Green
    Write-Host "Comando: .\buscar_archivos.ps1 -Patron '*.ps1' -MaxResults 10"
    Write-Host ""
    
    .\buscar_archivos.ps1 -Patron "*.ps1" -MaxResults 10
    Wait-Demo

    # Demo 2: Búsqueda con filtros avanzados
    Write-Host "📊 DEMO 2: Búsqueda con filtros de tamaño" -ForegroundColor Green  
    Write-Host "Comando: .\buscar_archivos.ps1 -Patron '*.md' -MinSize '1KB' -MaxResults 5"
    Write-Host ""
    
    .\buscar_archivos.ps1 -Patron "*.md" -MinSize "1KB" -MaxResults 5
    Wait-Demo

    # Demo 3: Modo silencioso con CSV
    Write-Host "📈 DEMO 3: Modo silencioso con exportación CSV" -ForegroundColor Green
    Write-Host "Comando: .\buscar_archivos.ps1 -Patron '*.md' -Quiet -ExportCSV -MaxResults 5"
    Write-Host ""
    
    .\buscar_archivos.ps1 -Patron "*.md" -Quiet -ExportCSV -MaxResults 5
    
    # Mostrar el CSV generado
    $csvFiles = Get-ChildItem -Path "C:\temp" -Filter "busqueda_*.csv" | Sort-Object CreationTime -Descending | Select-Object -First 1
    if ($csvFiles) {
        Write-Host "📋 Contenido del CSV generado:" -ForegroundColor Magenta
        Write-Host "Archivo: $($csvFiles.FullName)" -ForegroundColor Gray
        Write-Host ""
        Get-Content $csvFiles.FullName | Select-Object -First 10 | ForEach-Object { 
            Write-Host $_ -ForegroundColor White 
        }
        Write-Host "..." -ForegroundColor Gray
        Write-Host ""
    }
    Wait-Demo

    # Demo 4: Búsqueda por tipos específicos
    Write-Host "🎯 DEMO 4: Búsqueda por tipos específicos de archivos" -ForegroundColor Green
    Write-Host "Comando: .\buscar_archivos.ps1 -FileTypes @('ps1','md','txt') -MaxResults 8"
    Write-Host ""
    
    .\buscar_archivos.ps1 -FileTypes @("ps1","md","txt") -MaxResults 8
    Wait-Demo

    # Demo 5: Protección contra búsquedas masivas
    Write-Host "🛡️ DEMO 5: Protección contra búsquedas masivas" -ForegroundColor Green
    Write-Host "Comando: .\buscar_archivos.ps1 -Patron '*.*' -MaxResults 5"
    Write-Host "Nota: El sistema detectará el patrón peligroso y pedirá confirmación"
    Write-Host ""
    
    # Simular respuesta automática 'n' para no hacer búsqueda masiva real
    $userResponse = "n"
    $userResponse | .\buscar_archivos.ps1 -Patron "*.*" -MaxResults 5
    Wait-Demo

    # Demo 6: Ayuda completa
    Write-Host "📖 DEMO 6: Sistema de ayuda integrado" -ForegroundColor Green
    Write-Host "Comando: .\buscar_archivos.ps1 -Help"
    Write-Host ""
    
    .\buscar_archivos.ps1 -Help
    Wait-Demo

    # Resumen final
    Write-Host "🎉 ¡DEMOSTRACIÓN COMPLETADA!" -ForegroundColor Green
    Write-Host "=============================" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Funcionalidades demostradas:" -ForegroundColor Cyan
    Write-Host "   • Búsqueda básica con límites inteligentes"
    Write-Host "   • Filtros avanzados por tamaño y tipo"  
    Write-Host "   • Modo silencioso para automatización"
    Write-Host "   • Exportación CSV para análisis"
    Write-Host "   • Protecciones contra búsquedas masivas"
    Write-Host "   • Sistema de ayuda completo"
    Write-Host ""
    Write-Host "🔗 Repositorio: https://github.com/Jshell91/advanced-file-search-scripts" -ForegroundColor Yellow
    Write-Host "📚 Documentación completa: README.md" -ForegroundColor Yellow
    Write-Host "📋 Historial de versiones: CHANGELOG.md" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🚀 ¡Gracias por probar Advanced File Search Scripts v2.0!" -ForegroundColor Magenta

} catch {
    Write-Host "❌ Error durante la demostración: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Asegúrate de que buscar_archivos.ps1 esté en el directorio actual" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Fin de la demostración. ¡Explora más funcionalidades con -Help!" -ForegroundColor Green