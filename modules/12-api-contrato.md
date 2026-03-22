# API Contrato — Modulo Kroexus

## Objetivo

Documentar todos los endpoints del proyecto en formato legible para humanos:
metodo, ruta, autenticacion, parametros, respuestas y errores.

## Que buscar

### Detectar endpoints

```bash
# FastAPI: decoradores de ruta
grep -rn "@app\.\(get\|post\|put\|delete\|patch\)\|@router\.\(get\|post\|put\|delete\|patch\)" --include="*.py" . | grep -v __pycache__ | grep -v .venv | grep -v test

# Next.js: API routes
find . -path "*/api/*" \( -name "route.ts" -o -name "route.js" \) -not -path "*/node_modules/*" -not -path "*/.next/*"

# Express: rutas
grep -rn "app\.\(get\|post\|put\|delete\|patch\)\|router\.\(get\|post\|put\|delete\|patch\)" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v test
```

### Extraer detalles de cada endpoint

Para cada endpoint encontrado, leer el archivo y extraer:

**Metodo HTTP y ruta:**
```bash
# El decorador ya contiene metodo y ruta
# @router.get("/users/{user_id}") -> GET /users/{user_id}
```

**Autenticacion requerida:**
```bash
# FastAPI: buscar Depends con auth
grep -rn "Depends.*auth\|Depends.*get_current_user\|Depends.*verify" --include="*.py" . | grep -v __pycache__

# Next.js: buscar middleware o verificacion de sesion
grep -rn "getServerSession\|getToken\|auth()\|requireAuth" --include="*.ts" -path "*/api/*" . | grep -v node_modules
```

**Parametros de entrada:**
```bash
# FastAPI: modelos Pydantic de input
grep -rn "class.*Create\|class.*Update\|class.*Input\|class.*Request" --include="*.py" -A 15 . | grep -v __pycache__

# FastAPI: Query params y Path params
grep -rn "Query(\|Path(\|Body(" --include="*.py" . | grep -v __pycache__
```

**Estructura de respuesta:**
```bash
# FastAPI: modelos de respuesta
grep -rn "class.*Response\|class.*Out\|class.*Schema" --include="*.py" -A 15 . | grep -v __pycache__

# FastAPI: response_model en decorador
grep -rn "response_model" --include="*.py" . | grep -v __pycache__
```

**Posibles errores:**
```bash
# HTTPException en el endpoint
grep -rn "HTTPException\|raise.*Error\|status_code" --include="*.py" . | grep -v __pycache__ | grep -v test

# Next.js: NextResponse con status de error
grep -rn "NextResponse.*status\|new Response.*status" --include="*.ts" -path "*/api/*" . | grep -v node_modules
```

## Como analizar

### Documentacion saludable

- Cada endpoint tiene su metodo, ruta y proposito documentado
- Los parametros de entrada estan tipados y documentados
- Las respuestas exitosas tienen estructura definida
- Los posibles errores estan listados con sus codigos HTTP
- La autenticacion requerida esta clara

### Senales de problemas

- **Endpoints sin modelo de entrada tipado**: Reciben dict o Any, no hay forma de saber que datos esperan.
- **Sin modelo de respuesta**: No hay schema definido para la respuesta, el contrato es implicito.
- **Errores sin documentar**: El endpoint puede retornar 404, 403, 422 pero no esta documentado.
- **Rutas inconsistentes**: Mezcla de convenciones (`/get-users`, `/users`, `/api/v1/users`).

### Criterios de severidad

- **Critico**: Endpoints criticos (auth, pagos) sin documentacion de parametros ni errores.
- **Importante**: Mas del 50% de endpoints sin modelo de respuesta definido. Convenciones de ruta inconsistentes.
- **Mejora**: Documentacion presente pero incompleta (faltan posibles errores). Endpoints documentados pero sin ejemplos.

## Formato de documentacion

Para cada endpoint, generar esta ficha:

```markdown
### [Metodo] [Ruta]

**Proposito**: Descripcion breve de lo que hace el endpoint.

**Autenticacion**: Requerida / No requerida / Opcional
Si requerida: Bearer token / Cookie de sesion / API key

**Parametros de entrada**:

| Parametro | Tipo | Ubicacion | Requerido | Descripcion |
|-----------|------|-----------|-----------|-------------|
| user_id   | int  | path      | si        | ID del usuario |
| page      | int  | query     | no        | Pagina (default: 1) |
| nombre    | str  | body      | si        | Nombre del recurso |

**Respuesta exitosa** (200/201):
```json
{
  "id": 1,
  "nombre": "valor",
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Posibles errores**:

| Codigo | Descripcion |
|--------|-------------|
| 401    | Token no proporcionado o invalido |
| 404    | Recurso no encontrado |
| 422    | Datos de entrada invalidos |
```

## Soluciones de referencia

### Agregar modelo de respuesta a FastAPI

```python
from pydantic import BaseModel
from datetime import datetime

class ItemResponse(BaseModel):
    id: int
    nombre: str
    created_at: datetime

    class Config:
        from_attributes = True

@router.get("/items/{item_id}", response_model=ItemResponse)
async def get_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Item).get(item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item no encontrado")
    return item
```

### Estandarizar convenciones de ruta

Convenciones recomendadas:
- Recursos en plural: `/users`, `/orders`, `/products`
- IDs en la ruta: `/users/{user_id}`
- Acciones como sub-recurso: `/users/{user_id}/activate`
- Filtros como query params: `/users?role=admin&page=1`
- Versionado en prefijo: `/api/v1/users`

## Formato de output

El output de este modulo es diferente al de los demas: en lugar de hallazgos
con severidad, genera la documentacion completa de la API.

Si hay problemas de documentacion (endpoints sin tipado, respuestas sin schema),
registrarlos como hallazgos al final del documento con el formato estandar:

### [Nombre del hallazgo]
**Severidad**: Critico / Importante / Mejora
**Ubicacion**: ruta/archivo.py:linea
**Riesgo**: que puede ocurrir si no se resuelve
**Solucion**: accion exacta a tomar
**Esfuerzo**: 30 min / 2 horas / 1 dia / 1 semana

## Output file

_kroexus/12-api-contrato.md
