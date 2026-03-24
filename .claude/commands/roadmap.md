---
description: Muestra el estado actual del ROADMAP.md con porcentaje de avance
---

# /roadmap — Estado del proyecto

Leer el archivo ROADMAP.md del proyecto y calcular el estado de avance.
Mostrar los resultados directamente en el chat en formato de tabla simple.

## Paso 1: Verificar existencia

Buscar `ROADMAP.md` en la raiz del proyecto.

Si no existe, responder:

```
No se encontro ROADMAP.md en el proyecto.

Para generarlo, ejecuta la entrevista de configuracion de Kroexus.
Si el proyecto fue creado con Kroexus, el ROADMAP.md deberia existir
en la raiz. Verifica que no fue eliminado accidentalmente.
```

Y no continuar con los pasos siguientes.

## Paso 2: Parsear el roadmap

Leer ROADMAP.md y extraer:

1. **Fases**: Cada seccion `## Fase N — [Nombre]`
2. **Items por fase**: Cada linea que comienza con `- [ ]` (pendiente) o `- [x]` (completado)
3. **Calculos por fase**:
   - Total de items
   - Items completados
   - Porcentaje: `(completados / total) * 100`, redondeado a entero
4. **Calculos totales**:
   - Total global de items
   - Total global de completados
   - Porcentaje global

## Paso 3: Identificar fase actual

La fase actual es la primera fase que no esta al 100% de completitud.

Los items bloqueantes son los items incompletos (`- [ ]`) en la fase actual.

## Paso 4: Recomendar proximo item

El proximo item recomendado es el primer item incompleto de la fase actual.
Si la fase tiene una nota de "No avanzar a Fase N+1 sin completar esta fase",
mencionarlo en la recomendacion.

## Paso 5: Mostrar resultado

Imprimir en el chat:

```
--- Roadmap: [Nombre del proyecto] ---

Fase                          Avance        Estado
----                          ------        ------
Fase 1 — Fundamentos         [N]/[N]  [PP]%  [Completada / En progreso / Pendiente]
Fase 2 — Backend base        [N]/[N]  [PP]%  [Completada / En progreso / Pendiente]
Fase 3 — Frontend base       [N]/[N]  [PP]%  [Completada / En progreso / Pendiente]
Fase 4 — Integraciones       [N]/[N]  [PP]%  [Completada / En progreso / Pendiente]
Fase 5 — Listo para escalar  [N]/[N]  [PP]%  [Completada / En progreso / Pendiente]

Total: [N]/[N] items completados ([PP]%)

Fase actual: Fase [N] — [Nombre]

Items bloqueantes:
  - [item pendiente 1]
  - [item pendiente 2]
  - [item pendiente 3]

Proximo paso recomendado:
  [Primer item incompleto de la fase actual]
```

Notas:
- Solo mostrar las fases que existen en el ROADMAP.md del proyecto
- El estado es "Completada" si el porcentaje es 100%, "En progreso" si es mayor a 0%, "Pendiente" si es 0%
- Si todos los items estan completados, mostrar el mensaje: "Todas las fases completadas. El proyecto esta listo para produccion."
- No usar emojis en ninguna parte del output
