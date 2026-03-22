# Kroexus — Instrucciones de construcción para Claude Code

## Contexto

Kroexus es un sistema de inteligencia de proyectos que vive en GitHub y se usa
desde Claude Code. Tiene dos modos de operación:

- **Modo inicio**: se clona para comenzar un proyecto nuevo desde cero
- **Modo auditoría**: se instala en un proyecto existente via script

El objetivo es que cualquier proyecto que use Kroexus sea seguro, escalable,
bien diseñado y consistente — independientemente del stack o del equipo.

---

## Lo que debes construir

Un repositorio Git completo con la siguiente estructura:

```
kroexus/
├── CLAUDE.md
├── README.md
├── install.sh
├── init/
│   ├── entrevista.md
│   └── stacks/
│       ├── fastapi-react.md
│       ├── nextjs.md
│       ├── fastapi-only.md
│       └── generic.md
├── commands/
│   ├── audit.md
│   ├── checkpoint.md
│   ├── tentacle.md
│   └── roadmap.md
└── modules/
    ├── 00-resumen-ejecutivo.md
    ├── 01-arquitectura.md
    ├── 02-frontend-dna.md
    ├── 03-seguridad.md
    ├── 04-performance.md
    ├── 05-observabilidad.md
    ├── 06-tests.md
    ├── 07-dependencias.md
    ├── 08-escalabilidad.md
    ├── 09-compliance.md
    ├── 10-resiliencia.md
    ├── 11-deuda-tecnica.md
    ├── 12-api-contrato.md
    └── 13-costos.md
```

Construye todos los archivos con contenido completo y funcional.
No dejes placeholders ni TODOs — cada archivo debe estar listo para usar.

---

## Archivo 1: CLAUDE.md

Este es el archivo más importante. Se copia a todos los proyectos que usen
Kroexus y define cómo se comporta Claude Code en cualquiera de ellos.

Debe contener exactamente estas secciones:

### Reglas de comportamiento (no negociables)

- Sin emojis en ningún output: ni en código, ni comentarios, ni documentación,
  ni respuestas en el chat
- Sin color morado en archivos de estilos (CSS, Tailwind, tokens). Esto incluye
  #7B2FBE, #6B21A8, #9333EA, purple, violet y cualquier variante
- Sin gradientes CSS en ningún componente de interfaz
- Verificar ortografía y tildes en todo texto en español antes de escribir.
  Esto aplica a comentarios, documentación, nombres de variables descriptivos
  y cualquier string visible al usuario
- Al aprobar un plan, ejecutar todos los pasos siguientes sin interrupciones
  ni confirmaciones intermedias
- No preguntar al usuario en pasos intermedios de una tarea aprobada.
  Si hay ambigüedad, elegir la opción más conservadora, ejecutar y documentar
  la decisión tomada al final del resumen
- Nunca inventar datos de ejemplo (mock data). Si se necesitan datos para
  demostrar algo, usar datos reales del proyecto o dejar el componente
  con sus estados de carga y error implementados

### Reglas técnicas universales

Estas reglas aplican a todo código generado en cualquier proyecto:

**Seguridad**
- Nunca escribir secrets, API keys ni passwords en el código.
  Siempre usar variables de entorno y documentarlas en .env.example
- Toda llamada HTTP a servicios externos debe tener timeout explícito.
  Nunca dejar timeout por defecto o sin definir
- En FastAPI, deshabilitar /docs y /redoc en entornos de producción
- Todo input de usuario debe ser validado antes de procesarse
- Nunca loggear datos sensibles: passwords, tokens, datos personales,
  números de tarjeta, RUT

**Escalabilidad**
- Toda consulta a base de datos sobre colecciones debe tener paginación.
  Nunca retornar listas sin límite
- Las llamadas a APIs externas dentro de loops deben tener rate limiting
  y exponential backoff
- El estado de la aplicación no debe vivir en memoria del servidor si el
  proyecto puede tener múltiples instancias

**Calidad**
- Antes de instalar una dependencia nueva: verificar licencia, fecha del
  último commit y número de mantenedores activos
- Todo endpoint nuevo debe quedar documentado en _kroexus/12-api-contrato.md
- Los errores deben manejarse explícitamente. Nunca usar bare except o
  catch genérico sin logging

### Comandos disponibles

Una vez que Kroexus está instalado en un proyecto, estos comandos están
disponibles en Claude Code:

