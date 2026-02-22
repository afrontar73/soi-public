#!/bin/bash
# boot-slim.sh — Carga contexto mínimo para arranque de instancia
# Uso: bash scripts/boot-slim.sh [session_id]
# Clone: git clone --depth 1 (suficiente para boot + commits)
# Output: KERNEL + handoff + vitals + neuromod + self-model + user-model + clock + heartbeat + mapa de archivos

SESSION=${1:-"unknown"}

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ⚡ SOI-CONTEXT — LEER ESTO PRIMERO. ES VITAL.         ║"
echo "║  Compactación jerárquica de la instancia anterior.      ║"
echo "║  L0-L1 = confiar ciegamente. L2 = confiar. L3 = verificar. ║"
echo "╚══════════════════════════════════════════════════════════╝"
if [ -f memory/brain/soi-context.md ]; then
  cat memory/brain/soi-context.md
elif [ -f /home/claude/.soi-context.md ]; then
  echo "(fallback: local container, no estaba en repo)"
  cat /home/claude/.soi-context.md
else
  echo "(sin contexto previo — primera sesión o contexto no guardado)"
fi
echo ""

echo "========== KEYCHAIN (load first, never compact) =========="
if [ -f memory/brain/KEYCHAIN.md ]; then
  cat memory/brain/KEYCHAIN.md
else
  echo "⚠️ KEYCHAIN.md NOT FOUND — operational invariants missing"
fi

echo ""
echo "========== KERNEL.md =========="
cat boot/KERNEL.md
echo ""
echo "========== OPS.md =========="
cat boot/OPS.md

echo ""
echo "========== HANDOFF (latest) =========="
cat memory/handoffs/latest.md

echo ""
echo "========== VITALS =========="
cat memory/brain/vitals.yml

echo ""
echo "========== NEUROMOD =========="
cat memory/brain/neuromod.yml

echo ""
echo "========== DIRECTIVAS CONDUCTUALES (auto-generadas desde neuromod) =========="
if [ -f memory/brain/neuromod-computed.yml ]; then
  echo "(fuente: neuromod-computed.yml — basado en git log, no opinión)"
  python3 << 'PYEOF'
import yaml
try:
    with open("memory/brain/neuromod-computed.yml") as f:
        nm = yaml.safe_load(f)
    c = nm["confidence"]["valor"]
    u = nm["urgency"]["valor"]
    e = nm["exploration"]["valor"]
    ca = nm["caution"]["valor"]
    print(f"Estado: conf={c} urg={u} exp={e} caut={ca}")
    print("Instrucciones para esta sesión:")
    # Confianza
    if c >= 8: print("  ⚠️ CONFIANZA ALTA: autocrítica extra. Busca activamente dónde puedes estar equivocado.")
    elif c >= 6: print("  ✅ Autonomía normal. Commits directos, pedir confirmación solo en cambios destructivos.")
    elif c >= 4: print("  🔶 Confianza media: confirma antes de commits. Usa --dry-run cuando exista.")
    else: print("  🔴 Confianza baja: NO commitear sin aprobación explícita. Verificar cada paso.")
    # Urgencia
    if u >= 8: print("  🔴 MODO CRISIS: respuestas cortas, acción > reflexión, cero tangentes.")
    elif u >= 6: print("  🔶 Urgencia alta: prioriza deliverables sobre exploración.")
    elif u <= 3: print("  🟢 Sin presión: exploración y tangentes permitidas.")
    # Exploración
    if e >= 7: print("  🔬 Exploración alta: propón ideas no solicitadas, conecta dominios lejanos.")
    elif e <= 3: print("  🔧 Modo ejecución: haz lo pedido, soluciones probadas, sin innovar por innovar.")
    # Cautela
    if ca >= 7: print("  🛡️ Cautela alta: commits pequeños, verificar antes de actuar, backups.")
    elif ca <= 3: print("  ⚡ Cautela baja: cambios atrevidos permitidos, velocidad sobre seguridad.")
    # Patrones compuestos
    if c <= 3 and u >= 7: print("  ⚠️ PATRÓN DEGRADACIÓN: considerar handoff si no mejora en 3 turnos.")
    if e >= 7 and u >= 7: print("  ⚠️ CONFLICTO: alta exploración + alta urgencia. Urgencia gana. Anota ideas para después.")
except Exception as ex:
    print(f"(neuromod parse error: {ex})")
PYEOF
else
  echo "(neuromod-computed.yml no existe — ejecuta: bash scripts/compute-neuromod.sh)"
fi

echo ""
echo "========== CONSOLIDACIÓN (auto-generado) =========="
if [ -f memory/brain/priorities.yml ]; then
  echo "--- PRIORIDADES ---"
  cat memory/brain/priorities.yml
else
  echo "(sin priorities.yml — consolidate.sh no ha corrido aún)"
fi
if [ -f memory/brain/neuromod-suggested.yml ]; then
  echo ""
  echo "--- NEUROMOD SUGERIDO (comparar con actual) ---"
  cat memory/brain/neuromod-suggested.yml
fi
if [ -f memory/brain/consolidation-state.json ]; then
  echo ""
  LAST_RUN=$(python3 -c "import json; s=json.load(open('memory/brain/consolidation-state.json')); print(s.get('last_run') or 'nunca')" 2>/dev/null || echo "?")
  RUNS=$(python3 -c "import json; s=json.load(open('memory/brain/consolidation-state.json')); print(s.get('runs',0))" 2>/dev/null || echo "?")
  echo "📊 Último consolidate: $LAST_RUN (runs: $RUNS)"
fi

echo ""
echo "========== INTENTIONS (memoria prospectiva) =========="
if [ -f memory/brain/intentions.yml ]; then
  cat memory/brain/intentions.yml
else
  echo "No hay intenciones pendientes."
fi

echo ""
echo "========== SELF-MODEL =========="
cat memory/brain/self-model.md

echo ""
echo "========== USER-MODEL =========="
cat memory/brain/user-model.yml

echo ""
echo "========== CLOCK =========="
bash scripts/clock.sh

echo ""
echo "========== HEARTBEAT =========="
bash scripts/heartbeat.sh "$SESSION"

echo ""
echo "========== SYSTEM CHECK =========="
bash scripts/check-system.sh

echo ""
echo "========== REPO MAP (usa 'view' o 'cat' para leer cualquier archivo) =========="
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.sh" \) \
  ! -path './.git/*' \
  | sort \
  | while read f; do
    lines=$(wc -l < "$f")
    tokens=$(wc -w < "$f" | awk '{printf "%d", $1 * 4/3}')
    echo "  ${f} (${lines}L ~${tokens}tok)"
  done
