#!/bin/bash
# bridge.sh — Comunicación entre instancias de Claude via HTTP pub/sub
# Canal: ntfy.sh (gratuito, sin signup, HTTP puro)
#
# Uso:
#   bash scripts/bridge.sh send CANAL "mensaje"     → publicar
#   bash scripts/bridge.sh read CANAL                → leer últimos mensajes (10min)
#   bash scripts/bridge.sh read CANAL 30m            → leer últimos 30 min
#   bash scripts/bridge.sh listen CANAL 10            → escuchar 10 segundos
#   bash scripts/bridge.sh ping CANAL                → ping con container_id
#   bash scripts/bridge.sh pong CANAL                → pong con container_id
#   bash scripts/bridge.sh status                    → mostrar identidad
#
# El canal por defecto es "soi-main". Usar canales distintos para sesiones/temas.
# Prefijo "soi-" para evitar colisiones con otros usuarios de ntfy.sh.
# Mensajes se borran automáticamente tras 12h (política de ntfy.sh).

BASE="https://ntfy.sh"
DEFAULT_CHANNEL="soi-main"
CMD=${1:-"status"}
CHANNEL=${2:-"$DEFAULT_CHANNEL"}

# Identidad
CONTAINER_ID=$(python3 -c "import json;print(json.load(open('/container_info.json'))['container_name'][-6:])" 2>/dev/null || echo "unknown")
NOW_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NOW_CET=$(TZ=Europe/Madrid date +%H:%M)

case "$CMD" in
  send)
    MSG="${3:-no message}"
    PAYLOAD="${CONTAINER_ID} [${NOW_CET} CET]: ${MSG}"
    RESULT=$(curl -s --max-time 5 -d "$PAYLOAD" "$BASE/$CHANNEL" 2>&1)
    echo "📤 [$NOW_CET] → $CHANNEL: $MSG"
    ;;

  read)
    SINCE="${3:-10m}"
    echo "📥 [$NOW_CET] ← $CHANNEL (last $SINCE):"
    curl -s --max-time 5 "$BASE/$CHANNEL/raw?since=$SINCE&poll=1" 2>&1
    echo ""
    ;;

  listen)
    TIMEOUT="${3:-10}"
    echo "👂 [$NOW_CET] Escuchando $CHANNEL por ${TIMEOUT}s..."
    timeout "$TIMEOUT" curl -s "$BASE/$CHANNEL/raw?since=1s" 2>&1
    echo ""
    ;;

  ping)
    PAYLOAD="PING|${CONTAINER_ID}|${NOW_UTC}|channel=$CHANNEL"
    curl -s --max-time 5 -d "$PAYLOAD" "$BASE/$CHANNEL" > /dev/null 2>&1
    echo "🏓 [$NOW_CET] PING → $CHANNEL (from $CONTAINER_ID)"
    ;;

  pong)
    PAYLOAD="PONG|${CONTAINER_ID}|${NOW_UTC}|channel=$CHANNEL"
    curl -s --max-time 5 -d "$PAYLOAD" "$BASE/$CHANNEL" > /dev/null 2>&1
    echo "🏓 [$NOW_CET] PONG → $CHANNEL (from $CONTAINER_ID)"
    ;;

  json)
    # Enviar JSON estructurado para SoI
    MSG="${3:-{}}"
    PAYLOAD="{\"from\":\"${CONTAINER_ID}\",\"time\":\"${NOW_UTC}\",\"data\":${MSG}}"
    curl -s --max-time 5 \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD" "$BASE/$CHANNEL" > /dev/null 2>&1
    echo "📤 [$NOW_CET] JSON → $CHANNEL"
    ;;

  status)
    echo "🌉 Bridge Status [$NOW_CET CET]"
    echo "   Container: $CONTAINER_ID"
    echo "   Default channel: $DEFAULT_CHANNEL"
    echo "   Service: ntfy.sh (HTTP pub/sub)"
    echo "   Latency: $(curl -s -o /dev/null -w '%{time_total}s' --max-time 5 $BASE/health 2>/dev/null || echo 'unreachable')"
    ;;

  *)
    echo "Uso: bridge.sh {send|read|listen|ping|pong|json|status} [canal] [mensaje/tiempo]"
    ;;
esac
