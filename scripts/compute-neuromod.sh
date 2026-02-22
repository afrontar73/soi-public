#!/bin/bash
# compute-neuromod.sh — Calcula neuromod desde datos objetivos (git log + repo)
# Cero opinión. Solo aritmética.
# Output: memory/brain/neuromod-computed.yml

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

WINDOW=${1:-5}  # sesiones a mirar (default: 5)
OUTPUT="$REPO_ROOT/memory/brain/neuromod-computed.yml"

echo "=== compute-neuromod.sh (ventana: ${WINDOW} sesiones) ==="

python3 << PYEOF
import subprocess, json, re, os
from datetime import datetime, timezone

WINDOW = $WINDOW
repo = "$REPO_ROOT"

def git(*args):
    r = subprocess.run(["git", "-C", repo] + list(args), capture_output=True, text=True)
    return r.stdout.strip()

def clamp(val, lo=1, hi=10):
    return max(lo, min(hi, round(val, 1)))

# === DETECT SESSION RANGE ===
log = git("log", "--oneline", "-50")
sessions = sorted(set(int(m) for m in re.findall(r'\bs(\d+)\b', log)))
if not sessions:
    print("No sessions found in git log")
    exit(1)

current_s = max(sessions)
window_start = max(1, current_s - WINDOW + 1)
print(f"  Sesiones: s{window_start}-s{current_s} (ventana {WINDOW})")

# === SEÑAL 1: REVERTS ===
reverts = len(git("log", "--oneline", "--all", "--grep=revert", "-i").splitlines())
# Filter to window: check if revert commit message mentions sN in range
revert_lines = git("log", "--oneline", "--all", "--grep=revert", "-i").splitlines()
reverts_in_window = 0
for line in revert_lines:
    for s in range(window_start, current_s + 1):
        if f"s{s}" in line:
            reverts_in_window += 1
            break
print(f"  Reverts (ventana): {reverts_in_window} (total histórico: {reverts})")

# === SEÑAL 2: REWRITES (mismo archivo en 2+ commits misma sesión) ===
rewrites = 0
for s in range(window_start, current_s + 1):
    grep_pattern = "s%d:" % s
    raw = git("log", "--oneline", "--grep=" + grep_pattern, "--name-only")
    files_this_session = []
    for block in raw.split("\n"):
        line = block.strip()
        if line and not line[0].isalnum():
            continue
        # Lines that look like file paths (contain /)
        if "/" in line and not line.startswith(("s", "S")):
            files_this_session.append(line)
    from collections import Counter
    counts = Counter(files_this_session)
    session_rewrites = sum(1 for f, c in counts.items() if c > 1)
    rewrites += session_rewrites

print(f"  Rewrites (archivos tocados 2+ veces en misma sesión): {rewrites}")

# === SEÑAL 3: INTENCIONES ESTANCADAS ===
stalled = 0
try:
    with open(os.path.join(repo, "memory/brain/intentions.yml")) as f:
        content = f.read()
    # Find pending intentions with old last_executed
    for block in re.findall(r'- id:.*?(?=\n  - id:|\Z)', content, re.DOTALL):
        if 'status: pending' in block:
            m = re.search(r'last_executed:\s*s(\d+)', block)
            if m:
                last_s = int(m.group(1))
                if current_s - last_s >= 3:
                    stalled += 1
            elif 'last_executed: never' in block:
                stalled += 1
except Exception:
    pass
print(f"  Intenciones estancadas (pending + >3 sesiones): {stalled}")

# === SEÑAL 4: DÍAS DESDE ÚLTIMA CONSOLIDACIÓN ===
days_since_consol = 14  # default max
try:
    with open(os.path.join(repo, "memory/brain/consolidation-state.json")) as f:
        state = json.load(f)
    if state.get("last_run"):
        last = datetime.fromisoformat(state["last_run"])
        days_since_consol = (datetime.now(timezone.utc) - last).days
except Exception:
    pass
print(f"  Días desde consolidación: {days_since_consol}")

