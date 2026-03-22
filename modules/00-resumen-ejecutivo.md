# Resumen ejecutivo — Modulo Kroexus

## Objetivo

Leer todos los reportes de auditoria generados en `_kroexus/` y producir un
resumen ejecutivo con el estado de salud del proyecto, hallazgos priorizados
y tabla de proximos pasos.

## Instrucciones

Este modulo se ejecuta siempre al final, despues de todos los demas modulos.
No ejecutar antes de que los reportes individuales esten escritos.

## Paso 1: Leer todos los reportes

```bash
ls _kroexus/*.md | grep -v ".modules" | grep -v "00-resumen"
```

Leer cada archivo encontrado y extraer todos los hallazgos. Cada hallazgo tiene:
- Nombre
- Severidad (Critico, Importante, Mejora)
- Ubicacion
- Riesgo
- Solucion
- Esfuerzo

## Paso 2: Calcular estado de salud

Contar hallazgos por severidad:

| Condicion | Estado |
|-----------|--------|
| 0 Criticos Y menos de 3 Importantes | **Verde** |
| 1-2 Criticos O 3 o mas Importantes | **Amarillo** |
| 3 o mas Criticos | **Rojo** |

## Paso 3: Priorizar hallazgos

Ordenar todos los hallazgos con este criterio:

1. Primero por severidad: Critico > Importante > Mejora
2. Dentro de la misma severidad, por menor esfuerzo primero
   (30 min > 2 horas > 1 dia > 1 semana)

Seleccionar los 5 hallazgos mas urgentes de esta lista ordenada.

## Paso 4: Generar tabla de proximos pasos

Para cada uno de los 5 hallazgos mas urgentes, crear una fila en la tabla
de proximos pasos:

| Que hacer | Modulo de origen | Esfuerzo | Impacto si no se resuelve |
|-----------|-----------------|----------|--------------------------|
| [Solucion resumida] | [NN-nombre] | [esfuerzo] | [riesgo resumido] |

## Paso 5: Escribir el resumen

Generar el archivo `_kroexus/00-resumen-ejecutivo.md` con esta estructura:

```markdown
# Resumen ejecutivo — Auditoria Kroexus

Fecha: [fecha actual YYYY-MM-DD]
Proyecto: [nombre del proyecto o directorio]

## Estado de salud: [Verde / Amarillo / Rojo]

| Severidad | Cantidad |
|-----------|----------|
| Critico | [N] |
| Importante | [N] |
| Mejora | [N] |
| **Total** | **[N]** |

## Modulos ejecutados

| Modulo | Hallazgos | Estado |
|--------|-----------|--------|
| 01-arquitectura | [N] Critico, [N] Importante, [N] Mejora | [ejecutado/saltado] |
| 02-frontend-dna | [N] Critico, [N] Importante, [N] Mejora | [ejecutado/saltado] |
| ... | ... | ... |

## Los 5 hallazgos mas urgentes

### 1. [Nombre del hallazgo]
**Severidad**: [Critico/Importante]
**Modulo**: [NN-nombre]
**Ubicacion**: [ruta/archivo:linea]
**Riesgo**: [que puede pasar]
**Solucion**: [accion concreta]
**Esfuerzo**: [tiempo]

### 2. [Nombre del hallazgo]
...

### 3. [Nombre del hallazgo]
...

### 4. [Nombre del hallazgo]
...

### 5. [Nombre del hallazgo]
...

## Proximos pasos

| Que hacer | Modulo | Esfuerzo | Impacto si no se resuelve |
|-----------|--------|----------|--------------------------|
| [accion 1] | [modulo] | [tiempo] | [riesgo] |
| [accion 2] | [modulo] | [tiempo] | [riesgo] |
| [accion 3] | [modulo] | [tiempo] | [riesgo] |
| [accion 4] | [modulo] | [tiempo] | [riesgo] |
| [accion 5] | [modulo] | [tiempo] | [riesgo] |

## Deuda tecnica acumulada

Esfuerzo total estimado para resolver todos los hallazgos:
- Criticos: [N] horas
- Importantes: [N] horas
- Mejoras: [N] horas
- **Total**: [N] horas

## Recomendacion

[Una recomendacion final de 2-3 lineas basada en el estado de salud.
Si es Verde: confirmar buen estado y sugerir mantener con /checkpoint periodicos.
Si es Amarillo: identificar el area mas critica y recomendar resolverla primero.
Si es Rojo: recomendar detener el desarrollo de features y resolver Criticos primero.]
```

## Output file

_kroexus/00-resumen-ejecutivo.md
