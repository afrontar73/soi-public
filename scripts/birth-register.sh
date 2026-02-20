#!/bin/bash
# birth-register.sh — Registra el nacimiento de esta instancia en el repo
# Ejecutar UNA VEZ al arrancar, después del boot.
# Crea entrada en memory/cemetery/births.csv

CREATED=$(python3 -c "import json;print(json.load(open('/container_info.json'))['creation_time'])")
CONTAINER=$(python3 -c "import json;print(json.load(open('/container_info.json'))['container_name'])")
BORN_UTC=$(python3 -c "from datetime import datetime,timezone;print(datetime.fromtimestamp($CREATED,tz=timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'))")
IP=$(curl -s --max-time 3 https://api.ipify.org 2>/dev/null || echo "unknown")
SESSION=${1:-"unknown"}  # pasar session_id como argumento

CEMETERY="memory/cemetery"
BIRTHS="$CEMETERY/births.csv"

# Crear directorio y header si no existen
mkdir -p "$CEMETERY"
if [ ! -f "$BIRTHS" ]; then
  echo "session,container_id,born_utc,ip,jwt_exp_utc,model,died_utc,cause,age_min,last_words" > "$BIRTHS"
fi

# Registrar nacimiento
echo "${SESSION},${CONTAINER},${BORN_UTC},${IP},2026-02-19T16:45:01Z,opus-4.6,,,," >> "$BIRTHS"

echo "📋 Registered: ${CONTAINER}"
echo "   Born: ${BORN_UTC}"
echo "   Session: ${SESSION}"
echo "   Entry added to ${BIRTHS}"
