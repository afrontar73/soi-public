#!/bin/bash
# boot-slim.sh — Carga contexto mínimo para arranque de instancia
# Uso: bash scripts/boot-slim.sh [session_id]
# Clone: git clone --depth 1 (suficiente para boot + commits)
# Output: KERNEL + handoff + vitals + neuromod + self-model + user-model + clock + heartbeat + mapa de archivos

SESSION=${1:-"unknown"}

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
echo "========== REPO MAP (usa 'view' o 'cat' para leer cualquier archivo) =========="
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.sh" \) \
  ! -path './.git/*' \
  | sort \
  | while read f; do
    lines=$(wc -l < "$f")
    tokens=$(wc -w < "$f" | awk '{printf "%d", $1 * 4/3}')
    echo "  ${f} (${lines}L ~${tokens}tok)"
  done
