# Performance — Modulo Kroexus

## Objetivo

Identificar problemas de rendimiento: queries N+1, colecciones sin paginacion,
operaciones sincronas bloqueantes, assets sin optimizar e indices faltantes.

## Que buscar

### Queries N+1 (consultas a BD dentro de loops)

```bash
# Python: queries dentro de for/while
grep -rn "for.*in.*:" --include="*.py" -A 8 . | grep -E "\.query\(|\.filter\(|\.get\(|\.find\(|\.execute\(" | grep -v __pycache__ | grep -v .venv

# Python: acceso a relaciones dentro de loops (lazy loading)
grep -rn "for.*in.*:" --include="*.py" -A 5 . | grep -E "\.[a-z_]+s$\|\.[a-z_]+_set" | grep -v __pycache__

# TypeScript: queries dentro de loops
grep -rn "for.*of\|\.forEach\|\.map" --include="*.ts" --include="*.tsx" -A 5 . | grep -E "\.find\(|\.findOne\(|\.query\(|prisma\." | grep -v node_modules
```

### Endpoints que retornan colecciones sin paginacion

```bash
# Python: endpoints que retornan .all() sin limit/offset
grep -rn "\.all()\|\.find()\|\.select()" --include="*.py" . | grep -v __pycache__ | grep -v .venv | grep -v test

# Buscar ausencia de parametros skip/limit/page en endpoints de colecciones
grep -rn "@app\.\(get\|post\)\|@router\.\(get\|post\)" --include="*.py" -A 15 . | grep -v __pycache__ | grep -E "def.*list|def.*all|def.*get.*s\(" | head -20

# TypeScript: retorno de colecciones completas
grep -rn "\.find({})\|\.find()\|findMany()" --include="*.ts" . | grep -v node_modules | grep -v test
```

### Operaciones sincronas que podrian ser async

```bash
# Python: llamadas HTTP sincronas en funciones async
grep -rn "requests\.\(get\|post\|put\|delete\)" --include="*.py" . | grep -v __pycache__ | grep -v .venv

# Python: operaciones de archivo sincronas en handlers async
grep -rn "open(" --include="*.py" . | grep -v __pycache__ | grep -v .venv | grep -v test | grep -v config

# Python: time.sleep en funciones async
grep -rn "time\.sleep\|import time" --include="*.py" . | grep -v __pycache__ | grep -v test
```

### Assets frontend sin optimizar

```bash
# Imagenes grandes sin optimizacion
find . \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) -size +500k -not -path "*/node_modules/*" -not -path "*/.next/*"

# Imagenes usadas sin next/image o lazy loading
grep -rn "<img " --include="*.tsx" --include="*.jsx" --include="*.html" . | grep -v node_modules | grep -v .next

# Verificar si usa next/image o imagen optimizada
grep -rn "next/image\|Image.*from" --include="*.tsx" --include="*.jsx" . | grep -v node_modules | head -5

# Bundle sin code splitting (importaciones dinamicas)
grep -rn "import(" --include="*.tsx" --include="*.jsx" --include="*.ts" . | grep -v node_modules | grep -v .next | head -10
```

### Indices de base de datos faltantes

```bash
# Campos usados frecuentemente en filtros (Python/SQLAlchemy)
grep -rn "\.filter\(.*==\|\.filter_by\(" --include="*.py" . | grep -v __pycache__ | grep -v test

# Modelos sin indices definidos
grep -rn "class.*Model\|class.*Base\)" --include="*.py" -A 20 . | grep -E "Column\(|index=" | grep -v __pycache__

# Prisma: campos usados en where sin @index
grep -rn "where:" --include="*.ts" -A 3 . | grep -v node_modules | head -20
```

## Como analizar

### Distinguir falso positivo de riesgo real

- **N+1**: Si el loop procesa pocos elementos (menos de 10), el impacto es menor. Si la coleccion puede crecer sin limite, es riesgo real.
- **Sin paginacion**: Si el endpoint retorna datos de configuracion (pocos registros fijos), no necesita paginacion. Si retorna datos de usuarios, ordenes, productos (puede crecer), necesita paginacion.
- **Sync en async**: Si la operacion es rapida y no bloquea (leer un archivo de config pequeño), es aceptable. Si es una llamada HTTP o lectura de archivo grande, es riesgo.
- **Imagenes grandes**: Si son imagenes de documentacion o assets estaticos que se sirven con CDN, menor riesgo. Si se cargan en la UI principal, riesgo alto.

### Criterios de severidad

- **Critico**: N+1 en colecciones sin limite que pueden crecer. Endpoints de colecciones sin ningun tipo de paginacion en tablas con datos de usuarios.
- **Importante**: Llamadas HTTP sincronas en handlers async. Imagenes de mas de 1MB cargadas en la UI. Ausencia de indices en campos filtrados frecuentemente.
- **Mejora**: Imagenes entre 500KB y 1MB. Lazy loading ausente en imagenes below-the-fold. Code splitting no implementado.

## Soluciones de referencia

### Corregir N+1 con eager loading

```python
# SQLAlchemy: usar joinedload
from sqlalchemy.orm import joinedload

users = db.query(User).options(joinedload(User.orders)).all()
```

### Agregar paginacion

```python
from fastapi import Query

@router.get("/items")
async def list_items(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    items = db.query(Item).offset(skip).limit(limit).all()
    total = db.query(Item).count()
    return {"items": items, "total": total, "skip": skip, "limit": limit}
```

### Reemplazar requests sincronico por httpx async

```python
# Antes
import requests
response = requests.get("https://api.externa.com/datos")

# Despues
import httpx
async with httpx.AsyncClient(timeout=10.0) as client:
    response = await client.get("https://api.externa.com/datos")
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

_kroexus/04-performance.md