- `/audit` — auditoría completa de las 10 dimensiones
- `/checkpoint` — revisión rápida de seguridad y deuda en lo construido hasta ahora
- `/tentacle` — genera el repo template para un desarrollador externo
- `/roadmap` — muestra el estado actual del ROADMAP.md con porcentaje de avance

---

## Archivo 2: README.md

Documentación del repositorio. Debe cubrir:

- Qué es Kroexus en dos párrafos, sin tecnicismos
- Dos modos de uso con instrucciones exactas:

  **Proyecto nuevo:**
  ```bash
  git clone https://github.com/[usuario]/kroexus nombre-proyecto
  cd nombre-proyecto
  rm -rf .git && git init
  claude
  ```
  Al abrir Claude Code, detecta automáticamente que es un proyecto nuevo
  y activa la entrevista de configuración.

  **Proyecto existente:**
  ```bash
  cd tu-proyecto
  curl -s https://raw.githubusercontent.com/[usuario]/kroexus/main/install.sh | bash
  ```

- Lista de comandos disponibles y qué hace cada uno
- Nota sobre el CLAUDE.md: qué es y por qué no debe modificarse sin razón

---

## Archivo 3: install.sh

Script bash que instala Kroexus en un proyecto existente.

Lo que debe hacer:
1. Detectar que se está ejecutando desde la raíz de un proyecto
   (verificar que existe al menos un archivo de código o package.json o
   pyproject.toml)
2. Descargar CLAUDE.md desde el repo y copiarlo a la raíz del proyecto.
   Si ya existe un CLAUDE.md, hacer backup como CLAUDE.md.bak antes de
   reemplazar
3. Crear carpeta .claude/commands/ si no existe
4. Descargar los archivos de commands/ y copiarlos a .claude/commands/
5. Crear carpeta _kroexus/ si no existe
6. Agregar _kroexus/ al .gitignore si no está ya incluido
7. Imprimir un resumen de lo que instaló y los comandos disponibles

El script debe ser idempotente: correrlo dos veces no debe romper nada
ni duplicar entradas.

---

## Archivo 4: init/entrevista.md

Este archivo define la entrevista que Claude Code corre automáticamente
cuando detecta que es un proyecto nuevo (no hay código existente, solo
los archivos de Kroexus).

La detección ocurre en CLAUDE.md: si el directorio actual contiene
CLAUDE.md pero no contiene src/, app/, ni archivos .py/.ts/.tsx fuera
de configuración, activar este modo.

La entrevista debe:

1. Presentarse brevemente: "Voy a hacerte algunas preguntas para configurar
   el proyecto correctamente. Responde con naturalidad."

2. Hacer estas preguntas en secuencia (una a la vez, esperar respuesta):
   - Nombre del proyecto
   - Descripción en una línea: qué hace y para quién
   - Stack principal (ofrecer opciones: FastAPI + React, Next.js fullstack,
     solo FastAPI, otro)
   - Integraciones externas: APIs de terceros, pagos, email, GDS, etc.
   - Maneja datos personales de usuarios? (nombre, RUT, email, ubicación,
     datos financieros)
   - Habrá desarrolladores externos trabajando en módulos del proyecto?
   - Tiene fecha de entrega definida o es greenfield sin presión de tiempo?

3. Con las respuestas, generar dos archivos:

   **ROADMAP.md** en la raíz del proyecto — ver especificación abajo

   **PROJECT.md** en la raíz — ficha del proyecto:
   ```
   Nombre: [nombre]
   Descripción: [descripción]
   Stack: [stack]
   Integraciones: [lista]
   Datos personales: sí/no
   Equipo externo: sí/no
   Fecha de entrega: [fecha o "sin fecha definida"]
   Kroexus inicializado: [fecha]
   ```

4. Cargar el archivo de stack correspondiente de init/stacks/ y ejecutar
   la configuración inicial definida ahí

### Especificación del ROADMAP.md generado

El roadmap tiene fases fijas pero los ítems dentro de cada fase se
adaptan según las respuestas de la entrevista.

Reglas de adaptación:
- Si maneja datos personales: agregar ítems de compliance en Fase 1 y Fase 5
- Si tiene integraciones externas: agregar fase específica de integraciones
  con ítems de resiliencia para cada una
- Si habrá equipo externo: agregar ítem de generación de tentáculo en Fase 5
- Si tiene fecha de entrega: agregar nota de prioridad en cada fase

Estructura base del ROADMAP.md:

