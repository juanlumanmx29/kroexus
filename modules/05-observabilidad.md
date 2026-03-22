# Observabilidad — Modulo Kroexus

## Objetivo

Evaluar la capacidad del sistema para ser monitoreado y diagnosticado: logging
estructurado, manejo de excepciones, health checks, alertas y trazabilidad.

## Que buscar

### Logging: print() vs logging estructurado

```bash
# Uso de print() para logging (mala practica)
grep -rn "print(" --include="*.py" . | grep -v __pycache__ | grep -v .venv | grep -v test | grep -v setup.py

# Uso de console.log para logging en produccion
grep -rn "console\.log\|console\.error\|console\.warn" --include="*.ts" --include="*.tsx" --include="*.js" . | grep -v node_modules | grep -v .next | grep -v test

# Configuracion de logging estructurado
grep -rn "logging\.config\|logging\.basicConfig\|getLogger\|structlog\|pino\|winston" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__
```

### Excepciones silenciadas

```bash
# Python: except sin manejo (bare except o pass)
grep -rn "except:" --include="*.py" . | grep -v __pycache__ | grep -v .venv

grep -rn "except.*:" --include="*.py" -A 2 . | grep -B 1 "pass$" | grep -v __pycache__

# TypeScript/JavaScript: catch vacio
grep -rn "catch" --include="*.ts" --include="*.tsx" --include="*.js" -A 3 . | grep -B 1 "}" | grep -v node_modules | grep -v .next

# Catch que solo hace console.log (no re-lanza ni maneja)
grep -rn "catch" --include="*.ts" --include="*.tsx" -A 2 . | grep "console\." | grep -v node_modules
```

### Health checks

```bash
# Buscar endpoint de health check
grep -rn "health\|healthcheck\|health_check\|liveness\|readiness" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__ | grep -v test

# Verificar que el health check prueba conexiones reales (DB, cache, etc.)
```

### Alertas y notificaciones

```bash
# Buscar integraciones con servicios de alertas
grep -rn "sentry\|datadog\|newrelic\|pagerduty\|opsgenie\|alertmanager" --include="*.py" --include="*.ts" --include="*.js" --include="package.json" --include="requirements.txt" . | grep -v node_modules | grep -v __pycache__
```

### Trazabilidad entre servicios

```bash
# Buscar request IDs o correlation IDs
grep -rn "request.id\|correlation.id\|trace.id\|x-request-id\|X-Request-ID" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__

# Middleware de request ID
grep -rn "middleware" --include="*.py" --include="*.ts" -A 10 . | grep -i "request.*id\|trace\|correlation" | grep -v node_modules
```

### Logging en flujos criticos

Identificar los flujos criticos del proyecto (autenticacion, pagos, operaciones
de datos sensibles) y verificar si tienen logging adecuado:

```bash
# Funciones de autenticacion
grep -rn "def.*login\|def.*auth\|def.*register\|async.*login\|async.*auth" --include="*.py" --include="*.ts" -A 15 . | grep -E "log\.|logger\." | grep -v node_modules | grep -v __pycache__

# Funciones de pago
grep -rn "def.*pay\|def.*charge\|def.*order\|async.*pay" --include="*.py" --include="*.ts" -A 15 . | grep -E "log\.|logger\." | grep -v node_modules | grep -v __pycache__
```

## Como analizar

### Observabilidad saludable

- Logging configurado con niveles (DEBUG, INFO, WARNING, ERROR)
- Formato estructurado (JSON) en lugar de texto plano
- Excepciones capturadas con contexto suficiente para diagnosticar
- Health check que verifica conexiones reales (no solo retorna 200)
- Request ID propagado en logs para trazabilidad
- Flujos criticos (auth, pagos) con logging detallado

### Senales de problemas

- **print() como logging**: No tiene niveles, no tiene formato estructurado, no se puede filtrar.
- **Excepciones silenciadas**: Errores que pasan desapercibidos y causan comportamiento inesperado.
- **Health check superficial**: Retorna 200 sin verificar que la BD este conectada o que los servicios esten disponibles.
- **Sin request ID**: Imposible correlacionar logs entre microservicios o entre frontend y backend.
- **Flujos criticos sin logging**: Si falla un pago, no hay forma de diagnosticar que paso.

### Criterios de severidad

- **Critico**: Excepciones silenciadas en flujos criticos (auth, pagos, datos). Ausencia total de health check en un servicio desplegado.
- **Importante**: Uso extensivo de print() en lugar de logging. Health check que no verifica conexiones reales. Flujos criticos sin logging.
- **Mejora**: Logging presente pero sin formato estructurado. Ausencia de request ID. Sin integracion con servicio de alertas.

## Soluciones de referencia

### Configurar logging estructurado en Python

```python
import logging
import json

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_data)

handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())

logger = logging.getLogger(__name__)
logger.addHandler(handler)
logger.setLevel(logging.INFO)
```

### Reemplazar except silencioso

```python
# Antes (problematico)
try:
    result = external_api.call()
except:
    pass

# Despues (correcto)
try:
    result = external_api.call()
except ExternalAPIError as e:
    logger.error("Error al llamar API externa: %s", str(e), exc_info=True)
    raise
```

### Health check con verificacion de BD

```python
@app.get("/health")
async def health_check(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))
        db_status = "ok"
    except Exception as e:
        logger.error("Health check: BD no disponible: %s", str(e))
        db_status = "error"

    status = "ok" if db_status == "ok" else "degraded"
    status_code = 200 if status == "ok" else 503

    return JSONResponse(
        status_code=status_code,
        content={
            "status": status,
            "database": db_status,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        },
    )
```

## Formato de output

Cada hallazgo usa esta estructura:

### [Nombre del hallazgo]
**Severidad**: Critico / Importante / Mejora
**Ubicacion**: ruta/archivo.py:linea (o "global" si aplica a todo el proyecto)
**Riesgo**: que puede ocurrir si no se resuelve
**Solucion**: codigo o configuracion exacta para este proyecto
**Esfuerzo**: 30 min / 2 horas / 1 dia / 1 semana

## Output file

_kroexus/05-observabilidad.md
