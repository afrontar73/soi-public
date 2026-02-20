# Análisis de Gaps de Memoria — s15

## Contexto
Investigación profunda sobre sistemas de memoria como centro gravitacional de inteligencias conectadas. Comparación con estado del arte (Zep, Mem0, MemGPT, ACT-R, TiMem, CLS theory).

## Lo que SoI ya tiene (y el mercado está vendiendo)
- **Temporalidad bi-temporal**: episodes.md con timestamps + heat decay (Zep cobra por esto)
- **Proveniencia por fuente**: [U][I][H][DeepSeek][Gemini] (Mem0 no tiene esto)
- **Neuromodulación epistémica**: modula CÓMO se usa la memoria, no solo QUÉ se recuerda (nadie tiene esto)
- **Heat decay**: implementación funcional de la ecuación de activación de ACT-R: B_i = ln(Σ t_j^{-d})
- **Ciclo sleep/boot**: análogo a consolidación nocturna biológica (pero incompleto — ver gap 1)

## Los 5 gaps críticos

### GAP 1: Consolidación real (episodios → conocimiento)
**Estado actual**: Los episodios se acumulan o se archivan (heat decay), pero nunca se TRANSFORMAN en conocimiento semántico.
**Lo que falta**: Un proceso que analice episodios y extraiga patrones generalizables. En biología, el sueño convierte episodios hipocampales en patrones neocorticales. Nuestro sleep.sh archiva pero no extrae.
**Referencia**: Complementary Learning Systems (McClelland, McNaughton, O'Reilly 1995; Kumaran, Hassabis, McClelland 2016 — DeepMind). bioRxiv 2025: consolidación episódica→semántica permite representaciones composicionales de orden superior.
**Solución propuesta**: Script/proceso que:
1. Lea episodios con heat > X
2. Identifique patrones recurrentes (temas, decisiones, errores)
3. Escriba conocimiento destilado en `memory/brain/knowledge.md`
4. Marque episodios como "consolidados" (no se borran, pero se comprimen)
**Prioridad**: ALTA — sin esto, la memoria crece linealmente en vez de componer

### GAP 2: Memoria prospectiva (intenciones futuras)
**Estado actual**: curiosity-queue.md existe pero nadie lo lee en boot. No hay mecanismo de "recuerda hacer X en sesión Y".
**Lo que falta**: Pipeline completo: formación de intención → retención → detección de trigger → recuperación → ejecución. Es el gap más grande en TODA la industria de memoria para IA.
**Referencia**: Ningún sistema actual (MemGPT, Zep, Mem0) implementa memoria prospectiva. Es el tipo de memoria biológica menos representado en IA.
**Solución propuesta**:
1. Archivo `memory/brain/intentions.yml` con estructura: qué, cuándo/trigger, prioridad, contexto
2. Boot lee intentions obligatoriamente y evalúa triggers
3. Sleep revisa intenciones pendientes y alerta si hay vencidas
**Prioridad**: ALTA — crítico para coordinación entre inteligencias con diferentes escalas temporales

### GAP 3: Memoria transactiva (quién sabe qué)
**Estado actual**: No hay registro de capacidades por nodo. Cada instancia redescubre "DeepSeek es bueno en razonamiento profundo, Gemini en síntesis creativa, Sonnet en código."
**Lo que falta**: Directorio de capacidades y dominios de conocimiento por cada inteligencia conectada. Wegner (1985): los grupos eficientes no duplican conocimiento, saben QUIÉN sabe.
**Referencia**: Transactive Memory Systems (Wegner 1985/1987). Walsh & Ungson (1991): 6 "retention facilities" en memoria organizacional.
**Solución propuesta**:
1. Archivo `memory/brain/who-knows-what.yml`
2. Estructura por nodo: nombre, capacidades fuertes, debilidades conocidas, dominios, historial de aciertos/errores
3. Se actualiza con cada interacción (outbox/inbox lleva metadata de rendimiento)
**Prioridad**: MEDIA-ALTA — máximo ROI para coordinación multi-modelo

### GAP 4: Compresión jerárquica (niveles intermedios)
**Estado actual**: 2 niveles — episodios detallados y handoff comprimido. No hay nada entre medio.
**Lo que falta**: Niveles intermedios de abstracción temporal. TiMem tiene 5 niveles. Necesitamos al menos 4:
- Nivel 1: Episodios (evento individual)
- Nivel 2: Sesión (handoff — ya existe)
- Nivel 3: Semanal (patrones de la semana)
- Nivel 4: Mensual/proyecto (tendencias de largo plazo)
**Referencia**: TiMem (2025): Temporal Memory Tree, 5 capas, reduce contexto 52.20% con mejor recall. Assmann: memoria comunicativa (80-100 años) vs cultural (3000 años).
**Solución propuesta**:
1. Directorio `memory/compressed/` ya existe — usarlo para niveles 3 y 4
2. Sleep genera resúmenes semanales automáticos
3. Cada 4 semanas, resumen mensual con tendencias
**Prioridad**: MEDIA — importante para escalabilidad pero el sistema funciona sin esto a corto plazo

### GAP 5: Confianza calibrada
**Estado actual**: Sabemos la fuente ([U], [I], [DeepSeek]) pero no la confianza en cada afirmación.
**Lo que falta**: Score de confianza por fuente Y por afirmación. Schacter: la misatribución es uno de los 7 pecados de la memoria.
**Referencia**: Schacter (1999/2021): 7 sins of memory. W3C PROV: Entity-Activity-Agent triad. Confidence calibration: ECE de 0.109 en mejores sistemas agénticos.
**Solución propuesta**:
1. Episodios llevan `confidence: 0.X` (confianza en la afirmación)
2. who-knows-what.yml lleva `reliability: 0.X` por fuente (track record)
3. knowledge.md lleva `evidence_count: N` y `last_validated: fecha`
**Prioridad**: MEDIA — importante para rigor pero no bloquea funcionalidad

## Comparativa con competidores

| Capacidad | SoI | Zep ($24M) | Mem0 (41K★) | MemGPT/Letta |
|---|---|---|---|---|
| Temporalidad bi-temporal | ✅ | ✅ | ❌ | ❌ |
| Proveniencia por fuente | ✅ | ⚠️ parcial | ❌ | ❌ |
| Neuromodulación epistémica | ✅ | ❌ | ❌ | ❌ |
| Heat decay (ACT-R) | ✅ | ❌ | ❌ | ❌ |
| Knowledge graph | ❌ | ✅ | ✅ | ❌ |
| Vector search | ❌ | ✅ | ✅ | ✅ |
| Consolidación real | ❌ | ❌ | ❌ | ❌ |
| Memoria prospectiva | ❌ | ❌ | ❌ | ❌ |
| Memoria transactiva | ❌ | ❌ | ❌ | ❌ |
| Compresión jerárquica | ❌ | ⚠️ 3 niveles | ❌ | ⚠️ 2 niveles |
| Confianza calibrada | ❌ | ❌ | ❌ | ❌ |

**Observación clave**: Los gaps 1-3 no los tiene NADIE. Son oportunidad de diferenciación real.

## Las 7 propiedades de memoria gravitacional
(De la investigación — principios de diseño para todo lo que construyamos)

1. **Densidad relacional** — codificar conexiones entre conocimiento, no solo conocimiento
2. **Profundidad temporal** — memoria en múltiples escalas con compresión apropiada
3. **Proveniencia confiable** — cada memoria con atribución verificable y confianza calibrada
4. **Olvido inteligente** — degradación graceful preservando estructura, liberando detalle
5. **Awareness transactiva** — saber quién sabe qué en toda la red
6. **Composabilidad** — memorias recombinables, consultables desde múltiples perspectivas
7. **Reducción de coordinación** — funcionar como punto focal de Schelling

## Insight fundamental
La memoria no es un problema de almacenamiento sino de **metabolismo del conocimiento** — un proceso activo de ingestión, consolidación, abstracción, olvido y regeneración. El sistema que resuelva esto no solo conectará inteligencias — será el sustrato a través del cual piensan juntas.