```markdown
# [Nombre del proyecto] — Roadmap

[descripción] | Stack: [stack] | Inicio: [fecha]

## Fase 1 — Fundamentos
No avanzar a Fase 2 sin completar esta fase.

- [ ] Estructura de carpetas definida y documentada
- [ ] .env.example con todas las variables necesarias documentadas
- [ ] .gitignore configurado (node_modules, .env, __pycache__, _kroexus)
- [ ] README.md con instrucciones de setup local
- [ ] Decisiones de arquitectura documentadas en PROJECT.md
[+ ítems de compliance si aplica]

## Fase 2 — Backend base

- [ ] Servidor corriendo localmente sin errores
- [ ] Autenticación implementada
- [ ] Primer endpoint de negocio funcionando
- [ ] /docs deshabilitado para producción
- [ ] Tests del flujo crítico principal
- [ ] Manejo de errores centralizado

## Fase 3 — Frontend base
[solo si el stack incluye frontend]

- [ ] Proyecto inicializado con el stack definido
- [ ] Design tokens definidos (colores, tipografía, espaciado)
- [ ] Cliente HTTP centralizado con timeout y manejo de errores
- [ ] Primera pantalla conectada al API real (sin mock data)
- [ ] Estados cubiertos: carga, error, vacío, datos

## Fase 4 — Integraciones externas
[solo si hay integraciones, una sección por integración]

Por cada integración:
- [ ] Credenciales en variables de entorno
- [ ] Timeout configurado explícitamente
- [ ] Rate limiting implementado
- [ ] Retry logic con exponential backoff
- [ ] Fallback definido: qué hace la app si esta integración falla
- [ ] Logging de errores de integración

## Fase 5 — Listo para escalar

- [ ] /checkpoint corrido sin hallazgos Críticos
- [ ] /audit corrido sin hallazgos Críticos
- [ ] Todas las variables de entorno de producción documentadas
- [ ] Paginación implementada en todos los endpoints de colecciones
- [ ] Observabilidad básica: logging estructurado en flujos críticos
[+ generación de tentáculo si hay equipo externo]
[+ revisión de compliance si maneja datos personales]
```

---

## Archivo 5: init/stacks/fastapi-react.md

Define la configuración inicial para proyectos FastAPI + React.

Debe especificar:

**Estructura de carpetas a crear:**
```
[nombre-proyecto]/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   └── routes/
│   │   ├── core/
│   │   │   ├── config.py
│   │   │   └── security.py
│   │   ├── models/
│   │   ├── services/
│   │   └── main.py
│   ├── tests/
│   ├── .env.example
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── api/
│   │   │   └── client.ts
│   │   ├── components/
│   │   ├── design-system/
│   │   │   └── tokens.css
│   │   └── pages/
│   └── package.json
└── ROADMAP.md
```

**Archivos base a generar:**

backend/app/main.py — FastAPI con:
- CORS configurado (origins desde variable de entorno, no hardcoded)
- /docs y /redoc deshabilitados en producción (leer de variable ENVIRONMENT)
- Health check en GET /health que retorna version y timestamp
- Manejo de errores centralizado

backend/app/core/config.py — Settings con Pydantic BaseSettings:
- Todas las configuraciones desde variables de entorno
- Sin ningún valor sensible hardcodeado

backend/.env.example — con todas las variables necesarias documentadas

frontend/src/api/client.ts — cliente HTTP con:
- Base URL desde variable de entorno
- Timeout explícito de 10 segundos por defecto
- Manejo centralizado de errores
- Headers de autenticación

frontend/src/design-system/tokens.css — CSS custom properties base:
- Paleta de colores (sin morado ni gradientes)
- Escala tipográfica
- Escala de espaciado
- Radios de borde

---

## Archivo 6: init/stacks/nextjs.md, fastapi-only.md, generic.md

Mismo formato que fastapi-react.md pero adaptado a cada stack.

nextjs.md: estructura de App Router, configuración de API routes,
middleware de autenticación, variables de entorno con prefijo NEXT_PUBLIC_.

fastapi-only.md: solo el backend, sin carpeta frontend. Incluir estructura
para documentación del API como sustituto.

generic.md: estructura mínima universal. Solo los archivos que aplican
a cualquier stack: .env.example, .gitignore, README.md, estructura de
carpetas básica.

---

## Archivo 7: commands/audit.md

Comando /audit — auditoría completa.

Este archivo define exactamente qué hace Claude Code cuando el usuario
ejecuta /audit.

Lógica:

1. Detectar el stack del proyecto (mismo mecanismo que el orquestador
   principal)

