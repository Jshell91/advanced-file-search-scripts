#!/bin/bash

# Script simple para buscar archivos - equivalente al comando PowerShell
# Uso: ./buscar_simple.sh [patrón]

PATRON="${1:-*archivo*}"

echo "Buscando: $PATRON en todo el sistema..."

# Buscar en todas las unidades montadas
df -h | awk 'NR>1 {print $6}' | grep -E '^/' | while read unidad; do
    echo "Buscando en: $unidad"
    find "$unidad" -type f -name "$PATRON" 2>/dev/null
done