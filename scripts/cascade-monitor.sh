#!/usr/bin/env bash
# cascade-monitor.sh — Monitor metacognitivo pasivo
# Mide salud de la clasificación y señala cuando la taxonomía falla
# Uso: ./scripts/cascade-monitor.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EPISODES="$REPO_ROOT/memory/brain/episodes.md"
KNOWLEDGE="$REPO_ROOT/memory/brain/knowledge.md"
SOI_CTX="$REPO_ROOT/memory/brain/soi-context.md"

echo "🧠 Monitor Metacognitivo — Estado de clasificación SoI"
echo "   $(date -u '+%Y-%m-%dT%H:%M UTC')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# === EPISODIOS ===
EP_TOTAL=$(grep -cP '^\- \*\*E-' "$EPISODES" 2>/dev/null || echo 0)
EP_WITH_HEAT=$(grep -cP 'heat:\d' "$EPISODES" 2>/dev/null || echo 0)
EP_WITH_LINKS=$(grep -cP 'links: \[' "$EPISODES" 2>/dev/null || echo 0)
EP_CATEGORIES=$(grep -cP '^### ' "$EPISODES" 2>/dev/null || echo 0)

echo ""
echo "📂 EPISODIOS"
echo "  Total:            $EP_TOTAL"
echo "  Con heat:         $EP_WITH_HEAT ($(( EP_TOTAL > 0 ? EP_WITH_HEAT * 100 / EP_TOTAL : 0 ))%)"
echo "  Con links:        $EP_WITH_LINKS ($(( EP_TOTAL > 0 ? EP_WITH_LINKS * 100 / EP_TOTAL : 0 ))%)"
echo "  Categorías:       $EP_CATEGORIES"

# Heat distribution
echo "  Heat distribución:"
for h in 1 2 3 4 5 6 7 8 9 10; do
  COUNT=$(grep -cP "heat:$h\b" "$EPISODES" 2>/dev/null || true)
  COUNT=${COUNT:-0}
  COUNT=$(echo "$COUNT" | tr -d '[:space:]')
  [[ "$COUNT" -gt 0 ]] 2>/dev/null && echo "    heat:$h → $COUNT episodios"
done

# === KNOWLEDGE ===
K_TOTAL=$(grep -cP '^\*\*K-' "$KNOWLEDGE" 2>/dev/null || true)
K_TOTAL=${K_TOTAL:-0}
echo ""
echo "📚 KNOWLEDGE"
echo "  Entries:          $K_TOTAL"

# === SOI-CONTEXT ===
CTX_LINES=$(wc -l < "$SOI_CTX" 2>/dev/null || echo 0)
CTX_L0=$(grep -cP '^gh_pat:|^repo:|^remote:|^session:' "$SOI_CTX" 2>/dev/null || echo 0)
CTX_HALLAZGOS=$(grep -cP '### Hallazgo' "$SOI_CTX" 2>/dev/null || echo 0)
echo ""
echo "🧬 SOI-CONTEXT"
echo "  Líneas:           $CTX_LINES"
echo "  Datos L0:         $CTX_L0"
echo "  Hallazgos:        $CTX_HALLAZGOS"

# === SECRETOS (Layer 1 quick scan) ===
echo ""
echo "🔐 LAYER 1 — Quick secret scan"
SECRET_COUNT=0
for pattern in "ghp_[a-zA-Z0-9]{36}" "sk-ant-" "sk-[a-f0-9]{32}" "AKIA[0-9A-Z]{16}"; do
  HITS=$(grep -rlP "$pattern" "$REPO_ROOT/memory" --include="*.md" --include="*.yml" 2>/dev/null | grep -v KEYCHAIN | grep -v soi-context || true)
  if [[ -n "$HITS" ]]; then
    echo "  🚨 Patrón '$pattern' encontrado fuera de KEYCHAIN:"
    echo "$HITS" | sed 's/^/     /'
    SECRET_COUNT=$((SECRET_COUNT + 1))
  fi
done
[[ $SECRET_COUNT -eq 0 ]] && echo "  ✅ Limpio"

# === SEÑALES METACOGNITIVAS ===
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔮 SEÑALES METACOGNITIVAS"

ALERTS=0

# ¿Episodios sin heat?
NO_HEAT=$((EP_TOTAL - EP_WITH_HEAT))
if [[ $NO_HEAT -gt 5 ]]; then
  echo "  ⚠️  $NO_HEAT episodios sin heat — necesitan evaluación"
  ALERTS=$((ALERTS + 1))
fi

# ¿Episodios sin links?
NO_LINKS=$((EP_TOTAL - EP_WITH_LINKS))
if [[ $NO_LINKS -gt 10 ]]; then
  echo "  ⚠️  $NO_LINKS episodios sin links — conocimiento aislado"
  ALERTS=$((ALERTS + 1))
fi

# ¿Categorías suficientes?
if [[ $EP_CATEGORIES -lt 3 ]]; then
  echo "  ⚠️  Solo $EP_CATEGORIES categorías — taxonomía muy simple"
  ALERTS=$((ALERTS + 1))
fi

# ¿Secretos expuestos?
if [[ $SECRET_COUNT -gt 0 ]]; then
  echo "  🚨 $SECRET_COUNT patrón(es) de secretos fuera de whitelist"
  ALERTS=$((ALERTS + 1))
fi

# ¿soi-context creciendo demasiado?
if [[ $CTX_LINES -gt 100 ]]; then
  echo "  ⚠️  soi-context tiene $CTX_LINES líneas — considerar compactar L3/L4"
  ALERTS=$((ALERTS + 1))
fi

if [[ $ALERTS -eq 0 ]]; then
  echo "  ✅ Sin alertas. Sistema saludable."
else
  echo ""
  echo "  Total alertas: $ALERTS"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
