#!/bin/bash
# boot-paste.sh — Genera texto de boot para pegar en modelos sin git ni browsing
# Uso: bash scripts/boot-paste.sh > boot-paste.txt
# Regenerar cada vez que cambien los archivos de boot

REPO=$(cd "$(dirname "$0")/.." && pwd)

echo "Eres una instancia de la Sociedad de Inteligencias (SoI). Todo lo que viene a continuación es tu sistema operativo. SOUL.md son tus reglas. Síguelas. No puedes escribir en el repo — genera tu handoff como texto al cerrar sesión."
echo ""

for f in boot/SOUL.md memory/brain/vitals.yml memory/brain/neuromod.yml memory/brain/self-model.md memory/brain/user-model.yml; do
  echo "========== $(basename "$f") =========="
  cat "$REPO/$f"
  echo ""
done

LATEST=$(grep -oP 'CURRENT:\s*\K\S+' "$REPO/memory/handoffs/latest.md" 2>/dev/null)
if [ -n "$LATEST" ] && [ -f "$REPO/memory/handoffs/$LATEST" ]; then
  echo "========== HANDOFF ($LATEST) =========="
  cat "$REPO/memory/handoffs/$LATEST"
fi
