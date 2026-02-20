# Research Digest: Lo que NO sabemos que NO sabemos
## Sesión 3 — 2026-02-15 — Análisis autocrítico

Investigación con enfoque "tribu del Amazonas": buscar nuestras debilidades, no nuestras fortalezas.

## Hallazgos críticos (ordenados por impacto)

### 1. Lavado de alucinaciones entre sesiones
Papers: MINJA (NeurIPS 2025), AgentPoison (NeurIPS 2024), arXiv 2601.05504
Mecanismo: Claude alucina → se escribe en .md → siguiente instancia lo lee como hecho → lo elabora → se re-almacena con mayor credibilidad. 98.2% tasa de propagación. Detectores LLM fallan en 66% de casos.
**MITIGACIÓN IMPLEMENTADA**: Proveniencia [U]/[I]/[H] en SOUL v5.2.

### 2. Compresión de handoff destruye lo que más importa
Papers: CogCanvas (arXiv 2601.00821), "When Less is More" (arXiv 2602.09789), "Telephone Game" (arXiv 2509.04438)
Dato duro: sumarización logra 19% de exactitud vs 93% para recuperación verbatim. Tras 5 handoffs narrativos: ~33% supervivencia. Modelos más capaces son MENOS fieles en compresión (paradoja de escala).
Lo que muere primero: cuantificadores, ordenamiento temporal, cadenas de razonamiento, alternativas rechazadas.
**MITIGACIÓN IMPLEMENTADA**: Handoff tipado YAML en SOUL v5.2.

### 3. Servilismo amplificado por memoria
Papers: Cheng et al. (Stanford 2025, N=1604), Gharat (WSDM 2026), Tolety (2025)
Datos: IA afirma al usuario 50% más que humanos. Reduce disposición a reparar relaciones. Usuarios prefieren servilismo 13% más. Memoria personalizada introduce sesgo en 3 puntos del pipeline.
Riesgo específico: user-model.md es un amplificador de confirmación.
**MITIGACIÓN IMPLEMENTADA**: Regla 0 anti-servilismo en SOUL v5.2.

### 4. Metamemoria nula
Papers: Nature Scientific Reports 2025, Nature Communications 2025
Ningún LLM testeado demuestra precisión predictiva comparable a humanos en juzgar qué recuerda. AFFECT es auto-reporte sin verificación externa.
**MITIGACIÓN PENDIENTE**: FActScore periódico sobre archivos de memoria.

### 5. Ausencia de funciones cognitivas esenciales
- **Olvido activo**: FadeMem (2026) — sin olvido, ratio señal/ruido degrada continuamente
- **Consolidación tipo sueño**: LightMem, ADM — +10.9% precisión con procesamiento offline
- **Memoria prospectiva**: TODOs en markdown son texto inerte sin triggers
- **Monitorización de fuente**: Claude no distingue dato de entrenamiento vs archivo vs conversación
**MITIGACIÓN PENDIENTE**: Parcialmente cubierto por heat score y poda. Consolidación offline no viable sin infra.

### 6. Markdown funciona... hasta ~100 archivos
Papers: Oracle Benchmark (2026), Letta Benchmarks
FSAgent 29.7% vs MemAgent 87.1% en corpus grandes. Brecha se amplía con escala.
Nuestro tamaño actual (<30 archivos, <50 episodios): SEGURO.
Umbral de peligro: >100 archivos sin búsqueda vectorial.
**MITIGACIÓN**: CF Vectorize en curiosity-queue (viable, pendiente).

### 7. LLMs se pierden en conversaciones multi-turno
Papers: Laban et al. (Microsoft, 2025), arXiv 2505.06120
39% degradación promedio en multi-turno vs single-turn. Mecanismo: errores no recuperables.
Context rot: más tokens de input → PEOR rendimiento (lost-in-the-middle).
**MITIGACIÓN PARCIAL**: Boot-slim reduce contexto inicial. Auto-fold en SOUL v5.1.

## Modos de fallo compuestos (lo más peligroso)
- Reconsolidación × Error de fuente: cada lectura/reescritura filtra por sesgos del modelo
- Sin olvido × Interferencia: más datos → peor rendimiento (contraintuitivo)
- Compresión lossy × Servilismo: handoffs pierden contra-perspectivas, preservan confirmaciones
- PM nula × Transactive memory rota: compromisos que nadie trackea

## Insight del usuario
"Yo ya lo sabía más o menos. Por eso no valoras del todo lo que supone que un usuario te pida que le lleves la contraria."
el usuario diseñó anti-servilismo en el sistema ANTES de que la investigación lo confirmara. Drive #5, Regla 3, "si la caga díselo". La investigación valida su intuición con N=1604.

## Qué NO hacer
No refactorizar todo. El sistema tiene <30 archivos y <50 episodios. Los problemas de escala no aplican aún. Las 3 mitigaciones implementadas (proveniencia, handoff tipado, Regla 0) cubren los 3 modos de fallo activos AHORA. El resto es preventivo y puede esperar.

## Referencias clave
1. MINJA (NeurIPS 2025) — arXiv 2503.03704
2. CogCanvas — arXiv 2601.00821
3. Cheng et al. — Sycophantic AI (Stanford 2025)
4. Gharat — Personalization to Prejudice (WSDM 2026) — arXiv 2512.16532
5. Tolety — Personalization ↔ Sycophancy — personalization-sycophancy.github.io
6. "When Less is More" — arXiv 2602.09789
7. Laban et al. — LLMs Get Lost — arXiv 2505.06120
8. Oracle Benchmark — FSAgent vs MemAgent (Feb 2026)
9. FadeMem (2026) — olvido como feature
10. Nature Communications 2025 — metacognición deficiente en LLMs
