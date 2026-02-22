#!/usr/bin/env bash
# consolidate.sh — Consolidación adaptativa de memoria SoI
# Nombre: consolidate.sh (heartbeat.sh ya existe para detección de contenedor)
# Uso: ./scripts/consolidate.sh [--force] [--threshold N] [--dry-run]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EPISODES="$REPO_ROOT/memory/brain/episodes.md"
KNOWLEDGE="$REPO_ROOT/memory/brain/knowledge.md"
STATE="$REPO_ROOT/memory/brain/consolidation-state.json"
PRIORITIES="$REPO_ROOT/memory/brain/priorities.yml"
NEUROMOD_SUGGESTED="$REPO_ROOT/memory/brain/neuromod-suggested.yml"
VALIDATION="$REPO_ROOT/memory/brain/validation-tasks.yml"
DISTILL_SCRIPT="$REPO_ROOT/scripts/distill.py"

# Defaults
THRESHOLD=10
FORCE=false
DRY_RUN=false

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --force)    FORCE=true; shift ;;
    --threshold) THRESHOLD="$2"; shift 2 ;;
    --dry-run)  DRY_RUN=true; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# Asegurar state file
if [[ ! -f "$STATE" ]]; then
  echo '{"last_consolidated_count": 76, "last_run": null, "runs": 0}' > "$STATE"
fi

# Contar episodios: formato **E-X##**: 
LAST_COUNT=$(python3 -c "import json; print(json.load(open('$STATE'))['last_consolidated_count'])")
TOTAL=$(grep -oP '\*\*E-[A-Z]+\d+\*\*' "$EPISODES" | sort -u | wc -l)
NEW=$((TOTAL - LAST_COUNT))

# Sanity check
if [[ $NEW -lt 0 ]]; then
  echo "⚠️  State desincronizado (last=$LAST_COUNT, total=$TOTAL). Reseteando."
  LAST_COUNT=0
  NEW=$TOTAL
  python3 -c "
import json
with open('$STATE', 'w') as f:
    json.dump({'last_consolidated_count': 0, 'last_run': None, 'runs': 0}, f, indent=2)
"
fi

echo "=== SoI Consolidación ==="
echo "Episodios totales:       $TOTAL"
echo "Último consolidado:      $LAST_COUNT"
echo "Nuevos sin consolidar:   $NEW"
echo "Umbral:                  $THRESHOLD"
echo "Forzar:                  $FORCE"
echo ""

# Decidir si ejecutar
if [[ "$FORCE" == false && $NEW -lt $THRESHOLD ]]; then
  echo "⏸  No hay suficientes episodios nuevos ($NEW < $THRESHOLD). Usa --force para forzar."
  exit 0
fi

if [[ $NEW -eq 0 ]]; then
  echo "⏸  No hay episodios nuevos. Nada que consolidar."
  exit 0
fi

echo "🫀 Consolidación: $NEW episodios nuevos..."

# Extraer episodios no consolidados
EPISODES_EXTRACT=$(python3 -c "
import re

with open('$EPISODES', 'r') as f:
    content = f.read()

episodes = []
for line in content.split('\n'):
    m = re.match(r'- \*\*(E-[A-Z]+\d+)\*\*:\s*(.*)', line)
    if m:
        episodes.append(f'{m.group(1)}: {m.group(2)[:300]}')

last_count = $LAST_COUNT
new_eps = episodes[last_count:]
if not new_eps:
    new_eps = episodes[-10:]

print('\n'.join(new_eps))
")

if [[ -z "$EPISODES_EXTRACT" ]]; then
  echo "⚠️  No se pudieron extraer episodios. Revisa el formato."
  exit 1
fi

EXTRACTED_COUNT=$(echo "$EPISODES_EXTRACT" | wc -l)
echo "📋 Extraídos $EXTRACTED_COUNT episodios para destilación"

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo "=== DRY RUN ==="
  echo "$EPISODES_EXTRACT"
  echo ""
  echo "=== No se llamó a la API ==="
  exit 0
fi

# Verificar API key
if [[ -z "${DEEPSEEK_API_KEY:-}" ]]; then
  echo "❌ DEEPSEEK_API_KEY no definida."
  exit 1
fi

# Knowledge actual (primeros 3000 chars para contexto)
KNOWLEDGE_CURRENT=""
if [[ -f "$KNOWLEDGE" ]]; then
  KNOWLEDGE_CURRENT=$(head -c 3000 "$KNOWLEDGE")
fi

echo "🧪 Llamando a DeepSeek..."
python3 "$DISTILL_SCRIPT" \
  --episodes-text "$EPISODES_EXTRACT" \
  --knowledge-text "$KNOWLEDGE_CURRENT" \
  --api-key "$DEEPSEEK_API_KEY" \
  --total-new "$NEW" \
  --priorities-out "$PRIORITIES" \
  --neuromod-out "$NEUROMOD_SUGGESTED" \
  --knowledge-out "$KNOWLEDGE" \
  --validation-out "$VALIDATION"

if [[ $? -ne 0 ]]; then
  echo "❌ Error en destilación."
  exit 1
fi

# Actualizar state
python3 -c "
import json
from datetime import datetime, timezone

with open('$STATE', 'r') as f:
    state = json.load(f)

state['last_consolidated_count'] = $TOTAL
state['last_run'] = datetime.now(timezone.utc).isoformat()
state['runs'] = state.get('runs', 0) + 1

with open('$STATE', 'w') as f:
    json.dump(state, f, indent=2)
"

echo ""
echo "🫀 Consolidación completada."
echo "   Episodios: $LAST_COUNT → $TOTAL (+$NEW)"

# === HEAT DECAY ===
echo ""
echo "🔥 Aplicando heat decay a episodios no referenciados..."
python3 << HEATEOF
import re

episodes_path = "$REPO_ROOT/memory/brain/episodes.md"
with open(episodes_path, "r") as f:
    lines = f.readlines()

sessions = re.findall(r'### s(\d+)', ''.join(lines))
if not sessions:
    print("  No sessions found, skip")
    exit(0)

current_s = max(int(s) for s in sessions)
decay_threshold = 5
changes = 0
new_lines = []

for line in lines:
    m = re.search(r'heat:(\d+)', line)
    s = re.search(r'\bs(\d+)\b', line) if m else None
    if m and s:
        heat = int(m.group(1))
        ep_s = int(s.group(1))
        age = current_s - ep_s
        if age >= decay_threshold and heat > 1:
            new_heat = heat - 1
            line = line.replace("heat:%d" % heat, "heat:%d" % new_heat, 1)
            changes += 1
    new_lines.append(line)

if changes > 0:
    with open(episodes_path, "w") as f:
        f.writelines(new_lines)
    print("  decay: %d episodios (-1 heat, umbral %d sesiones)" % (changes, decay_threshold))
else:
    print("  sin decay necesario")
HEATEOF

echo ""
echo "Revisa antes de commit:"
echo "  - $PRIORITIES"
echo "  - $NEUROMOD_SUGGESTED"
echo "  - $VALIDATION (tareas de validación → promover a intentions.yml si procede)"
echo "  - $KNOWLEDGE (append si hay patrones nuevos)"