2. Determinar qué módulos ejecutar según el stack y el contenido del
   proyecto. Reglas:
   - Sin frontend detectado: saltar módulo 02
   - Sin integraciones externas detectadas: módulo 10 en modo básico
   - Con datos personales detectados: módulo 09 obligatorio en modo estricto
   - Con archivos de migración o scripts de seed: módulo 03 con foco en
     vector de ataque saliente

3. Ejecutar módulos en orden numérico. El módulo 00 siempre último.

4. Antes de ejecutar cada módulo, leer su archivo correspondiente en
   modules/ y seguir sus instrucciones exactamente.

5. Escribir el output de cada módulo en _kroexus/[NN]-[nombre].md

6. Al finalizar todos los módulos, ejecutar módulo 00 para generar el
   resumen ejecutivo.

7. Imprimir al usuario:
   - Estado de salud del proyecto (Verde / Amarillo / Rojo)
   - Número de hallazgos por severidad
   - Los 3 hallazgos más urgentes
   - Ruta a _kroexus/ para ver el reporte completo

---

## Archivo 8: commands/checkpoint.md

Comando /checkpoint — revisión rápida durante el desarrollo.

Más liviano que /audit. Corre solo tres módulos: seguridad (03),
dependencias (07) y deuda técnica (11).

Enfocado en lo construido desde el último checkpoint o desde el inicio
si es el primero.

Output: lista directa en el chat (no genera archivos) con los hallazgos
Críticos e Importantes encontrados. Si no hay ninguno, confirmarlo
explícitamente.

---

## Archivo 9: commands/tentacle.md

Comando /tentacle — genera repo template para desarrollador externo.

Este comando es el equivalente al pulpo-skill ya construido, pero
integrado en Kroexus.

Debe seguir exactamente la misma lógica del pulpo-skill:
1. Extraer tokens de diseño reales del proyecto
2. Inventariar componentes y clasificarlos
3. Detectar patrones de llamadas al API
4. Generar _kroexus/_tentaculo/ con el template completo
5. Generar README.md, CONTRATO.md y CONTEXTO.md para Claude Code

La sección "Tu misión" del README generado debe quedar en blanco con
una nota clara: "[COMPLETAR: describir el módulo específico que debe
construir este desarrollador]"

---

## Archivo 10: commands/roadmap.md

Comando /roadmap — estado actual del proyecto.

Lee ROADMAP.md del proyecto y calcula:
- Porcentaje de completitud por fase
- Porcentaje de completitud total
- Ítems bloqueantes: los incompletos en la fase actual que impiden avanzar
- Próximo ítem recomendado para trabajar ahora

Muestra el resultado en el chat en formato de tabla simple, sin emojis.

Si no existe ROADMAP.md en el proyecto, ofrecer correr la entrevista
de init para generarlo.

---

## Archivos 11-24: modules/

Cada módulo sigue este formato estándar sin excepción:

```markdown
# [Nombre] — Módulo Kroexus

## Objetivo
Una línea.

## Qué buscar
Comandos bash exactos para encontrar los hallazgos.
Patrones de código a identificar.

## Cómo analizar
Qué significa cada hallazgo.
Cómo distinguir falso positivo de riesgo real.
Criterios de severidad para este módulo específico.

## Soluciones de referencia
Código o configuración exacta para los hallazgos más comunes.
Estas son plantillas — siempre adaptar al proyecto real.

## Formato de output
Cada hallazgo usa exactamente esta estructura:

### [Nombre del hallazgo]
**Severidad**: Crítico / Importante / Mejora
**Ubicación**: ruta/archivo.py:línea (o "global" si aplica a todo el proyecto)
**Riesgo**: qué puede ocurrir si no se resuelve
**Solución**: código o configuración exacta para este proyecto
**Esfuerzo**: 30 min / 2 horas / 1 día / 1 semana

## Output file
_kroexus/[NN]-[nombre].md
```

### Contenido específico por módulo

Construye cada módulo con instrucciones concretas y profundas.
A continuación los focos clave de cada uno:

**01-arquitectura**: mapear el sistema real — qué hace cada carpeta,
cómo fluyen los datos entre capas, qué llama a qué. Identificar
acoplamiento fuerte entre módulos que debería ser desacoplado.

**02-frontend-dna**: extraer tokens reales del proyecto y generar el
template de tentáculo. Ver lógica completa del pulpo-skill.

