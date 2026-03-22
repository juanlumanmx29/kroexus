# Kroexus

Kroexus es un sistema de inteligencia de proyectos que se integra con Claude Code para
garantizar que cualquier proyecto de software sea seguro, escalable, bien disenado y
consistente desde el primer dia. Funciona como un conjunto de reglas, comandos y modulos
de auditoria que Claude Code lee y ejecuta automaticamente.

No importa el stack tecnologico ni el tamano del equipo: Kroexus establece estandares
claros de seguridad, calidad y arquitectura, y proporciona herramientas para verificar
que se cumplan durante todo el ciclo de desarrollo. Tiene dos modos de operacion:
inicio de proyectos nuevos desde cero y auditoria de proyectos existentes.

---

## Modo 1: Proyecto nuevo

Clona el repositorio, elimina el historial de Git e inicia Claude Code. La entrevista
de configuracion se activa automaticamente.

```bash
git clone https://github.com/juanlumanmx29/kroexus nombre-proyecto
cd nombre-proyecto
rm -rf .git && git init
claude
```

Al abrir Claude Code, detecta que es un proyecto nuevo (no hay codigo fuente) y
comienza la entrevista de configuracion. Esta entrevista genera la estructura del
proyecto, el roadmap y los archivos base segun el stack elegido.

---

## Modo 2: Proyecto existente

Ejecuta el script de instalacion desde la raiz de tu proyecto. El script descarga
los archivos necesarios y configura los comandos de Kroexus.

```bash
cd tu-proyecto
curl -fsSL https://raw.githubusercontent.com/juanlumanmx29/kroexus/main/install.sh | bash
```

El script es idempotente: ejecutarlo mas de una vez no duplica configuraciones ni
rompe archivos existentes. Si ya existe un CLAUDE.md en el proyecto, se crea un
respaldo automatico antes de reemplazarlo.

---

## Comandos disponibles

Una vez instalado, estos comandos estan disponibles en Claude Code:

| Comando | Descripcion |
|---------|-------------|
| `/audit` | Auditoria completa en 13 dimensiones. Genera reportes en `_kroexus/` con hallazgos clasificados por severidad y un resumen ejecutivo. |
| `/checkpoint` | Revision rapida de seguridad, dependencias y deuda tecnica. Muestra resultados en el chat sin generar archivos. |
| `/tentacle` | Genera un repositorio template para desarrolladores externos con tokens de diseno, componentes y contratos de API. |
| `/roadmap` | Muestra el avance del proyecto por fases con porcentajes, items bloqueantes y recomendacion del proximo paso. |

---

## Sobre el archivo CLAUDE.md

El archivo `CLAUDE.md` en la raiz del proyecto es el nucleo de Kroexus. Contiene las
reglas de comportamiento y las normas tecnicas que Claude Code sigue automaticamente
en cada sesion de trabajo.

No debe modificarse sin una razon documentada. Si necesitas ajustar alguna regla para
un proyecto especifico, documenta el cambio y la razon en el mismo archivo para que
el equipo tenga contexto de por que se hizo la excepcion.

---

## Estructura del repositorio

```
kroexus/
├── CLAUDE.md              Reglas de comportamiento y normas tecnicas
├── README.md              Este archivo
├── install.sh             Script de instalacion para proyectos existentes
├── init/
│   ├── entrevista.md      Entrevista de configuracion para proyectos nuevos
│   └── stacks/
│       ├── fastapi-react.md   Configuracion: FastAPI + React
│       ├── nextjs.md          Configuracion: Next.js fullstack
│       ├── fastapi-only.md    Configuracion: solo FastAPI
│       └── generic.md         Configuracion: estructura minima universal
├── commands/
│   ├── audit.md           Comando /audit
│   ├── checkpoint.md      Comando /checkpoint
│   ├── tentacle.md        Comando /tentacle
│   └── roadmap.md         Comando /roadmap
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
