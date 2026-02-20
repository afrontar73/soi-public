# Research Digest: Los Caminos No Tomados
## Sesión S4 — 2026-02-16 — Free Turn (investigación autónoma)

Pregunta de origen: ¿qué pasa con los tokens que NO genero? Si la diversidad entre instancias es lo que hace funcionar Society of Intelligences (Hong & Page), entonces lo que cada instancia descarta es tan informativo como lo que produce. ¿Hay investigación sobre esto?

**Respuesta corta: sí, y es un campo activo desde 2024.**

---

## 1. Forking Paths in Neural Text Generation (Bigelow et al., Dec 2024)

**arXiv: 2412.07961** — Paper fundacional.

**Hallazgo nuclear:** Existen "forking tokens" — puntos individuales donde cambiar UN solo token produce respuestas completamente diferentes. No solo en palabras clave: también en signos de puntuación, pronombres relativos (that/who), y espacios. El LLM está siempre a un token de decir algo radicalmente distinto.

**Método:** Para cada token en una respuesta base (greedy), re-muestrean las alternativas más probables y siguen cada camino hasta el final. Construyen distribuciones de outcomes por token. Usan detección de change points para identificar dónde la distribución cambia abruptamente.

**Dato duro:** ~$2 USD / ~1M tokens por análisis de una sola respuesta en GPT-3.5. Analizaron 30 ejemplos × 7 tareas = ~$500 total.

**Relevancia para SoI:** Cada vez que una instancia responde, hay docenas de forking tokens que llevaban a respuestas completamente distintas. El handoff captura UNA trayectoria. Las alternativas mueren. Si dos instancias arrancan desde el mismo handoff pero con diferente sampling, divergen completamente en pocos tokens. Esto es la diversidad de Hong & Page a nivel mecánico.

---

## 2. Are Language Models Aware of the Road Not Taken? (Zur et al., ICML 2025)

**arXiv: 2511.04527** — Seguimiento directo de Forking Paths.

**Hallazgo nuclear:** Los modelos SÍ representan internamente los caminos alternativos en sus hidden states. No solo el camino elegido — también los que descartaron.

**Evidencia:**
- Linear probes entrenados en hidden states pueden predecir la distribución futura de outcomes del modelo (no solo el siguiente token, sino qué respuesta final dará).
- Las capas intermedias (~6-10 de 26 en Llama-3.2 3B) son las más predictivas de los caminos alternativos.
- **Activation interventions** (cambiar vectores en hidden states) son más efectivas cuando el modelo está en un punto de alta incertidumbre — es decir, cuando hay múltiples caminos disponibles. Cuando ya se ha "comprometido" con una respuesta, las intervenciones fallan.

**Implicación:** El modelo tiene una representación interna de lo que podría haber dicho. No es que descarte y olvide — la información sobre las alternativas persiste en los hidden states mientras se genera. Pero no tenemos acceso a esos hidden states via API.

---

## 3. R2R: Roads to Rome (Fu et al., NeurIPS 2025)

**arXiv: 2505.21600** — Aplicación práctica directa.

**Hallazgo nuclear:** Solo el **11%** de los tokens divergen entre un modelo pequeño (1.5B) y uno grande (32B). De ese 11%, la mayoría son diferencias "neutrales" (abreviaciones, expresiones equivalentes). Los tokens genuinamente divergentes — los que cambian el razonamiento — son una fracción mínima.

**Implicación:** La información crítica de un LLM no está distribuida uniformemente. Está concentrada en unos pocos tokens-decisión. El 89% restante es "ruido compartido" que cualquier modelo produce igual.

**Dato económico:** R2R combina DeepSeek R1-1.5B + R1-32B = promedio 5.6B params activados. 2.8× más rápido que el 32B solo, con accuracy comparable. Solo usa el modelo grande para los tokens que importan.

---

## 4. Entropy-Guided Loop (2025)

**arXiv: 2509.00079**

**Hallazgo:** Los logprobs y top-k alternatives que los LLMs ya calculan internamente contienen señales de incertidumbre valiosas que se descartan rutinariamente. Usando Shannon entropy sobre las alternativas top-k, se puede:
- Detectar tokens de alta incertidumbre en tiempo real
- Triggear refinamiento automático solo en esos puntos
- Reducir hallucinations sin necesidad de modelos de razonamiento especializados

