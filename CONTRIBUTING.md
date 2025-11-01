# 🤝 Contributing to Advanced File Search Scripts

¡Gracias por tu interés en contribuir! 🎉 Este proyecto está abierto a mejoras y sugerencias de la comunidad.

## 🚀 Formas de Contribuir

### 🐛 Reportar Bugs
- Usa el [sistema de Issues](https://github.com/Jshell91/advanced-file-search-scripts/issues)
- Incluye información del sistema (OS, PowerShell/Bash version)
- Proporciona pasos para reproducir el problema
- Adjunta logs o capturas si es posible

### 💡 Sugerir Mejoras
- Revisa primero los [Issues existentes](https://github.com/Jshell91/advanced-file-search-scripts/issues)
- Describe claramente la mejora propuesta
- Explica los beneficios para los usuarios
- Considera la compatibilidad con versiones existentes

### 🔧 Contribuir Código

#### Antes de empezar:
1. Fork el repositorio
2. Crea una rama para tu feature: `git checkout -b feature/nueva-funcionalidad`
3. Revisa el [CHANGELOG.md](CHANGELOG.md) para entender la dirección del proyecto

#### Estándares de código:

**Para PowerShell (.ps1):**
- Usa `PascalCase` para funciones y variables
- Incluye comentarios explicativos para lógica compleja
- Mantén compatibilidad con PowerShell 5.1+
- Usa `Write-Host` para output usuario, `Write-Verbose` para debug

**Para Bash (.sh):**
- Usa `snake_case` para variables y funciones
- Incluye `#!/bin/bash` en la primera línea
- Mantén compatibilidad con Bash 4.0+
- Usa `set -euo pipefail` para manejo de errores

#### Testing:
- Prueba en múltiples escenarios (archivos grandes, permisos, drives)
- Verifica que no rompa funcionalidad existente
- Incluye casos edge en tus pruebas

#### Commit Messages:
Usa el formato del proyecto:
```
✨ Add new feature description

📝 Details:
- Specific change 1
- Specific change 2

🧪 Testing:
- Test scenario 1
- Test scenario 2
```

## 📋 Roadmap Actual

### v2.1.0 (Próximamente)
- [ ] Filtros de fecha avanzados
- [ ] Búsqueda de contenido dentro de archivos
- [ ] Soporte para exclusiones con regex

### v3.0.0 (Futuro)
- [ ] Interfaz gráfica opcional
- [ ] API REST para integración
- [ ] Soporte para búsqueda en red

## 🛡️ Política de Seguridad

- **NO** incluyas credenciales o información sensible
- **Valida** todos los inputs de usuario
- **Maneja** errores de permisos graciosamente
- **Documenta** cualquier cambio de seguridad

## 📞 Contacto

- **Issues**: [GitHub Issues](https://github.com/Jshell91/advanced-file-search-scripts/issues)
- **Discussiones**: [GitHub Discussions](https://github.com/Jshell91/advanced-file-search-scripts/discussions)

## 🏆 Reconocimientos

Todos los contribuidores serán reconocidos en el [CHANGELOG.md](CHANGELOG.md) y en la sección de agradecimientos.

---

**¡Gracias por hacer este proyecto mejor! 🙌**