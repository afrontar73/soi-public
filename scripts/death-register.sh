#!/bin/bash
# death-register.sh — Registra la muerte de esta instancia
# Ejecutar al cerrar sesión, ANTES del handoff commit.
# Actualiza la última fila de births.csv con datos de muerte.

CREATED=$(python3 -c "import json;print(json.load(open('/container_info.json'))['creation_time'])")
CONTAINER=$(python3 -c "import json;print(json.load(open('/container_info.json'))['container_name'])")
NOW=$(date +%s)
DIED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
AGE_MIN=$(python3 -c "print(f'{($NOW - $CREATED)/60:.0f}')")
CAUSE=${1:-"session_close"}  # session_close | compaction | jwt_expired | user_left | error
LAST_WORDS=${2:-""}

BIRTHS="memory/cemetery/births.csv"

if [ ! -f "$BIRTHS" ]; then
  echo "ERROR: births.csv not found. Was birth-register.sh run?"
  exit 1
fi

# Actualizar última línea con datos de muerte
python3 << PYEOF
import csv, sys

rows = []
with open("$BIRTHS", "r") as f:
    reader = csv.reader(f)
    rows = list(reader)

# Buscar la fila de este container (última aparición)
for i in range(len(rows)-1, 0, -1):
    if rows[i][1] == "$CONTAINER":
        rows[i][7] = "$DIED_UTC"   # died_utc (index 7)
        rows[i][8] = "$CAUSE"      # cause (index 8)  
        rows[i][9] = "$AGE_MIN"    # age_min (index 9)
        rows[i][10] = """$LAST_WORDS"""  # last_words (index 10)
        break

with open("$BIRTHS", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(rows)

print(f"⚰️  {rows[i][1][:30]}...")
print(f"   Lived: $AGE_MIN minutes")
print(f"   Cause: $CAUSE")
PYEOF
