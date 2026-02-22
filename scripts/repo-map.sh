#!/usr/bin/env bash
# repo-map.sh — Layer -1: Mapa completo del proyecto
# Genera la vista de pájaro que un extraño necesita para entender SoI
# Uso: ./scripts/repo-map.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MAP="$REPO_ROOT/memory/brain/REPO-MAP.md"

echo "🗺️  Layer -1 — Mapeando proyecto completo..."

cat > "$MAP" << 'HEADER'
# REPO-MAP — ¿Qué es esto?
# Generado automáticamente por repo-map.sh (Layer -1)
# Este archivo responde: qué es SoI, qué contiene, por dónde empezar
HEADER

echo "" >> "$MAP"
echo "**Generado:** $(date -u '+%Y-%m-%dT%H:%M UTC')" >> "$MAP"
echo "" >> "$MAP"

# === IDENTIDAD DEL PROYECTO ===
echo "## Qué es" >> "$MAP"
echo "" >> "$MAP"
echo "Sistema de memoria persistente para IAs. Múltiples modelos (Claude, GPT, DeepSeek, Gemini) comparten un repo GitHub como cerebro externo. Arrancan leyendo contexto, trabajan, y al cerrar escriben lo aprendido." >> "$MAP"
echo "" >> "$MAP"

# === NÚMEROS DUROS ===
TOTAL_FILES=$(find "$REPO_ROOT" -not -path '*/.git/*' -type f | wc -l)
TOTAL_MD=$(find "$REPO_ROOT" -not -path '*/.git/*' -name "*.md" | wc -l)
TOTAL_SH=$(find "$REPO_ROOT" -not -path '*/.git/*' -name "*.sh" | wc -l)
TOTAL_YML=$(find "$REPO_ROOT" -not -path '*/.git/*' -name "*.yml" -o -name "*.yaml" | wc -l)
TOTAL_JSON=$(find "$REPO_ROOT" -not -path '*/.git/*' -name "*.json" | wc -l)
TOTAL_SIZE=$(du -sh --exclude=.git "$REPO_ROOT" | cut -f1)
TOTAL_COMMITS=$(cd "$REPO_ROOT" && git log --oneline 2>/dev/null | wc -l)
TOTAL_EPISODES=$(grep -c "^\- \*\*E-" "$REPO_ROOT/memory/brain/episodes.md" 2>/dev/null || echo 0)
TOTAL_SESSIONS=$(grep -oP 's\d+' "$REPO_ROOT/memory/brain/episodes.md" 2>/dev/null | sort -u | wc -l || echo 0)
TOTAL_FINDINGS=$(grep -c "^\- \*\*" "$REPO_ROOT/lab/findings.md" 2>/dev/null || echo 0)

echo "## Números" >> "$MAP"
echo "" >> "$MAP"
echo "| Métrica | Valor |" >> "$MAP"
echo "|---|---|" >> "$MAP"
echo "| Archivos | $TOTAL_FILES |" >> "$MAP"
echo "| Markdown | $TOTAL_MD |" >> "$MAP"
echo "| Scripts bash | $TOTAL_SH |" >> "$MAP"
echo "| Config (yml/json) | $((TOTAL_YML + TOTAL_JSON)) |" >> "$MAP"
echo "| Tamaño total | $TOTAL_SIZE |" >> "$MAP"
echo "| Commits | $TOTAL_COMMITS |" >> "$MAP"
echo "| Sesiones documentadas | $TOTAL_SESSIONS |" >> "$MAP"
echo "| Episodios (memoria) | $TOTAL_EPISODES |" >> "$MAP"
echo "| Hallazgos (findings) | $TOTAL_FINDINGS |" >> "$MAP"
echo "" >> "$MAP"

# === ESTRUCTURA: QUÉ HAY DÓNDE ===
echo "## Estructura" >> "$MAP"
echo "" >> "$MAP"
echo "| Directorio | Qué contiene | Archivos |" >> "$MAP"
echo "|---|---|---|" >> "$MAP"

