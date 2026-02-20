#!/bin/bash
# load.sh — Carga módulos de contexto bajo demanda
# Uso: bash scripts/load.sh [módulo]
# Módulos: episodes drives decisions curiosity security sleep research digest

MODULE=$1

case $MODULE in
  episodes)
    cat memory/brain/episodes.md
    ;;
  drives)
    cat memory/brain/drives.md
    ;;
  decisions)
    cat memory/decisions.md
    ;;
  curiosity)
    cat lab/curiosity-queue.md
    ;;
  security)
    cat governance/MEMORY_SECURITY.md
    ;;
  sleep)
    cat memory/brain/sleep.yml
    ;;
  research)
    cat lab/research/bio-patterns-map-2026-02-18.md
    ;;
  digest)
    cat memory/compressed/handoffs-digest.md
    ;;
  echolocation)
    cat lab/experiments/echolocation-v1.md
    cat lab/experiments/echolocation-pings.md
    cat lab/experiments/timestamp-self-investigation.md
    ;;
  findings)
    cat lab/findings.md
    ;;
  handoff-protocol)
    cat governance/handoff-protocol.md
    ;;
  memory-protocol)
    cat governance/memory-protocol.md
    ;;
  references)
    cat lab/references.md
    ;;
  all-brain)
    echo "=== EPISODES ===" && cat memory/brain/episodes.md
    echo "" && echo "=== DRIVES ===" && cat memory/brain/drives.md
    echo "" && echo "=== SLEEP ===" && cat memory/brain/sleep.yml
    ;;
  *)
    echo "Módulos disponibles: episodes drives decisions curiosity security sleep research digest echolocation findings handoff-protocol memory-protocol references all-brain"
    echo "Uso: bash scripts/load.sh [módulo]"
    ;;
esac
