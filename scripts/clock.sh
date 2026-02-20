#!/bin/bash
# clock.sh — Reloj mecánico de la instancia
# Usa container_info.json + system time. No puede fabricar.
# Uso: bash scripts/clock.sh

CREATED=$(python3 -c "import json;print(json.load(open('/container_info.json'))['creation_time'])")
CONTAINER=$(python3 -c "import json;print(json.load(open('/container_info.json'))['container_name'])")
NOW=$(date +%s)
AGE=$(python3 -c "print(f'{($NOW - $CREATED)/60:.0f}')")
JWT_EXP=1771519501  # TODO: extraer dinámicamente del ENV
LIFE_LEFT=$(python3 -c "r=$JWT_EXP - $NOW; print(f'{r/3600:.1f}h') if r > 0 else print('EXPIRED')")

# Output
echo "now:      $(date -u +%Y-%m-%dT%H:%M:%S\ UTC) | $(TZ=Europe/Madrid date +%H:%M\ CET)"
echo "born:     $(python3 -c "from datetime import datetime,timezone;print(datetime.fromtimestamp($CREATED,tz=timezone.utc).strftime('%H:%M:%S UTC'))")"
echo "age:      ${AGE}min"
echo "jwt_dies: $(python3 -c "from datetime import datetime,timezone;print(datetime.fromtimestamp($JWT_EXP,tz=timezone.utc).strftime('%H:%M UTC'))") (${LIFE_LEFT} left)"
echo "container: ${CONTAINER}"
