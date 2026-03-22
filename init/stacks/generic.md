# Stack: Generico — Configuracion inicial

## Instrucciones para Claude Code

Este archivo se ejecuta automaticamente despues de la entrevista de configuracion
cuando el stack elegido no corresponde a ninguno de los predefinidos. Crear una
estructura minima universal que funcione para cualquier tecnologia.

---

## Estructura de carpetas

Crear la siguiente estructura usando `mkdir -p`:

```
[nombre-proyecto]/
├── src/
├── tests/
├── docs/
├── .env.example
├── .gitignore
├── README.md
├── CLAUDE.md
├── PROJECT.md
└── ROADMAP.md
```

---

## Archivos base a generar

### .env.example

```env
# Entorno: development | staging | production
ENVIRONMENT=development

# Nombre del proyecto
PROJECT_NAME=[NOMBRE]

# Version de la aplicacion
APP_VERSION=0.1.0

# Base de datos (ajustar segun el motor elegido)
DATABASE_URL=

# Autenticacion
SECRET_KEY=cambiar-este-valor-en-produccion
```

### .gitignore

```
# Dependencias
node_modules/
vendor/
.venv/

# Entorno
.env
.env.local

# Build
dist/
build/
out/
target/

# Cache
__pycache__/
*.pyc
.cache/

# IDE
.idea/
.vscode/
*.swp
*.swo

# Sistema
.DS_Store
Thumbs.db

# Kroexus
_kroexus/
```

### README.md

Generar con este contenido, reemplazando los valores entre corchetes:

```markdown
# [NOMBRE]

[DESCRIPCION]

## Requisitos previos

Documentar aqui las herramientas necesarias para ejecutar el proyecto localmente.

## Configuracion local

1. Clonar el repositorio
2. Copiar `.env.example` a `.env` y completar con valores reales
3. Instalar dependencias (documentar el comando especifico)
4. Ejecutar el proyecto (documentar el comando especifico)

## Estructura del proyecto

```
src/       Codigo fuente principal
tests/     Tests
docs/      Documentacion adicional
```

## Comandos Kroexus

Este proyecto usa Kroexus para inteligencia de proyecto. Comandos disponibles
en Claude Code:

- `/audit` — Auditoria completa en 13 dimensiones
- `/checkpoint` — Revision rapida de seguridad y deuda tecnica
- `/tentacle` — Genera template para desarrollador externo
- `/roadmap` — Muestra avance del proyecto por fases
```

---

## Instrucciones post-generacion

Despues de crear todos los archivos:

1. No instalar dependencias automaticamente. El usuario definira el stack
   especifico y las instalara cuando este listo.
2. Informar al usuario que la estructura base esta generada y que debe
   adaptar la configuracion a su stack especifico.
3. Recomendar empezar por la Fase 1 del ROADMAP.md, que incluye definir
   la estructura de carpetas especifica para su tecnologia.
