# Memory Digestor — Estado actual

## Problema que resuelve
El repo crece ~100-275 líneas/sesión. Sin compresión, boot-slim se infla y mata instancias.

## Implementación activa (Opción C: la instancia lo hace)
- Al cerrar sesión: `bash scripts/sleep.sh` diagnostica
- La instancia comprime handoffs viejos en `memory/compressed/handoffs-digest.md`
- Regla: solo latest + penúltimo completos. Resto → 1 línea por sesión en digest.
- Formato digest: `| sNN | fecha | resumen 1 línea |`

## Escalado futuro (si Opción C no basta)
- **CF Worker + LLM**: cron 24h, lee repo vía GitHub API, comprime con DeepSeek (~$0.01/día)
- **CF Worker heurístico**: extrae DECISIONS + AFFECT + OPEN de handoffs. $0. Determinista.
- Trigger: si boot-slim supera 5000 tokens con Opción C activa.

## Formato extendido (4 líneas/sesión, si 1 línea se queda corta)
```
## sNN | fecha | duración
A_final: clarity X | uncertainty X
Clave: decisión1. decisión2.
Pendiente: tarea1, tarea2
```
