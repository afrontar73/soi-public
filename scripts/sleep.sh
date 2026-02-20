#!/bin/bash
# sleep.sh — Ciclo NREM mecánico. Ejecutar al cerrar sesión.
# Uso: bash scripts/sleep.sh [--dry-run]
# --dry-run: solo diagnostica, no modifica archivos (default si no se pasa flag)
# Sin flag: EJECUTA poda y compresión

set -e
REPO=$(cd "$(dirname "$0")/.." && pwd)
EPISODES="$REPO/memory/brain/episodes.md"
HANDOFFS="$REPO/memory/handoffs"
DIGEST="$REPO/memory/compressed/handoffs-digest.md"
DRY_RUN=true

[ "$1" = "--execute" ] && DRY_RUN=false

echo "🛌 SLEEP CYCLE $([ "$DRY_RUN" = true ] && echo '(DRY RUN)' || echo '(EXECUTING)')"
echo ""

# ═══════════════════════════════════════
# 1. EPISODES: contar, identificar podables, podar si --execute
# ═══════════════════════════════════════
TOTAL=$(grep -c "^- \*\*E-" "$EPISODES" 2>/dev/null || echo 0)
echo "📊 Episodes: $TOTAL (umbral: 50)"

# Aplicar heat decay (-1 global) si --execute
if [ "$DRY_RUN" = false ]; then
  python3 -c "
import re, sys
text = open('$EPISODES').read()
def decay(m):
    v = int(m.group(1)) - 1
    return f'heat:{v}'
text = re.sub(r'heat:(\d+)', decay, text)
open('$EPISODES', 'w').write(text)
print(f'   🔥 Heat decay aplicado (-1 global)')
"
fi

# Encontrar episodios con heat < 1 (candidatos a poda)
PODABLES=$(grep -P "^- \*\*E-.*heat:\s*[0-]" "$EPISODES" 2>/dev/null | wc -l || echo 0)
echo "   Candidatos poda (heat ≤ 0): $PODABLES"

if [ "$TOTAL" -gt 50 ]; then
  EXCESO=$((TOTAL - 50))
  echo "⚠️  $EXCESO sobre el límite"
  
  if [ "$DRY_RUN" = false ] && [ "$PODABLES" -gt 0 ]; then
    # Mover episodios con heat ≤ 0 a ARCHIVE al final del archivo
    if ! grep -q "^## ARCHIVE" "$EPISODES"; then
      echo "" >> "$EPISODES"
      echo "## ARCHIVE (podados por sleep.sh)" >> "$EPISODES"
    fi
    # Mover líneas con heat:0 o heat negativo
    # Mover líneas con heat:0 o heat negativo (solo si no tienen links entrantes)
    python3 -c "
import re
text = open('$EPISODES').read()
lines = text.splitlines()
defined = set(re.findall(r'\*\*(E-[A-Z]\d+)\*\*', text))
# Find all link targets to know which episodes are referenced
all_links = set()
for line in lines:
    m = re.search(r'links:\s*\[([^\]]*)\]', line)
    if m:
        all_links.update(t.strip() for t in m.group(1).split(',') if t.strip())

archive = []
keep = []
in_archive = False
for line in lines:
    if line.startswith('## ARCHIVE'):
        in_archive = True
        continue
    if in_archive:
        archive.append(line)
        continue
    # Check if this is a podable episode
    m_id = re.search(r'\*\*(E-[A-Z]\d+)\*\*', line)
    m_heat = re.search(r'heat:\s*(-?\d+)', line)
    if m_id and m_heat and int(m_heat.group(1)) <= 0:
        eid = m_id.group(1)
        if eid in all_links:
            # Has incoming links, keep it but warn
            print(f'   ⚠️  {eid} tiene links entrantes, no archivado')
            keep.append(line)
        else:
            archive.append(line)
            print(f'   ✂️  {eid} archivado (heat {m_heat.group(1)})')
    else:
        keep.append(line)

# Rebuild file
with open('$EPISODES', 'w') as f:
    f.write('\n'.join(keep))
    if archive:
        f.write('\n\n## ARCHIVE (podados por sleep.sh)\n')
        f.write('\n'.join(archive))
    f.write('\n')
"
  fi
else
  echo "✅ Dentro del umbral"
fi

echo ""

