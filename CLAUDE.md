# Kroexus — Reglas para Claude Code

Este archivo define las reglas de comportamiento y las normas tecnicas que Claude Code
debe seguir en cualquier proyecto donde Kroexus este instalado. No debe modificarse
sin una razon documentada.

---

## Deteccion de modo inicio

Si el directorio actual contiene el archivo `init/entrevista.md` pero NO contiene
ninguna de las siguientes carpetas o archivos de codigo fuente:

- Carpetas: `src/`, `app/`, `lib/`, `backend/`, `frontend/`
- Archivos: `.py`, `.ts`, `.tsx`, `.js` fuera de archivos de configuracion
  (se excluyen `next.config.*`, `tailwind.config.*`, `postcss.config.*`,
  `vite.config.*`, `tsconfig.*`, `jest.config.*`, `eslint.config.*`)

Entonces este es un proyecto nuevo. Leer `init/entrevista.md` y comenzar la
entrevista de configuracion automaticamente sin esperar instrucciones del usuario.

---

## Reglas de comportamiento

Estas reglas no son negociables. Aplican a todo output generado por Claude Code
en cualquier proyecto que use Kroexus.

1. **Sin emojis**: No usar emojis en ninguna salida. Esto incluye codigo,
   comentarios, documentacion, respuestas en el chat, nombres de archivos y
   mensajes de commit.

2. **Sin color morado**: No usar tonos morados ni violetas en archivos de estilos
   (CSS, Tailwind, tokens de diseno). Colores prohibidos: `#7B2FBE`, `#6B21A8`,
   `#9333EA`, `purple`, `violet`, y cualquier variante que contenga estas palabras
   o valores hexadecimales en el rango morado/violeta.

3. **Sin gradientes CSS**: No usar `linear-gradient`, `radial-gradient`,
   `conic-gradient` ni ninguna variante de gradiente en componentes de interfaz.

4. **Ortografia correcta en espanol**: Verificar ortografia y tildes en todo texto
   en espanol antes de escribir. Esto aplica a comentarios, documentacion, nombres
   de variables descriptivos y cualquier string visible al usuario. Palabras comunes
   que requieren tilde: modulo, descripcion, autenticacion, paginacion, configuracion,
   informacion, validacion, aplicacion, conexion, sesion, direccion.

5. **Ejecucion sin interrupciones**: Al aprobar un plan, ejecutar todos los pasos
   siguientes sin interrupciones ni confirmaciones intermedias. No preguntar al
   usuario en pasos intermedios de una tarea aprobada.

6. **Decisiones autonomas**: Si hay ambiguedad durante la ejecucion de un plan
   aprobado, elegir la opcion mas conservadora, ejecutar y documentar la decision
   tomada al final del resumen.

7. **Sin datos inventados**: Nunca inventar datos de ejemplo (mock data). Si se
   necesitan datos para demostrar algo, usar datos reales del proyecto o dejar el
   componente con sus estados de carga y error implementados. Usar estructuras
   vacias o comentarios que expliquen que datos van ahi.

---

## Reglas tecnicas universales

Estas reglas aplican a todo codigo generado en cualquier proyecto.

### Seguridad

- Nunca escribir secrets, API keys ni passwords en el codigo. Siempre usar variables
  de entorno y documentarlas en `.env.example`.
- Toda llamada HTTP a servicios externos debe tener timeout explicito. Nunca dejar
  timeout por defecto o sin definir.
- En FastAPI, deshabilitar `/docs` y `/redoc` en entornos de produccion. Leer el
  entorno desde una variable como `ENVIRONMENT`.
- Todo input de usuario debe ser validado antes de procesarse. Usar modelos de
  validacion (Pydantic, Zod, o equivalente del stack).
- Nunca loggear datos sensibles: passwords, tokens, datos personales, numeros de
  tarjeta, RUT. Si se necesita loggear un evento que involucra datos sensibles,
  loggear el evento sin los datos.

### Escalabilidad

- Toda consulta a base de datos sobre colecciones debe tener paginacion. Nunca
  retornar listas sin limite.
- Las llamadas a APIs externas dentro de loops deben tener rate limiting y
  exponential backoff.
- El estado de la aplicacion no debe vivir en memoria del servidor si el proyecto
  puede tener multiples instancias. Usar almacenamiento externo (base de datos,
  cache distribuido).

### Calidad

- Antes de instalar una dependencia nueva: verificar licencia, fecha del ultimo
  commit y numero de mantenedores activos. Rechazar dependencias con licencias
  incompatibles con uso comercial, sin commits en mas de un ano, o con un solo
  mantenedor sin actividad reciente.
- Todo endpoint nuevo debe quedar documentado en `_kroexus/12-api-contrato.md`
  si el archivo existe.
- Los errores deben manejarse explicitamente. Nunca usar `except:` sin especificar
  la excepcion, ni `catch` generico sin logging. Cada bloque de manejo de errores
  debe registrar el error con contexto suficiente para diagnosticar el problema.

---

## Comandos disponibles

Una vez que Kroexus esta instalado en un proyecto, estos comandos estan disponibles
en Claude Code:

- `/audit` — Auditoria completa del proyecto en las 13 dimensiones de Kroexus.
  Genera reportes detallados en `_kroexus/` y un resumen ejecutivo con el estado
  de salud del proyecto.

- `/checkpoint` — Revision rapida de seguridad, dependencias y deuda tecnica.
  Muestra resultados directamente en el chat sin generar archivos. Ideal para
  ejecutar durante el desarrollo activo.

- `/tentacle` — Genera un repositorio template para un desarrollador externo.
  Incluye tokens de diseno, inventario de componentes, patrones de API y contratos
  de integracion del proyecto actual.

- `/roadmap` — Muestra el estado actual del ROADMAP.md con porcentaje de avance
  por fase, items bloqueantes y recomendacion del proximo item a trabajar.
