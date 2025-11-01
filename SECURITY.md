# 🛡️ Security Policy

## 📢 Supported Versions

Las siguientes versiones de nuestros scripts están actualmente soportadas con actualizaciones de seguridad:

| Version | Supported          | Notes                    |
| ------- | ------------------ | ------------------------ |
| 2.0.x   | ✅ Yes             | Versión actual           |
| 1.0.x   | ⚠️ Limited support | Solo fixes críticos     |
| < 1.0   | ❌ No              | No soportado             |

## 🚨 Reporting a Vulnerability

Si descubres una vulnerabilidad de seguridad en nuestros scripts, por favor repórtala responsablemente:

### 📧 Contacto Privado
**NO** uses el sistema público de Issues para vulnerabilidades de seguridad.

1. **Email**: Envía un email a [insertar email cuando esté disponible]
2. **GitHub Security**: Usa [GitHub Security Advisories](https://github.com/Jshell91/advanced-file-search-scripts/security/advisories/new)

### 📋 Información Requerida

Incluye en tu reporte:

- **Descripción** detallada de la vulnerabilidad
- **Pasos** para reproducir el problema
- **Impacto** potencial de la vulnerabilidad  
- **Versión** afectada del script
- **Sistema** donde fue encontrada (OS, PowerShell/Bash version)

### 🔄 Proceso de Respuesta

1. **Confirmación** (48 horas): Confirmaremos la recepción
2. **Evaluación** (1 semana): Evaluaremos la severidad y validez
3. **Fix** (2-4 semanas): Desarrollaremos y probaremos el fix
4. **Release** (1 semana): Publicaremos la versión corregida
5. **Disclosure** (después del release): Publicación coordinada

### 🏆 Reconocimiento

Los reportes válidos de seguridad serán reconocidos en:
- Sección de agradecimientos en CHANGELOG.md
- Release notes de la versión que incluya el fix
- Hall of Fame de seguridad (cuando esté disponible)

## 🔒 Mejores Prácticas de Seguridad

### Para Usuarios:
- ✅ Siempre descargar desde el repositorio oficial
- ✅ Verificar checksums cuando estén disponibles  
- ✅ Ejecutar con permisos mínimos necesarios
- ✅ Revisar parámetros antes de ejecutar
- ❌ No ejecutar en directorios con datos críticos sin pruebas
- ❌ No deshabilitar warnings de seguridad sin entender las implicaciones

### Para Desarrolladores:
- ✅ Validar todos los inputs de usuario
- ✅ Usar rutas absolutas para evitar path traversal
- ✅ Implementar rate limiting para operaciones costosas
- ✅ Manejar errores de permisos graciosamente
- ❌ No hardcodear credenciales o rutas sensibles
- ❌ No ejecutar comandos construidos con input no validado

## 🚦 Niveles de Severidad

### 🔴 Critical
- Ejecución remota de código
- Escalación de privilegios
- Acceso no autorizado a datos

### 🟡 High  
- Denial of Service local
- Path traversal vulnerabilities
- Information disclosure

### 🟢 Medium
- Input validation bypass
- Logic flaws menores

### 🔵 Low
- Mejoras de logging
- Hardening suggestions

## 🛠️ Security Features

### Protecciones Implementadas:
- ✅ **Pattern Validation**: Detecta patrones peligrosos como `*` y `*.*`
- ✅ **User Confirmation**: Requiere confirmación para búsquedas amplias
- ✅ **Permission Handling**: Manejo gracioso de errores de permisos
- ✅ **Input Sanitization**: Validación de rutas y patrones de entrada
- ✅ **Rate Limiting**: MaxResults por defecto para prevenir búsquedas masivas

### Próximas Mejoras:
- 🔄 **Path Traversal Protection**: Validación más estricta de rutas
- 🔄 **Execution Logging**: Log de operaciones para auditoría
- 🔄 **Config Validation**: Validación de archivos de configuración

---

**Fecha de última actualización**: Noviembre 2025  
**Próxima revisión**: Febrero 2026