# ═══════════════════════════════════════
# 2. HANDOFFS: comprimir viejos automáticamente
# ═══════════════════════════════════════
LATEST=$(grep -oP 's\d+-[0-9-]+\.md' "$HANDOFFS/latest.md" 2>/dev/null || echo "unknown")
HANDOFF_FILES=($(ls "$HANDOFFS"/s*.md 2>/dev/null | sort))
HANDOFF_COUNT=${#HANDOFF_FILES[@]}
echo "📋 Handoffs: $HANDOFF_COUNT archivos (latest: $LATEST)"

# Identificar comprimibles (todo menos latest y penúltimo)
COMPRIMIBLES=()
for f in "${HANDOFF_FILES[@]}"; do
  FNAME=$(basename "$f")
  [ "$FNAME" = "$LATEST" ] && continue
  # Penúltimo: el anterior al latest en orden
  COMPRIMIBLES+=("$f")
done
# Quitar el último de COMPRIMIBLES (es el penúltimo handoff, lo mantenemos)
if [ ${#COMPRIMIBLES[@]} -gt 1 ]; then
  unset 'COMPRIMIBLES[${#COMPRIMIBLES[@]}-1]'
fi

if [ ${#COMPRIMIBLES[@]} -gt 0 ]; then
  echo "⚠️  ${#COMPRIMIBLES[@]} handoffs comprimibles"
  
  if [ "$DRY_RUN" = false ]; then
    for f in "${COMPRIMIBLES[@]}"; do
      FNAME=$(basename "$f")
      # Extraer session_id
      SID=$(grep -oP 'session_id:\s*\K.*' "$f" 2>/dev/null | head -1 || echo "$FNAME")
      # Extraer DECISIONS (primera línea)
      DECISION=$(grep -A1 "DECISIONS" "$f" 2>/dev/null | tail -1 | head -c 120 || echo "sin datos")
      # Añadir al digest si no está ya
      if ! grep -q "$FNAME" "$DIGEST" 2>/dev/null; then
        echo "| $SID | $(echo $FNAME | grep -oP '\d{4}-\d{2}-\d{2}' || echo '?') | $DECISION |" >> "$DIGEST"
      fi
      rm "$f"
      echo "   ✂️  $FNAME → digest + eliminado"
    done
  else
    for f in "${COMPRIMIBLES[@]}"; do
      echo "   → $(basename $f)"
    done
  fi
else
  echo "✅ Handoffs dentro de rango"
fi

echo ""

# ═══════════════════════════════════════
# 3. REPO SIZE
# ═══════════════════════════════════════
BRAIN_LINES=$(find "$REPO/memory/brain" -name "*.md" -o -name "*.yml" | xargs cat 2>/dev/null | wc -l)
BOOT_WORDS=$(bash "$REPO/scripts/boot-slim.sh" test 2>/dev/null | wc -w)
BOOT_TOKENS=$((BOOT_WORDS * 4 / 3))
echo "🧠 brain/ total: ${BRAIN_LINES} líneas"
echo "🚀 boot-slim: ~${BOOT_TOKENS} tokens"

if [ "$BOOT_TOKENS" -gt 4000 ]; then
  echo "⚠️  boot-slim > 4000 tokens — PODAR"
elif [ "$BOOT_TOKENS" -gt 3000 ]; then
  echo "🟡 boot-slim acercándose al límite"
else
  echo "✅ boot-slim en rango saludable"
fi

echo ""
echo "🛌 SLEEP CYCLE END $([ "$DRY_RUN" = true ] && echo '— usa --execute para aplicar cambios')"

# ═══════════════════════════════════════
# 4. MACRO-VITALS TELEMETRY (append-only)
# ═══════════════════════════════════════
HISTORY="$REPO/memory/brain/vitals_history.csv"
if [ ! -f "$HISTORY" ]; then
  echo "timestamp,session,cal,coh,eff,sat,carga,ctx,conf,urg,exp,caut" > "$HISTORY"
  echo "📊 vitals_history.csv creado"
fi

if [ "$DRY_RUN" = false ]; then
  python3 -c "
import yaml, datetime
v = yaml.safe_load(open('$REPO/memory/brain/vitals.yml'))
n = yaml.safe_load(open('$REPO/memory/brain/neuromod.yml'))
ts = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
# Extract session from latest handoff
sid = 'unknown'
try:
    lt = open('$REPO/memory/handoffs/latest.md').read()
    import re
    m = re.search(r'CURRENT:\s*(\S+)', lt)
    if m: sid = m.group(1).replace('.md','')
except: pass
row = f\"{ts},{sid},{v['calibracion']['valor']},{v['coherencia_memoria']['valor']},{v['eficiencia_tokens']['valor']},{v['satisfaccion_humano']['valor']},{v['carga_alostatica']['valor']},{v['ventana_contexto']['valor']},{n['confianza']['valor']},{n['urgencia']['valor']},{n['exploracion']['valor']},{n['cautela']['valor']}\"
with open('$HISTORY', 'a') as f:
    f.write(row + '\n')
print(f'   📊 Macro-vitals registrados: {row}')
"
else
  ROWS=$(tail -n +2 "$HISTORY" 2>/dev/null | wc -l)
  echo "📊 Macro-vitals: $ROWS registros históricos"
fi

# ═══════════════════════════════════════
# 5. LAST WRITER (state lock ligero)
# ═══════════════════════════════════════
if [ "$DRY_RUN" = false ]; then
  python3 -c "
import yaml, datetime
path = '$REPO/memory/brain/vitals.yml'
v = yaml.safe_load(open(path))
v['last_writer'] = {
    'timestamp': datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'),
    'instance': 'sleep.sh'
}
with open(path, 'w') as f:
    yaml.dump(v, f, default_flow_style=False, allow_unicode=True, sort_keys=False)
print('   🔒 last_writer actualizado')
"
fi
