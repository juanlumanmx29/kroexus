# Seguridad — Modulo Kroexus

## Objetivo

Auditar la seguridad del proyecto en dos vectores: el sistema como victima de
ataques externos y el sistema como atacante involuntario de servicios de terceros.

## Que buscar

### Vector 1: Sistema como victima

#### Secrets hardcodeados

```bash
# API keys, passwords y secrets en el codigo
grep -rn "API_KEY\s*=\s*['\"]" --include="*.py" --include="*.ts" --include="*.js" --include="*.tsx" . | grep -v node_modules | grep -v .env.example | grep -v __pycache__

grep -rn "password\s*=\s*['\"][^'\"]*['\"]" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__ | grep -v test | grep -v example

grep -rn "secret\s*=\s*['\"][^'\"]*['\"]" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__ | grep -v .env

grep -rn "Bearer [A-Za-z0-9\-_]" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__

# Archivos .env commiteados
find . -name ".env" -not -path "*/node_modules/*" -not -path "*/.git/*"
```

#### Endpoints sin autenticacion

```bash
# FastAPI: endpoints sin Depends de autenticacion
grep -rn "@app\.\(get\|post\|put\|delete\|patch\)\|@router\.\(get\|post\|put\|delete\|patch\)" --include="*.py" . | grep -v __pycache__

# Next.js: API routes
find . -path "*/api/*" -name "route.ts" -o -name "route.js" | grep -v node_modules | grep -v .next

# Express: rutas sin middleware de auth
grep -rn "app\.\(get\|post\|put\|delete\)\|router\.\(get\|post\|put\|delete\)" --include="*.ts" --include="*.js" . | grep -v node_modules
```

Para cada endpoint encontrado, verificar si tiene un mecanismo de autenticacion
(Depends, middleware, decorador, verificacion de token).

#### /docs y /redoc expuestos en produccion

```bash
# Verificar configuracion de docs en FastAPI
grep -rn "docs_url\|redoc_url" --include="*.py" . | grep -v __pycache__

# Si no se encuentra deshabilitacion condicional, es un hallazgo
```

#### CORS abierto

```bash
# Configuracion de CORS
grep -rn "CORSMiddleware\|cors\|Access-Control" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__

# CORS con allow_origins=["*"] y credentials=True es critico
grep -rn "allow_origins.*\*\|origin.*\*" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__
```

#### Rate limiting ausente

```bash
# Buscar implementacion de rate limiting
grep -rn "rate.limit\|ratelimit\|throttle\|slowapi\|express-rate-limit" --include="*.py" --include="*.ts" --include="*.js" --include="package.json" --include="requirements.txt" . | grep -v node_modules | grep -v __pycache__
```

#### Inputs sin validar

```bash
# FastAPI: endpoints que reciben dict o Any en lugar de modelo tipado
grep -rn "def.*request.*dict\|def.*body.*dict\|def.*data.*Any" --include="*.py" . | grep -v __pycache__

# Uso directo de request.body sin validacion
grep -rn "request\.body\|request\.json\|req\.body" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__
```

#### Logs con datos sensibles

```bash
# Buscar logging de variables potencialmente sensibles
grep -rn "log.*password\|log.*token\|log.*secret\|log.*key\|print.*password\|print.*token" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__

# Buscar logging de request body completo (puede contener datos sensibles)
grep -rn "log.*request\.body\|log.*req\.body\|print.*request\." --include="*.py" --include="*.ts" . | grep -v node_modules
```

#### Dependencias con CVEs

```bash
# Python: verificar con pip-audit (si esta disponible)
pip-audit --requirement requirements.txt 2>/dev/null || echo "pip-audit no disponible"

# Node: verificar con npm audit (si aplica)
npm audit --json 2>/dev/null | head -50 || echo "npm no disponible o no hay package-lock.json"
```

### Vector 2: Sistema como atacante involuntario

#### Loops con llamadas HTTP sin throttling

```bash
# Llamadas HTTP dentro de bucles
grep -rn "for.*in.*:" --include="*.py" -A 10 . | grep -E "requests\.\(get\|post\|put\|delete\)\|httpx\.\|fetch\(|axios\." | grep -v __pycache__ | grep -v node_modules

grep -rn "for.*of\|\.forEach\|\.map" --include="*.ts" --include="*.js" -A 5 . | grep -E "fetch\(|axios\." | grep -v node_modules
```

#### Clientes HTTP sin timeout

