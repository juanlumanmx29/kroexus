# Kroexus — Script de instalacion universal (PowerShell)
# Uso: irm https://raw.githubusercontent.com/juanlumanmx29/kroexus/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$REPO_RAW = "https://raw.githubusercontent.com/juanlumanmx29/kroexus/main"

Write-Host "Kroexus — Instalando en: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""

# --- Detectar modo: nuevo o existente ---

$hasCode = (
    (Test-Path "package.json") -or
    (Test-Path "pyproject.toml") -or
    (Test-Path "requirements.txt") -or
    (Test-Path "go.mod") -or
    (Test-Path "Cargo.toml") -or
    (Test-Path "pom.xml") -or
    (Test-Path "Gemfile") -or
    (Test-Path "composer.json") -or
    (Test-Path "src") -or
    (Test-Path "app") -or
    (Test-Path "lib") -or
    (Test-Path "backend") -or
    (Test-Path "frontend") -or
    (@(Get-ChildItem -Path . -Include *.py,*.ts,*.tsx,*.js,*.go,*.rs -File -ErrorAction SilentlyContinue).Count -gt 0)
)

if ($hasCode) {
    $MODE = "existente"
    Write-Host "Modo: proyecto existente (se detecto codigo)"
} else {
    $MODE = "nuevo"
    Write-Host "Modo: proyecto nuevo (carpeta vacia o sin codigo)"
}
Write-Host ""

# --- Funcion para descargar archivos ---

function Download-File {
    param([string]$Url, [string]$Output)
    $dir = Split-Path -Parent $Output
    if ($dir -and !(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Invoke-RestMethod -Uri $Url -OutFile $Output
}

# --- Descarga de CLAUDE.md ---

if (Test-Path "CLAUDE.md") {
    Copy-Item "CLAUDE.md" "CLAUDE.md.bak" -Force
    Write-Host "[1/5] CLAUDE.md existente respaldado como CLAUDE.md.bak"
}

Download-File "$REPO_RAW/CLAUDE.md" "CLAUDE.md"
Write-Host "[1/5] CLAUDE.md descargado"

# --- Comandos para Claude Code ---

$commands = @("kroexus.md", "audit.md", "checkpoint.md", "tentacle.md", "roadmap.md")
foreach ($cmd in $commands) {
    Download-File "$REPO_RAW/.claude/commands/$cmd" ".claude/commands/$cmd"
}
Write-Host "[2/5] Comandos instalados en .claude/commands/"

# --- Modulos de auditoria ---

$modules = @(
    "00-resumen-ejecutivo.md", "01-arquitectura.md", "02-frontend-dna.md",
    "03-seguridad.md", "04-performance.md", "05-observabilidad.md",
    "06-tests.md", "07-dependencias.md", "08-escalabilidad.md",
    "09-compliance.md", "10-resiliencia.md", "11-deuda-tecnica.md",
    "12-api-contrato.md", "13-costos.md"
)
foreach ($mod in $modules) {
    Download-File "$REPO_RAW/modules/$mod" "_kroexus/.modules/$mod"
}
Write-Host "[3/5] Modulos de auditoria descargados en _kroexus/.modules/"

# --- Archivos de entrevista (solo proyecto nuevo) ---

if ($MODE -eq "nuevo") {
    Download-File "$REPO_RAW/init/entrevista.md" "init/entrevista.md"
    $stacks = @("fastapi-react.md", "nextjs.md", "fastapi-only.md", "generic.md")
    foreach ($stack in $stacks) {
        Download-File "$REPO_RAW/init/stacks/$stack" "init/stacks/$stack"
    }
    Write-Host "[4/5] Entrevista y stacks descargados en init/"
} else {
    Write-Host "[4/5] Proyecto existente — entrevista no necesaria"
}

# --- Actualizacion de .gitignore ---

if (!(Test-Path ".gitignore")) {
    "_kroexus/" | Out-File -FilePath ".gitignore" -Encoding utf8
    Write-Host "[5/5] .gitignore creado con _kroexus/"
} elseif (!(Select-String -Path ".gitignore" -Pattern "^_kroexus/$" -Quiet)) {
    "" | Out-File -FilePath ".gitignore" -Append -Encoding utf8
    "_kroexus/" | Out-File -FilePath ".gitignore" -Append -Encoding utf8
    Write-Host "[5/5] _kroexus/ agregado a .gitignore"
} else {
    Write-Host "[5/5] _kroexus/ ya estaba en .gitignore"
}

# --- Inicializar git si no existe ---

if (!(Test-Path ".git")) {
    git init -q
    Write-Host ""
    Write-Host "Repositorio git inicializado."
}

# --- Resumen ---

Write-Host ""
Write-Host "--- Instalacion completa ---" -ForegroundColor Green
Write-Host ""

if ($MODE -eq "nuevo") {
    Write-Host "Siguiente paso:"
    Write-Host "  1. Abre Claude Code: claude"
    Write-Host "  2. Escribe: /kroexus"
    Write-Host "  3. Responde la entrevista de configuracion"
} else {
    Write-Host "Comandos disponibles en Claude Code:"
    Write-Host "  /audit       Auditoria completa en 13 dimensiones"
    Write-Host "  /checkpoint  Revision rapida de seguridad y deuda tecnica"
    Write-Host "  /tentacle    Genera template para desarrollador externo"
    Write-Host "  /roadmap     Muestra avance del proyecto por fases"
    Write-Host ""
    Write-Host "Abre Claude Code para comenzar: claude"
}
