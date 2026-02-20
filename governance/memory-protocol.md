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
