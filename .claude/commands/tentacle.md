---
description: Genera template de repositorio para desarrollador externo
---

# /tentacle — Template para desarrollador externo

Generar un repositorio template completo que un desarrollador externo pueda usar
para construir un modulo del proyecto sin acceso al repositorio principal.
El template incluye tokens de diseno, componentes existentes, patrones de API
y contratos de integracion.

## Paso 1: Extraer tokens de diseno

Buscar los tokens de diseno reales del proyecto:

```bash
# CSS custom properties
grep -rn "^  --" --include="*.css" . | grep -v node_modules | grep -v .next

# Tailwind config (si existe)
find . -name "tailwind.config.*" -not -path "*/node_modules/*"

# Archivos de tokens o theme
find . \( -name "tokens.*" -o -name "theme.*" -o -name "variables.*" \) -not -path "*/node_modules/*" -not -path "*/.next/*"
```

Si se encuentran tokens, extraerlos completos. Registrar:
- Paleta de colores completa
- Escala tipografica
- Escala de espaciado
- Radios de borde
- Sombras
- Breakpoints (si existen)

## Paso 2: Inventariar componentes

Buscar todos los componentes del proyecto:

```bash
# Componentes React/Next.js
find . -path "*/components/*" \( -name "*.tsx" -o -name "*.jsx" \) -not -path "*/node_modules/*"

# Componentes por nombre de archivo
find . \( -name "*.component.ts" -o -name "*.component.tsx" \) -not -path "*/node_modules/*"
```

Para cada componente encontrado, registrar:
- Nombre del componente
- Ruta del archivo
- Props que recibe (leer las interfaces/types)
- Si es un componente de UI base (boton, input, card) o de negocio

Clasificar en:
- **Componentes base**: reutilizables, sin logica de negocio (Button, Input, Card, Modal)
- **Componentes de layout**: definen estructura de pagina (Header, Sidebar, PageLayout)
- **Componentes de negocio**: logica especifica del dominio (no incluir en el template)

## Paso 3: Detectar patrones de API

Buscar como el proyecto hace llamadas al API:

```bash
# Cliente HTTP centralizado
find . \( -name "client.ts" -o -name "api-client.ts" -o -name "http.ts" \) -path "*/api/*" -not -path "*/node_modules/*"

# Llamadas fetch/axios
grep -rn "fetch\|axios\|httpx" --include="*.ts" --include="*.tsx" --include="*.py" . | grep -v node_modules | grep -v .next | head -20

# Endpoints del backend
grep -rn "@app\.\(get\|post\|put\|delete\|patch\)\|@router\.\(get\|post\|put\|delete\|patch\)" --include="*.py" . | grep -v __pycache__
```

Documentar:
- Si existe un cliente HTTP centralizado y como se usa
- Patron de autenticacion (Bearer token, cookies, etc.)
- Estructura de respuestas (envelope pattern, errores estandarizados, etc.)
- Base URL y como se configura

## Paso 4: Generar el template

Crear la carpeta `_kroexus/_tentaculo/` con los siguientes archivos:

### _kroexus/_tentaculo/README.md

```markdown
# [Nombre del proyecto] — Modulo externo

## Tu mision

[COMPLETAR: describir el modulo especifico que debe construir este desarrollador]

## Configuracion del entorno

1. Clonar este repositorio
2. Instalar dependencias: [comando segun el stack]
3. Copiar `.env.example` a `.env` y completar con los valores proporcionados
4. Ejecutar en modo desarrollo: [comando segun el stack]

## Estructura esperada

Tu codigo debe seguir esta estructura:

[Estructura de carpetas que debe seguir el desarrollador, basada en
los patrones del proyecto principal]

## Reglas de integracion

- Seguir los patrones de codigo documentados en CONTRATO.md
- Usar los tokens de diseno documentados en CONTEXTO.md
- No instalar dependencias adicionales sin aprobacion previa
- Todo endpoint nuevo debe documentarse con metodo, ruta, parametros y respuesta
- Todo componente nuevo debe usar los tokens de diseno existentes

## Entrega

Al completar el modulo:

1. Asegurar que no hay errores en build ni en tests
2. Documentar cualquier variable de entorno nueva en .env.example
3. Listar los endpoints nuevos con su documentacion
4. Confirmar que el codigo sigue los patrones del CONTRATO.md
```

### _kroexus/_tentaculo/CONTRATO.md

```markdown
# Contrato de integracion

## Reglas de codigo

### Generales
- Sin emojis en codigo, comentarios ni documentacion
- Sin colores morados ni violetas en estilos
- Sin gradientes CSS
- Ortografia y tildes correctas en texto en espanol
- Sin datos inventados (mock data)

### Seguridad
- Secrets y API keys en variables de entorno, nunca en el codigo
- Toda llamada HTTP con timeout explicito
- Todo input de usuario validado antes de procesarse
- No loggear datos sensibles (passwords, tokens, datos personales)

### Calidad
- Manejo explicito de errores (sin catch generico sin logging)
- Paginacion en endpoints que retornan colecciones
- Tests para el flujo critico principal del modulo

### Estilo de codigo

[Insertar aqui los patrones detectados del proyecto:]
- Convencion de nombres de archivos
- Convencion de nombres de variables y funciones
- Estructura de imports
- Patron de manejo de errores utilizado

### Patron de llamadas al API

[Insertar aqui el patron detectado en Paso 3:]
- Como se usa el cliente HTTP
- Como se manejan los errores de API
- Como se envian headers de autenticacion
```

### _kroexus/_tentaculo/CONTEXTO.md

```markdown
# Contexto del proyecto

## Tokens de diseno

[Insertar aqui los tokens extraidos en Paso 1, completos]

## Componentes disponibles

[Insertar aqui el inventario de componentes del Paso 2]

Para cada componente base y de layout:
- Nombre
- Props disponibles
- Ejemplo de uso

## Patrones de API

[Insertar aqui los patrones detectados en Paso 3]

- URL base del API
- Patron de autenticacion
- Estructura de respuestas
- Manejo de errores

## Dependencias del proyecto

[Listar las dependencias principales del proyecto con sus versiones,
para que el desarrollador externo use versiones compatibles]
```

## Paso 5: Resultado al usuario

Imprimir en el chat:

```
--- Tentaculo generado ---

Template creado en: _kroexus/_tentaculo/

Archivos generados:
  README.md     Instrucciones para el desarrollador externo
  CONTRATO.md   Reglas de codigo y patrones de integracion
  CONTEXTO.md   Tokens de diseno, componentes y patrones de API

Componentes inventariados: [N] ([N] base, [N] layout, [N] negocio)
Tokens de diseno extraidos: [si/no]
Patrones de API documentados: [si/no]

Siguiente paso: Editar la seccion "Tu mision" en README.md con la
descripcion del modulo que debe construir el desarrollador externo.
```