**03-seguridad**: dos vectores obligatorios.
Vector 1 (sistema como víctima): secretos hardcodeados, endpoints sin
autenticación, /docs expuesto, CORS abierto con credenciales, rate limiting
ausente, inputs sin validar, logs con datos sensibles, dependencias con CVEs.
Vector 2 (sistema como atacante involuntario): loops con llamadas HTTP sin
throttling, clientes sin timeout, scripts de migración sin límite de velocidad,
webhooks sin validación de firma.
Cada hallazgo incluye el código exacto del proyecto donde se encontró.

**04-performance**: queries N+1 (buscar patrones de consulta dentro de loops),
endpoints que retornan colecciones sin paginación, llamadas síncronas que
podrían ser async, assets frontend sin optimizar, ausencia de índices en
campos usados frecuentemente en filtros.

**05-observabilidad**: presencia de logging estructurado vs print(), manejo
de excepciones que silencia errores, ausencia de health checks, ausencia de
alertas en flujos críticos, trazabilidad entre servicios.

**06-tests**: identificar las tres funciones o rutas más críticas del proyecto
y verificar si tienen tests. Distinguir tests que prueban comportamiento real
vs tests que solo verifican que el código corre. Ausencia total de tests de
integración.

**07-dependencias**: para cada dependencia en requirements.txt o package.json,
verificar: fecha del último release, número de issues abiertos, si tiene un
solo mantenedor, si tiene CVEs conocidos, si la licencia es compatible con
uso comercial. Priorizar las que tienen acceso a red o datos.

**08-escalabilidad**: estado en memoria del servidor, ausencia de paginación,
configuraciones hardcodeadas que limitan la escala (número de workers, tamaño
de pool de conexiones), diseño que asume una sola instancia del servidor.

**09-compliance**: datos personales sin política de retención documentada,
logs que guardan PII, endpoints que exponen datos de terceros sin anonimizar,
ausencia de mecanismo para eliminar datos de un usuario, transferencia de datos
a servicios externos sin documentar.

**10-resiliencia**: para cada integración externa detectada, verificar si existe:
timeout explícito, retry logic, circuit breaker o fallback, logging de fallos.
Qué hace la aplicación si esa integración no responde — colapsa o degrada.

**11-deuda-tecnica**: síntesis de patrones repetidos encontrados en módulos
anteriores. Código duplicado, inconsistencias de naming, archivos con más de
300 líneas, funciones con más de 50 líneas, TODOs y FIXMEs abandonados.

**12-api-contrato**: para cada endpoint detectado, documentar: método HTTP,
ruta, autenticación requerida, parámetros de entrada con tipos, estructura
de respuesta exitosa, posibles errores. Formato legible para humanos,
no Swagger técnico.

**13-costos**: estimar costo operativo mensual según el stack. Considerar:
hosting de backend y frontend, base de datos, llamadas a APIs de terceros
(con sus precios por llamada), modelos de IA si aplica, servicios de email,
almacenamiento. Presentar escenario mínimo y escenario con 10x el uso actual.

**00-resumen-ejecutivo**: leer todos los archivos en _kroexus/ y calcular:
estado de salud (Verde/Amarillo/Rojo según criterios: Verde = 0 Críticos y
menos de 3 Importantes, Amarillo = 1-2 Críticos o 3+ Importantes, Rojo = 3+
Críticos), los 5 hallazgos más urgentes priorizados por severidad y menor
esfuerzo, tabla de próximos pasos con qué hacer, módulo de origen, esfuerzo
estimado e impacto si no se resuelve.

---

## Reglas de construcción

Estas reglas aplican a todo lo que construyas en este proyecto:

- Sin emojis en ningún archivo
- Sin color morado en ningún ejemplo de CSS o tokens
- Sin gradientes en ningún ejemplo de código
- Ortografía y tildes correctas en todo texto en español
- Sin mock data — si un archivo necesita datos de ejemplo, usar
  estructuras vacías o comentarios que expliquen qué va ahí
- Cada archivo debe estar completo y funcional. Sin placeholders,
  sin TODOs, sin "aquí va el contenido"
- Al aprobar este plan, construir todo sin interrupciones

---

## Instrucciones finales

1. Antes de empezar, presenta el plan de construcción: lista de archivos
   en orden de creación con una línea de descripción cada uno

2. Al aprobar el plan, construir todos los archivos en secuencia sin
   pausas ni confirmaciones intermedias

3. Al terminar, presentar un resumen de lo construido y las instrucciones
   para subir el repo a GitHub y probarlo en un proyecto real
