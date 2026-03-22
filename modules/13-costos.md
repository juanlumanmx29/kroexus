# Costos — Modulo Kroexus

## Objetivo

Estimar el costo operativo mensual del proyecto segun su stack, integraciones
y volumen esperado. Presentar escenario minimo y escenario con 10x de uso.

## Que buscar

### Stack y hosting

```bash
# Detectar stack principal
ls package.json pyproject.toml requirements.txt go.mod Cargo.toml 2>/dev/null

# Detectar si es fullstack (frontend + backend separados)
ls -d frontend/ backend/ 2>/dev/null
find . -name "next.config.*" -not -path "*/node_modules/*" 2>/dev/null

# Detectar framework web
grep -rn "fastapi\|django\|flask\|express\|next" requirements.txt package.json pyproject.toml 2>/dev/null | head -5
```

### Base de datos

```bash
# Tipo de base de datos
grep -rn "postgresql\|postgres\|mysql\|mongodb\|sqlite\|redis\|dynamodb\|firestore\|supabase" --include="*.py" --include="*.ts" --include="*.js" --include="*.env.example" --include="*.yml" --include="*.yaml" . | grep -v node_modules | grep -v __pycache__ | head -10

# Modelos (para estimar tamano de datos)
grep -rn "class.*Model\|class.*Base\)\|model " --include="*.py" --include="*.prisma" . | grep -v __pycache__ | grep -v test
```

### Integraciones externas y sus costos

```bash
# APIs de pago
grep -rn "stripe\|mercadopago\|transbank\|webpay\|paypal" --include="*.py" --include="*.ts" --include="*.js" --include="requirements.txt" --include="package.json" . | grep -v node_modules | grep -v __pycache__

# APIs de IA
grep -rn "openai\|anthropic\|claude\|gpt\|gemini\|mistral\|replicate\|huggingface" --include="*.py" --include="*.ts" --include="*.js" --include="requirements.txt" --include="package.json" . | grep -v node_modules | grep -v __pycache__

# Email
grep -rn "sendgrid\|ses\|mailgun\|resend\|postmark" --include="*.py" --include="*.ts" --include="*.js" --include="requirements.txt" --include="package.json" . | grep -v node_modules | grep -v __pycache__

# Almacenamiento
grep -rn "s3\|cloudinary\|gcs\|azure.*blob\|storage.*bucket" --include="*.py" --include="*.ts" --include="*.js" --include="requirements.txt" --include="package.json" . | grep -v node_modules | grep -v __pycache__

# SMS/Notificaciones
grep -rn "twilio\|firebase.*messaging\|onesignal\|sns" --include="*.py" --include="*.ts" --include="*.js" --include="requirements.txt" --include="package.json" . | grep -v node_modules | grep -v __pycache__

# Mapas/Geocoding
grep -rn "google.*maps\|mapbox\|here.*api\|geocod" --include="*.py" --include="*.ts" --include="*.js" --include="requirements.txt" --include="package.json" . | grep -v node_modules | grep -v __pycache__
```

### Volumen estimado

```bash
# Buscar indicios de volumen esperado en documentacion
grep -rn "usuarios\|users\|requests\|RPM\|RPS\|concurrentes\|concurrent" README.md PROJECT.md ROADMAP.md 2>/dev/null
```

## Como analizar

### Tablas de referencia de costos

Usar estas referencias para estimar costos. Los precios son aproximados y pueden
variar segun proveedor y region.

**Hosting backend:**

| Servicio | Plan basico | Plan escalado |
|----------|-------------|---------------|
| Railway | $5/mes (500h) | $20-50/mes |
| Render | $7/mes | $25-85/mes |
| AWS EC2 t3.small | $15/mes | $30-60/mes |
| DigitalOcean | $6/mes | $24-48/mes |
| Fly.io | $0 (free tier) | $10-30/mes |

**Hosting frontend:**

| Servicio | Plan basico | Plan escalado |
|----------|-------------|---------------|
| Vercel | $0 (free tier) | $20/mes |
| Netlify | $0 (free tier) | $19/mes |
| Cloudflare Pages | $0 (free tier) | $5/mes |

**Base de datos:**

| Servicio | Plan basico | Plan escalado |
|----------|-------------|---------------|
| Supabase | $0 (free) | $25/mes |
| PlanetScale | $0 (free) | $29/mes |
| Railway Postgres | $5/mes | $20-40/mes |
| AWS RDS t3.micro | $15/mes | $30-60/mes |
| MongoDB Atlas | $0 (free) | $57/mes |

**APIs externas (por llamada):**

| Servicio | Costo por unidad |
|----------|-----------------|
| OpenAI GPT-4 | $0.03/1K tokens input, $0.06/1K output |
| OpenAI GPT-3.5 | $0.0005/1K tokens input, $0.0015/1K output |
| Anthropic Claude | $0.003-0.015/1K tokens (segun modelo) |
| SendGrid | $0 (100 emails/dia free), $15/mes (50K) |
| Stripe | 2.9% + $0.30 por transaccion |
| Twilio SMS | $0.0079/SMS |
| Cloudinary | $0 (25 creditos free), $89/mes |
| Google Maps | $0.007/llamada (geocoding) |

### Criterios de severidad para costos

- **Critico**: Uso de API de IA sin control de costos (sin limites de tokens/llamadas). Integracion de pagos sin monitoreo de transacciones fallidas. Almacenamiento sin politica de limpieza.
- **Importante**: Sin estimacion de costos documentada. Uso de tier de pago cuando el free tier cubriria el volumen actual. Base de datos sobredimensionada para el uso actual.
- **Mejora**: Sin alertas de costos configuradas. Sin plan de optimizacion para escalar.

## Formato de output

Generar dos escenarios:

### Escenario minimo (uso actual o MVP)

Estimar basandose en:
- 100-500 usuarios activos mensuales
- Trafico bajo (1-5 requests por segundo promedio)
- Almacenamiento minimo (< 1 GB)

```markdown
| Componente | Servicio sugerido | Costo mensual |
|------------|-------------------|---------------|
| Backend hosting | [servicio] | $[N] |
| Frontend hosting | [servicio] | $[N] |
| Base de datos | [servicio] | $[N] |
| [Integracion 1] | [servicio] | $[N] |
| [Integracion 2] | [servicio] | $[N] |
| **Total estimado** | | **$[N]/mes** |
```

### Escenario 10x (crecimiento)

Estimar basandose en:
- 1,000-5,000 usuarios activos mensuales
- Trafico moderado (10-50 requests por segundo promedio)
- Almacenamiento moderado (1-10 GB)

```markdown
| Componente | Servicio sugerido | Costo mensual |
|------------|-------------------|---------------|
| Backend hosting | [servicio] | $[N] |
| Frontend hosting | [servicio] | $[N] |
| Base de datos | [servicio] | $[N] |
| [Integracion 1] | [servicio] | $[N] |
| [Integracion 2] | [servicio] | $[N] |
| **Total estimado** | | **$[N]/mes** |
```

### Hallazgos y recomendaciones

Si se detectan riesgos de costos, documentarlos como hallazgos con el formato
estandar:

### [Nombre del hallazgo]
**Severidad**: Critico / Importante / Mejora
**Ubicacion**: componente o integracion afectada
**Riesgo**: que puede ocurrir si no se resuelve (ejemplo: costos inesperados)
**Solucion**: accion exacta (configurar limites, cambiar plan, agregar cache)
**Esfuerzo**: 30 min / 2 horas / 1 dia / 1 semana

## Output file

_kroexus/13-costos.md
