# Arquitectura — Modulo Kroexus

## Objetivo

Mapear la arquitectura real del sistema, documentar el flujo de datos entre capas
e identificar acoplamiento problematico entre modulos.

## Que buscar

### Estructura de carpetas

```bash
find . -type d -not -path "*/node_modules/*" -not -path "*/.next/*" -not -path "*/__pycache__/*" -not -path "*/.git/*" -not -path "*/.venv/*" -not -path "*/_kroexus/*" | sort
```

### Mapa de dependencias entre modulos

```bash
# Python: imports entre modulos internos
grep -rn "^from app\.\|^import app\." --include="*.py" . | grep -v __pycache__ | grep -v .venv

# TypeScript/JavaScript: imports entre modulos internos
grep -rn "from ['\"]@/\|from ['\"]\\./\|from ['\"]\\.\\./" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" . | grep -v node_modules | grep -v .next
```

### Archivos con demasiadas dependencias (posible god module)

```bash
# Archivos que son importados por mas de 5 otros archivos
for f in $(find . -name "*.py" -o -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v __pycache__ | grep -v .next); do
  count=$(grep -rl "$(basename $f .py)\|$(basename $f .ts)\|$(basename $f .tsx)" --include="*.py" --include="*.ts" --include="*.tsx" . 2>/dev/null | grep -v node_modules | wc -l)
  if [ "$count" -gt 5 ]; then
    echo "$count dependientes: $f"
  fi
done
```

### Capas del sistema

```bash
# Buscar patrones de capas: routes/controllers, services, models/schemas, repositories
find . -type d \( -name "routes" -o -name "controllers" -o -name "services" -o -name "models" -o -name "schemas" -o -name "repositories" -o -name "api" \) -not -path "*/node_modules/*" -not -path "*/.next/*"
```

### Llamadas entre capas

```bash
# Rutas/controllers que llaman directamente a la base de datos (sin pasar por services)
grep -rn "\.query\|\.execute\|\.find\|\.findOne\|\.create\|\.update\|\.delete" --include="*.py" --include="*.ts" . | grep -i "route\|controller\|endpoint" | grep -v node_modules
```

## Como analizar

### Arquitectura saludable

- Separacion clara entre capas: rutas/controladores, servicios, modelos, repositorios
- Cada carpeta tiene una responsabilidad definida
- Los controladores/rutas no contienen logica de negocio directa
- Los servicios no acceden directamente a la base de datos si existe una capa de repositorio
- No hay dependencias circulares entre modulos

### Senales de problemas

- **God module**: Un archivo importado por mas de 10 otros archivos. Indica acoplamiento excesivo.
- **Capa saltada**: Un controlador que accede directamente a la base de datos sin pasar por el servicio. Indica falta de separacion de responsabilidades.
- **Dependencia circular**: El modulo A importa de B y B importa de A. Indica acoplamiento fuerte que dificulta refactorizacion.
- **Carpeta cajun de sastre**: Una carpeta `utils/` o `helpers/` con mas de 10 archivos sin relacion entre si.
- **Logica de negocio en la ruta**: Funciones de ruta con mas de 20 lineas de logica que deberia estar en un servicio.

### Criterios de severidad

- **Critico**: Dependencias circulares que causan problemas de importacion. Ausencia total de separacion entre capas.
- **Importante**: God modules con mas de 10 dependientes. Logica de negocio directa en controladores/rutas. Capas saltadas sistematicamente.
- **Mejora**: Carpetas utils demasiado grandes. Inconsistencia menor en la organizacion de archivos.

## Soluciones de referencia

### Separar logica de negocio del controlador

Antes (problematico):
```python
@router.post("/orders")
async def create_order(order_data: OrderCreate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == order_data.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    order = Order(**order_data.dict())
    db.add(order)
    db.commit()
    # ... 30 lineas mas de logica
    return order
```

Despues (correcto):
```python
@router.post("/orders")
async def create_order(order_data: OrderCreate, db: Session = Depends(get_db)):
    return await order_service.create(db, order_data)
```

### Romper dependencia circular

Si `services/auth.py` importa de `services/user.py` y viceversa, extraer la
funcionalidad compartida a un tercer modulo o usar inyeccion de dependencias.

## Formato de output

Cada hallazgo usa esta estructura:

### [Nombre del hallazgo]
**Severidad**: Critico / Importante / Mejora
**Ubicacion**: ruta/archivo.py:linea (o "global" si aplica a todo el proyecto)
**Riesgo**: que puede ocurrir si no se resuelve
**Solucion**: codigo o configuracion exacta para este proyecto
**Esfuerzo**: 30 min / 2 horas / 1 dia / 1 semana

Incluir al inicio del reporte:
- Diagrama textual del flujo de datos entre capas
- Lista de carpetas con su responsabilidad
- Mapa de dependencias entre modulos principales

## Output file

_kroexus/01-arquitectura.md
