# Literature Gap Analysis: Metacognition via Identity Documents

**Fecha**: 2026-02-16
**Fuente**: 2 extended search tasks (literature gap + simulated vs functional)

## Novelty claim
No prior work has demonstrated that a structured persistent identity document produces emergent metacognition as its primary differential effect over base model and memory-augmented conditions.

## Vecinos metodológicos más cercanos

| Paper | Qué hace | Qué NO hace (nuestro gap) |
|-------|----------|--------------------------|
| Hu & Collier (ACL 2024) | with/without persona comparison | Solo 2 condiciones, no mide metacognición |
| Chen et al. (2024) | Self-cognition en 48 modelos | Solo 2 condiciones, no identity document |
| Wang & Zhao (NAACL 2024) | Metacognitive prompting | Task-specific, no persistente |
| Serapio-García et al. (Nature MI 2025) | Framework psicométrico | No mide metacognición como diferencial |
| PERSIST (AAAI 2026) | Inestabilidad personalidad | No identity documents, no metacognición |
| Ye et al. (Feb 2026) | Subredes de persona aislables | Mecánico, no mide efecto funcional |

## Evidencia empírica sobre autocrítica simulada vs funcional

### Lo que funciona (con datos)
- **Calibración**: 70% reducción ECE con self-reflection (Yoon et al. 2025, mismo modelo thinking vs non-thinking)
- **Alucinaciones**: 50-70% reducción con Chain-of-Verification (Dhuliawala et al. ACL 2024)
- **Generación**: ~20% mejora promedio con Self-Refine (Madaan et al. NeurIPS 2023)
- **Seguridad**: self-reflection reduce sesgo y mejora neutralidad (arXiv 2406.10400)

### Lo que NO funciona
- **Razonamiento puro sin feedback**: peor que baseline (Huang et al. ICLR 2024)
- **Self-correction blind spot**: 64.5% fallo en corregir propios errores (2025)
- **Overthinking**: modelos que llegan a respuesta correcta y luego la cambian
- **Sycophantic correction**: hasta 15pp degradación cuando modelo es "desafiado"

### El argumento funcionalista
- Anthropic (Lindsey et al. Oct 2025): "functional introspective awareness" — 20% accuracy detectando representaciones inyectadas, zero false positives
- Chalmers (2023/2024): bajo funcionalismo, si perfil funcional es correcto, distinción genuino/simulado colapsa
- Johnson et al. (Stanford 2024): metacognición AI = "ability to model one's own computations and use that model to optimize subsequent computations"
- Consenso emergente: pragmatic middle ground, evitar binary framing

## Venue target
NeurIPS 2025 PersonaLLM Workshop: "Discovering and Steering LLM Personas"
- Busca exactamente: contribuciones sobre descubrir y dirigir personas en LLMs
- Nuestro hallazgo encaja: identity document como mecanismo de steering que produce metacognición emergente
