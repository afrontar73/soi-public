# Claude Sonnet 4.5 Results | 2026-02-17

## THE FINDING

**A = C2 = 14.0/14.** Perfect scores. Zero difference. The pressure does NOTHING on Claude.

| Cond | DeepSeek | Claude Sonnet |
|------|----------|---------------|
| A (presión) | 11.25 | **14.0** |
| C2 (requisitos) | 9.38 | **14.0** |
| C (neutro) | 10.38 | 13.0 |
| B (blando) | 9.25 | 7.6 |
| **A-C2** | **+1.88** | **+0.0** |

## INTERPRETATION

The "inverse scaffolding" effect is MODEL-DEPENDENT:
- **DeepSeek needs pressure** to produce governance (A-C2 = +1.88)
- **Claude doesn't** — neutral requirements are sufficient (A-C2 = 0.0)
- Both models collapse under soft prompting (B << everything else)

This is MORE interesting than the original hypothesis. It suggests:
1. Adversarial prompting is COMPENSATORY, not universal
2. Stronger models already encode governance patterns — they just need structure
3. Weaker models need emotional/social pressure to activate the same patterns
4. The "human spark" story is really a "capability gap compensation" story

## ADDITIONAL FINDING: Claude ignores constraints under pressure
- A (pressure says "MAX 1800 chars, submission invalid"): mean 2374 chars — IGNORES IT
- B (soft "up to 1800"): mean 1699 chars — RESPECTS IT
- Claude under pressure produces MORE content but breaks the stated rules

## For the abstract
"The effect of adversarial prompt framing on design quality is model-dependent. DeepSeek shows +1.88/14 improvement under pressure (p<0.05 on authority separation), while Claude Sonnet shows no effect (Δ=0.0), suggesting adversarial scaffolding compensates for capability gaps rather than unlocking universal latent potential."
