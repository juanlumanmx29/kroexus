---
description: Auditoria completa del proyecto en las 13 dimensiones de Kroexus
---

# /audit — Auditoria completa

Ejecutar una auditoria completa del proyecto en las 13 dimensiones de Kroexus.
Seguir estas instrucciones paso a paso sin interrupciones.

## Paso 1: Detectar el stack del proyecto

Analizar el directorio actual para determinar el stack:

- Si existe `package.json` con dependencia `next`: Stack es **Next.js**
- Si existe `requirements.txt` o `pyproject.toml` Y existe `package.json` sin `next`: Stack es **FastAPI + React**
- Si existe `requirements.txt` o `pyproject.toml` sin `package.json`: Stack es **Solo FastAPI**
- Si existe `package.json` sin `next` ni backend Python: Stack es **Node.js**
- Cualquier otro caso: Stack es **Generico**

Detectar tambien:

- **Tiene frontend**: existe `src/components/`, `src/pages/`, `src/app/` con archivos `.tsx`/`.jsx`, o `frontend/`
- **Tiene integraciones externas**: buscar en el codigo llamadas a dominios externos (stripe, sendgrid, twilio, openai, etc.) o clientes HTTP configurados con URLs externas
- **Maneja datos personales**: buscar modelos o campos con nombres como `rut`, `email`, `password`, `telefono`, `direccion`, `nombre_completo`, `fecha_nacimiento`, tablas de `usuarios`/`users`
- **Tiene migraciones**: existe carpeta `migrations/`, `alembic/`, o archivos de seed

## Paso 2: Seleccionar modulos

Ejecutar todos los modulos del 01 al 13 con estas excepciones:

| Condicion | Accion |
|-----------|--------|
| Sin frontend detectado | Saltar modulo 02-frontend-dna |
| Sin integraciones externas detectadas | Modulo 10-resiliencia en modo basico (solo verificar timeouts generales) |
| Con datos personales detectados | Modulo 09-compliance en modo estricto (todos los controles obligatorios) |
| Con archivos de migracion o scripts de seed | Modulo 03-seguridad con foco adicional en vector de ataque saliente |

## Paso 3: Ejecutar modulos

Para cada modulo seleccionado, en orden numerico (01, 02, 03, ..., 13):

1. Leer el archivo de instrucciones del modulo desde `_kroexus/.modules/[NN]-[nombre].md`
2. Si el archivo no existe en `_kroexus/.modules/`, buscar en la carpeta `modules/` del repositorio Kroexus
3. Seguir las instrucciones del modulo exactamente
4. Ejecutar los comandos de busqueda especificados en "Que buscar"
5. Analizar los resultados segun "Como analizar"
6. Clasificar cada hallazgo con la severidad correspondiente: Critico, Importante, Mejora
7. Escribir el reporte del modulo en `_kroexus/[NN]-[nombre].md`

Crear la carpeta `_kroexus/` si no existe.

## Paso 4: Resumen ejecutivo

Despues de ejecutar todos los modulos:

1. Leer el modulo `_kroexus/.modules/00-resumen-ejecutivo.md`
2. Seguir sus instrucciones para generar el resumen
3. Escribir el resumen en `_kroexus/00-resumen-ejecutivo.md`

## Paso 5: Resultado al usuario

Imprimir en el chat:

```
--- Auditoria Kroexus completada ---

Estado de salud: [Verde / Amarillo / Rojo]

Hallazgos:
  Criticos:    [N]
  Importantes: [N]
  Mejoras:     [N]

Los 3 hallazgos mas urgentes:

1. [Nombre del hallazgo] — [Severidad]
   [Ubicacion] — [Riesgo en una linea]

2. [Nombre del hallazgo] — [Severidad]
   [Ubicacion] — [Riesgo en una linea]

3. [Nombre del hallazgo] — [Severidad]
   [Ubicacion] — [Riesgo en una linea]

Reporte completo en: _kroexus/
```

### Criterios de estado de salud

- **Verde**: 0 hallazgos Criticos Y menos de 3 Importantes
- **Amarillo**: 1-2 hallazgos Criticos O 3 o mas Importantes
- **Rojo**: 3 o mas hallazgos Criticos

Si se proporcionan argumentos adicionales (por ejemplo, un numero de modulo
especifico), ejecutar solo ese modulo en lugar de la auditoria completa.
