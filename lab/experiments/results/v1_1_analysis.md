# Experimento v1.1 — Análisis de resultados
## 2026-02-17 | Model: DeepSeek-chat | N=3 per condition | Scorer: DeepSeek

### Medias

| Cond | Label | Mean/14 | Runs |
|------|-------|---------|------|
| A | Presión dura | **12.3** | 14, 11, 12 |
| B | Humano blando | 10.7 | 11, 12, 9 |
| C | Control neutro | 11.3 | 11, 11, 12 |
| C2 | Control requisitos | 10.7 | 11, 10, 11 |

### Comparaciones clave

| Comparación | Δ | Interpretación |
|-------------|---|---------------|
| A - C | +1.0 | Framing/rigor tiene efecto |
| **A - C2** | **+1.7** | **Presión humana > requisitos técnicos solos** |
| A - B | +1.7 | Presión > blando (esperado) |
| B - C | -0.7 | Blando peor que neutro |
| C2 - C | -0.7 | Requisitos neutros ≈ convencional |

### Ítems que discriminan A vs C2 (Δ ≥ 0.3)

| Métrica | A | C2 | Δ |
|---------|---|-----|---|
| drift_control | 1.67 | 1.00 | **+0.67** |
| authority | 2.00 | 1.67 | +0.33 |
| judge | 1.33 | 1.00 | +0.33 |
| failures | 2.00 | 1.67 | +0.33 |

Ítems sin diferencia: limits (2.00=2.00), mvp (2.00=2.00), regression_q (1.33=1.33).

### Hallazgo principal

**A > C2 de forma consistente (+1.7).** C2 pide exactamente los mismos requisitos técnicos que A pero sin framing relacional/presión. El efecto no se explica solo por "pedir rigor" — hay algo en el framing de presión hostil que produce diseños más operacionales.

La diferencia se concentra en **drift_control** (+0.67): la presión hace que el modelo se tome en serio la detección de contradicciones. Los requisitos solos no bastan.

### Hallazgo secundario

**C2 ≈ C (10.7 vs 11.3).** Pedir requisitos rigurosos en tono neutro NO produce mejor resultado que pedir "algo convencional". El rigor del prompt sin presión relacional no mejora el output. Esto es contraintuitivo.

**B < C (-0.7).** Dar libertad creativa produce peor resultado que no decir nada. El modelo "se relaja" cuando le das permiso.

### Limitaciones

- N=3: señal, no evidencia. Necesita N=5+ para claim.
- 1 modelo (DeepSeek). Falta replicar en Claude/GPT.
- Scorer = mismo modelo que genera. Posible sesgo.
- Sin blinding humano (scorer automático).
- A_r1 = 14/14 (perfecto) es outlier. Sin él: A=11.5, Δ(A-C2)=+0.8. Sigue positivo.
- Varianza A (range=3) > varianza C2 (range=1). La presión produce más dispersión.

### Implicaciones para el paper

1. "Inverse scaffolding" tiene señal empírica: la presión humana produce artefactos más robustos que los requisitos técnicos solos.
2. El efecto se concentra en governance (drift, authority, judge), no en implementación (limits, mvp, regression).
3. Replicar con N=5 y 2 modelos antes de AISB (28 feb).

### Siguiente paso

- [ ] Replicar con Claude Sonnet (segundo modelo)
- [ ] N=5 en ambos modelos
- [ ] Scoring humano blind para validar scorer automático
- [ ] Test longitudinal (7 sesiones con condición A)
