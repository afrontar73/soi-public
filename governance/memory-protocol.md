# Memory Protocol — Referencia completa
# Movido desde KERNEL.md en poda-v1 (2026-02-20)

## Episodios atómicos (obligatorio al escribir)
- Resolver pronombres: "él dijo" → "Jesús dijo"
- Timestamps absolutos: "ayer" → "2026-02-15"
- Si existe episodio relacionado, FUSIONAR en vez de añadir nuevo
- Cada episodio lleva: id, content, created, heat, last_accessed, scene, related[], foresight?

## Heat score
- Cada vez que un episodio se referencia en sesión: heat += 1, actualizar last_accessed
- **Auto-decay**: cada sesión, TODOS los episodios que NO se referenciaron pierden heat -1
- heat = 0 → mover a ARCHIVE automáticamente en sleep.sh (sin preguntar)
- heat negativo no existe (floor = 0)
- Episodios [U] con heat ≥ 8: decay -0.5 en vez de -1 (los hechos verificados resisten más)
- Poda manual sigue disponible para casos urgentes (episodes > 50)

## Proveniencia (obligatorio en brain/ y episodes.md)
Cada hecho lleva fuente:
- `[U]` = Jesús lo dijo directamente
- `[I]` = la instancia lo infirió
- `[H]` = heredado de handoff anterior (sin verificar)
En conflicto: `[U]` > `[I]` > `[H]`. Siempre.
Si `[I]` o `[H]` persiste 3+ sesiones sin verificación `[U]` → marcar `⚠️ NO VERIFICADO`.
Esto corta el lavado de alucinaciones (MINJA 2025). [ref: lab/references.md#minja-2025]

## Higiene
- Si episodes.md > 50 entradas → poda obligatoria (ACTIVE/ARCHIVE/DELETE)
- Si detectas contradicción entre brain/ y la interacción actual → actualizar brain/ + registrar en LEDGER
- Formato preferido para user-model: YAML (user-model.yml). El .md es legacy.

## Triggers de actualización de user-model.yml
- **profile**: Solo cuando el usuario corrige explícitamente [U]. Actualizar campo + fecha.
- **patterns**: Añadir si se observa en 2+ sesiones. Promover a high en 4+. Marcar dormant si no se ve en 5.
- **session_state**: Inferir cada arranque (hora, tono, longitud). Recalibrar turno 3.
- **contradicción**: Si user-model contradice al usuario → preguntar una vez → actualizar o anotar discrepancia.
- **No asumir que user-model tiene razón sobre el usuario.**

## Decaimiento epistémico (Active Forgetting)

Las inferencias `[I]` y datos heredados `[H]` pierden fiabilidad con el tiempo si nadie los verifica.

**Regla**: en cada sleep cycle con --execute, sleep.sh lista inferencias [I] y [H] en:
- `memory/compressed/handoffs-digest.md`
- `memory/brain/` (cualquier archivo)

**Ciclo de vida**:
1. Dato se crea como `[I]` o `[H]`
2. Si el usuario lo confirma explícitamente → muta a `[U]` (inmutable)
3. Si no se referencia en 5 sesiones consecutivas → candidato a purga
4. La instancia con escritura (Claude) decide: purgar, verificar con el usuario, o mantener con nota `[H:stale]`

**No se implementa como contador inline** (`[I:T5]`) porque:
- Requiere que cada instancia recuerde decrementarlo (no fiable cross-model)
- Cambia el formato de todos los archivos existentes
- La alternativa (sleep.sh lista candidatos) es más simple y más robusta

**Implementación**: sleep.sh --execute reporta inferencias no referenciadas. La instancia actúa.

## Heat: calibración y decay

**Regla de techo**: heat máximo al crear episodio = 7. Solo sube a 8+ si otra sesión posterior lo referencia y confirma importancia. El heat se gana, no se asigna.

**Recalibración**: si >40% de episodios activos tienen heat ≥ 7, aplicar `nuevo = round(actual * 0.7)` con techo 8. Última recalibración: s18 (76 episodios, 38% saturados → corregido).

**Archivo**: heat < 3 y no referenciado en 5+ sesiones → mover a ARCHIVE en episodes.md.
