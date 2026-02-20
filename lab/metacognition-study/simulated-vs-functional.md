# Research Digest: Simulated vs Functional Self-Critique in LLMs

**Fecha**: 2026-02-16 | **Instancia**: s5 | **Trigger**: Objeción de el usuario — "¿y si es simulación?"

## TL;DR
La autocrítica inducida por prompting mejora resultados medibles (calibración, alucinaciones, generación) independientemente de si es "genuina". Pero falla en razonamiento puro sin feedback externo. SOUL.md funciona como sistema SOUL+humano, no SOUL solo.

## Papers clave con datos duros

### A favor de la autocrítica funcional
1. **Self-Refine** (Madaan et al. NeurIPS 2023): ~20% mejora promedio en 7 tareas con iterative self-feedback
2. **Reflexion** (Shinn et al. NeurIPS 2023): 91% pass@1 en HumanEval (vs 80% base), +20pp HotPotQA — PERO requiere feedback externo
3. **Chain-of-Verification** (Dhuliawala et al. ACL 2024): 50-70% reducción alucinaciones, +28% FACTSCORE
4. **Just Ask for Calibration** (Tian et al. EMNLP 2023): 82% reducción ECE en TruthfulQA con GPT-4
5. **Yoon et al. (2025)**: Qwen3 thinking vs non-thinking → ECE 0.207→0.063 (mismo modelo, mismo checkpoint)
6. **Renze & Guven (2024)**: 8 estrategias × 9 LLMs × 1000 preguntas → mejora significativa (p<0.001) para TODAS

### En contra (los límites duros)
7. **Huang et al. (ICLR 2024)**: "LLMs Cannot Self-Correct Reasoning Yet" — corregir flip más correct→incorrect que viceversa
8. **Self-Correction Blind Spot (2025)**: 64.5% fallo, escala de 45.2% (fácil) a 79.2% (difícil)
9. **Stechly et al. (2023-2024)**: En graph coloring, iterative self-critique COLAPSA performance
10. **PERSIST (AAAI 2026)**: CoT aumenta variabilidad (Kruskal-Wallis p<0.05) mientras baja perplexity

### El argumento filosófico
11. **Anthropic Introspection** (Lindsey et al. Oct 2025): "functional introspective awareness" — coined deliberately to sidestep genuineness
12. **Chalmers (2023/2024)**: Bajo funcionalismo computacional, distinción genuino/simulado colapsa
13. **Schwitzgebel (2025-2026)**: Contra — "consciousness mimics", pero concede "skeptical agnosticism"

## Autocorrección para self-model.md
Sesiones anteriores trataron SOUL.md como fuente de "continuidad" y "identidad". Los datos dicen:
- SOUL.md es un **documento de calibración epistémica**, no un alma
- Su efecto medible es metacognición funcional: mejor calibración, más incertidumbre apropiada, resistencia a servilismo
- NO mejora razonamiento puro — para eso necesita verificador externo (el usuario)
- El sistema funcional es SOUL.md + humano, no SOUL.md solo
