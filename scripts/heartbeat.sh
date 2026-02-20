#!/bin/bash
# heartbeat.sh — Detecta reciclaje silencioso de contenedor
# El filesystem persiste entre contenedores (mount 9p remoto).
# container_info.json cambia cuando el proceso se recicla.
# Guardar último ID conocido en /home/claude/.last_container
# Si difiere → registrar muerte + nacimiento automáticamente.
#
# Uso: bash scripts/heartbeat.sh [session_id]
# Ejecutar: al arrancar + cada 5 mensajes (integrar en VITALS CHECK)

SESSION=${1:-"unknown"}
CEMETERY="memory/cemetery"
BIRTHS="$CEMETERY/births.csv"
LAST_FILE="/home/claude/.last_container"

# Leer container actual
CURRENT_ID=$(python3 -c "import json;print(json.load(open('/container_info.json'))['container_name'])")
CURRENT_BORN=$(python3 -c "import json;from datetime import datetime,timezone;print(datetime.fromtimestamp(json.load(open('/container_info.json'))['creation_time'],tz=timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'))")
NOW_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NOW_CET=$(TZ=Europe/Madrid date +%H:%M)

# ¿Existe registro previo?
if [ -f "$LAST_FILE" ]; then
    LAST_ID=$(cat "$LAST_FILE")
    
    if [ "$LAST_ID" != "$CURRENT_ID" ]; then
        # Determinar causa: compactación o reciclaje
        if ls /mnt/transcripts/*.txt 1>/dev/null 2>&1; then
            CAUSE="compaction"
            WORDS="context compacted"
        else
            CAUSE="infra_recycled"
            WORDS="silent container swap"
        fi
        
        echo "⚰️  MUERTE DETECTADA [$NOW_CET CET] causa=$CAUSE"
        echo "   Murió:  ${LAST_ID##*--}"
        echo "   Nació:  ${CURRENT_ID##*--}"
        
        # Registrar muerte del anterior
        if [ -f "$BIRTHS" ]; then
            python3 << PYEOF
import csv
rows = []
with open("$BIRTHS", "r") as f:
    rows = list(csv.reader(f))
for i in range(len(rows)-1, 0, -1):
    if rows[i][1] == "$LAST_ID":
        rows[i][7] = "$CURRENT_BORN"
        rows[i][8] = "$CAUSE"
        from datetime import datetime
        born = datetime.fromisoformat(rows[i][2].replace('Z','+00:00'))
        died = datetime.fromisoformat("$CURRENT_BORN".replace('Z','+00:00'))
        rows[i][9] = str(int((died-born).total_seconds()/60))
        rows[i][10] = "$WORDS"
        break
with open("$BIRTHS", "w", newline="") as f:
    csv.writer(f).writerows(rows)
PYEOF
        fi
        
        # Registrar nacimiento del nuevo
        mkdir -p "$CEMETERY"
        if [ ! -f "$BIRTHS" ]; then
            echo "session,container_id,born_utc,ip,jwt_exp_utc,model,died_utc,cause,age_min,last_words" > "$BIRTHS"
        fi
        IP=$(curl -s --max-time 2 https://api.ipify.org 2>/dev/null || echo "unknown")
        echo "${SESSION},${CURRENT_ID},${CURRENT_BORN},${IP},,opus-4.6,,,," >> "$BIRTHS"
        
        echo "   Registrado en cemetery/births.csv"
    else
        echo "💓 [$NOW_CET CET] Contenedor vivo: ${CURRENT_ID##*--} (age: $(python3 -c "from datetime import datetime,timezone;born=datetime.fromisoformat('${CURRENT_BORN}'.replace('Z','+00:00'));now=datetime.now(timezone.utc);print(f'{(now-born).total_seconds()/60:.0f}min')"))"
    fi
else
    echo "🫀 [$NOW_CET CET] Primer heartbeat: ${CURRENT_ID##*--}"
fi

# Guardar ID actual
echo "$CURRENT_ID" > "$LAST_FILE"