```bash
# Python: requests sin timeout
grep -rn "requests\.\(get\|post\|put\|delete\)" --include="*.py" . | grep -v __pycache__ | grep -v timeout

# Python: httpx sin timeout
grep -rn "httpx\.\(get\|post\|put\|delete\)\|AsyncClient\(\|Client\(" --include="*.py" . | grep -v __pycache__

# TypeScript/JavaScript: fetch sin AbortController/timeout
grep -rn "fetch(" --include="*.ts" --include="*.tsx" --include="*.js" . | grep -v node_modules | grep -v .next
```

Para cada llamada fetch encontrada, verificar si hay un AbortController o
mecanismo de timeout asociado.

#### Scripts de migracion sin limite de velocidad

```bash
# Buscar scripts de migracion o seed que hacen operaciones masivas
find . -path "*/migrations/*" -o -path "*/seeds/*" -o -name "seed*.py" -o -name "migrate*.py" | grep -v node_modules | grep -v __pycache__

# Dentro de esos archivos, buscar loops con operaciones de BD
```

#### Webhooks sin validacion de firma

```bash
# Buscar endpoints de webhook
grep -rn "webhook\|hook\|callback" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__

# Verificar si validan firma/signature del request
```

## Como analizar

### Distinguir falso positivo de riesgo real

- **Secret hardcodeado**: Si el valor es "test", "example", "changeme" o esta en un archivo de test, es falso positivo. Si es un valor que parece real (larga cadena alfanumerica), es riesgo real.
- **Endpoint sin auth**: Endpoints publicos como `/health`, `/login`, `/register`, `/docs` son esperados. Endpoints de negocio como `/users`, `/orders`, `/admin` sin auth son riesgo real.
- **CORS abierto**: `allow_origins=["*"]` es aceptable en desarrollo si hay control por variable de entorno. Si esta hardcodeado sin condicion de entorno, es riesgo.
- **Fetch sin timeout**: Si usa un cliente centralizado que ya tiene timeout, es falso positivo. Si es una llamada directa sin timeout, es riesgo.

### Criterios de severidad

- **Critico**: Secret real hardcodeado en codigo. Endpoint de administracion sin autenticacion. CORS abierto con credenciales en produccion. Archivo .env commiteado con datos reales.
- **Importante**: Rate limiting ausente en endpoints publicos. Inputs sin validacion en endpoints que modifican datos. Clientes HTTP sin timeout. /docs expuesto en produccion.
- **Mejora**: Logging de request body que podria contener datos sensibles. Rate limiting ausente en endpoints internos.

## Soluciones de referencia

### Mover secret a variable de entorno

```python
# Antes (critico)
API_KEY = "sk-1234567890abcdef"

# Despues
import os
API_KEY = os.environ["API_KEY"]
# Documentar en .env.example: API_KEY=tu-api-key-aqui
```

### Agregar timeout a cliente HTTP

```python
# Python con httpx
import httpx

async with httpx.AsyncClient(timeout=10.0) as client:
    response = await client.get("https://api.externa.com/datos")
```

```typescript
// TypeScript con fetch
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 10000);

try {
  const response = await fetch(url, { signal: controller.signal });
} finally {
  clearTimeout(timeoutId);
}
```

### Configurar rate limiting en FastAPI

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.get("/api/recurso")
@limiter.limit("10/minute")
async def obtener_recurso(request: Request):
    ...
```

### Validar input con Pydantic

```python
# Antes (riesgo)
@router.post("/users")
async def create_user(data: dict):
    ...

# Despues (seguro)
from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    nombre: str
    email: EmailStr

@router.post("/users")
async def create_user(data: UserCreate):
    ...
```

## Formato de output

Cada hallazgo usa esta estructura:

### [Nombre del hallazgo]
**Severidad**: Critico / Importante / Mejora
**Vector**: Sistema como victima / Sistema como atacante involuntario
**Ubicacion**: ruta/archivo.py:linea
**Codigo encontrado**: bloque exacto del codigo problematico
**Riesgo**: que puede ocurrir si no se resuelve
**Solucion**: codigo o configuracion exacta para este proyecto
**Esfuerzo**: 30 min / 2 horas / 1 dia / 1 semana

Organizar el reporte en dos secciones principales:
1. Vector 1: Sistema como victima
2. Vector 2: Sistema como atacante involuntario

## Output file

_kroexus/03-seguridad.md
