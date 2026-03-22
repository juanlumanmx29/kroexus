# Stack: FastAPI + React — Configuracion inicial

## Instrucciones para Claude Code

Este archivo se ejecuta automaticamente despues de la entrevista de configuracion
cuando el usuario elige el stack FastAPI + React. Crear toda la estructura de
carpetas y generar los archivos base definidos abajo.

---

## Estructura de carpetas

Crear la siguiente estructura usando `mkdir -p`:

```
[nombre-proyecto]/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   └── routes/
│   │   ├── core/
│   │   ├── models/
│   │   ├── services/
│   │   └── main.py
│   ├── tests/
│   ├── .env.example
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── api/
│   │   ├── components/
│   │   ├── design-system/
│   │   └── pages/
│   └── package.json
├── CLAUDE.md
├── PROJECT.md
└── ROADMAP.md
```

---

## Archivos base a generar

### backend/app/main.py

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

### backend/app/core/config.py

```python
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    PROJECT_NAME: str = "Mi Proyecto"
    APP_VERSION: str = "0.1.0"
    ENVIRONMENT: str = "development"

    # Origenes permitidos para CORS (separados por coma)
    ALLOWED_ORIGINS_STR: str = "http://localhost:3000,http://localhost:5173"

    # Base de datos
    DATABASE_URL: str = ""

    # Autenticacion
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

### backend/app/core/security.py

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

### backend/.env.example

```env
# Entorno: development | staging | production
ENVIRONMENT=development

# Nombre del proyecto
PROJECT_NAME=Mi Proyecto

# Version de la aplicacion
APP_VERSION=0.1.0

# Origenes permitidos para CORS (separados por coma)
ALLOWED_ORIGINS_STR=http://localhost:3000,http://localhost:5173

# Base de datos
DATABASE_URL=postgresql://usuario:password@localhost:5432/nombre_db

# Autenticacion
SECRET_KEY=cambiar-este-valor-en-produccion
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### backend/requirements.txt

```
fastapi>=0.109.0
uvicorn[standard]>=0.27.0
pydantic-settings>=2.1.0
python-jose[cryptography]>=3.3.0
httpx>=0.27.0
```

### frontend/src/api/client.ts

```typescript
const BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";
const DEFAULT_TIMEOUT_MS = 10000;

interface RequestOptions extends RequestInit {
  timeout?: number;
}

class ApiError extends Error {
  status: number;
  body: unknown;

  constructor(message: string, status: number, body: unknown) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.body = body;
  }
}

async function request<T>(
  path: string,
  options: RequestOptions = {}
): Promise<T> {
  const { timeout = DEFAULT_TIMEOUT_MS, ...fetchOptions } = options;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  const token = localStorage.getItem("access_token");

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  };

  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  try {
    const response = await fetch(`${BASE_URL}${path}`, {
      ...fetchOptions,
      headers,
      signal: controller.signal,
    });

    if (!response.ok) {
      const body = await response.json().catch(() => null);
      throw new ApiError(
        `Error ${response.status} en ${path}`,
        response.status,
        body
      );
    }

    return response.json();
  } catch (error) {
    if (error instanceof ApiError) throw error;

    if (error instanceof DOMException && error.name === "AbortError") {
      throw new ApiError(
        `Timeout: la solicitud a ${path} excedio ${timeout}ms`,
        0,
        null
      );
    }

    throw new ApiError(
      `Error de conexion con el servidor: ${String(error)}`,
      0,
      null
    );
  } finally {
    clearTimeout(timeoutId);
  }
}

export const api = {
  get: <T>(path: string, options?: RequestOptions) =>
    request<T>(path, { ...options, method: "GET" }),

  post: <T>(path: string, body: unknown, options?: RequestOptions) =>
    request<T>(path, {
      ...options,
      method: "POST",
      body: JSON.stringify(body),
    }),

  put: <T>(path: string, body: unknown, options?: RequestOptions) =>
    request<T>(path, {
      ...options,
      method: "PUT",
      body: JSON.stringify(body),
    }),

  patch: <T>(path: string, body: unknown, options?: RequestOptions) =>
    request<T>(path, {
      ...options,
      method: "PATCH",
      body: JSON.stringify(body),
    }),

  delete: <T>(path: string, options?: RequestOptions) =>
    request<T>(path, { ...options, method: "DELETE" }),
};
```

