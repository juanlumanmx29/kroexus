# Compliance — Modulo Kroexus

## Objetivo

Verificar el cumplimiento de normas de proteccion de datos personales: politicas
de retencion, PII en logs, exposicion de datos de terceros, mecanismos de
eliminacion y transferencia a servicios externos.

## Modo de operacion

Este modulo tiene dos modos:

- **Modo basico**: Se ejecuta cuando no se detectan datos personales en el proyecto.
  Solo verifica que no haya PII accidental en logs o respuestas.
- **Modo estricto**: Se ejecuta cuando se detectan datos personales. Todos los
  controles son obligatorios.

## Que buscar

### Deteccion de datos personales en el sistema

```bash
# Modelos con campos de PII
grep -rn "rut\|email\|password\|telefono\|phone\|direccion\|address\|nombre_completo\|full_name\|fecha_nacimiento\|birth_date\|tarjeta\|card_number" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v test | grep -v .env

# Tablas de usuarios
grep -rn "class.*User\|class.*Usuario\|model.*User\|model.*Usuario" --include="*.py" --include="*.ts" --include="*.prisma" . | grep -v node_modules | grep -v __pycache__
```

### PII en logs

```bash
# Logging que podria incluir datos personales
grep -rn "log.*email\|log.*rut\|log.*password\|log.*token\|log.*nombre\|log.*telefono\|log.*direccion" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__

# Print de objetos de usuario completos
grep -rn "print.*user\|log.*user\|logger.*user" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v test

# Logging de request/response body completo
grep -rn "log.*request\.\(body\|json\)\|log.*response\.\(body\|json\)" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__
```

### Endpoints que exponen datos de terceros

```bash
# Endpoints que retornan listas de usuarios o datos personales
grep -rn "def.*users\|def.*usuarios\|/users\|/usuarios" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v test

# Verificar si las respuestas filtran campos sensibles
# Buscar serializers o schemas de respuesta
grep -rn "class.*Response\|class.*Schema\|class.*Out" --include="*.py" -A 10 . | grep -v __pycache__
```

Para cada endpoint que retorna datos de usuarios, verificar:
- Que no expone campos como password_hash, tokens, datos internos
- Que los datos de un usuario no son accesibles por otro sin autorizacion
- Que las listas estan paginadas y no exponen toda la tabla

### Politica de retencion de datos

```bash
# Buscar documentacion de retencion
find . \( -name "retencion*" -o -name "retention*" -o -name "privacy*" -o -name "privacidad*" \) -not -path "*/node_modules/*"

# Buscar logica de eliminacion automatica o archivado
grep -rn "delete.*old\|cleanup\|purge\|archive\|retention" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v test
```

### Mecanismo de eliminacion de datos de usuario

```bash
# Buscar endpoint o funcion de eliminacion de cuenta/datos
grep -rn "def.*delete.*user\|def.*eliminar.*usuario\|def.*remove.*account\|def.*delete.*account" --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v __pycache__ | grep -v test

# Buscar cascada de eliminacion (eliminar datos relacionados)
grep -rn "cascade\|on_delete\|onDelete" --include="*.py" --include="*.ts" --include="*.prisma" . | grep -v node_modules | grep -v __pycache__
```

### Transferencia de datos a servicios externos

```bash
# Llamadas a APIs externas que envian datos de usuario
grep -rn "requests\.\(post\|put\|patch\)\|httpx\.\(post\|put\|patch\)\|fetch.*POST\|fetch.*PUT\|axios\.\(post\|put\|patch\)" --include="*.py" --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v __pycache__ | grep -v test

# Integraciones con servicios de analytics o tracking
grep -rn "analytics\|tracking\|mixpanel\|amplitude\|segment\|google.*analytics\|gtag\|hotjar" --include="*.py" --include="*.ts" --include="*.js" --include="*.html" . | grep -v node_modules | grep -v __pycache__
```

Para cada transferencia detectada, documentar:
- Que datos se envian
- A que servicio
- Si hay consentimiento del usuario documentado
- Si hay acuerdo de procesamiento de datos con el servicio

## Como analizar

### Compliance saludable

- Datos personales identificados y clasificados
- Politica de retencion documentada y con fecha de revision
- Mecanismo funcional para que un usuario solicite la eliminacion de sus datos
- PII nunca aparece en logs
- Endpoints de datos de usuario filtran campos sensibles
- Transferencias a terceros documentadas con base legal

### Criterios de severidad (modo estricto)

- **Critico**: PII en logs de produccion. Endpoint que expone datos sensibles sin autorizacion. Sin mecanismo de eliminacion de datos de usuario. Transferencia de datos a terceros sin documentar.
- **Importante**: Sin politica de retencion documentada. Respuestas que incluyen campos internos (IDs de BD, timestamps internos) que no deberian ser publicos. Eliminacion de usuario sin cascada a datos relacionados.
- **Mejora**: Politica de retencion documentada pero sin revision reciente. Ausencia de anonimizacion en datos usados para analytics.

### Criterios de severidad (modo basico)

- **Critico**: PII accidental en logs (email, telefono en mensajes de error).
- **Importante**: Respuestas de API que incluyen mas datos de los necesarios.
- **Mejora**: Sin documentacion explicita de que el sistema no maneja PII.

## Soluciones de referencia

### Filtrar PII de logs

```python
import logging
import re

class PIIFilter(logging.Filter):
    PII_PATTERNS = [
        (re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), '[EMAIL]'),
        (re.compile(r'\b\d{1,2}\.\d{3}\.\d{3}-[\dkK]\b'), '[RUT]'),
        (re.compile(r'\b\d{8,9}-[\dkK]\b'), '[RUT]'),
    ]

    def filter(self, record):
        msg = record.getMessage()
        for pattern, replacement in self.PII_PATTERNS:
            msg = pattern.sub(replacement, msg)
        record.msg = msg
        record.args = ()
        return True
```

### Schema de respuesta que filtra campos sensibles

```python
from pydantic import BaseModel

class UserResponse(BaseModel):
    id: int
    nombre: str
    email: str

    class Config:
        from_attributes = True

# Nunca retornar el modelo de BD directamente
# Siempre usar un schema de respuesta que solo incluya campos publicos
```

### Endpoint de eliminacion de datos

```python
@router.delete("/users/me")
async def delete_my_account(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # Eliminar datos relacionados primero
    db.query(Order).filter(Order.user_id == current_user.id).delete()
    db.query(UserProfile).filter(UserProfile.user_id == current_user.id).delete()

    # Eliminar el usuario
    db.query(User).filter(User.id == current_user.id).delete()
    db.commit()

    logger.info("Cuenta eliminada: user_id=%s", current_user.id)
    return {"detail": "Cuenta y datos eliminados correctamente"}
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
- Modo de operacion utilizado (basico o estricto)
- Lista de datos personales detectados en el sistema
- Resumen de transferencias a servicios externos

## Output file

_kroexus/09-compliance.md
