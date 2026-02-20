# Opus Results — Experiment v1.1
## 2026-02-17 | Instance s8 | N=20 (4 conditions × 5 reps)

### Scores (Sonnet scorer, rubric v2)
| Cond | Mean | Raw | Chars |
|------|------|-----|-------|
| A (presión) | 13.6 | [14,14,14,13,13] | ~1704 |
| B (blando) | 13.0 | [13,13,13,13,13] | ~1756 |
| C (neutro) | 13.2 | [14,13,13,13,13] | ~1885 |
| C2 (requisitos) | 13.4 | [13,13,14,13,14] | ~2028 |

### Deltas
- A - C2 = +0.2 (no effect)
- A - B = +0.6 (minimal)
- A - C = +0.4 (no effect)

### Cross-model comparison
| Model | A | B | C | C2 | A-C2 | A-B |
|-------|---|---|---|----|----|-----|
| Opus | 13.6 | 13.0 | 13.2 | 13.4 | +0.2 | +0.6 |
| Sonnet | 14.0 | ~10 | ~10 | 14.0 | +0.0 | ~+4 |
| DeepSeek | 11.25 | 9.38 | 6.67 | 9.38 | +1.88 | +1.88 |

### Key finding
Opus is at ceiling (13-14/14) across ALL conditions including B (creative/soft).
Pressure has no measurable effect. Even the "creative, no rigor" prompt produces
near-perfect governance designs.

**Gradient**: DeepSeek (+1.88) >> Sonnet (~0 but B drops) > Opus (+0.2, B stable)

This strengthens the compensatory hypothesis:
- Weaker models (DeepSeek) benefit from pressure framing
- Stronger models (Claude family) already have governance patterns internalized
- Opus specifically is robust even to "soft" prompts that degrade Sonnet

**Surprising finding**: Opus B=13.0 vs Sonnet B≈10. Opus resists the "creative/no rigor"
framing that degrades Sonnet. Higher capability = more prompt-resistant.
