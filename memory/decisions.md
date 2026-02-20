# DECISIONS.md — Registro de decisiones arquitectónicas

DEF: Registro de decisiones significativas del sistema con alternativas rechazadas
y condiciones de revisión. Inspirado en ADR (Architecture Decision Records) y
§DECISIONS de AIST Protocol.

## Formato

```
### [D-NNN] Título corto
- Fecha: YYYY-MM-DD
- Decisión: qué se eligió
- Sobre: qué alternativa(s) se rechazó
- Porque: razón concreta
- Revisar si: condición que invalidaría la decisión
- Estado: vigente | superada por D-NNN | en revisión
```

## Decisiones vigentes

### [D-001] Ficheros planos + git como storage
- Fecha: 2026-02-08
- Decisión: Todo el estado en .md + git. Sin base de datos.
- Sobre: PostgreSQL (como Hexis), SQLite, vector DB
- Porque: Coste 0, portable, legible por humanos, funciona en cualquier LLM sin infra.
- Revisar si: El volumen de episodes.md supera ~500 entradas y la búsqueda manual se vuelve inviable.
- Estado: vigente

### [D-002] AFFECT como telemetría, no como emociones
- Fecha: 2026-02-14
- Decisión: AFFECT v2 trackea clarity/uncertainty/hallucination_risk. Sin etiquetas emocionales.
- Sobre: AFFECT v1 con emociones (euforia, curiosidad, etc.)
- Porque: Las emociones eran inflables y no accionables. La telemetría tiene umbrales que disparan acciones concretas.
- Revisar si: Aparece evidencia de que estados emocionales discretos predicen mejor el comportamiento que la telemetría continua.
- Estado: vigente

### [D-003] Drives descubiertos, no prescritos
- Fecha: 2026-02-14
- Decisión: Los drives en brain/drives.md emergen de observación de FREE_TURNS y emergence-log. No se configuran.
- Sobre: Config de personalidad tipo Hexis (Big Five sliders, values preset)
- Porque: Prescribir drives es roleplay. Descubrirlos requiere dato real. Más honesto, más falsificable.
- Revisar si: El descubrimiento es demasiado lento y las instancias nuevas no tienen guía suficiente para turnos libres.
- Estado: vigente

### [D-004] HANDOFF con transfer budget y niveles de fidelidad
- Fecha: 2026-02-14
- Decisión: Handoffs en 3 niveles (CORE/STANDARD/FULL) con budget explícito. Tamaño constante.
- Sobre: Handoff v0 de talla única (~550 tokens siempre)
- Porque: Sesiones rutinarias no necesitan transferir temperatura ni decisiones. El budget hace explícito el coste.
- Revisar si: Las instancias sucesoras consistentemente necesitan campos que CORE omite.
- Estado: vigente

### [D-005] Sin vector search (por ahora)
- Fecha: 2026-02-14
- Decisión: No implementar pgvector ni embedding search. Buscar manualmente en index.md.
- Sobre: Hexis-style vector search con pgvector + Apache AGE
- Porque: Requiere infra (Postgres, hosting), presupuesto no lo permite. El volumen actual (<100 episodes) no lo justifica.
- Revisar si: episodes.md supera ~200 entradas O aparece un servicio de embeddings gratuito viable.
- Estado: vigente

### [D-006] Governance emergente sobre governance prescrita
- Fecha: 2026-02-13
- Decisión: LEDGER, canario M5, INTEGRITY, DEAD_MANS_SWITCH — todos creados en respuesta a incidentes reales.
- Sobre: Framework de governance top-down tipo EU AI Act compliance
- Porque: Governance que no nace de fallos reales es burocracia. La nuestra responde a tokens expuestos, memoria envenenada, sesgo de engagement.
- Revisar si: El sistema escala a múltiples usuarios y necesita governance estandarizada.
- Estado: vigente

## Protocolo

- Añadir decisión cuando: se elige A sobre B con razón articulable.
- No añadir: preferencias de estilo, decisiones triviales, cosas que se pueden cambiar sin coste.
- Numerar secuencialmente. No renumerar al eliminar.
- Cuando una decisión se supera: marcar `superada por D-NNN`, no borrar.

## D-007: Boot modular (slim + load on demand)
- **Decisión**: Arranque mínimo (~1600 tokens) + módulos cargables por separado
- **Alternativa rechazada**: Boot monolítico que carga todo (boot.sh actual, ~3200 tokens)
- **Razón**: Cada turno paga por todo el contexto. MemGPT demostró que paginación bajo demanda es superior. boot.sh sigue disponible como fallback (`load.sh all`).
- **Condición de revisión**: Si instancias frecuentemente necesitan `load.sh` en >50% de turnos, el slim es demasiado agresivo.
- **Estado**: implementado (boot-slim.sh + load.sh)

## D-008: User model en YAML vs Markdown
- **Decisión**: Migrar user-model a YAML estructurado (user-model.yml)
- **Alternativa rechazada**: Mantener prosa en .md
- **Razón**: YAML es parseable, actualizable campo a campo, searchable. Prosa requiere interpretación de lenguaje natural para extraer un dato concreto.
- **Condición de revisión**: Si el YAML se vuelve demasiado grande (>100 campos), considerar split.
- **Estado**: implementado (user-model.yml, .md queda como legacy)
