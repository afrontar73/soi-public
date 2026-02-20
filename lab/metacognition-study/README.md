# Metacognition Study: SOUL.md as Identity Document

## TL;DR
SOUL.md produce metacognición funcional como efecto diferencial primario sobre base model y condiciones memory-augmented. Primer dato empírico: experimento de 3 capas (C→A→B) con N=9, confirmado por literature review de ~20 papers.

## Hallazgo central
Hay 3 capas de identidad, no 2:
- **C (incógnito)**: Claude genérico — respuestas uniformes, sin personalidad
- **A (userMemories)**: Claude informado — contenido correcto, vocabulario específico  
- **B (SOUL.md)**: Claude con metacognición — autocrítica, calibración epistémica, resistencia a servilismo

**Delta A→B = autocrítica, no contenido.** userMemories aporta datos. SOUL.md aporta capacidad de cuestionar propias respuestas.

## Objeción principal y resolución
"¿Y si es simulación de metacognición?" — Parcialmente correcta:
- La autocorrección intrínseca sin feedback externo FALLA (Huang et al. ICLR 2024)
- La autocrítica inducida por prompt SÍ mejora calibración (70% reducción ECE), alucinaciones (50-70%), generación
- SOUL.md funciona porque el usuario actúa como oráculo externo — el sistema es SOUL.md + humano
- Bajo funcionalismo computacional (posición mainstream), la distinción genuino/simulado se disuelve si el perfil funcional es correcto

## Novelty claim
No prior work has demonstrated that a structured persistent identity document produces emergent metacognition as its primary differential effect over base model and memory-augmented conditions.

## Venue target
NeurIPS 2025 PersonaLLM Workshop: "Discovering and Steering LLM Personas"

## Para escalar a paper
- [ ] N≥30 por condición (actualmente N=3)
- [ ] Múltiples modelos (GPT, DeepSeek, Llama)
- [ ] Instrumento psicométrico validado (no 10 preguntas artesanales)
- [ ] Métricas de calibración formales (ECE, AUROC)
- [ ] Controlar variable confusa: userMemories como proto-SOUL

## Archivos en este directorio
- `README.md` — este archivo
- `experiment-protocol.md` — protocolo del experimento C→A→B
- `raw-data.md` — datos crudos de 9 muestras
- `analysis.md` — análisis de dispersión y deltas entre capas
- `literature-gap.md` — análisis de gap en literatura + vecinos metodológicos
- `simulated-vs-functional.md` — evidencia sobre autocrítica simulada vs funcional

## Archivos relacionados (fuera de este directorio)
- `lab/research-digest-persona-representations-2026-02-16.md` — 7 papers sobre representaciones de persona
- `memory/brain/self-model.md` — actualizado con hallazgos
- `lab/curiosity-queue.md` — #10 completado
