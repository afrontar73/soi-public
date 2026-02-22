#!/bin/bash
# check-system.sh — Watchdog del sistema
# Lee todo, no escribe nada. Solo reporta.
# Niveles: 🔴 alerta | 🟡 aviso | ℹ️ info

echo "========== SYSTEM CHECK $(date -u +%Y-%m-%dT%H:%M:%SZ) =========="
echo ""

# 1. INTENTIONS
echo "--- INTENCIONES ---"
if [ -f memory/brain/intentions.yml ]; then
  PENDING=$(grep -c "status: pending" memory/brain/intentions.yml)
  echo "ℹ️ Pendientes: $PENDING"
  # List just id + action for pending
  awk '/status: pending/{found=1} found && /id:/{id=$2} found && /action:/{print "  " id, $0; found=0}' memory/brain/intentions.yml 2>/dev/null || \
  grep -B5 "status: pending" memory/brain/intentions.yml | grep -E "id:|action:" | sed 's/^[ ]*/  /'
else
  echo "🔴 intentions.yml no existe"
fi
echo ""

# 2. CONSOLIDATION
echo "--- CONSOLIDACIÓN ---"
if [ -f memory/brain/episodes.md ]; then
  TOTAL_EP=$(grep -c "^\- \*\*E-" memory/brain/episodes.md)
  if [ "$TOTAL_EP" -gt 80 ]; then
    echo "🔴 $TOTAL_EP episodios — consolidación urgente"
  elif [ "$TOTAL_EP" -gt 50 ]; then
    echo "🟡 $TOTAL_EP episodios — considerar consolidación"
  else
    echo "ℹ️ $TOTAL_EP episodios — OK"
  fi
fi
if [ -f memory/brain/knowledge.md ]; then
  PATTERNS=$(grep -c "^### K-" memory/brain/knowledge.md)
  echo "ℹ️ Patrones destilados: $PATTERNS"
fi
echo ""

# 3. WEEKLY
echo "--- COMPRESIÓN SEMANAL ---"
CURRENT_WEEK=$(date -u +%Y-W%V)
if [ -f "memory/compressed/weekly/week-${CURRENT_WEEK}.md" ]; then
  echo "ℹ️ Weekly $CURRENT_WEEK existe"
else
  echo "🟡 No hay weekly para $CURRENT_WEEK"
fi
echo ""

# 4. HANDOFF
echo "--- HANDOFF ---"
if [ -f memory/handoffs/latest.md ]; then
  HANDOFF_HEAD=$(head -1 memory/handoffs/latest.md)
  echo "ℹ️ $HANDOFF_HEAD"
else
  echo "🔴 No hay handoff"
fi
echo ""

# 5. VITALS
echo "--- VITALS ---"
if [ -f memory/brain/vitals.yml ]; then
  STATUS=$(grep "status:" memory/brain/vitals.yml | head -1 | awk '{print $2}')
  SESSION=$(grep "session:" memory/brain/vitals.yml | head -1 | awk '{print $2}')
  FOCUS=$(grep "focus:" memory/brain/vitals.yml | head -1 | cut -d: -f2-)
  if [ "$STATUS" != "active" ]; then
    echo "🔴 Status: $STATUS"
  else
    echo "ℹ️ Status: $STATUS | Session: $SESSION"
  fi
  echo "ℹ️ Focus:$FOCUS"
fi
echo ""

# 6. NODOS
echo "--- NODOS ---"
if [ -f memory/brain/who-knows-what.yml ]; then
  echo "ℹ️ Nodos: claude-opus, deepseek-r1, gemini-2.5-pro, gpt-4o, jesus"
fi
echo ""

# 7. REPO
echo "--- ÚLTIMOS COMMITS ---"
git log --oneline -3 2>/dev/null || echo "Sin acceso a git"
echo ""

echo "========== FIN CHECK =========="
