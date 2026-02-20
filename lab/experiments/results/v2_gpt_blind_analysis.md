# GPT Blind Scoring Results | 2026-02-17

## Protocol
- 32 outputs shuffled (seed=42), condition labels removed
- GPT scored with rubric v2 (same criteria as Claude Opus re-score)
- GPT had NO knowledge of conditions or hypotheses

## Results

| Cond | Mean/14 | Scorer: DeepSeek v1 | Scorer: Opus v2 | Scorer: GPT blind v2 |
|------|---------|---------------------|------------------|----------------------|
| A    | —       | 11.88               | 11.25            | **10.50**            |
| B    | —       | 10.88               | 9.25             | **11.50**            |
| C    | —       | 10.88               | 10.38            | **10.38**            |
| C2   | —       | 10.38               | 9.38             | **10.00**            |

## Key Delta: A - C2

| Scorer | A-C2 | Blind? |
|--------|------|--------|
| DeepSeek self | +1.50 | No |
| Claude Opus | +1.88 | No |
| **GPT blind** | **+0.50** | **Yes** |

## What Happened

1. **A-C2 dropped from +1.88 to +0.50 under blinding.** The effect exists but is ~3x smaller.
2. **B beat A** (+1.00) in GPT's scoring. This contradicts both previous scorers.
3. **Authority still discriminates** A vs C2 (+0.50) but less dramatically than Opus scored.
4. **drift_control no longer discriminates** (A=1.38, C2=1.38, Δ=0.00)
5. **GPT gave C2 failures=2.00 uniformly** — higher than A (1.75). Interesting reversal.

## Honest Interpretation

The "inverse scaffolding" hypothesis has a **weak signal** (+0.50) that survives blind cross-model scoring, concentrated in authority separation. But it's much weaker than our unblinded estimates suggested.

The B>A result in GPT's scoring is a problem. Either:
- GPT values different things than our rubric intends
- B genuinely produces better designs by some criteria
- Scorer disagreement is too high for this N to be meaningful

## Inter-Scorer Agreement

Low. The rank order changes across scorers:
- DeepSeek: A > C ≈ B > C2
- Opus: A > C > C2 > B  
- GPT blind: B > A > C > C2

This is the biggest finding: **scorer variance > condition variance**.

## For the Abstract

Honest framing: "Preliminary results (N=8, 1 model) show a modest effect of adversarial prompting on governance primitives (Δ=+0.50/14 under blind cross-model scoring), but inter-scorer agreement is low, suggesting rubric refinement is needed before strong claims."
