# Stack: Solo FastAPI — Configuracion inicial

## Instrucciones para Claude Code

Este archivo se ejecuta automaticamente despues de la entrevista de configuracion
cuando el usuario elige el stack solo FastAPI (sin frontend). Crear toda la
estructura de carpetas y generar los archivos base definidos abajo.

---

## Estructura de carpetas

Crear la siguiente estructura usando `mkdir -p`:

```
[nombre-proyecto]/
├── app/
│   ├── api/
│   │   └── routes/
│   ├── core/
│   ├── models/
│   ├── services/
│   └── main.py
├── tests/
├── docs/
│   └── api.md
├── .env.example
├── requirements.txt
├── CLAUDE.md
├── PROJECT.md
└── ROADMAP.md
```

---

## Archivos base a generar

### app/main.py

```python
import os
from datetime import datetime, timezone

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    docs_url="/docs" if settings.ENVIRONMENT != "production" else None,
    redoc_url="/redoc" if settings.ENVIRONMENT != "production" else None,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    import logging

    logger = logging.getLogger(__name__)
    logger.error(
        "Error no manejado en %s %s: %s",
        request.method,
        request.url.path,
        str(exc),
        exc_info=True,
    )
    return JSONResponse(
        status_code=500,
        content={"detail": "Error interno del servidor"},
    )


@app.get("/health")
async def health_check():
    return {
        "status": "ok",
        "version": settings.APP_VERSION,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
```

### app/core/config.py

```python
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    PROJECT_NAME: str = "Mi Proyecto"
    APP_VERSION: str = "0.1.0"
    ENVIRONMENT: str = "development"

    ALLOWED_ORIGINS_STR: str = "http://localhost:3000"

    DATABASE_URL: str = ""

    SECRET_KEY: str = ""
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    @property
    def ALLOWED_ORIGINS(self) -> list[str]:
        return [
            origin.strip()
            for origin in self.ALLOWED_ORIGINS_STR.split(",")
            if origin.strip()
        ]

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
```

### app/core/security.py

```python
from datetime import datetime, timedelta, timezone

from jose import jwt

from app.core.config import settings


def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm="HS256")


def verify_token(token: str) -> dict | None:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
        return payload
    except jwt.JWTError:
        return None
```

### .env.example

```env
# Entorno: development | staging | production
ENVIRONMENT=development

# Nombre del proyecto
PROJECT_NAME=Mi Proyecto

# Version de la aplicacion
APP_VERSION=0.1.0

# Origenes permitidos para CORS (separados por coma)
ALLOWED_ORIGINS_STR=http://localhost:3000

# Base de datos
DATABASE_URL=postgresql://usuario:password@localhost:5432/nombre_db

# Autenticacion
SECRET_KEY=cambiar-este-valor-en-produccion
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### requirements.txt

```
fastapi>=0.109.0
uvicorn[standard]>=0.27.0
pydantic-settings>=2.1.0
python-jose[cryptography]>=3.3.0
httpx>=0.27.0
```

### docs/api.md

```markdown
# Documentacion del API

Este archivo documenta los endpoints disponibles en el proyecto.
Se actualiza automaticamente al ejecutar /audit (modulo 12-api-contrato).

## Endpoints

### GET /health

Verificacion de estado del servidor.

**Autenticacion**: No requerida

**Respuesta exitosa (200)**:
```
{
  "status": "ok",
  "version": "0.1.0",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

---

Los siguientes endpoints se documentaran a medida que se construyan.
Ejecutar `/audit` para generar la documentacion completa automaticamente.
```

---

## Archivos de configuracion adicionales

### .gitignore

```
.env
__pycache__/
*.pyc
.venv/
_kroexus/
.DS_Store
```

---

## Instrucciones post-generacion

Despues de crear todos los archivos:

1. No ejecutar `pip install` automaticamente. El usuario lo hara cuando este listo.
2. Informar al usuario que los archivos base estan generados y que puede empezar
   por la Fase 1 del ROADMAP.md.
3. Recordar que `.env.example` debe copiarse a `.env` y completarse con valores
   reales antes de ejecutar el servidor.