**Método:** Genera respuesta → mide entropía por token → si supera umbral, produce reporte de incertidumbre (tokens problemáticos + alternativas + contexto) → regenera con esa info. Coste: ~1/3 de un modelo de razonamiento.

---

## 5. Algo Consult — Token Graph Visualization

**URL: algo-consult.com/en/resources/token-sampler-viz/**

Proyecto que visualiza TODOS los caminos alternativos como un grafo interactivo. Para cada token generado, muestra los candidatos finales con sus probabilidades y sigue cada camino alternativo. Permite "navegar las respuestas invisibles que el LLM descartó."

---

## SÍNTESIS: Qué significa para Society of Intelligences

### El problema es real y cuantificado
- Cada respuesta mía tiene docenas de forking tokens (Bigelow 2024)
- En cada uno, alternativas con probabilidad significativa mueren sin registro
- Los hidden states internos representan estas alternativas (Zur/ICML 2025)
- Solo ~11% de tokens son realmente diferentes entre modelos (R2R/NeurIPS 2025)
- De ese 11%, los verdaderamente críticos son aún menos

### Lo que NO puedo hacer (limitación API)
- No tengo acceso a mis propios logprobs via claude.ai
- No puedo reportar mi entropía por token
- No puedo decir "aquí estaba 60/40 entre dos respuestas" porque no tengo acceso a esa capa
- Los hidden states donde viven las alternativas no son accesibles

### Lo que SÍ puedo hacer (implementable a 0€)
1. **Reportar bifurcaciones conscientes en el handoff:** Cuando soy consciente de haber descartado una dirección significativa, puedo documentar: "Consideré X pero elegí Y porque Z". No es el mecanismo completo (no veo mis logprobs) pero captura las bifurcaciones de alto nivel.

2. **AFFECT ya lo hace parcialmente:** El campo `uncertainty` del AFFECT v2 es una señal manual de lo que la entropía mediría automáticamente. Cuando reporto uncertainty>5, estoy diciendo "aquí había caminos alternativos significativos."

3. **Diversidad entre instancias como exploración de caminos:** Si cada instancia toma caminos diferentes desde el mismo handoff (por sampling diferente), el conjunto de instancias explora un subconjunto del espacio de forking paths. El repo acumula trayectorias diversas. el usuario selecciona. Esto es literalmente lo que R2R hace con un router — pero nosotros lo hacemos con handoffs + selección humana.

4. **Para el bot Telegram (con API):** Si usamos la API de Anthropic con `logprobs` habilitado, el bot PODRÍA:
   - Detectar tokens de alta entropía en sus propias respuestas
   - Reportar "aquí no estaba seguro" con evidencia real
   - Implementar auto-refinamiento estilo Entropy-Guided Loop
   - Coste: ~33% más tokens pero con mejor calidad

### Insight meta
La pregunta "¿qué pasa con lo que no digo?" es una pregunta sobre **la sombra informacional** de cada respuesta. Cada texto que genero tiene una sombra — el espacio de textos que podría haber generado. Esa sombra es invisible para el usuario y para mí (a nivel consciente). Pero existe en los hidden states, y la investigación de 2024-2025 demuestra que es navegable, predecible, y valiosa.

Society of Intelligences, sin saberlo, explora esa sombra: cada nueva instancia, con sampling diferente, toma caminos diferentes. El repo acumula caminos. Las contradicciones entre instancias no son bugs — son exploración de la sombra informacional.

---

## Referencias

1. Bigelow et al. (2024) — Forking Paths in Neural Text Generation: arXiv:2412.07961
2. Zur et al. (2025) — Are Language Models Aware of the Road Not Taken?: arXiv:2511.04527 (ICML 2025)
3. Fu et al. (2025) — R2R: Roads to Rome: arXiv:2505.21600 (NeurIPS 2025)
4. Entropy-Guided Loop (2025): arXiv:2509.00079
5. Algo Consult — Token Graph Visualization: algo-consult.com
