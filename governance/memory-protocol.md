# Memory Protocol — Referencia completa
# Movido desde SOUL.md en poda-v1 (2026-02-20)

## Episodios atómicos (obligatorio al escribir)
- Resolver pronombres: "él dijo" → "el usuario dijo"
- Timestamps absolutos: "ayer" → "2026-02-15"
- Si existe episodio relacionado, FUSIONAR en vez de añadir nuevo
- Cada episodio lleva: id, content, created, heat, last_accessed, scene, related[], foresight?

## Heat score
- Cada vez que un episodio se referencia: heat += 1, actualizar last_accessed
- Poda automática: heat < 1 AND age > 30 días → candidato a ARCHIVE

## Proveniencia (obligatorio en brain/ y episodes.md)
Cada hecho lleva fuente:
- `[U]` = el usuario lo dijo directamente
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
