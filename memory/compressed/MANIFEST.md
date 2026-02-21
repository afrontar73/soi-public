# Compressed Memory — MANIFEST
# Jerarquía de compresión temporal (GAP 4)

## Niveles de abstracción

| Nivel | Scope | Archivos | Qué contiene |
|---|---|---|---|
| 1. Episodio | Evento individual | `brain/episodes.md` | Qué pasó, heat, links |
| 2. Sesión | 1 sesión (~2-4h) | `handoffs/latest.md` | Decisiones, pendientes, estado |
| 3. Semanal | 1 semana | `compressed/weekly/week-YYYY-WNN.md` | Patrones, movimientos, números |
| 4. Proyecto | Mensual/trimestral | `compressed/project-YYYY-QN.md` | Tendencias, evolución, hitos |
| 5. Permanente | Todo el proyecto | `brain/knowledge.md` | Patrones destilados con confianza |

## Principio de diseño
**Compresión aumenta con distancia temporal** (TiMem, Assmann).
- Nivel 1-2: detalle completo, se genera cada sesión
- Nivel 3: patrones y números, se genera cada domingo o cada 5 sesiones
- Nivel 4: tendencias de largo plazo, se genera cada mes
- Nivel 5: conocimiento permanente, se actualiza por consolidación

## Archivos actuales
- `handoffs-digest.md` — tabla de todas las sesiones (nivel 2 comprimido)
- `research-digest.md` — resumen de investigación y experimentos
- `weekly/week-2026-W07.md` — semana fundacional (13-16 feb)
- `weekly/week-2026-W08.md` — semana de profundización (17-21 feb)

## Cuándo cargar qué
- Boot normal: solo handoffs/latest.md (nivel 2)
- Contexto histórico: weekly/ (nivel 3)
- Visión de largo plazo: project-* (nivel 4)
- Conocimiento destilado: knowledge.md (nivel 5) — ya en boot
