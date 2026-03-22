# Resiliencia — Modulo Kroexus

## Objetivo

Evaluar la resiliencia del sistema frente a fallos de integraciones externas:
verificar timeout, retry, circuit breaker, fallback y logging para cada servicio
externo conectado.

## Modo de operacion

- **Modo completo**: Se ejecuta cuando se detectan integraciones externas.
  Analiza cada integracion individualmente.
- **Modo basico**: Se ejecuta cuando no se detectan integraciones externas.
  Solo verifica timeouts generales y manejo de errores de red.

## Que buscar

### Detectar integraciones externas

```bash
# URLs de servicios externos en el codigo
grep -rn "https://\|http://" --include="*.py" --include="*.ts" --include="*.js" --include="*.env.example" . | grep -v node_modules | grep -v __pycache__ | grep -v .git | grep -v localhost | grep -v 127.0.0.1 | grep -v "0.0.0.0"

# SDKs de servicios externos
grep -rn "stripe\|sendgrid\|twilio\|openai\|aws\|firebase\|supabase\|cloudinary\|mercadopago\|transbank\|webpay" --include="*.py" --include="*.ts" --include="*.js" --include="package.json" --include="requirements.txt" . | grep -v node_modules | grep -v __pycache__

# Clientes HTTP configurados con URLs externas
grep -rn "base_url\|baseURL\|BASE_URL\|API_URL" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__ | grep -v test | grep -v .env
```

### Timeout por integracion

```bash
# Python: timeout en llamadas HTTP
grep -rn "timeout" --include="*.py" . | grep -v __pycache__ | grep -v .venv | grep -v test

# Python: clientes sin timeout
grep -rn "requests\.\(get\|post\|put\|delete\)\|httpx\.\(get\|post\|put\|delete\)" --include="*.py" . | grep -v __pycache__ | grep -v timeout

# TypeScript: timeout en fetch/axios
grep -rn "timeout\|AbortController" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v test
```

### Retry logic

```bash
# Buscar implementacion de retry
grep -rn "retry\|retries\|max_retries\|backoff\|tenacity\|p-retry\|async-retry" --include="*.py" --include="*.ts" --include="*.js" --include="package.json" --include="requirements.txt" . | grep -v node_modules | grep -v __pycache__

# Buscar loops de reintento manuales
grep -rn "while.*retry\|for.*attempt\|for.*retry" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v test
```

### Circuit breaker o fallback

```bash
# Buscar patrones de circuit breaker
grep -rn "circuit.breaker\|circuitbreaker\|pybreaker\|opossum\|cockatiel" --include="*.py" --include="*.ts" --include="*.js" --include="package.json" --include="requirements.txt" . | grep -v node_modules | grep -v __pycache__

# Buscar fallback logic
grep -rn "fallback\|default.*value\|cache.*fallback\|offline" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v test
```

### Logging de fallos de integracion

```bash
# Buscar logging en bloques try/except que llaman APIs externas
grep -rn "except" --include="*.py" -B 5 -A 3 . | grep -E "requests\.|httpx\.|fetch|log|logger" | grep -v __pycache__ | grep -v node_modules

# Buscar manejo de errores en llamadas a SDKs
grep -rn "except.*Error\|catch.*Error" --include="*.py" --include="*.ts" -A 3 . | grep -E "log|logger|console" | grep -v node_modules | grep -v __pycache__
```

## Como analizar

Para cada integracion externa detectada, completar esta tabla:

| Integracion | Timeout | Retry | Circuit Breaker | Fallback | Logging |
|-------------|---------|-------|-----------------|----------|---------|
| [nombre]    | si/no   | si/no | si/no           | si/no    | si/no   |

### Que pasa si la integracion no responde

Para cada integracion, determinar:
- **Colapsa**: La aplicacion deja de funcionar completamente
- **Degrada**: La funcionalidad afectada no esta disponible pero el resto funciona
- **Transparente**: El usuario no nota la falla (hay fallback o cache)

### Resiliencia saludable

- Toda llamada externa tiene timeout explicito
- Las operaciones criticas tienen retry con backoff exponencial
- Si una integracion falla, la aplicacion degrada en lugar de colapsar
- Los fallos se loggean con contexto suficiente para diagnosticar
- Hay fallback definido para cada integracion (aunque sea mostrar un mensaje claro)

### Criterios de severidad

- **Critico**: Integracion de pagos sin timeout (puede bloquear el servidor indefinidamente). Integracion sin la cual la aplicacion colapsa completamente y no tiene fallback. Llamadas externas en el flujo critico sin ningun manejo de error.
- **Importante**: Integracion sin retry logic (un error transitorio causa fallo permanente). Sin logging de fallos de integracion. Timeout demasiado alto (>30s) que degrada la experiencia.
- **Mejora**: Sin circuit breaker (aceptable en sistemas con pocas integraciones). Fallback definido pero no probado.

## Soluciones de referencia

### Retry con backoff exponencial en Python

```python
import httpx
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=1, max=10),
)
async def call_external_api(payload: dict) -> dict:
    async with httpx.AsyncClient(timeout=10.0) as client:
        response = await client.post(
            "https://api.externa.com/endpoint",
            json=payload,
        )
        response.raise_for_status()
        return response.json()
```

### Fallback con degradacion elegante

```python
async def get_exchange_rate(currency: str) -> float:
    try:
        rate = await external_api.get_rate(currency)
        # Guardar en cache para usar como fallback
        await cache.set(f"rate:{currency}", rate, ttl=3600)
        return rate
    except (httpx.TimeoutException, httpx.HTTPStatusError) as e:
        logger.warning(
            "Error obteniendo tasa de cambio para %s: %s. Usando cache.",
            currency,
            str(e),
        )
        cached_rate = await cache.get(f"rate:{currency}")
        if cached_rate:
            return cached_rate
        raise ServiceUnavailableError(
            f"Servicio de tasas de cambio no disponible para {currency}"
        )
```

### Timeout explicito en cada integracion

```python
# Cada integracion con su propio timeout segun criticidad
INTEGRATION_TIMEOUTS = {
    "pagos": 15.0,      # Mas tolerante por ser critico
    "email": 10.0,      # Estandar
    "analytics": 5.0,   # Si falla, no es critico
    "maps": 8.0,        # Estandar
}
```

## Formato de output

Cada hallazgo usa esta estructura:

### [Nombre del hallazgo]
**Severidad**: Critico / Importante / Mejora
**Integracion**: Nombre del servicio externo afectado
**Ubicacion**: ruta/archivo.py:linea
**Riesgo**: que puede ocurrir si no se resuelve
**Solucion**: codigo o configuracion exacta para este proyecto
**Esfuerzo**: 30 min / 2 horas / 1 dia / 1 semana

Incluir al inicio del reporte:
- Lista de integraciones externas detectadas
- Tabla de resiliencia por integracion (timeout/retry/fallback/logging)
- Evaluacion de impacto: que pasa si cada integracion falla

## Output file

_kroexus/10-resiliencia.md
