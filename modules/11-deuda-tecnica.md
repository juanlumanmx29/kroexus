# Deuda tecnica — Modulo Kroexus

## Objetivo

Sintetizar la deuda tecnica del proyecto: codigo duplicado, inconsistencias de
naming, archivos y funciones demasiado largos, TODOs abandonados y patrones
problematicos repetidos encontrados en otros modulos.

## Que buscar

### Codigo duplicado

```bash
# Buscar bloques de codigo similares (funciones con nombres parecidos)
grep -rn "def \|function \|const.*=.*=>" --include="*.py" --include="*.ts" --include="*.tsx" . | grep -v node_modules | grep -v __pycache__ | grep -v test | grep -v .next | sort -t: -k3 | head -40

# Buscar imports repetidos del mismo modulo en muchos archivos
grep -rn "^from \|^import " --include="*.py" . | grep -v __pycache__ | sort -t: -k2 | uniq -f1 -d | head -20

# Buscar patrones de manejo de errores duplicados
grep -rn "try:" --include="*.py" -A 5 . | grep -v __pycache__ | head -40
grep -rn "try {" --include="*.ts" --include="*.tsx" -A 5 . | grep -v node_modules | head -40
```

### Inconsistencias de naming

```bash
# Python: mezcla de snake_case y camelCase
grep -rn "def [a-z]*[A-Z]" --include="*.py" . | grep -v __pycache__ | grep -v .venv

# TypeScript: mezcla de convenciones en archivos
find . -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v .next | head -30
# Verificar si los nombres de archivo son consistentes (kebab-case, camelCase, PascalCase)

# Variables con nombres poco descriptivos
grep -rn "data\s*=\|result\s*=\|temp\s*=\|tmp\s*=\|x\s*=\|val\s*=" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v test | head -20
```

### Archivos demasiado largos (>300 lineas)

```bash
# Contar lineas por archivo
find . \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -not -path "*/node_modules/*" -not -path "*/__pycache__/*" -not -path "*/.next/*" -not -path "*/.venv/*" | xargs wc -l 2>/dev/null | sort -rn | head -20
```

### Funciones demasiado largas (>50 lineas)

```bash
# Python: buscar funciones largas
grep -rn "def " --include="*.py" . | grep -v __pycache__ | grep -v .venv | grep -v test
# Para cada funcion encontrada, contar lineas hasta la siguiente funcion o fin de indentacion

# TypeScript: buscar funciones largas
grep -rn "function \|const.*=.*=>\|async " --include="*.ts" --include="*.tsx" . | grep -v node_modules | grep -v .next | grep -v test
```

Para identificar funciones largas, leer los archivos con mas lineas (del paso
anterior) y buscar funciones que excedan 50 lineas.

### TODOs y FIXMEs abandonados

```bash
# Buscar todos los TODO, FIXME, HACK, XXX
grep -rn "TODO\|FIXME\|HACK\|XXX\|TEMP\|WORKAROUND" --include="*.py" --include="*.ts" --include="*.tsx" --include="*.js" . | grep -v node_modules | grep -v __pycache__ | grep -v .next

# Verificar antigedad con git blame (si hay git)
# Para cada TODO encontrado, ejecutar:
# git blame -L linea,linea archivo
# Si tiene mas de 3 meses, es abandonado
```

### Patrones repetidos de otros modulos

Si ya se ejecutaron otros modulos de la auditoria, leer los reportes en `_kroexus/`
y buscar patrones que se repiten:

```bash
# Leer reportes existentes
ls _kroexus/*.md 2>/dev/null | grep -v ".modules"
```

Patrones comunes a buscar:
- El mismo tipo de hallazgo de seguridad aparece en multiples archivos
- La misma falta de timeout se repite en varias integraciones
- El mismo patron de error handling incompleto se repite
- Ausencia sistematica de validacion de inputs

## Como analizar

### Base de codigo saludable

- Archivos de menos de 300 lineas con responsabilidad clara
- Funciones de menos de 50 lineas con un solo proposito
- Naming consistente en todo el proyecto (misma convencion)
- Sin TODOs de mas de un mes sin resolver
- Sin codigo duplicado que deberia ser una funcion compartida

### Criterios de severidad

- **Critico**: Patrones de seguridad insegura repetidos en todo el proyecto (indica problema sistematico). Codigo duplicado que maneja logica critica de forma ligeramente diferente en cada copia (inconsistencia peligrosa).
- **Importante**: Archivos de mas de 500 lineas. Funciones de mas de 100 lineas. TODOs y FIXMEs de mas de 3 meses. Inconsistencia de naming que causa confusion.
- **Mejora**: Archivos entre 300 y 500 lineas. Funciones entre 50 y 100 lineas. Codigo duplicado en logica no critica. Variables con nombres poco descriptivos.

## Soluciones de referencia

### Extraer funcion duplicada

Cuando el mismo bloque de codigo aparece en mas de dos lugares:

```python
# Antes: duplicado en routes/users.py y routes/orders.py
def get_users():
    try:
        items = db.query(User).all()
    except Exception as e:
        logger.error("Error: %s", str(e))
        raise HTTPException(status_code=500)

def get_orders():
    try:
        items = db.query(Order).all()
    except Exception as e:
        logger.error("Error: %s", str(e))
        raise HTTPException(status_code=500)

# Despues: funcion compartida en services/base.py
def get_all(db: Session, model):
    try:
        return db.query(model).all()
    except Exception as e:
        logger.error("Error consultando %s: %s", model.__name__, str(e))
        raise HTTPException(status_code=500)
```

### Dividir archivo largo

Si un archivo tiene mas de 300 lineas, identificar grupos de funciones relacionadas
y extraerlos a archivos separados dentro de la misma carpeta.

### Resolver o documentar TODOs

Para cada TODO abandonado, tomar una de dos acciones:
1. Resolver el TODO ahora si el esfuerzo es menor a 30 minutos
2. Convertirlo en un issue documentado con contexto y prioridad, y eliminar el
   comentario TODO del codigo

## Formato de output

Cada hallazgo usa esta estructura:

### [Nombre del hallazgo]
**Severidad**: Critico / Importante / Mejora
**Ubicacion**: ruta/archivo.py:linea (o "global" si aplica a todo el proyecto)
**Riesgo**: que puede ocurrir si no se resuelve
**Solucion**: codigo o configuracion exacta para este proyecto
**Esfuerzo**: 30 min / 2 horas / 1 dia / 1 semana

Incluir al inicio del reporte:
- Resumen numerico: N archivos >300 lineas, N funciones >50 lineas, N TODOs abandonados
- Patrones repetidos encontrados en otros modulos (si aplica)
- Deuda acumulada estimada en horas de trabajo

## Output file

_kroexus/11-deuda-tecnica.md
