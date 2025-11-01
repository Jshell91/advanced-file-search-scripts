# 🔄 Pull Request

## 📋 Descripción
<!-- Describe claramente qué cambios introduces y por qué -->

Fixes #(issue number) <!-- Si aplica, referencia el issue que resuelve -->

## 🔧 Tipo de Cambio
<!-- Marca el tipo de cambio que aplica -->

- [ ] 🐛 Bug fix (cambio que no rompe nada y arregla un problema)
- [ ] ✨ Nueva feature (cambio que no rompe nada y añade funcionalidad)  
- [ ] 💥 Breaking change (fix o feature que causa que funcionalidad existente no funcione como se espera)
- [ ] 📚 Cambio de documentación

## 🧪 Testing
<!-- Describe las pruebas que realizaste -->

### Casos Probados:
- [ ] Funcionalidad básica mantiene comportamiento esperado
- [ ] Nuevos cambios funcionan según lo esperado
- [ ] Edge cases manejados correctamente
- [ ] Compatibilidad con PowerShell 5.1+ / Bash 4.0+

### Entornos de Prueba:
- [ ] Windows PowerShell 5.1
- [ ] PowerShell 7.x
- [ ] Bash en Linux/macOS
- [ ] Casos con archivos grandes (>1000 archivos)
- [ ] Casos con permisos limitados

## 📝 Checklist
<!-- Marca todo lo que aplique antes de crear el PR -->

### Código:
- [ ] Mi código sigue el estilo del proyecto
- [ ] He realizado self-review de mi código
- [ ] He comentado áreas complejas de mi código
- [ ] Mis cambios no generan nuevos warnings
- [ ] He añadido tests que prueban mi fix o feature
- [ ] Tests nuevos y existentes pasan localmente

### Documentación:
- [ ] He actualizado la documentación según sea necesario
- [ ] He actualizado CHANGELOG.md con mis cambios
- [ ] He actualizado README.md si añadí nuevos parámetros
- [ ] Ejemplos de uso están actualizados

### Compatibilidad:
- [ ] Mis cambios mantienen compatibilidad hacia atrás
- [ ] He considerado el impacto en diferentes plataformas
- [ ] Nuevos parámetros tienen valores por defecto sensatos
- [ ] Manejo de errores es consistente con el resto del código

## 📊 Cambios Realizados
<!-- Lista específicamente qué archivos cambiaron y por qué -->

### Archivos Modificados:
- `buscar_archivos.ps1`: <!-- Describir cambios -->
- `buscar_archivos.sh`: <!-- Describir cambios -->
- `README.md`: <!-- Describir cambios -->

### Nuevos Archivos:
- <!-- Lista archivos nuevos si los hay -->

## 🔍 Capturas/Ejemplos
<!-- Si aplica, incluye capturas o ejemplos de uso -->

### Antes:
```powershell
# Comando anterior y su salida
```

### Después:
```powershell
# Comando nuevo y su salida
```

## 📋 Notas Adicionales
<!-- Cualquier información adicional para los reviewers -->

### Para los Reviewers:
- <!-- Aspectos específicos en los que enfocarse -->
- <!-- Áreas que requieren atención especial -->

### Consideraciones Futuras:
- <!-- Mejoras futuras relacionadas -->
- <!-- Refactoring que podría ser necesario -->