# === SEÑAL 5: ARCHIVOS NUEVOS vs MODIFICADOS (última sesión) ===
new_files = 0
mod_files = 0
dirs_touched = set()
grep_current = "s%d:" % current_s
session_raw = git("log", "--grep=" + grep_current, "--name-status", "--pretty=format:")
for line in session_raw.splitlines():
    line = line.strip()
    if line.startswith("A\t"):
        new_files += 1
        dirs_touched.add(os.path.dirname(line[2:]))
    elif line.startswith("M\t"):
        mod_files += 1
        dirs_touched.add(os.path.dirname(line[2:]))
print(f"  Última sesión: {new_files} nuevos, {mod_files} modificados, {len(dirs_touched)} dirs")

# === SEÑAL 6: ZERO DELIVERABLES ===
zero_deliverables = 1 if (new_files + mod_files) == 0 else 0

# ========== FÓRMULAS (DS v1) ==========

# CONFIANZA: 10 - penalización por errores
revert_score = min(reverts_in_window, 3) / 3.0
rewrite_score = min(rewrites, 10) / 10.0
penalizacion = 0.6 * revert_score + 0.4 * rewrite_score
confidence = clamp(10 - 6 * penalizacion)  # rango ~4-10

# URGENCIA: presión por deuda acumulada
stalled_score = min(stalled, 5) / 5.0
consol_score = min(days_since_consol, 14) / 14.0
urgency_raw = 1 + 5 * (0.5 * stalled_score + 0.3 * consol_score + 0.2 * zero_deliverables)
urgency = clamp(urgency_raw * 1.66)

# EXPLORACIÓN: territorio nuevo
new_score = min(new_files, 5) / 5.0
mod_score = min(mod_files, 10) / 10.0
exploration = clamp(3 + 5 * (0.6 * new_score + 0.4 * mod_score))  # rango 3-8

# CAUTELA: inversamente proporcional a confianza + errores recientes
recent_errors = reverts_in_window  # solo reverts de esta ventana
error_score = min(recent_errors, 3) / 3.0
conf_low = 1 if confidence < 6 else 0
caution = clamp(4 + 4 * (0.7 * error_score + 0.3 * conf_low))  # rango 4-8

print(f"\n  === RESULTADO ===")
print(f"  confidence: {confidence}")
print(f"  urgency:    {urgency}")
print(f"  exploration: {exploration}")
print(f"  caution:    {caution}")

# === WRITE OUTPUT ===
from datetime import datetime as dt
now = dt.now(timezone.utc).isoformat()

output = f"""# neuromod-computed.yml — Auto-generado por compute-neuromod.sh
# Basado en git log + repo data. Cero opinión.
# Generado: {now}
# Ventana: s{window_start}-s{current_s} ({WINDOW} sesiones)

confidence:
  valor: {confidence}
  evidencia:
    reverts_ventana: {reverts_in_window}
    rewrites_ventana: {rewrites}
    formula: "10 - 6*(0.6*{revert_score:.2f} + 0.4*{rewrite_score:.2f})"

urgency:
  valor: {urgency}
  evidencia:
    intenciones_estancadas: {stalled}
    dias_sin_consolidacion: {days_since_consol}
    zero_deliverables_ultima_sesion: {zero_deliverables}
    formula: "(1 + 5*(0.5*{stalled_score:.2f} + 0.3*{consol_score:.2f} + 0.2*{zero_deliverables})) * 1.66"

exploration:
  valor: {exploration}
  evidencia:
    archivos_nuevos: {new_files}
    archivos_modificados: {mod_files}
    dirs_tocados: {len(dirs_touched)}
    formula: "3 + 5*(0.6*{new_score:.2f} + 0.4*{mod_score:.2f})"

caution:
  valor: {caution}
  evidencia:
    errores_recientes: {recent_errors}
    confianza_baja: {conf_low}
    formula: "4 + 4*(0.7*{error_score:.2f} + 0.3*{conf_low})"
"""

with open("$OUTPUT", "w") as f:
    f.write(output)
print(f"\n  ✅ Escrito: $OUTPUT")
PYEOF
