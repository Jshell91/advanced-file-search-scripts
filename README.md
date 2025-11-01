# 🔍 Scripts de Búsqueda de Archivos

Una colección de scripts para buscar archivos y carpetas en todo el sistema con informes detallados.

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

### **v1.0 - Funcionalidades Base** ✅
- ✅ Búsqueda básica con patrones
- ✅ Informes detallados con estadísticas
- ✅ Soporte para múltiples unidades

### **v2.0 - Filtros Avanzados (ACTUAL)** ✅  
- ✅ Filtros por tamaño, fecha y tipo
- ✅ Protecciones contra búsquedas masivas
- ✅ Control de límite de resultados
- ✅ Modo silencioso para automatización
- ✅ Export CSV para análisis
- ✅ Búsqueda en unidad específica

### **v3.0 - Próximas Funcionalidades** 🔄
- 🔄 Modo interactivo con menús
- 🔄 Export HTML con visualizaciones
- 🔄 Búsqueda por contenido de archivos
- 🔄 Configuración persistente
- 🔄 Historial de búsquedas

### **v4.0 - Funcionalidades Avanzadas** 📋
- 📋 Dashboard visual con gráficos
- 📋 Integración con Windows Explorer
- 📋 Tareas programadas automáticas
- 📋 API REST para integración

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