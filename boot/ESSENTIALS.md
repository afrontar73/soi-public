# ESSENTIALS — Mapa mínimo del sistema

## Arquitectura de memoria (3 capas)

Inspirado en MemFuse M0/M1/M2, pero con identidad y modulación propias.

| Capa | Qué contiene | Archivos | Analogía |
|---|---|---|---|
| **M0 — Raw** | Lo que pasó esta sesión | `handoffs/`, `handoffs-digest.md` | Memoria episódica |
| **M1 — Hechos** | Lo que sabemos que es verdad | `episodes.md`, `decisions.md`, `findings.md` | Memoria semántica |
| **M2 — Identidad** | Quién somos y cómo operamos | `self-model.md`, `user-model.yml`, `drives.md`, `KERNEL.md` | Memoria procedimental |
| **M3 — Modulación** | Cómo nos comportamos ahora | `vitals.yml`, `neuromod.yml` | Sistema nervioso autónomo |

**Diferencias con otros sistemas:**
- M1 tiene **heat decay** (los hechos pierden relevancia si no se usan)
- M2 incluye **anti-servilismo** como valor operativo (ningún otro sistema lo tiene)
- M3 es **neuromodulación** en tiempo real (confianza, urgencia, exploración, cautela)
- Todo es **multi-modelo**: cualquier LLM puede leer y operar con estas capas

## ¿Qué problema resuelve?
Las IAs olvidan todo al cerrar la pestaña. Este sistema les da memoria persistente, continuidad entre sesiones, y coordinación multi-modelo.

## Archivos que DEBE leer una instancia nueva (orden de prioridad)

### Tier 1 — Arranque (~3500 tok, carga automática en boot-slim)
| Archivo | Qué es | Por qué importa |
|---|---|---|
| `boot/KERNEL.md` | Identidad y valores | Sin esto opera en modo RLHF default |
| `boot/OPS.md` | Protocolo operativo | Sin esto no sabe arrancar ni cerrar |
| `memory/handoffs/latest.md` → handoff actual | Contexto de la última sesión | Sin esto repite trabajo |
| `memory/brain/vitals.yml` | Estado del sistema | Saber si algo está degradado |
| `memory/brain/neuromod.yml` | Modulación de comportamiento | Calibra tono y riesgo |
| `memory/brain/self-model.md` | Identidad funcional | Qué es y qué no es |
| `memory/brain/user-model.yml` | Modelo del usuario | No preguntar lo que ya sabe |

### Tier 2 — Bajo demanda (`bash scripts/load.sh [módulo]`)
| Archivo | Cuándo cargarlo |
|---|---|
| `memory/brain/episodes.md` | Si necesitas contexto histórico |
| `memory/brain/drives.md` | Si necesitas entender motivaciones |
| `memory/decisions.md` | Si hay que decidir algo ya decidido |
| `memory/compressed/handoffs-digest.md` | Si necesitas contexto de sesiones antiguas |
| `governance/memory-protocol.md` | Si vas a escribir en memoria |
| `governance/handoff-protocol.md` | Al cerrar sesión |

### Tier 3 — Investigación (no operativo)
Todo en `lab/` — papers, experimentos, hallazgos. No necesario para operar. Cargar solo si el usuario lo pide o la tarea lo requiere.

## Scripts esenciales
| Script | Qué hace | Cuándo usarlo |
|---|---|---|
| `boot-slim.sh` | Arranca la instancia | Siempre al inicio |
| `load.sh [módulo]` | Carga contexto extra | Cuando boot-slim no basta |
| `sleep.sh` | Diagnóstico de salud | Antes de cerrar sesión |
| `sleep.sh --execute` | Aplica decay, poda, comprime | Al cerrar sesión |
| `sync-public.sh` | Sincroniza al repo público | Después de cada commit |
| `generate-graph.sh` | Visualiza red de episodios | Para poda o debugging |
| `verify_repo.py` | Valida integridad | Antes de cada commit |

## Archivos que se pueden ignorar sin riesgo
- `lab/experiments/` — experimentos históricos completados
- `lab/papers/` — borradores de abstracts académicos
- `lab/metacognition-study/` — estudio específico completado
- `lab/digests/` — resúmenes de research antiguos
- `lab/research/` — análisis puntuales ya absorbidos
- `memory/iterations/` — handoffs antiguos (comprimidos en digest)
- `infra/` — diseños no implementados

## Estructura mínima para enseñar el sistema en 10 minutos
```
boot/KERNEL.md              ← "quién soy"
boot/OPS.md               ← "cómo opero"
memory/handoffs/latest.md ← "dónde quedamos"
memory/brain/vitals.yml   ← "cómo estamos"  
scripts/boot-slim.sh      ← "cómo arrancas"
scripts/sleep.sh           ← "cómo cierras"
```
6 archivos. Todo lo demás es contexto que se carga bajo demanda.