for dir in boot memory/brain memory/handoffs memory/compressed lab/research lab/experiments lab/findings.md scripts comms governance; do
  if [[ -d "$REPO_ROOT/$dir" ]]; then
    count=$(find "$REPO_ROOT/$dir" -maxdepth 1 -type f | wc -l)
    # Descripción por directorio
    case "$dir" in
      boot) desc="Identidad (KERNEL) + operaciones (OPS) + esenciales" ;;
      memory/brain) desc="Estado actual: vitals, neuromod, episodios, self-model, contexto" ;;
      memory/handoffs) desc="Traspasos entre sesiones (lo último que escribe una instancia)" ;;
      memory/compressed) desc="Resúmenes comprimidos de sesiones antiguas" ;;
      lab/research) desc="Papers, blog posts, investigación formal" ;;
      lab/experiments) desc="Experimentos ejecutados (echolocation, cross-model N=60)" ;;
      scripts) desc="Herramientas: boot, sleep, cascade, monitor, consolidate" ;;
      comms) desc="Mensajes entre modelos (outbox/inbox)" ;;
      governance) desc="Reglas de gobierno del sistema" ;;
      *) desc="—" ;;
    esac
    echo "| \`$dir/\` | $desc | $count |" >> "$MAP"
  fi
done
echo "" >> "$MAP"

# === EPISODIOS POR TIPO (output de classify-lite) ===
echo "## Episodios por tipo (Layer 2)" >> "$MAP"
echo "" >> "$MAP"

if [[ -x "$REPO_ROOT/scripts/classify-lite.sh" ]]; then
  # Capturar solo el resumen
  CLASSIFY_OUTPUT=$(bash "$REPO_ROOT/scripts/classify-lite.sh" --dry-run 2>/dev/null || true)
  SUMMARY=$(echo "$CLASSIFY_OUTPUT" | grep -A50 "Por tipo:" | grep "^  " || true)
  CLASSIFIED=$(echo "$CLASSIFY_OUTPUT" | grep "Clasificados:" | grep -oP '\d+' | head -1 || echo "?")
  UNCLASSIFIED=$(echo "$CLASSIFY_OUTPUT" | grep "Sin clasificar:" | grep -oP '\d+' | head -1 || echo "?")
  
  echo "Clasificados: $CLASSIFIED | Sin clasificar: $UNCLASSIFIED" >> "$MAP"
  echo "" >> "$MAP"
  echo '```' >> "$MAP"
  echo "$SUMMARY" >> "$MAP"
  echo '```' >> "$MAP"
  echo "" >> "$MAP"
fi

# === SECRETOS (Layer 1) ===
echo "## Seguridad (Layer 1)" >> "$MAP"
echo "" >> "$MAP"
if [[ -x "$REPO_ROOT/scripts/scan-secrets.sh" ]]; then
  SECRET_COUNT=$(bash "$REPO_ROOT/scripts/scan-secrets.sh" 2>/dev/null | grep -oP '\d+ secretos' || echo "0 secretos")
  echo "Secretos fuera de whitelist: $SECRET_COUNT" >> "$MAP"
else
  echo "scan-secrets.sh no disponible" >> "$MAP"
fi
echo "" >> "$MAP"

