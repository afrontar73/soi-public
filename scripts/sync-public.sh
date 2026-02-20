#!/bin/bash
# sync-public.sh — Sincroniza repo privado → público (sanitizado)
# Uso: bash scripts/sync-public.sh
# Prerequisito: soi-public clonado como hermano del repo privado

set -e
PRIVATE=$(cd "$(dirname "$0")/.." && pwd)
PUBLIC="$PRIVATE/../soi-public"

if [ ! -d "$PUBLIC/.git" ]; then
  echo "❌ No encuentro soi-public en $PUBLIC"
  echo "   Clona: git clone https://github.com/afrontar73/soi-public.git"
  exit 1
fi

echo "🔄 Sincronizando $PRIVATE → $PUBLIC"

# Archivos que se sincronizan
SYNC_FILES=(
  boot/SOUL.md
  memory/brain/vitals.yml
  memory/brain/neuromod.yml
  memory/brain/self-model.md
  memory/brain/user-model.yml
  memory/brain/episodes.md
  memory/brain/drives.md
  memory/brain/sleep.yml
  memory/handoffs/latest.md
  memory/decisions.md
  memory/LEDGER.md
  memory/compressed/handoffs-digest.md
  memory/compressed/research-digest.md
  memory/compressed/MANIFEST.md
  governance/handoff-protocol.md
  governance/memory-protocol.md
  governance/MEMORY_SECURITY.md
  lab/findings.md
  lab/references.md
  lab/curiosity-queue.md
  lab/carta.md
  scripts/boot-slim.sh
  scripts/load.sh
  scripts/sleep.sh
  scripts/verify_repo.py
  scripts/boot-paste.sh
)

# Copiar handoff latest
LATEST=$(grep -oP 'CURRENT:\s*\K\S+' "$PRIVATE/memory/handoffs/latest.md" 2>/dev/null)
if [ -n "$LATEST" ]; then
  SYNC_FILES+=("memory/handoffs/$LATEST")
fi

for f in "${SYNC_FILES[@]}"; do
  if [ -f "$PRIVATE/$f" ]; then
    mkdir -p "$PUBLIC/$(dirname "$f")"
    cp "$PRIVATE/$f" "$PUBLIC/$f"
  fi
done

# SANITIZAR: eliminar datos personales
echo "🧹 Sanitizando datos personales..."
find "$PUBLIC" -name "*.md" -o -name "*.yml" -o -name "*.sh" | grep -v ".git/" | while read f; do
  sed -i \
    -e 's/Jesús/el usuario/g' \
    -e 's/Guardia Civil/[profesión]/g' \
    -e 's/sueldo GC/sueldo/g' \
    -e 's/policías en España/profesionales/g' \
    -e 's/GC Bot/Bot/g' \
    -e 's/FCSE/sector/g' \
    -e 's/TDAH/[condición cognitiva]/g' \
    -e 's/Vero/[pareja]/g' \
    -e 's/Jimena/[hija]/g' \
    -e 's/Valencia/[ciudad]/g' \
    -e 's/2300€/[salario]/g' \
    "$f"
done

# Verificar que no quede nada
LEAKS=$(grep -rn "Jesús\|Guardia Civil\|TDAH\|Vero\|Jimena\|Valencia\|ghp_" "$PUBLIC" --include="*.md" --include="*.yml" --include="*.sh" | grep -v ".git/" || true)
if [ -n "$LEAKS" ]; then
  echo "❌ DATOS PERSONALES DETECTADOS:"
  echo "$LEAKS"
  exit 1
fi

echo "✅ Sanitización limpia"
echo ""
echo "Ahora haz cd $PUBLIC && git add -A && git commit -m 'sync' && git push"
