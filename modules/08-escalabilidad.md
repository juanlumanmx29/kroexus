# Escalabilidad — Modulo Kroexus

## Objetivo

Evaluar si el sistema esta preparado para escalar: identificar estado en memoria,
ausencia de paginacion, configuraciones hardcodeadas y diseno que asume una sola
instancia.

## Que buscar

### Estado en memoria del servidor

```bash
# Python: variables globales mutables
grep -rn "^[a-z_].*=\s*\[\]\|^[a-z_].*=\s*{}\|^[a-z_].*=\s*set()" --include="*.py" . | grep -v __pycache__ | grep -v .venv | grep -v test | grep -v config

# Python: atributos de clase usados como estado compartido
grep -rn "cls\.\|self\.__class__\." --include="*.py" -B 2 . | grep -E "append|update|add|\[\]|{}" | grep -v __pycache__

# Python: modulos con estado global
grep -rn "cache\s*=\|sessions\s*=\|connections\s*=\|users\s*=\|data\s*=" --include="*.py" . | grep -v __pycache__ | grep -v .venv | grep -v test | grep -v ".env"

# Node.js: variables globales mutables
grep -rn "^let\|^var" --include="*.ts" --include="*.js" . | grep -E "=\s*\[\]|=\s*\{\}|=\s*new Map|=\s*new Set" | grep -v node_modules | grep -v .next | grep -v test
```

### Ausencia de paginacion

```bash
# Endpoints que retornan colecciones (ya cubierto en 04, buscar tambien)
grep -rn "\.all()\|\.find({})\|findMany()" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v test

# Verificar si hay parametros de paginacion
grep -rn "skip\|offset\|limit\|page\|per_page\|page_size" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v test | head -10
```

### Configuraciones hardcodeadas que limitan escala

```bash
# Workers hardcodeados
grep -rn "workers\s*=" --include="*.py" --include="*.toml" --include="*.yml" --include="*.yaml" . | grep -v node_modules | grep -v __pycache__

# Pool de conexiones hardcodeado
grep -rn "pool_size\|max_connections\|connection_limit\|maxconn" --include="*.py" --include="*.ts" --include="*.yml" . | grep -v node_modules | grep -v __pycache__

# Limites hardcodeados
grep -rn "MAX_\|LIMIT_\|TIMEOUT_" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v .env
```

### Diseno de instancia unica

```bash
# Archivos escritos al disco (asume filesystem compartido)
grep -rn "open(.*'w'\|writeFileSync\|writeFile" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__ | grep -v test | grep -v config

# Scheduled tasks o cron jobs sin lock distribuido
grep -rn "schedule\|cron\|setInterval\|BackgroundTasks" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__ | grep -v test

# Sesiones en memoria
grep -rn "session\[.*\]\s*=\|req\.session\." --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__

# Cache en memoria local
grep -rn "lru_cache\|@cache\|NodeCache\|Map()\s*\/\/" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__
```

### Cuellos de botella potenciales

```bash
# Operaciones sincronas pesadas
grep -rn "time\.sleep\|setTimeout.*[0-9]\{4,\}" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v test

# Procesamiento de archivos sin streaming
grep -rn "readFileSync\|read()\|\.read()" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__ | grep -v test
```

## Como analizar

### Sistema escalable

- Sin estado mutable en memoria del servidor (o usando cache distribuido)
- Todas las colecciones paginadas
- Configuraciones de workers, pool y limites desde variables de entorno
- Tasks programados con lock distribuido
- Sesiones en almacenamiento externo (Redis, BD)
- Archivos en storage externo (S3, GCS), no en filesystem local

### Criterios de severidad

- **Critico**: Estado mutable en variables globales usado para datos de sesion o cache de usuarios. Sesiones almacenadas solo en memoria. Endpoints de colecciones sin ninguna forma de paginacion en tablas que pueden crecer.
- **Importante**: Cache en memoria sin alternativa distribuida. Workers y pool sizes hardcodeados. Archivos escritos al filesystem local sin alternativa de storage.
- **Mejora**: lru_cache para datos de configuracion que cambian poco. Scheduled tasks sin lock distribuido pero que toleran ejecucion duplicada.

## Soluciones de referencia

### Mover estado a almacenamiento externo

```python
# Antes: cache en memoria
users_cache = {}

def get_user(user_id: str):
    if user_id in users_cache:
        return users_cache[user_id]
    user = db.query(User).get(user_id)
    users_cache[user_id] = user
    return user

# Despues: cache en Redis
import redis

redis_client = redis.Redis.from_url(settings.REDIS_URL)

def get_user(user_id: str):
    cached = redis_client.get(f"user:{user_id}")
    if cached:
        return json.loads(cached)
    user = db.query(User).get(user_id)
    redis_client.setex(f"user:{user_id}", 300, json.dumps(user.dict()))
    return user
```

### Configuracion desde variables de entorno

```python
# Antes
uvicorn.run("app.main:app", workers=4, host="0.0.0.0", port=8000)

# Despues
import os
uvicorn.run(
    "app.main:app",
    workers=int(os.environ.get("WORKERS", "4")),
    host=os.environ.get("HOST", "0.0.0.0"),
    port=int(os.environ.get("PORT", "8000")),
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

_kroexus/08-escalabilidad.md
