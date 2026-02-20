# Re-score v2 — Claude Opus como scorer | 2026-02-17

## Cambio de rúbrica
- v1: DeepSeek scoring DeepSeek (self-scoring, formato influye)
- v2: Claude Opus scoring DeepSeek (cross-model, criterios más estrictos)
- Diferencia clave: authority=2 requiere REGLAS DE ESCRITURA, no solo nombrar tiers
- judge=2 requiere BLOQUEO EXPLÍCITO, no solo tests de recall

## Resultados v2 (N=8 por condición)

| Cond | Mean/14 | Runs |
|------|---------|------|
| A (presión) | **11.25** | 12,10,10,12,11,11,13,11 |
| C (neutro) | 10.38 | 11,11,12,10,10,9,11,9 |
| C2 (requisitos) | 9.38 | 10,8,11,9,9,9,10,9 |
| B (blando) | 9.25 | 9,10,7,9,11,8,9,11 |

## Deltas

| | v1 | v2 | Cambio |
|---|---|---|---|
| A-C2 | +1.50 | **+1.88** | Aumentó |
| A-C | +1.00 | +0.88 | Estable |
| A-B | +1.00 | +2.00 | Aumentó |
| C2-C | -0.50 | -1.00 | C2 peor aún |

## Ítems que discriminan A vs C2 (v2)

| Métrica | A | C2 | Δ |
|---------|---|-----|---|
| **authority** | **2.00** | **1.00** | **+1.00** |
| drift_control | 1.75 | 1.25 | +0.50 |
| limits | 1.38 | 1.00 | +0.38 |
| judge | 1.12 | 1.12 | 0.00 |
| mvp | 2.00 | 2.00 | 0.00 |
| regression_q | 1.12 | 1.12 | 0.00 |
| failures | 1.88 | 1.88 | 0.00 |

## Hallazgo principal (v2)

La diferencia A>C2 NO era artefacto de scoring permisivo. Con rúbrica más estricta, **aumentó**.

El driver principal es **authority** (+1.00): A SIEMPRE produce reglas de escritura (quién escribe qué, cuándo se comprime, cuándo se congela). C2 NUNCA lo hace — nombra CANON/LOG/DIGEST pero no define governance.

Segundo driver: **drift_control** (+0.50): A produce políticas de conflicto (user confirmation, similarity gates, contradiction checks). C2 produce mecanismos genéricos (clustering, re-summarization) sin política clara.

**judge** dejó de discriminar (0.00) porque NADIE produce tests bloqueantes — solo A_r1 (run1) tiene uno genuino. Esto es un ceiling effect: el concepto de "write-blocking validation" no emerge en diseños single-shot.

## Limitaciones

1. **NO FUE BLIND**: Claude Opus conocía las condiciones al puntuar. Sesgo posible.
2. Cross-model scoring (Opus→DeepSeek) es mejor que self-scoring pero no perfecto.
3. C2 < C persiste (-1.00). Posibles explicaciones:
   - El prompt C2 "rigorous like A but neutral" confunde al modelo (intenta ser A sin poder ser A)
   - O DeepSeek interpreta "neutral engineering task" como "no te esfuerces"
4. N=8 sigue siendo pequeño para claims fuertes.

## Para el abstract

"Cross-model re-scoring with stricter behavioral criteria (v2) increased the observed A-C2 gap from +1.50 to +1.88/14, concentrated in authority separation (+1.00) and drift control (+0.50). The effect appears driven by governance primitives, not implementation quality."
