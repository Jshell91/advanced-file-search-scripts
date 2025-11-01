#!/bin/bash

# Script para buscar archivos por patrón en todas las unidades montadas
# Equivalente al comando PowerShell:
# Get-WmiObject -Class Win32_LogicalDisk | ForEach-Object { Get-ChildItem -Path ($_.DeviceID + "\") -Recurse -Name "*archivo*" -ErrorAction SilentlyContinue }

# Función para mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 [patrón_de_búsqueda]"
    echo "Ejemplo: $0 archivo"
    echo "Ejemplo: $0 '*.pdf'"
    echo ""
    echo "Si no se proporciona un patrón, se usará '*archivo*' por defecto"
    echo "El script generará un informe detallado con tiempos y conteos por unidad"
}

# Función para formatear tiempo transcurrido
formatear_tiempo() {
    local segundos=$1
    local horas=$((segundos / 3600))
    local minutos=$(((segundos % 3600) / 60))
    local segs=$((segundos % 60))
    
    if [ $horas -gt 0 ]; then
        printf "%02d:%02d:%02d" $horas $minutos $segs
    elif [ $minutos -gt 0 ]; then
        printf "%02d:%02d" $minutos $segs
    else
        printf "%d segundos" $segs
    fi
}

# Verificar si se solicita ayuda
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    mostrar_ayuda
    exit 0
fi

# Patrón de búsqueda (por defecto "*archivo*")
PATRON="${1:-*archivo*}"

# Variables para el informe
INICIO_TOTAL=$(date +%s)
declare -A CONTEOS_UNIDAD
declare -A TIEMPOS_UNIDAD
TOTAL_ARCHIVOS=0
ARCHIVO_REPORTE="/tmp/busqueda_$(date +%Y%m%d_%H%M%S).log"

echo "==================================================="
echo "INFORME DE BÚSQUEDA DE ARCHIVOS"
echo "==================================================="
echo "Patrón de búsqueda: $PATRON"
echo "Fecha y hora inicio: $(date)"
echo "Archivo de reporte: $ARCHIVO_REPORTE"
echo "==================================================="

# Obtener todas las unidades montadas
UNIDADES=$(df -h | awk 'NR>1 {print $6}' | grep -E '^/')

# Si no hay unidades encontradas, usar rutas comunes
if [ -z "$UNIDADES" ]; then
    UNIDADES="/ /home /mnt /media"
fi

# Inicializar archivo de reporte
echo "==================================================" > "$ARCHIVO_REPORTE"
echo "INFORME DETALLADO DE BÚSQUEDA DE ARCHIVOS" >> "$ARCHIVO_REPORTE"
echo "==================================================" >> "$ARCHIVO_REPORTE"
echo "Patrón: $PATRON" >> "$ARCHIVO_REPORTE"
echo "Inicio: $(date)" >> "$ARCHIVO_REPORTE"
echo "" >> "$ARCHIVO_REPORTE"

# Buscar en cada unidad
for unidad in $UNIDADES; do
    echo ""
    echo "Procesando: $unidad"
    echo "--------------------"
    
    # Inicializar contadores para esta unidad
    CONTEOS_UNIDAD["$unidad"]=0
    INICIO_UNIDAD=$(date +%s)
    
    # Usar find para buscar archivos, suprimiendo errores
    if [ -d "$unidad" ] && [ -r "$unidad" ]; then
        echo "Unidad: $unidad" >> "$ARCHIVO_REPORTE"
        echo "Archivos encontrados:" >> "$ARCHIVO_REPORTE"
        
        while IFS= read -r -d '' archivo; do
            echo "  $archivo"
            echo "  $archivo" >> "$ARCHIVO_REPORTE"
            ((CONTEOS_UNIDAD["$unidad"]++))
            ((TOTAL_ARCHIVOS++))
        done < <(find "$unidad" -type f -name "$PATRON" -print0 2>/dev/null)
        
        # Calcular tiempo para esta unidad
        FIN_UNIDAD=$(date +%s)
        TIEMPOS_UNIDAD["$unidad"]=$((FIN_UNIDAD - INICIO_UNIDAD))
        
        echo "Archivos en $unidad: ${CONTEOS_UNIDAD["$unidad"]}"
        echo "Tiempo transcurrido: $(formatear_tiempo ${TIEMPOS_UNIDAD["$unidad"]})"
        
        # Escribir resumen de unidad al reporte
        echo "Total en esta unidad: ${CONTEOS_UNIDAD["$unidad"]} archivos" >> "$ARCHIVO_REPORTE"
        echo "Tiempo: $(formatear_tiempo ${TIEMPOS_UNIDAD["$unidad"]})" >> "$ARCHIVO_REPORTE"
        echo "" >> "$ARCHIVO_REPORTE"
    else
        echo "No se puede acceder a $unidad"
        echo "ERROR: No se puede acceder a $unidad" >> "$ARCHIVO_REPORTE"
        CONTEOS_UNIDAD["$unidad"]=0
        TIEMPOS_UNIDAD["$unidad"]=0
    fi
done

# Calcular tiempo total
FIN_TOTAL=$(date +%s)
TIEMPO_TOTAL=$((FIN_TOTAL - INICIO_TOTAL))

# Generar informe final
echo ""
echo "==================================================="
echo "INFORME FINAL"
echo "==================================================="
echo "Fecha y hora fin: $(date)"
echo "Tiempo total transcurrido: $(formatear_tiempo $TIEMPO_TOTAL)"
echo ""
echo "DESGLOSE POR UNIDAD:"
echo "-------------------"

# Mostrar estadísticas por unidad
for unidad in $UNIDADES; do
    if [[ ${CONTEOS_UNIDAD["$unidad"]} -gt 0 ]]; then
        printf "%-20s: %5d archivos (%s)\n" "$unidad" "${CONTEOS_UNIDAD["$unidad"]}" "$(formatear_tiempo ${TIEMPOS_UNIDAD["$unidad"]})"
    else
        printf "%-20s: %5d archivos (sin acceso o vacía)\n" "$unidad" "${CONTEOS_UNIDAD["$unidad"]}"
    fi
done

echo ""
echo "RESUMEN TOTAL:"
echo "-------------"
echo "Total de archivos encontrados: $TOTAL_ARCHIVOS"
echo "Unidades procesadas: $(echo $UNIDADES | wc -w)"
echo "Tiempo total: $(formatear_tiempo $TIEMPO_TOTAL)"
echo ""
echo "Reporte detallado guardado en: $ARCHIVO_REPORTE"

# Escribir resumen final al archivo de reporte
{
    echo "==================================================="
    echo "RESUMEN FINAL"
    echo "==================================================="
    echo "Fin: $(date)"
    echo "Tiempo total: $(formatear_tiempo $TIEMPO_TOTAL)"
    echo ""
    echo "ESTADÍSTICAS POR UNIDAD:"
    for unidad in $UNIDADES; do
        printf "%-20s: %5d archivos (%s)\n" "$unidad" "${CONTEOS_UNIDAD["$unidad"]}" "$(formatear_tiempo ${TIEMPOS_UNIDAD["$unidad"]})"
    done
    echo ""
    echo "TOTAL GENERAL: $TOTAL_ARCHIVOS archivos"
    echo "UNIDADES PROCESADAS: $(echo $UNIDADES | wc -w)"
    echo "TIEMPO TOTAL: $(formatear_tiempo $TIEMPO_TOTAL)"
} >> "$ARCHIVO_REPORTE"

echo ""
echo "¡Búsqueda completada! Consulta el archivo $ARCHIVO_REPORTE para el informe completo."