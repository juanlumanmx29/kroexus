---
description: Revision rapida de seguridad, dependencias y deuda tecnica
---

# /checkpoint — Revision rapida

Ejecutar una revision rapida enfocada en seguridad, dependencias y deuda tecnica.
Mas liviano que /audit. Los resultados se muestran directamente en el chat sin
generar archivos de reporte.

## Alcance

Ejecutar solo estos tres modulos:

1. **03-seguridad**: Buscar secrets expuestos, endpoints sin autenticacion, inputs sin validar, logs con datos sensibles
2. **07-dependencias**: Verificar dependencias con CVEs conocidos, licencias incompatibles, paquetes abandonados
3. **11-deuda-tecnica**: Identificar archivos excesivamente largos, funciones complejas, TODOs abandonados, codigo duplicado

## Alcance temporal

Determinar que analizar segun el ultimo checkpoint:

1. Buscar el archivo `_kroexus/.last-checkpoint` que contiene un timestamp
2. Si existe, enfocar el analisis en archivos modificados desde esa fecha. Usar:
   ```bash
   find . -newer _kroexus/.last-checkpoint -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" | grep -v node_modules | grep -v __pycache__ | grep -v .next
   ```
3. Si no existe (primer checkpoint), analizar todo el proyecto

## Ejecucion

Para cada modulo:

1. Leer las instrucciones del modulo. Buscar en este orden:
   - `_kroexus/.modules/[NN]-[nombre].md` (proyectos con install.sh)
   - `modules/[NN]-[nombre].md` (proyectos clonados directamente)
3. Ejecutar los comandos de busqueda del modulo
4. Filtrar resultados al alcance temporal definido (si aplica)
5. Clasificar hallazgos por severidad

## Output

Mostrar directamente en el chat. No generar archivos.

Solo mostrar hallazgos con severidad **Critico** o **Importante**.
Si no hay ninguno, confirmarlo explicitamente.

Formato:

```
--- Checkpoint Kroexus ---

[Si hay hallazgos:]

Seguridad:
  - [Severidad] [Nombre del hallazgo] — [ubicacion]
    [Riesgo en una linea]

Dependencias:
  - [Severidad] [Nombre del hallazgo] — [ubicacion]
    [Riesgo en una linea]

Deuda tecnica:
  - [Severidad] [Nombre del hallazgo] — [ubicacion]
    [Riesgo en una linea]

[Si no hay hallazgos Criticos ni Importantes:]

Sin hallazgos Criticos ni Importantes. El proyecto esta en buen estado.

---
Archivos analizados: [N] | Ultimo checkpoint: [fecha anterior o "primero"]
```

## Registro del checkpoint

Al finalizar, guardar el timestamp actual:

```bash
mkdir -p _kroexus
date -u +"%Y-%m-%dT%H:%M:%SZ" > _kroexus/.last-checkpoint
```

Esto permite que el proximo checkpoint se enfoque solo en los cambios nuevos.