### frontend/src/design-system/tokens.css

```css
:root {
  /* --- Colores base --- */
  --color-primary-50: #EFF6FF;
  --color-primary-100: #DBEAFE;
  --color-primary-200: #BFDBFE;
  --color-primary-300: #93C5FD;
  --color-primary-400: #60A5FA;
  --color-primary-500: #3B82F6;
  --color-primary-600: #2563EB;
  --color-primary-700: #1D4ED8;
  --color-primary-800: #1E40AF;
  --color-primary-900: #1E3A8A;

  --color-neutral-50: #F9FAFB;
  --color-neutral-100: #F3F4F6;
  --color-neutral-200: #E5E7EB;
  --color-neutral-300: #D1D5DB;
  --color-neutral-400: #9CA3AF;
  --color-neutral-500: #6B7280;
  --color-neutral-600: #4B5563;
  --color-neutral-700: #374151;
  --color-neutral-800: #1F2937;
  --color-neutral-900: #111827;

  --color-success-500: #22C55E;
  --color-success-600: #16A34A;
  --color-warning-500: #F59E0B;
  --color-warning-600: #D97706;
  --color-error-500: #EF4444;
  --color-error-600: #DC2626;

  --color-background: #FFFFFF;
  --color-surface: #F9FAFB;
  --color-text-primary: #111827;
  --color-text-secondary: #6B7280;
  --color-border: #E5E7EB;

  /* --- Tipografia --- */
  --font-family-base: "Inter", system-ui, -apple-system, sans-serif;
  --font-family-mono: "JetBrains Mono", "Fira Code", monospace;

  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;
  --font-size-2xl: 1.5rem;
  --font-size-3xl: 1.875rem;
  --font-size-4xl: 2.25rem;

  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;

  --line-height-tight: 1.25;
  --line-height-base: 1.5;
  --line-height-relaxed: 1.75;

  /* --- Espaciado --- */
  --spacing-1: 0.25rem;
  --spacing-2: 0.5rem;
  --spacing-3: 0.75rem;
  --spacing-4: 1rem;
  --spacing-5: 1.25rem;
  --spacing-6: 1.5rem;
  --spacing-8: 2rem;
  --spacing-10: 2.5rem;
  --spacing-12: 3rem;
  --spacing-16: 4rem;
  --spacing-20: 5rem;

  /* --- Radios de borde --- */
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-xl: 0.75rem;
  --radius-2xl: 1rem;
  --radius-full: 9999px;

  /* --- Sombras --- */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);

  /* --- Transiciones --- */
  --transition-fast: 150ms ease;
  --transition-base: 200ms ease;
  --transition-slow: 300ms ease;
}
```

### frontend/package.json

```json
{
  "name": "[nombre-proyecto]-frontend",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "react-router-dom": "^6.22.0"
  },
  "devDependencies": {
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "@vitejs/plugin-react": "^4.2.0",
    "typescript": "^5.4.0",
    "vite": "^5.1.0"
  }
}
```

---

## Archivos de configuracion adicionales

### .gitignore (en la raiz del proyecto)

```
node_modules/
dist/
.env
__pycache__/
*.pyc
.venv/
_kroexus/
.DS_Store
```

### .env (frontend — crear como frontend/.env.example)

```env
# URL del API backend
VITE_API_URL=http://localhost:8000
```

---

## Instrucciones post-generacion

Despues de crear todos los archivos:

1. No ejecutar `npm install` ni `pip install` automaticamente. El usuario lo hara
   cuando este listo.
2. Informar al usuario que los archivos base estan generados y que puede empezar
   por la Fase 1 del ROADMAP.md.
3. Recordar que `backend/.env.example` debe copiarse a `backend/.env` y completarse
   con valores reales antes de ejecutar el servidor.
