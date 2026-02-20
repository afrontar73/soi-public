# Compressed Memory Manifest
> Última actualización: 2026-02-20 (s14: poda-v1)

## Archivos comprimidos
| Archivo | Fuente | Contenido |
|---|---|---|
| handoffs-digest.md | s03-s14 | 1 línea por sesión, 18 líneas |
| research-digest.md | lab/ resumen | Hallazgos + estado, ~38 líneas |

## Handoffs activos
Regla: solo latest + penúltimo. Resto → handoffs-digest.md.
Archivos: latest.md, s13, s14.

## Boot-slim actual
~2900 tokens. Umbrales: verde <3K, amarillo <4K, rojo >5K.
Diagnóstico: `bash scripts/sleep.sh`
