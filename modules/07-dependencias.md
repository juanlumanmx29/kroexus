# Dependencias — Modulo Kroexus

## Objetivo

Auditar la salud de las dependencias del proyecto: CVEs conocidos, licencias
incompatibles, paquetes abandonados y riesgo por mantenedores unicos.

## Que buscar

### Listar dependencias

```bash
# Python
cat requirements.txt 2>/dev/null
cat pyproject.toml 2>/dev/null | grep -A 50 "\[project\]" | grep -A 50 "dependencies"

# Node.js
cat package.json 2>/dev/null | grep -A 100 "dependencies" | grep -B 0 "}"
```

### CVEs conocidos

```bash
# Python: usar pip-audit si esta disponible
pip-audit --requirement requirements.txt 2>/dev/null

# Node.js: usar npm audit si esta disponible
npm audit 2>/dev/null

# Alternativa: buscar en requirements.txt versiones conocidas como vulnerables
cat requirements.txt 2>/dev/null
```

Si las herramientas de auditoria no estan disponibles, verificar manualmente las
dependencias principales que tienen acceso a red o manejan datos:

Dependencias de alto riesgo a verificar primero:
- Frameworks web (fastapi, express, next)
- Clientes HTTP (requests, httpx, axios)
- ORMs y drivers de BD (sqlalchemy, prisma, pg)
- Librerias de autenticacion (jose, jsonwebtoken, passport)
- Librerias de criptografia

### Licencias

```bash
# Python: verificar licencias
pip show $(cat requirements.txt | sed 's/[>=<].*//' | tr '\n' ' ') 2>/dev/null | grep -E "Name:|License:"

# Node.js: verificar licencias
npx license-checker --json 2>/dev/null | head -100
```

Si las herramientas no estan disponibles, leer los archivos de manifiesto y para
cada dependencia critica (las que manejan datos o red), verificar la licencia en
su repositorio.

Licencias compatibles con uso comercial: MIT, Apache-2.0, BSD-2-Clause,
BSD-3-Clause, ISC, 0BSD, Unlicense.

Licencias que requieren revision legal: GPL-2.0, GPL-3.0, LGPL, AGPL, MPL-2.0,
EUPL, SSPL.

### Dependencias abandonadas

Para cada dependencia, verificar:

1. **Fecha del ultimo release**: Si no hay releases en mas de 18 meses, marcar como potencialmente abandonada.
2. **Numero de mantenedores**: Si tiene un solo mantenedor sin actividad reciente, es un riesgo de bus factor.
3. **Issues abiertos**: Si tiene mas de 100 issues abiertos sin respuesta, indica falta de mantenimiento.

Priorizar la verificacion en dependencias que:
- Tienen acceso a la red (clientes HTTP, SDKs de APIs)
- Manejan datos sensibles (auth, crypto)
- Son criticas para el funcionamiento (framework principal, ORM)

### Dependencias duplicadas o redundantes

```bash
# Node.js: multiples librerias para lo mismo
grep -E "axios|got|node-fetch|undici|superagent" package.json 2>/dev/null
grep -E "moment|dayjs|date-fns|luxon" package.json 2>/dev/null
grep -E "lodash|underscore|ramda" package.json 2>/dev/null

# Python: multiples librerias HTTP
grep -E "requests|httpx|urllib3|aiohttp" requirements.txt 2>/dev/null
```

## Como analizar

### Dependencias saludables

- Sin CVEs conocidos en la version instalada
- Licencias compatibles con uso comercial
- Release en los ultimos 12 meses
- Mas de un mantenedor activo
- Sin dependencias duplicadas que hagan lo mismo

### Criterios de severidad

- **Critico**: CVE con severidad alta o critica en una dependencia con acceso a red o datos. Licencia GPL/AGPL en proyecto comercial sin revision legal.
- **Importante**: Dependencia critica con un solo mantenedor sin actividad en 6+ meses. CVE de severidad media. Licencia ambigua sin verificar.
- **Mejora**: Dependencia sin release en 12+ meses pero sin CVEs. Dependencias duplicadas. Dependencia de desarrollo con licencia restrictiva.

## Soluciones de referencia

### Actualizar dependencia con CVE

```bash
# Python
pip install --upgrade nombre-paquete
# Actualizar requirements.txt con la version nueva

# Node.js
npm update nombre-paquete
# O para fixes de seguridad
npm audit fix
```

### Reemplazar dependencia abandonada

Documentar la alternativa recomendada para cada caso comun:

- `requests` abandonado -> `httpx` (async compatible, API similar)
- `python-jose` con pocos mantenedores -> `pyjwt` (mas activo)
- `moment.js` deprecated -> `date-fns` o `dayjs`

### Verificar licencia antes de instalar

Antes de agregar una dependencia nueva, ejecutar:

```bash
# Verificar repositorio, licencia, actividad
# En el navegador o con herramientas:
pip show nombre-paquete | grep -E "License|Home-page"
```

## Formato de output

Cada hallazgo usa esta estructura:

### [Nombre del hallazgo]
**Severidad**: Critico / Importante / Mejora
**Ubicacion**: requirements.txt / package.json (nombre del paquete y version)
**Riesgo**: que puede ocurrir si no se resuelve
**Solucion**: accion exacta a tomar (actualizar, reemplazar, verificar licencia)
**Esfuerzo**: 30 min / 2 horas / 1 dia / 1 semana

Incluir al inicio del reporte:
- Tabla con todas las dependencias, version, licencia, ultimo release, estado
- Resumen: N dependencias totales, N con CVEs, N con licencias a revisar, N potencialmente abandonadas

## Output file

_kroexus/07-dependencias.md
