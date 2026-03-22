# Entrevista de configuracion — Kroexus

## Instrucciones para Claude Code

Este archivo se activa automaticamente cuando se detecta un proyecto nuevo
(ver logica de deteccion en CLAUDE.md). Seguir estas instrucciones paso a paso.

---

## Paso 1: Presentacion

Decir al usuario:

> Voy a hacerte algunas preguntas para configurar el proyecto correctamente.
> Responde con naturalidad. Al terminar, genero la estructura del proyecto,
> el roadmap y los archivos base.

---

## Paso 2: Preguntas

Hacer las siguientes preguntas una a la vez. Esperar la respuesta del usuario
antes de hacer la siguiente pregunta.

### Pregunta 1: Nombre del proyecto
> Como se llama el proyecto?

Guardar como `NOMBRE`. Se usara para nombrar carpetas y documentos.

### Pregunta 2: Descripcion
> Describilo en una linea: que hace y para quien?

Guardar como `DESCRIPCION`.

### Pregunta 3: Stack principal
> Que stack vas a usar? Opciones:
> 1. FastAPI + React
> 2. Next.js fullstack
> 3. Solo FastAPI (sin frontend)
> 4. Otro (describir)

Guardar como `STACK`. Si elige "Otro", preguntar que tecnologias usara y mapear
al stack mas cercano. Si no mapea a ninguno, usar `generic`.

Mapeo de respuestas a archivos de stack:
- Opcion 1 o menciona FastAPI con React/Vue/Angular: `fastapi-react.md`
- Opcion 2 o menciona Next.js: `nextjs.md`
- Opcion 3 o menciona solo FastAPI/Django/Flask sin frontend: `fastapi-only.md`
- Opcion 4 o cualquier otro caso: `generic.md`

### Pregunta 4: Integraciones externas
> Vas a integrar APIs de terceros? Por ejemplo: pagos (Stripe, WebPay),
> email (SendGrid, SES), mapas, IA, GDS, u otros servicios externos.

Guardar como `INTEGRACIONES`. Si no hay, guardar como "Ninguna".

### Pregunta 5: Datos personales
> El proyecto maneja datos personales de usuarios? Nombre, RUT, email,
> ubicacion, datos financieros, datos de salud.

Guardar como `DATOS_PERSONALES` (si/no).

### Pregunta 6: Equipo externo
> Va a haber desarrolladores externos trabajando en modulos del proyecto?

Guardar como `EQUIPO_EXTERNO` (si/no).

### Pregunta 7: Fecha de entrega
> Tiene fecha de entrega definida? Si la tiene, cual es?

Guardar como `FECHA_ENTREGA`. Si no tiene, guardar como "Sin fecha definida".

---

## Paso 3: Generar PROJECT.md

Crear el archivo `PROJECT.md` en la raiz del proyecto con este formato exacto:

```
# [NOMBRE] — Ficha del proyecto

Nombre: [NOMBRE]
Descripcion: [DESCRIPCION]
Stack: [STACK]
Integraciones: [INTEGRACIONES o "Ninguna"]
Datos personales: [si/no]
Equipo externo: [si/no]
Fecha de entrega: [FECHA_ENTREGA o "Sin fecha definida"]
Kroexus inicializado: [fecha actual en formato YYYY-MM-DD]
```

---

## Paso 4: Generar ROADMAP.md

Crear el archivo `ROADMAP.md` en la raiz del proyecto usando la plantilla base
y aplicando las reglas de adaptacion segun las respuestas.

### Plantilla base

```markdown
# [NOMBRE] — Roadmap

[DESCRIPCION] | Stack: [STACK] | Inicio: [fecha actual YYYY-MM-DD]

## Fase 1 — Fundamentos
No avanzar a Fase 2 sin completar esta fase.

- [ ] Estructura de carpetas definida y documentada
- [ ] .env.example con todas las variables necesarias documentadas
- [ ] .gitignore configurado (node_modules, .env, __pycache__, _kroexus)
- [ ] README.md con instrucciones de setup local
- [ ] Decisiones de arquitectura documentadas en PROJECT.md
```

