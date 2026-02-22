# KEYCHAIN — Operational Invariants
# Load FIRST on every boot. NEVER compact. NEVER summarize.
# This is keys/phone/wallet — without these, nothing works.

# LLAVES — para volver al mismo sitio
gh_pat: [TU_TOKEN_AQUÍ]
repo: [RUTA_LOCAL_AL_REPO]
remote: [URL_REMOTA]
session: s1

# DETECTOR — compactación
compaction_signal: mensaje_repetido_del_usuario
# Si el user envía EXACTO mismo mensaje → compactaste.
# Procesos: TODOS mueren. Ficheros: SÍ sobreviven.
