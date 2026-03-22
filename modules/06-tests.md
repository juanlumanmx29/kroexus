# Tests — Modulo Kroexus

## Objetivo

Evaluar la cobertura y calidad de los tests: identificar las rutas mas criticas
del proyecto y verificar si tienen tests que prueben comportamiento real.

## Que buscar

### Existencia de tests

```bash
# Buscar archivos de test
find . \( -name "test_*.py" -o -name "*_test.py" -o -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.ts" -o -name "*.spec.tsx" \) -not -path "*/node_modules/*" -not -path "*/.next/*" -not -path "*/__pycache__/*" | sort

# Contar tests
find . \( -name "test_*.py" -o -name "*_test.py" -o -name "*.test.ts" -o -name "*.test.tsx" \) -not -path "*/node_modules/*" | wc -l

# Buscar carpeta de tests
find . -type d -name "tests" -o -name "__tests__" -o -name "test" | grep -v node_modules | grep -v __pycache__
```

### Configuracion de testing

```bash
# Python: pytest configurado
find . \( -name "pytest.ini" -o -name "pyproject.toml" -o -name "setup.cfg" \) -not -path "*/node_modules/*" | head -5
grep -l "pytest\|unittest" requirements.txt pyproject.toml setup.cfg 2>/dev/null

# JavaScript/TypeScript: jest, vitest, etc.
grep -rn "jest\|vitest\|mocha\|cypress\|playwright" package.json 2>/dev/null | head -5
```

### Las 3 rutas mas criticas del proyecto

Para identificar las funciones o rutas mas criticas, usar estos criterios:

```bash
# Endpoints con mas logica (funciones mas largas en routes)
find . -path "*/routes/*" -o -path "*/api/*" | grep -E "\.(py|ts|tsx)$" | grep -v node_modules | grep -v __pycache__ | grep -v .next

# Archivos mas importados (mayor impacto si fallan)
for f in $(find . -name "*.py" -not -path "*/node_modules/*" -not -path "*/__pycache__/*" -not -path "*/.venv/*" | head -30); do
  name=$(basename "$f" .py)
  count=$(grep -rl "$name" --include="*.py" . 2>/dev/null | grep -v __pycache__ | wc -l)
  if [ "$count" -gt 3 ]; then
    echo "$count refs: $f"
  fi
done

# Funciones relacionadas con autenticacion, pagos, datos sensibles
grep -rn "def.*login\|def.*auth\|def.*pay\|def.*create_user\|def.*delete\|def.*register" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v test
```

Seleccionar las 3 funciones o rutas mas criticas basandose en:
1. Manejo de autenticacion o autorizacion
2. Operaciones con dinero o pagos
3. Creacion o eliminacion de datos de usuarios

### Tests de comportamiento vs tests superficiales

Para cada test encontrado, verificar si:

```bash
# Tests que solo verifican que no lanza excepcion (superficiales)
grep -rn "assert.*True\|assert.*is not None\|expect.*toBeTruthy\|expect.*toBeDefined" --include="test_*.py" --include="*.test.ts" --include="*.test.tsx" . | grep -v node_modules

# Tests que verifican valores especificos (comportamiento real)
grep -rn "assert.*==\|assertEqual\|expect.*toBe\|expect.*toEqual\|expect.*toContain" --include="test_*.py" --include="*.test.ts" --include="*.test.tsx" . | grep -v node_modules
```

### Tests de integracion

```bash
# Buscar tests que usan BD real o TestClient
grep -rn "TestClient\|httpx.AsyncClient\|supertest\|request(app)" --include="test_*.py" --include="*.test.ts" . | grep -v node_modules | grep -v __pycache__

# Buscar fixtures de BD
grep -rn "fixture\|beforeAll\|beforeEach\|setup\|teardown" --include="test_*.py" --include="*.test.ts" . | grep -v node_modules | grep -v __pycache__ | head -10
```

## Como analizar

### Testing saludable

- Las 3 rutas mas criticas tienen tests que verifican comportamiento real
- Existen tests de integracion que prueban el flujo completo (request -> response)
- Los tests no dependen de mock data hardcodeada que puede divergir de produccion
- La configuracion de testing esta lista para correr con un solo comando

### Senales de problemas

- **Sin tests**: No hay archivos de test en el proyecto. Riesgo maximo.
- **Tests superficiales**: Solo verifican que la funcion no lanza excepcion, no verifican el resultado correcto.
- **Rutas criticas sin cobertura**: Autenticacion, pagos o eliminacion de datos sin tests.
- **Solo tests unitarios, sin integracion**: Cada funcion pasa sus tests pero el flujo completo puede fallar.
- **Tests con mock data divergente**: Mocks que no reflejan la estructura real de los datos.

### Criterios de severidad

- **Critico**: Ausencia total de tests. Funciones de autenticacion o pagos sin ningun test. Tests que pasan pero no verifican nada real (assert True).
- **Importante**: Menos de 3 tests para las rutas criticas del proyecto. Ausencia de tests de integracion. Configuracion de testing incompleta.
- **Mejora**: Tests presentes pero no cubren edge cases. Ausencia de tests para funciones auxiliares.

## Soluciones de referencia

### Test de integracion para FastAPI

```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "version" in data
    assert "timestamp" in data


def test_create_user_returns_user_data():
    response = client.post(
        "/api/users",
        json={"nombre": "Test", "email": "test@example.com"},
    )
    assert response.status_code == 201
    data = response.json()
    assert data["nombre"] == "Test"
    assert data["email"] == "test@example.com"
    assert "id" in data
```

### Test de integracion para Next.js API routes

```typescript
import { GET } from "@/app/api/health/route";

describe("Health check", () => {
  it("retorna status ok con version y timestamp", async () => {
    const response = await GET();
    const data = await response.json();

    expect(response.status).toBe(200);
    expect(data.status).toBe("ok");
    expect(data).toHaveProperty("version");
    expect(data).toHaveProperty("timestamp");
  });
});
```

## Formato de output

Cada hallazgo usa esta estructura:

### [Nombre del hallazgo]
**Severidad**: Critico / Importante / Mejora
**Ubicacion**: ruta/archivo.py:linea (o "global" si aplica a todo el proyecto)
**Riesgo**: que puede ocurrir si no se resuelve
**Solucion**: codigo o configuracion exacta para este proyecto
**Esfuerzo**: 30 min / 2 horas / 1 dia / 1 semana

Incluir al inicio del reporte:
- Tabla con las 3 rutas criticas identificadas y si tienen tests
- Numero total de archivos de test y tests individuales
- Relacion tests de integracion vs tests unitarios

## Output file

_kroexus/06-tests.md