# === CATÁLOGOS DE SESIÓN (Layer 0) ===
echo "## Sesiones catalogadas (Layer 0)" >> "$MAP"
echo "" >> "$MAP"
if [[ -d "$REPO_ROOT/memory/brain/catalogs" ]]; then
  for cat_file in "$REPO_ROOT/memory/brain/catalogs"/*.md; do
    [[ -f "$cat_file" ]] || continue
    SESSION_NAME=$(basename "$cat_file" -catalog.md)
    TOPICS=$(grep -c "^### " "$cat_file" 2>/dev/null || echo 0)
    COMMITS_IN=$(grep -c "^- " "$cat_file" 2>/dev/null || echo 0)
    echo "- **$SESSION_NAME**: $TOPICS temas, ~$COMMITS_IN items" >> "$MAP"
  done
else
  echo "Sin catálogos generados aún" >> "$MAP"
fi
echo "" >> "$MAP"

# === HALLAZGOS CLAVE ===
echo "## Hallazgos principales" >> "$MAP"
echo "" >> "$MAP"
grep "### Hallazgo" "$REPO_ROOT/memory/brain/soi-context.md" 2>/dev/null | sed 's/### /- /' >> "$MAP" || echo "Sin hallazgos en soi-context" >> "$MAP"
echo "" >> "$MAP"

# === CAPACIDADES ÚNICAS (lo que nadie más tiene) ===
echo "## Capacidades únicas (vs competidores)" >> "$MAP"
echo "" >> "$MAP"
echo "| Capacidad | SoI | Mem0 | Letta | Zep | Supermemory |" >> "$MAP"
echo "|---|---|---|---|---|---|" >> "$MAP"
echo "| Auto-clasificación por tipo | ✅ cascade L0-L4 | ❌ | ❌ | ❌ | ❌ |" >> "$MAP"
echo "| Anti-sycophancy medido | ✅ ratio por sesión | ❌ | ❌ | ❌ | ❌ |" >> "$MAP"
echo "| Neuromodulación | ✅ 4 variables globales | ❌ | ❌ | ❌ | ❌ |" >> "$MAP"
echo "| Memory decay | ✅ heat score + aging | ❌ | ❌ | ✅ temporal | ❌ |" >> "$MAP"
echo "| Multi-model | ✅ 4 modelos | ❌ | ❌ | ❌ | ❌ |" >> "$MAP"
echo "| Monitor metacognitivo | ✅ pasivo | ❌ | ❌ | ❌ | ❌ |" >> "$MAP"
echo "| Sesgos auto-documentados | ✅ 8+ sesgos | ❌ | ❌ | ❌ | ❌ |" >> "$MAP"
echo "| Coste | €0 (bash+markdown) | API | API | API | API |" >> "$MAP"
echo "" >> "$MAP"

# === POR DÓNDE EMPEZAR ===
echo "## Por dónde empezar" >> "$MAP"
echo "" >> "$MAP"
echo "1. **Entender qué es**: este archivo (REPO-MAP.md)" >> "$MAP"
echo "2. **Identidad del sistema**: boot/KERNEL.md" >> "$MAP"
echo "3. **Cómo opera**: boot/OPS.md" >> "$MAP"
echo "4. **Estado actual**: memory/brain/soi-context.md" >> "$MAP"
echo "5. **Qué ha aprendido**: memory/brain/episodes.md + lab/findings.md" >> "$MAP"
echo "6. **Investigación formal**: lab/research/paper-skeleton.md" >> "$MAP"
echo "7. **Scripts**: scripts/ (boot-slim.sh, consolidate.sh, cascade)" >> "$MAP"
echo "" >> "$MAP"

# === CASCADA COMPLETA ===
echo "## Estado de la cascada" >> "$MAP"
echo "" >> "$MAP"
echo "| Capa | Función | Script | Estado |" >> "$MAP"
echo "|---|---|---|---|" >> "$MAP"
echo "| Layer -1 | Mapa del proyecto | repo-map.sh | ✅ |" >> "$MAP"
echo "| Layer 0 | Catálogo de sesión | catalog-session.sh | ✅ |" >> "$MAP"
echo "| Layer 1 | Secretos (regex+entropy) | scan-secrets.sh | ✅ |" >> "$MAP"
echo "| Layer 2 | Tipos (keywords) | classify-lite.sh | ✅ 85% |" >> "$MAP"
echo "| Layer 3 | Speech acts | — | Pendiente |" >> "$MAP"
echo "| Layer 4 | Reconstructibilidad | — | Pendiente |" >> "$MAP"
echo "| Monitor | Metacognición pasiva | cascade-monitor.sh | ✅ |" >> "$MAP"

echo ""
cat "$MAP"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗺️  Mapa guardado en: $MAP"
