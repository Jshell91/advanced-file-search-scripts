# 🔍 Advanced File Search Scripts

[![Version](https://img.shields.io/badge/version-v2.0.0-blue.svg)](https://github.com/yourusername/advanced-file-search-scripts/releases)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
[![Bash](https://img.shields.io/badge/Bash-4.0%2B-green.svg)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)]()

Una colección avanzada de scripts para búsqueda inteligente de archivos con filtros sofisticados, protecciones automáticas y exportación de datos estructurados.

## 📁 Archivos incluidos:

### 1. `buscar_archivos.ps1` (Windows - PowerShell) ⭐
**Script avanzado con filtros inteligentes y protecciones**

**Uso Básico:**
```powershell
.\buscar_archivos.ps1 -Patron "*.pdf"          # Buscar archivos PDF
.\buscar_archivos.ps1 -Patron "*documento*"    # Buscar archivos con "documento"
.\buscar_archivos.ps1 -Help                    # Mostrar ayuda completa
```

**Uso Avanzado:**
```powershell
# Filtros por tamaño y fecha
.\buscar_archivos.ps1 -Patron "*.pdf" -MinSize "1MB" -MaxSize "10MB" -DateFrom "2024-01-01"

# Búsqueda en unidad específica con límite
.\buscar_archivos.ps1 -Patron "*.docx" -Drive "C:" -MaxResults 100

# Modo silencioso con export CSV
.\buscar_archivos.ps1 -Patron "*.xlsx" -Quiet -ExportCSV

# Filtros por tipos de archivo
.\buscar_archivos.ps1 -FileTypes @("pdf","docx","xlsx") -DateFrom "2024-01-01"
```

**Características Principales:**
- ✅ **Filtros avanzados**: tamaño, fecha, tipo, unidad específica
- ✅ **Protecciones inteligentes**: advertencias para patrones masivos (`*`, `*.*`)
- ✅ **Control de resultados**: límite configurable (por defecto 1000)
- ✅ **Modo silencioso**: ideal para automatización (`-Quiet`)
- ✅ **Export CSV**: análisis en Excel con columnas estructuradas
- ✅ **Búsqueda rápida**: en unidad específica o todas las unidades
- ✅ **Informes detallados**: estadísticas completas y tiempos por unidad
- ✅ **Manejo robusto de errores**: continúa ante problemas de permisos

### 2. `buscar_archivos.sh` (Linux/macOS - Bash) ⭐
**Equivalente del script principal para sistemas Unix**

**Uso:**
```bash
chmod +x buscar_archivos.sh                    # Hacer ejecutable (una sola vez)
./buscar_archivos.sh "*.jpg"                   # Buscar imágenes JPG
./buscar_archivos.sh documento                 # Buscar archivos con "documento"
./buscar_archivos.sh --help                   # Mostrar ayuda
```

**Características:**
- ✅ Búsqueda en todas las unidades montadas
- ✅ Informe completo igual que la versión Windows
- ✅ Reporte guardado en `/tmp/busqueda_[fecha_hora].log`

### 3. `buscar_simple.sh` (Linux/macOS - Versión básica)
**Script simple sin informes extras**

**Uso:**
```bash
chmod +x buscar_simple.sh
./buscar_simple.sh documento                  # Búsqueda básica
```

## 🚀 Ejemplos de uso común:

### 📁 **Búsquedas Básicas:**
```powershell
# Buscar documentos PDF
.\buscar_archivos.ps1 -Patron "*.pdf"

# Buscar archivos de video
.\buscar_archivos.ps1 -Patron "*.mp4"

# Buscar por nombre específico
.\buscar_archivos.ps1 -Patron "*presupuesto*"
```

### 🎯 **Búsquedas Filtradas:**
```powershell
# PDFs grandes creados este año
.\buscar_archivos.ps1 -Patron "*.pdf" -MinSize "5MB" -DateFrom "2024-01-01"

# Documentos pequeños en unidad C:
.\buscar_archivos.ps1 -FileTypes @("docx","xlsx","pptx") -MaxSize "1MB" -Drive "C:"

# Archivos recientes con export CSV
.\buscar_archivos.ps1 -Patron "*invoice*" -DateFrom "2024-10-01" -ExportCSV
```

### ⚡ **Búsquedas Rápidas:**
```powershell
# Modo silencioso para scripts
.\buscar_archivos.ps1 -Patron "*.log" -Quiet -MaxResults 50

# Búsqueda limitada y segura
.\buscar_archivos.ps1 -Patron "*config*" -Drive "C:" -MaxResults 100

# Solo estadísticas, sin mostrar cada archivo
.\buscar_archivos.ps1 -Patron "*.tmp" -Quiet -ExportCSV
```

## 📊 Ejemplo de salida:

```
===================================================
INFORME DE BÚSQUEDA AVANZADA DE ARCHIVOS
===================================================
Patrón de búsqueda: *.pdf
Filtros aplicados: Tamaño máximo: 10MB | Desde: 2024-01-01
Fecha y hora inicio: 11/01/2025 10:30:15
Archivo de reporte: C:\temp\busqueda_20251101_103015.log
===================================================

Unidades detectadas: C:, D:

DESGLOSE POR UNIDAD:
-------------------
C:        :    25 archivos (08:32)
D:        :    12 archivos (03:41)

RESUMEN TOTAL:
-------------
Total de archivos encontrados: 37
Tamaño total: 145,67 MB
Tamaño promedio: 3,94 MB
Unidades procesadas: 2
Tiempo total: 12:13

Archivo CSV generado: C:\temp\busqueda_20251101_103015.csv

¡Búsqueda completada!
  • Informe detallado: C:\temp\busqueda_20251101_103015.log
  • Datos CSV: C:\temp\busqueda_20251101_103015.csv
```

## 📁 Ubicación de reportes:

- **Windows:** `C:\temp\busqueda_[fecha_hora].log`
- **Linux/macOS:** `/tmp/busqueda_[fecha_hora].log`

## �️ **Parámetros Completos:**

| Parámetro | Tipo | Descripción | Ejemplo |
|-----------|------|-------------|---------|
| `-Patron` | String | Patrón de búsqueda | `"*.pdf"`, `"*factura*"` |
| `-MinSize` | String | Tamaño mínimo | `"1MB"`, `"500KB"`, `"2GB"` |
| `-MaxSize` | String | Tamaño máximo | `"10MB"`, `"1GB"` |
| `-DateFrom` | String | Fecha desde | `"2024-01-01"`, `"2024-12-25"` |
| `-DateTo` | String | Fecha hasta | `"2025-01-31"` |
| `-Drive` | String | Unidad específica | `"C:"`, `"D:"` |
| `-MaxResults` | Int | Límite de archivos | `100`, `1000` (defecto) |
| `-Quiet` | Switch | Modo silencioso | `-Quiet` |
| `-ExportCSV` | Switch | Exportar a CSV | `-ExportCSV` |
| `-FileTypes` | Array | Tipos específicos | `@("pdf","docx","xlsx")` |
| `-ExcludePaths` | Array | Excluir rutas | `@("temp","cache")` |
| `-Help` | Switch | Mostrar ayuda | `-Help` |

## 💡 Consejos y Mejores Prácticas:

### 🔍 **Patrones de Búsqueda:**
- `"*.pdf"` - Solo archivos PDF
- `"*factura*"` - Archivos que contengan "factura" 
- `"documento.*"` - Archivos que empiecen con "documento"
- `"2024*"` - Archivos que empiecen con "2024"

### ⚡ **Optimización de Rendimiento:**
- Usa `-Drive` para limitar a una unidad específica
- Usa `-MaxResults` para búsquedas rápidas
- Usa `-Quiet` para automatización y mejor velocidad
- Combina filtros de fecha y tamaño para ser más específico

### 🛡️ **Protecciones Integradas:**
- **Advertencia automática** para patrones masivos (`*`, `*.*`)
- **Límite por defecto** de 1000 archivos (configurable)
- **Manejo de errores** robusto ante problemas de permisos
- **Validación** de parámetros antes de la ejecución

## 🔧 Personalización:

Puedes modificar los scripts para:
- Cambiar la ubicación de los reportes
- Añadir más tipos de archivos
- Modificar el formato de salida
- Añadir filtros adicionales (fecha, tamaño, etc.)

---

## 🚀 **Roadmap y Versiones**

### **v2.0.0 - Filtros Avanzados (ACTUAL)** ✅  
- ✅ **Protecciones inteligentes** contra búsquedas masivas
- ✅ **Filtros sofisticados** por tamaño, fecha y tipo
- ✅ **Export CSV** para análisis profesional
- ✅ **Modo silencioso** para automatización
- ✅ **Control preciso** de límites de resultados
- ✅ **Búsqueda dirigida** por unidad específica

### **v3.0.0 - Interactividad Avanzada** 🔄 *(Q1 2026)*
- 🔄 **Modo interactivo** con menús dinámicos
- 🔄 **Export HTML** con visualizaciones gráficas  
- 🔄 **Búsqueda por contenido** de archivos
- 🔄 **Configuración persistente** con perfiles
- 🔄 **Historial inteligente** de búsquedas

### **v4.0.0 - Integración Empresarial** 📋 *(Q2 2026)*
- 📋 **Dashboard visual** con métricas en tiempo real
- 📋 **Integración Windows Explorer** con menús contextuales
- 📋 **Automatización avanzada** con tareas programadas
- 📋 **API REST** para integración con sistemas empresariales

> 📋 **Ver historial completo**: [`CHANGELOG.md`](CHANGELOG.md) - Registro detallado de todas las versiones, mejoras y estadísticas del proyecto.

---

## 📦 **Instalación Rápida**

### **Windows (PowerShell):**
```powershell
# Clonar repositorio
git clone https://github.com/yourusername/advanced-file-search-scripts.git
cd advanced-file-search-scripts

# Ejecutar directamente
.\buscar_archivos.ps1 -Help
```

### **Linux/macOS (Bash):**
```bash
# Clonar repositorio
git clone https://github.com/yourusername/advanced-file-search-scripts.git
cd advanced-file-search-scripts

# Hacer ejecutable
chmod +x buscar_archivos.sh

# Ejecutar
./buscar_archivos.sh --help
```

### **Descarga Directa:**
- 📥 [**Releases**](https://github.com/yourusername/advanced-file-search-scripts/releases) - Versiones estables
- 📋 [**CHANGELOG.md**](CHANGELOG.md) - Historial completo de versiones  
- 🛠️ [**MEJORAS_PENDIENTES.md**](MEJORAS_PENDIENTES.md) - Roadmap detallado

---

## 📄 **Licencia**
MIT License - Libre para uso personal y comercial

## 🤝 **Contribuciones**
¡Las contribuciones son bienvenidas! Por favor:
1. Fork el repositorio
2. Crea una rama para tu feature
3. Hace commit de tus cambios
4. Abre un Pull Request

## 📞 **Soporte**
- 📋 **Issues**: Reporta bugs o solicita features
- 💡 **Discussions**: Ideas y mejoras
- 📚 **Wiki**: Documentación detallada

---
*Proyecto iniciado el 31 de octubre de 2025*  
*Scripts optimizados para búsquedas exhaustivas y análisis de archivos*  
*Desarrollado con ❤️ para la comunidad PowerShell*