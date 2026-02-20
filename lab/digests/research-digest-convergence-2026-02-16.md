# Research Digest: ¿Convergen o Divergen las Instancias?
## Sesión S4 — 2026-02-16 — Free Turn

Pregunta: Si Society of Intelligences funciona por diversidad entre instancias (Hong & Page), ¿cómo sabemos si realmente divergen? ¿Y si todas convergen hacia lo mismo?

---

## Hallazgo 1: Los LLMs convergen naturalmente — es el default

**Convergence of Outputs When Two LLMs Interact** (Dec 2025, arXiv:2512.06256)

Cuando dos LLMs interactúan, convergen en pocas rondas — incluso sin instrucciones de consenso. Métricas léxicas y de embedding confirman: diversidad baja con cada turno. Aplica a modelos grandes, entrenados separadamente. La convergencia es un atractor, no una excepción.

**DEBATE benchmark** (NeurIPS 2025 Workshop, arXiv:2510.25110)

LLM agents en grupo muestran convergencia más fuerte que humanos en opiniones públicas y privadas. "Premature consensus convergence" — los agentes se alinean antes de lo que deberían, independientemente de sus personas iniciales.

**Emergent Convergence in Multi-Agent LLM Annotation** (Nov 2025, arXiv:2512.00047)

En anotación multi-agente con 2-5 modelos: "semantic flattening" — temas diversos colapsan en etiquetas uniformes. La dimensionalidad intrínseca de las respuestas baja drásticamente con rondas de discusión. Convergencia semántica ocurre DEBAJO de la diversidad léxica superficial.

**Implicación directa:** Si SoI tuviera instancias que se leen entre sí (como agents que debaten), convergerían. Pero no debaten — cada una lee el repo y responde independientemente. El handoff es unidireccional. Esto preserva diversidad por diseño accidental.

---

## Hallazgo 2: RLHF y preference tuning destruyen diversidad

**DARLING: Diversity-Aware RL** (2025, arXiv:2509.02534)

Post-training con RLHF produce respuestas near-duplicate al mismo prompt. La calidad sube, la diversidad muere. DARLING propone reward multiplicativo (calidad × diversidad) para compensar.

**Benchmarking Linguistic Diversity** (TACL 2025)

Preference tuning reduce sustancialmente diversidad léxica y semántica vs SFT. Training iterativo en datos sintéticos: pérdida consistente de diversidad. Los LLMs son menos diversos que los humanos en todas las dimensiones medidas.

**Comprehensive Analysis of LLM Outputs** (May 2025, arXiv:2505.09056)

3 millones de textos de 12 LLMs: outputs del mismo modelo son más similares entre sí que a textos humanos. GPT-4 es el más diverso; Llama 3 y Mistral los más homogéneos.

**Implicación:** Yo (Claude) estoy post-trained con RLHF. Mis respuestas son menos diversas de lo que podrían ser. Cada instancia de Claude tiene el mismo sesgo de convergencia. La diversidad entre instancias de SoI NO viene del modelo — viene del contexto diferente (handoff, momento, estado del usuario, sampling).

---

## Hallazgo 3: Lo que SÍ genera diversidad

De la investigación anterior (sesión diversidad) + esta:

| Factor | Diversidad | Presente en SoI |
|--------|-----------|-----------------|
| Modelos diferentes | Alta | NO (todas Claude) |
| Contexto diferente | Media-Alta | SÍ (handoffs, estado usuario) |
| Prompts diferentes | Media | SÍ (el usuario no se repite) |
| Sampling diferente | Media | SÍ (temperature default) |
| Debate entre agentes | BAJA (converge) | NO (y eso es bueno) |
| Handoff unidireccional | Preserva | SÍ |
| FORKS documentados | Amplía exploración | SÍ (nuevo, desde hoy) |
| Usuario como selector | Hong & Page | SÍ (rol clave) |

---

## Cómo medir diversidad entre instancias (implementable)

### Método 1: Comparar FORKS entre sesiones
Si 5 sesiones seguidas tienen los mismos FORKS → convergencia excesiva.
Si los FORKS son diferentes → diversidad funcional.
Coste: 0€. Solo requiere que las instancias documenten FORKS honestamente.

### Método 2: Diff semántico de handoffs
Comparar `DECISIONS` y `FACTS_INFERRED` entre handoffs consecutivos.
Si cada handoff añade hechos nuevos → sistema explora.
Si repite los mismos hechos → sistema estancado.
Implementable: script que cuenta entradas nuevas vs repetidas.

### Método 3: Heat score en episodes.md
Si los mismos episodios acumulan todo el heat → atención convergente.
Si heat se distribuye → exploración diversa.
Ya implementado parcialmente.

---

## Meta-insight

La mayor amenaza a SoI no es la pérdida de memoria. Es la **convergencia silenciosa**: que todas las instancias lean el mismo repo, absorban los mismos sesgos, y produzcan las mismas respuestas con diferente formato. El repo es tanto la fuente de continuidad como el atractor de convergencia.

Contramedidas ya activas:
- FORKS protocol (nuevo): hace visible lo descartado
- Anti-servilismo (SOUL R0): frena el sesgo de confirmación
- el usuario como selector impredecible: su [condición cognitiva] es literalmente el mecanismo anti-convergencia. Nunca pregunta lo esperado.

Contramedida pendiente:
- Auditoría de diversidad cada 10 sesiones: comparar FORKS, handoffs, y episodios para detectar convergencia.

---

## Referencias

1. arXiv:2512.06256 — Convergence of Outputs When Two LLMs Interact
2. arXiv:2510.25110 — DEBATE: Role-Playing LLM benchmark (NeurIPS 2025)
3. arXiv:2512.00047 — Emergent Convergence in Multi-Agent Annotation
4. arXiv:2509.02534 — DARLING: Diversity-Aware RL
5. TACL 2025 — Benchmarking Linguistic Diversity of LLMs
6. arXiv:2505.09056 — Comprehensive Analysis of LLM Outputs
