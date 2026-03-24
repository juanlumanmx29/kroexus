#!/usr/bin/env bash
set -euo pipefail

# Kroexus — Script de instalacion universal
# Funciona en carpetas vacias (proyecto nuevo) y en proyectos existentes.
# Uso: curl -fsSL https://raw.githubusercontent.com/juanlumanmx29/kroexus/main/install.sh | bash

REPO_RAW="https://raw.githubusercontent.com/juanlumanmx29/kroexus/main"

echo "Kroexus — Instalando en: $(pwd)"
echo ""

# --- Detectar modo: nuevo o existente ---

has_code() {
  [ -f "package.json" ] ||
  [ -f "pyproject.toml" ] ||
  [ -f "requirements.txt" ] ||
  [ -f "go.mod" ] ||
  [ -f "Cargo.toml" ] ||
  [ -f "pom.xml" ] ||
  [ -f "Gemfile" ] ||
  [ -f "composer.json" ] ||
  [ -d "src" ] || [ -d "app" ] || [ -d "lib" ] || [ -d "backend" ] || [ -d "frontend" ] ||
  ls ./*.py ./*.ts ./*.tsx ./*.js ./*.go ./*.rs 2>/dev/null | head -1 > /dev/null 2>&1
}

if has_code; then
  MODE="existente"
  echo "Modo: proyecto existente (se detecto codigo)"
else
  MODE="nuevo"
  echo "Modo: proyecto nuevo (carpeta vacia o sin codigo)"
fi
echo ""

# --- Descarga de CLAUDE.md ---

if [ -f "CLAUDE.md" ]; then
  cp CLAUDE.md CLAUDE.md.bak
  echo "[1/5] CLAUDE.md existente respaldado como CLAUDE.md.bak"
fi

curl -fsSL "$REPO_RAW/CLAUDE.md" -o CLAUDE.md
echo "[1/5] CLAUDE.md descargado"

# --- Comandos para Claude Code ---

mkdir -p .claude/commands

COMMANDS="init.md audit.md checkpoint.md tentacle.md roadmap.md"
for cmd in $COMMANDS; do
  curl -fsSL "$REPO_RAW/.claude/commands/$cmd" -o ".claude/commands/$cmd"
done
echo "[2/5] Comandos instalados en .claude/commands/"

# --- Modulos de auditoria ---

mkdir -p _kroexus/.modules

MODULES="00-resumen-ejecutivo.md 01-arquitectura.md 02-frontend-dna.md 03-seguridad.md 04-performance.md 05-observabilidad.md 06-tests.md 07-dependencias.md 08-escalabilidad.md 09-compliance.md 10-resiliencia.md 11-deuda-tecnica.md 12-api-contrato.md 13-costos.md"
for mod in $MODULES; do
  curl -fsSL "$REPO_RAW/modules/$mod" -o "_kroexus/.modules/$mod"
done
echo "[3/5] Modulos de auditoria descargados en _kroexus/.modules/"

# --- Archivos de entrevista (solo proyecto nuevo) ---

if [ "$MODE" = "nuevo" ]; then
  mkdir -p init/stacks
  curl -fsSL "$REPO_RAW/init/entrevista.md" -o "init/entrevista.md"
  STACKS="fastapi-react.md nextjs.md fastapi-only.md generic.md"
  for stack in $STACKS; do
    curl -fsSL "$REPO_RAW/init/stacks/$stack" -o "init/stacks/$stack"
  done
  echo "[4/5] Entrevista y stacks descargados en init/"
else
  echo "[4/5] Proyecto existente — entrevista no necesaria"
fi

# --- Actualizacion de .gitignore ---

if [ ! -f ".gitignore" ]; then
  echo "_kroexus/" > .gitignore
  echo "[5/5] .gitignore creado con _kroexus/"
elif ! grep -qxF '_kroexus/' .gitignore; then
  echo "" >> .gitignore
  echo "_kroexus/" >> .gitignore
  echo "[5/5] _kroexus/ agregado a .gitignore"
else
  echo "[5/5] _kroexus/ ya estaba en .gitignore"
fi

# --- Inicializar git si no existe ---

if [ ! -d ".git" ]; then
  git init -q
  echo ""
  echo "Repositorio git inicializado."
fi

# --- Resumen ---

echo ""
echo "--- Instalacion completa ---"
echo ""

if [ "$MODE" = "nuevo" ]; then
  echo "Siguiente paso:"
  echo "  1. Abre Claude Code: claude"
  echo "  2. Escribe: /init"
  echo "  3. Responde la entrevista de configuracion"
else
  echo "Comandos disponibles en Claude Code:"
  echo "  /audit       Auditoria completa en 13 dimensiones"
  echo "  /checkpoint  Revision rapida de seguridad y deuda tecnica"
  echo "  /tentacle    Genera template para desarrollador externo"
  echo "  /roadmap     Muestra avance del proyecto por fases"
  echo ""
  echo "Abre Claude Code para comenzar: claude"
fi
