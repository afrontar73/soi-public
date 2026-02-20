#!/bin/bash
# sleep.sh — Ciclo NREM mecánico. Ejecutar al cerrar sesión.
# Uso: bash scripts/sleep.sh
# Hace: poda episodes, comprime handoffs viejos, reporta estado.

set -e
REPO=$(cd "$(dirname "$0")/.." && pwd)
EPISODES="$REPO/memory/brain/episodes.md"
HANDOFFS="$REPO/memory/handoffs"
DIGEST="$REPO/memory/compressed/handoffs-digest.md"

echo "🛌 SLEEP CYCLE START"
echo ""

# ═══════════════════════════════════════
# 1. EPISODES: contar y reportar candidatos a poda
# ═══════════════════════════════════════
TOTAL=$(grep -c "^- \*\*E-" "$EPISODES" 2>/dev/null || echo 0)
echo "📊 Episodes: $TOTAL (umbral poda: 50)"

if [ "$TOTAL" -gt 50 ]; then
  echo "⚠️  PODA NECESARIA — $((TOTAL - 50)) episodios sobre el límite"
  echo "   La instancia debe revisar episodes.md y mover a ARCHIVE los de heat < 1"
else
  echo "✅ Dentro del umbral"
fi

echo ""

# ═══════════════════════════════════════
# 2. HANDOFFS: listar, identificar comprimibles
# ═══════════════════════════════════════
LATEST=$(cat "$HANDOFFS/latest.md" | grep -oP 's\d+-[0-9-]+\.md' || echo "unknown")
HANDOFF_COUNT=$(ls "$HANDOFFS"/s*.md 2>/dev/null | wc -l)
echo "📋 Handoffs: $HANDOFF_COUNT archivos (latest: $LATEST)"

# Handoffs que NO son el latest ni el penúltimo → comprimibles
COMPRIMIBLES=0
for f in "$HANDOFFS"/s*.md; do
  FNAME=$(basename "$f")
  if [ "$FNAME" != "$LATEST" ]; then
    COMPRIMIBLES=$((COMPRIMIBLES + 1))
  fi
done

if [ "$COMPRIMIBLES" -gt 5 ]; then
  echo "⚠️  $COMPRIMIBLES handoffs antiguos. Comprimir en handoffs-digest.md"
  echo "   Mantener: latest + penúltimo. Resto → digest con 1 línea por sesión."
else
  echo "✅ Handoffs dentro de rango"
fi

echo ""

# ═══════════════════════════════════════
# 3. REPO SIZE: peso total de memoria activa
# ═══════════════════════════════════════
BRAIN_LINES=$(find "$REPO/memory/brain" -name "*.md" -o -name "*.yml" | xargs cat 2>/dev/null | wc -l)
BOOT_WORDS=$(bash "$REPO/scripts/boot-slim.sh" test 2>/dev/null | wc -w)
BOOT_TOKENS=$((BOOT_WORDS * 4 / 3))
echo "🧠 brain/ total: ${BRAIN_LINES} líneas"
echo "🚀 boot-slim: ~${BOOT_TOKENS} tokens"

if [ "$BOOT_TOKENS" -gt 4000 ]; then
  echo "⚠️  boot-slim > 4000 tokens — considerar poda"
elif [ "$BOOT_TOKENS" -gt 3000 ]; then
  echo "🟡 boot-slim acercándose al límite"
else
  echo "✅ boot-slim en rango saludable"
fi

echo ""
echo "🛌 SLEEP CYCLE END"
