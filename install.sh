#!/usr/bin/env bash
set -euo pipefail

# Kroexus — Script de instalacion para proyectos existentes
# Uso: curl -fsSL https://raw.githubusercontent.com/juanlumanmx29/kroexus/main/install.sh | bash

REPO_RAW="https://raw.githubusercontent.com/juanlumanmx29/kroexus/main"

# --- Deteccion de raiz de proyecto ---

is_project_root() {
  [ -f "package.json" ] ||
  [ -f "pyproject.toml" ] ||
  [ -f "requirements.txt" ] ||
  [ -f "go.mod" ] ||
  [ -f "Cargo.toml" ] ||
  [ -f "pom.xml" ] ||
  [ -f "Gemfile" ] ||
  [ -f "composer.json" ] ||
  ls ./*.py ./*.ts ./*.tsx ./*.js ./*.go ./*.rs 2>/dev/null | head -1 > /dev/null 2>&1
}

if ! is_project_root; then
  echo "Error: No se detecto un proyecto en el directorio actual."
  echo "Ejecuta este script desde la raiz de un proyecto que contenga"
  echo "al menos un archivo de codigo o un manifiesto de dependencias"
  echo "(package.json, pyproject.toml, requirements.txt, etc.)."
  exit 1
fi

echo "Kroexus — Instalando en: $(pwd)"
echo ""

# --- Descarga de CLAUDE.md ---

if [ -f "CLAUDE.md" ]; then
  cp CLAUDE.md CLAUDE.md.bak
  echo "[1/4] CLAUDE.md existente respaldado como CLAUDE.md.bak"
fi

curl -fsSL "$REPO_RAW/CLAUDE.md" -o CLAUDE.md
echo "[1/4] CLAUDE.md descargado"

# --- Comandos para Claude Code ---

mkdir -p .claude/commands

COMMANDS="audit.md checkpoint.md tentacle.md roadmap.md"
for cmd in $COMMANDS; do
  curl -fsSL "$REPO_RAW/.claude/commands/$cmd" -o ".claude/commands/$cmd"
done
echo "[2/4] Comandos instalados en .claude/commands/"

# --- Directorio de reportes y modulos ---

mkdir -p _kroexus/.modules

MODULES="00-resumen-ejecutivo.md 01-arquitectura.md 02-frontend-dna.md 03-seguridad.md 04-performance.md 05-observabilidad.md 06-tests.md 07-dependencias.md 08-escalabilidad.md 09-compliance.md 10-resiliencia.md 11-deuda-tecnica.md 12-api-contrato.md 13-costos.md"
for mod in $MODULES; do
  curl -fsSL "$REPO_RAW/modules/$mod" -o "_kroexus/.modules/$mod"
done
echo "[3/4] Modulos de auditoria descargados en _kroexus/.modules/"

# --- Actualizacion de .gitignore ---

if [ ! -f ".gitignore" ]; then
  echo "_kroexus/" > .gitignore
  echo "[4/4] .gitignore creado con _kroexus/"
elif ! grep -qxF '_kroexus/' .gitignore; then
  echo "" >> .gitignore
  echo "_kroexus/" >> .gitignore
  echo "[4/4] _kroexus/ agregado a .gitignore"
else
  echo "[4/4] _kroexus/ ya estaba en .gitignore"
fi

# --- Resumen ---

echo ""
echo "--- Instalacion completa ---"
echo ""
echo "Archivos instalados:"
echo "  CLAUDE.md                   Reglas de comportamiento y normas tecnicas"
echo "  .claude/commands/audit.md   Comando /audit"
echo "  .claude/commands/checkpoint.md  Comando /checkpoint"
echo "  .claude/commands/tentacle.md    Comando /tentacle"
echo "  .claude/commands/roadmap.md     Comando /roadmap"
echo "  _kroexus/.modules/          Modulos de auditoria (14 archivos)"
echo ""
echo "Comandos disponibles en Claude Code:"
echo "  /audit       Auditoria completa en 13 dimensiones"
echo "  /checkpoint  Revision rapida de seguridad y deuda tecnica"
echo "  /tentacle    Genera template para desarrollador externo"
echo "  /roadmap     Muestra avance del proyecto por fases"
echo ""
echo "Abre Claude Code para comenzar: claude"
