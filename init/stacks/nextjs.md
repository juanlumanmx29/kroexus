# Stack: Next.js Fullstack — Configuracion inicial

## Instrucciones para Claude Code

Este archivo se ejecuta automaticamente despues de la entrevista de configuracion
cuando el usuario elige el stack Next.js fullstack. Crear toda la estructura de
carpetas y generar los archivos base definidos abajo.

---

## Estructura de carpetas

Crear la siguiente estructura usando `mkdir -p`:

```
[nombre-proyecto]/
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   └── health/
│   │   │       └── route.ts
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── globals.css
│   ├── components/
│   ├── lib/
│   │   └── api-client.ts
│   └── design-system/
│       └── tokens.css
├── public/
├── middleware.ts
├── .env.local.example
├── next.config.ts
├── tsconfig.json
├── package.json
├── CLAUDE.md
├── PROJECT.md
└── ROADMAP.md
```

---

## Archivos base a generar

### src/app/layout.tsx

```tsx
import type { Metadata } from "next";
import "./globals.css";
import "../design-system/tokens.css";

export const metadata: Metadata = {
  title: "[NOMBRE]",
  description: "[DESCRIPCION]",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  );
}
```

### src/app/page.tsx

```tsx
export default function Home() {
  return (
    <main>
      <h1>[NOMBRE]</h1>
      <p>[DESCRIPCION]</p>
    </main>
  );
}
```

### src/app/globals.css

```css
*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: var(--font-family-base);
  font-size: var(--font-size-base);
  line-height: var(--line-height-base);
  color: var(--color-text-primary);
  background-color: var(--color-background);
}
```

### src/app/api/health/route.ts

```typescript
import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({
    status: "ok",
    version: process.env.APP_VERSION || "0.1.0",
    timestamp: new Date().toISOString(),
  });
}
```

### middleware.ts

```typescript
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const PUBLIC_PATHS = ["/", "/login", "/registro", "/api/health"];

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  const isPublicPath = PUBLIC_PATHS.some(
    (path) => pathname === path || pathname.startsWith("/api/health")
  );

  if (isPublicPath) {
    return NextResponse.next();
  }

  const token = request.cookies.get("session_token")?.value;

  if (!token) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("redirect", pathname);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|public/).*)",
  ],
};
```

### src/lib/api-client.ts

```typescript
const BASE_URL = process.env.NEXT_PUBLIC_API_URL || "";
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

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  };

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

### src/design-system/tokens.css

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

### .env.local.example

```env
# URL del API (para llamadas desde el cliente)
NEXT_PUBLIC_API_URL=http://localhost:3000/api

# Version de la aplicacion
APP_VERSION=0.1.0

# Autenticacion
AUTH_SECRET=cambiar-este-valor-en-produccion

# Base de datos
DATABASE_URL=postgresql://usuario:password@localhost:5432/nombre_db
```

### next.config.ts

```typescript
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  poweredByHeader: false,
};

export default nextConfig;
```

### package.json

```json
{
  "name": "[nombre-proyecto]",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "^14.1.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "typescript": "^5.4.0"
  }
}
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

---

## Archivos de configuracion adicionales

### .gitignore

```
node_modules/
.next/
out/
.env
.env.local
_kroexus/
.DS_Store
```

---

## Instrucciones post-generacion

Despues de crear todos los archivos:

1. No ejecutar `npm install` automaticamente. El usuario lo hara cuando este listo.
2. Reemplazar `[NOMBRE]` y `[DESCRIPCION]` en layout.tsx y page.tsx con los valores
   reales de la entrevista.
3. Reemplazar `[nombre-proyecto]` en package.json con el nombre real del proyecto.
4. Informar al usuario que los archivos base estan generados y que puede empezar
   por la Fase 1 del ROADMAP.md.
