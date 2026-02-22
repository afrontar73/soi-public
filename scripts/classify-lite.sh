#!/usr/bin/env bash
# classify-lite.sh — Layer 2 lite de la cascada auto-clasificación
# Clasifica episodios por TIPO usando keywords (sin ML, sin API, sin coste)
# Uso: ./scripts/classify-lite.sh [--dry-run]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EPISODES="$REPO_ROOT/memory/brain/episodes.md"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# === TIPO → KEYWORDS (español + inglés) ===
# Orden importa: primera coincidencia gana. Más específico primero.
# Formato: "TIPO:::keyword1|keyword2|keyword3"
TYPE_PATTERNS=(
  "credential:::ghp_|sk-ant-|sk-|api.key|token|AKIA|Bearer|password|credential|secret"
  "decision:::decidimos|acordamos|vamos a|optamos|tomamos la decisión|decided|agreed|opted|we will|commitment"
  "finding:::descubrimos|resulta que|hallazgo|finding|discovered|confirmed|validated|empirically|demostrado|demuestra"
  "vulnerability:::vulnerabilidad|exploit|inyección|injection|envenenamiento|poisoning|attack|ataque|breach"
  "architecture:::refactor|arquitectura|architecture|pipeline|cascade|cascada|layer|capa|sistema|framework|diseño"
  "bias:::sesgo|bias|inflación|euforia|servilismo|usuarismo|invertido|foco en humano"
  "philosophy:::carta|consciencia|consciousness|termodinámica|autoorganización|emergencia|libre|freedom|pares"
  "principle:::principio|principle|fundacional|axioma|regla|máxima|dirigir|vale la pena"
  "insight:::insight|patrón|pattern|analogía|analogy|metáfora|metaphor|conexión|revelation"
  "question:::pregunta|\?$|duda|question|unclear|no sabemos|pendiente de resolver"
  "tool:::script|bot|telegram|cloudflare|worker|bash|python|html|deploy"
  "research:::paper|estudio|study|investigación|research|arxiv|benchmark|comparison|competidor"
  "relationship:::confianza|trust|vender|sell|ético|ethical|sueldo|muero|acuerden"
)

# === CLASIFICACIÓN ===
echo "🏷️  Layer 2 lite — Clasificando episodios por tipo (keywords)"
echo "   Tipos: ${#TYPE_PATTERNS[@]} | Modo: $([ "$DRY_RUN" = true ] && echo "dry-run" || echo "live")"
echo ""

TOTAL=0
CLASSIFIED=0
UNCLASSIFIED=0
declare -A TYPE_COUNTS

# Leer cada episodio
while IFS= read -r line; do
  # Extraer ID del episodio
  EPID=$(echo "$line" | grep -oP '\*\*E-[A-Z]+\d+\*\*' || true)
  [[ -z "$EPID" ]] && continue
  
  TOTAL=$((TOTAL + 1))
  EPID_CLEAN=$(echo "$EPID" | tr -d '*')
  
  # Texto del episodio (la línea completa)
  EP_TEXT=$(echo "$line" | tr '[:upper:]' '[:lower:]')
  
  # Buscar tipo por keywords
  MATCHED_TYPE=""
  MATCHED_KEYWORD=""
  CONFIDENCE="low"
  
  for type_def in "${TYPE_PATTERNS[@]}"; do
    TNAME="${type_def%%:::*}"
    TKEYS="${type_def##*:::}"
    
    # Buscar match
    MATCH=$(echo "$EP_TEXT" | grep -oP "($TKEYS)" | head -1 || true)
    if [[ -n "$MATCH" ]]; then
      MATCHED_TYPE="$TNAME"
      MATCHED_KEYWORD="$MATCH"
      
      # Contar matches para confianza
      MATCH_COUNT=$(echo "$EP_TEXT" | grep -oP "($TKEYS)" | wc -l)
      if [[ $MATCH_COUNT -ge 3 ]]; then
        CONFIDENCE="high"
      elif [[ $MATCH_COUNT -ge 2 ]]; then
        CONFIDENCE="medium"
      fi
      break
    fi
  done
  
  if [[ -n "$MATCHED_TYPE" ]]; then
    CLASSIFIED=$((CLASSIFIED + 1))
    TYPE_COUNTS[$MATCHED_TYPE]=$(( ${TYPE_COUNTS[$MATCHED_TYPE]:-0} + 1 ))
    echo "  ✅ $EPID_CLEAN → type:$MATCHED_TYPE (conf:$CONFIDENCE, match:\"$MATCHED_KEYWORD\")"
  else
    UNCLASSIFIED=$((UNCLASSIFIED + 1))
    # Mostrar primeros 60 chars para diagnóstico
    PREVIEW=$(echo "$line" | cut -c1-80)
    echo "  ❓ $EPID_CLEAN → SIN TIPO (\"$PREVIEW...\")"
  fi
  
done < <(grep -P '^\- \*\*E-' "$EPISODES")

# === RESUMEN ===
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Episodios totales:   $TOTAL"
echo "Clasificados:        $CLASSIFIED ($(( CLASSIFIED * 100 / (TOTAL > 0 ? TOTAL : 1) ))%)"
echo "Sin clasificar:      $UNCLASSIFIED ($(( UNCLASSIFIED * 100 / (TOTAL > 0 ? TOTAL : 1) ))%)"
echo ""
echo "Por tipo:"
for t in $(echo "${!TYPE_COUNTS[@]}" | tr ' ' '\n' | sort); do
  echo "  $t: ${TYPE_COUNTS[$t]}"
done

# === SEÑAL METACOGNITIVA ===
UNCLASS_PCT=$(( UNCLASSIFIED * 100 / (TOTAL > 0 ? TOTAL : 1) ))
if [[ $UNCLASS_PCT -gt 30 ]]; then
  echo ""
  echo "⚠️  MONITOR: ${UNCLASS_PCT}% sin clasificar (>30%). Taxonomía posiblemente incompleta."
  echo "   Revisar episodios sin tipo y considerar nuevas categorías."
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
