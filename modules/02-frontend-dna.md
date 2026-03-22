# Frontend DNA — Modulo Kroexus

## Objetivo

Extraer el ADN de diseno del frontend: tokens, componentes, patrones visuales
y nivel de consistencia del sistema de diseno.

## Que buscar

### Tokens de diseno

```bash
# CSS custom properties
grep -rn "^  --" --include="*.css" . | grep -v node_modules | grep -v .next

# Archivos de tokens/theme
find . \( -name "tokens.*" -o -name "theme.*" -o -name "variables.*" -o -name "design-system*" \) -not -path "*/node_modules/*" -not -path "*/.next/*"

# Tailwind config
find . -name "tailwind.config.*" -not -path "*/node_modules/*"
```

### Uso de colores hardcodeados

```bash
# Colores hexadecimales en componentes (fuera de archivos de tokens)
grep -rn "#[0-9A-Fa-f]\{3,8\}" --include="*.tsx" --include="*.jsx" --include="*.css" . | grep -v node_modules | grep -v .next | grep -v tokens | grep -v theme | grep -v variables

# Colores RGB/HSL inline
grep -rn "rgb\|rgba\|hsl\|hsla" --include="*.tsx" --include="*.jsx" --include="*.css" . | grep -v node_modules | grep -v .next | grep -v tokens | grep -v variables
```

### Componentes

```bash
# Inventario de componentes
find . -path "*/components/*" \( -name "*.tsx" -o -name "*.jsx" \) -not -path "*/node_modules/*" -not -path "*/.next/*" | sort

# Componentes de design system
find . -path "*/design-system/*" -o -path "*/ui/*" -o -path "*/common/*" | grep -E "\.(tsx|jsx)$" | grep -v node_modules | sort
```

### Tipografia

```bash
# Definiciones de font-family
grep -rn "font-family\|fontFamily" --include="*.css" --include="*.tsx" --include="*.jsx" . | grep -v node_modules | grep -v .next

# Tamanos de fuente hardcodeados en componentes
grep -rn "font-size\|fontSize" --include="*.tsx" --include="*.jsx" . | grep -v node_modules | grep -v .next | grep -v tokens | grep -v theme
```

### Espaciado

```bash
# Valores de padding/margin hardcodeados en componentes
grep -rn "padding:\|margin:\|gap:" --include="*.tsx" --include="*.jsx" . | grep -v node_modules | grep -v .next | grep -v tokens | head -30
```

### Iconos y assets

```bash
# Librerias de iconos
grep -rn "lucide\|heroicons\|react-icons\|fontawesome\|material-icons" --include="*.tsx" --include="*.jsx" --include="package.json" . | grep -v node_modules | head -10

# Imagenes en el proyecto
find . \( -name "*.svg" -o -name "*.png" -o -name "*.jpg" -o -name "*.webp" \) -not -path "*/node_modules/*" -not -path "*/.next/*" | head -20
```

## Como analizar

### Sistema de diseno saludable

- Tokens centralizados en un archivo dedicado (tokens.css, theme.ts, etc.)
- Componentes de UI base reutilizables (Button, Input, Card, etc.)
- Colores usados solo via tokens/variables, no hardcodeados en componentes
- Tipografia consistente via escala definida
- Espaciado consistente via escala definida

### Senales de problemas

- **Colores hardcodeados en componentes**: Cada componente usa sus propios valores de color. Hace imposible mantener consistencia visual.
- **Sin tokens centralizados**: No existe archivo de tokens ni config de Tailwind. Cada archivo define sus propios valores.
- **Componentes duplicados**: Multiples implementaciones del mismo componente (dos botones diferentes, dos modales, etc.)
- **Tipografia inconsistente**: Mas de 5 valores distintos de font-size sin relacion con una escala.
- **Mezclando librerias de iconos**: Usar dos o mas librerias de iconos distintas.

### Criterios de severidad

- **Critico**: Sin ningun sistema de tokens. Colores y tipografia completamente inconsistentes. Componentes de UI duplicados con comportamiento diferente.
- **Importante**: Tokens definidos pero no usados consistentemente. Colores hardcodeados en mas de 5 componentes. Espaciado inconsistente.
- **Mejora**: Tokens completos pero falta documentacion. Algunos valores hardcodeados en componentes aislados. Libreria de iconos mixta.

## Soluciones de referencia

### Centralizar tokens

Si no existen tokens, crearlos:

```css
:root {
  --color-primary-500: #3B82F6;
  --color-primary-600: #2563EB;
  /* completar con la paleta real del proyecto */

  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;

  --spacing-2: 0.5rem;
  --spacing-4: 1rem;
  --spacing-6: 1.5rem;
}
```

### Reemplazar color hardcodeado

Antes:
```tsx
<button style={{ backgroundColor: "#3B82F6" }}>Guardar</button>
```

Despues:
```tsx
<button style={{ backgroundColor: "var(--color-primary-500)" }}>Guardar</button>
```

## Formato de output

Cada hallazgo usa esta estructura:

### [Nombre del hallazgo]
**Severidad**: Critico / Importante / Mejora
**Ubicacion**: ruta/archivo.tsx:linea (o "global" si aplica a todo el proyecto)
**Riesgo**: que puede ocurrir si no se resuelve
**Solucion**: codigo o configuracion exacta para este proyecto
**Esfuerzo**: 30 min / 2 horas / 1 dia / 1 semana

Incluir al inicio del reporte:
- Resumen de tokens encontrados (colores, tipografia, espaciado)
- Inventario de componentes clasificados (base, layout, negocio)
- Porcentaje estimado de uso de tokens vs valores hardcodeados

## Output file

_kroexus/02-frontend-dna.md