### Regla: Si DATOS_PERSONALES es "si"

Agregar al final de Fase 1:
```markdown
- [ ] Politica de retencion de datos definida y documentada
- [ ] Mecanismo de eliminacion de datos de usuario disenado
```

### Continuacion de la plantilla

```markdown
## Fase 2 — Backend base

- [ ] Servidor corriendo localmente sin errores
- [ ] Autenticacion implementada
- [ ] Primer endpoint de negocio funcionando
- [ ] /docs deshabilitado para produccion
- [ ] Tests del flujo critico principal
- [ ] Manejo de errores centralizado
```

### Regla: Si STACK incluye frontend

Agregar la Fase 3 completa:
```markdown
## Fase 3 — Frontend base

- [ ] Proyecto inicializado con el stack definido
- [ ] Design tokens definidos (colores, tipografia, espaciado)
- [ ] Cliente HTTP centralizado con timeout y manejo de errores
- [ ] Primera pantalla conectada al API real (sin mock data)
- [ ] Estados cubiertos: carga, error, vacio, datos
```

Si no incluye frontend, omitir Fase 3 completamente.

### Regla: Si INTEGRACIONES no es "Ninguna"

Agregar la Fase 4. Crear una seccion por cada integracion mencionada:
```markdown
## Fase 4 — Integraciones externas

### [Nombre de la integracion]
- [ ] Credenciales en variables de entorno
- [ ] Timeout configurado explicitamente
- [ ] Rate limiting implementado
- [ ] Retry logic con exponential backoff
- [ ] Fallback definido: que hace la app si esta integracion falla
- [ ] Logging de errores de integracion
```

Repetir el bloque de items para cada integracion. Si no hay integraciones,
omitir Fase 4 completamente.

### Continuacion: Fase final

```markdown
## Fase 5 — Listo para escalar

- [ ] /checkpoint corrido sin hallazgos Criticos
- [ ] /audit corrido sin hallazgos Criticos
- [ ] Todas las variables de entorno de produccion documentadas
- [ ] Paginacion implementada en todos los endpoints de colecciones
- [ ] Observabilidad basica: logging estructurado en flujos criticos
```

### Regla: Si EQUIPO_EXTERNO es "si"

Agregar al final de Fase 5:
```markdown
- [ ] /tentacle ejecutado y template de repositorio externo generado
- [ ] CONTRATO.md revisado y aprobado
```

### Regla: Si DATOS_PERSONALES es "si"

Agregar al final de Fase 5:
```markdown
- [ ] Revision de compliance completada (modulo 09 de /audit sin hallazgos Criticos)
- [ ] Mecanismo de eliminacion de datos de usuario implementado y probado
```

### Regla: Si FECHA_ENTREGA tiene una fecha definida

Agregar esta nota al inicio del ROADMAP.md, debajo de la linea de descripcion:
```markdown
Fecha de entrega: [FECHA_ENTREGA] — Priorizar items criticos en cada fase.
```

---

## Paso 5: Cargar configuracion del stack

Leer el archivo de stack correspondiente de `init/stacks/`:

- FastAPI + React: leer `init/stacks/fastapi-react.md`
- Next.js: leer `init/stacks/nextjs.md`
- Solo FastAPI: leer `init/stacks/fastapi-only.md`
- Otro/generico: leer `init/stacks/generic.md`

Ejecutar todas las instrucciones del archivo de stack: crear carpetas, generar
archivos base, configurar el entorno.

---

## Paso 6: Mensaje final

Al terminar, informar al usuario:

> Proyecto configurado. Archivos generados:
>
> - PROJECT.md — Ficha del proyecto
> - ROADMAP.md — Roadmap con [N] fases
> - Estructura de carpetas del stack [STACK]
> - Archivos base generados
>
> Revisa ROADMAP.md para ver los pasos a seguir. Empieza por la Fase 1.
> Cuando quieras verificar el estado del proyecto, usa /checkpoint o /roadmap.
