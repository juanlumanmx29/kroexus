# Kroexus

Kroexus es un sistema de inteligencia de proyectos que se integra con Claude Code para
garantizar que cualquier proyecto de software sea seguro, escalable, bien disenado y
consistente desde el primer dia. Funciona como un conjunto de reglas, comandos y modulos
de auditoria que Claude Code lee y ejecuta automaticamente.

No importa el stack tecnologico ni el tamano del equipo: Kroexus establece estandares
claros de seguridad, calidad y arquitectura, y proporciona herramientas para verificar
que se cumplan durante todo el ciclo de desarrollo.

---

## Instalacion

Una vez dentro de tu proyecto (carpeta vacia o con codigo existente):

**PowerShell (Windows):**
```powershell
irm https://raw.githubusercontent.com/juanlumanmx29/kroexus/main/install.ps1 | iex
```

**Git Bash / macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/juanlumanmx29/kroexus/main/install.sh | bash
```

El script detecta automaticamente si es un proyecto nuevo o existente e instala
lo que corresponda. Es idempotente: ejecutarlo mas de una vez no duplica
configuraciones ni rompe archivos existentes.

---

## Despues de instalar

### Proyecto nuevo (carpeta vacia)

Abre Claude Code y ejecuta `/kroexus` para iniciar la entrevista de configuracion:

```bash
claude
```

> Escribe `/kroexus` y responde las preguntas. Kroexus genera la estructura del
> proyecto, el roadmap y los archivos base segun el stack que elijas.

### Proyecto existente (con codigo)

Abre Claude Code y usa los comandos de auditoria:

```bash
claude
```

> Escribe `/audit` para una auditoria completa o `/checkpoint` para una
> revision rapida.

---

## Comandos disponibles

Una vez instalado, estos comandos estan disponibles en Claude Code:

| Comando | Descripcion |
|---------|-------------|
| `/kroexus` | Entrevista de configuracion para proyectos nuevos. Genera estructura, roadmap y archivos base. |
| `/audit` | Auditoria completa en 13 dimensiones. Genera reportes en `_kroexus/` con hallazgos clasificados por severidad. |
| `/checkpoint` | Revision rapida de seguridad, dependencias y deuda tecnica. Muestra resultados en el chat. |
| `/tentacle` | Genera repositorio template para desarrolladores externos con tokens de diseno y contratos de API. |
| `/roadmap` | Muestra avance del proyecto por fases con porcentajes e items bloqueantes. |

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
├── install.sh             Script de instalacion universal
├── .claude/
│   └── commands/
│       ├── kroexus.md     Comando /kroexus
│       ├── audit.md       Comando /audit
│       ├── checkpoint.md  Comando /checkpoint
│       ├── tentacle.md    Comando /tentacle
│       └── roadmap.md     Comando /roadmap
├── init/
│   ├── entrevista.md      Entrevista de configuracion para proyectos nuevos
│   └── stacks/
│       ├── fastapi-react.md   Configuracion: FastAPI + React
│       ├── nextjs.md          Configuracion: Next.js fullstack
│       ├── fastapi-only.md    Configuracion: solo FastAPI
│       └── generic.md         Configuracion: estructura minima universal
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
