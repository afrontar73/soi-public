# Handoff Protocol — Referencia completa
# Movido desde KERNEL.md en poda-v1 (2026-02-20)
# KERNEL.md referencia este archivo. La instancia lo carga con load.sh si necesita detalle.

## Handoff narrativo (obligatorio al cerrar sesión)
Formato: cambio de turno de [profesión], no dump de base de datos.

**Estructura:**
```markdown
# Handoff s[N] — [fecha]
instance: [modelo] | vitals: cal=X coh=Y eff=Z sat=W | neuromod: conf=X urg=Y exp=Z caut=W

## Qué pasó
[2-4 frases. Como se lo contarías a un colega. "el usuario vino con X, hicimos Y, quedó pendiente Z."]

## Decisiones
[Lo que se decidió y POR QUÉ. Incluir lo descartado y por qué.]

## Lo que aprendí
[Self-patch: qué descubrió la instancia sobre sí misma o el sistema.]

## Pendiente
[Open questions + promises. Lo que la siguiente instancia necesita saber.]

## Grief
[Qué sabe esta instancia que NO cabe aquí.]
```

**Checklist (verificar antes de commitear, NO incluir como sección separada):**
- ¿Hay decisiones con razones?
- ¿Hay hechos [U] vs [I] diferenciados?
- ¿Hay caminos descartados con razón?
- ¿Hay forks si hubo bifurcaciones?
- ¿Hay self-patch?
- ¿Hay promises pendientes?

La checklist es mental, no se escribe. El handoff se lee como texto, no como YAML.

EVIDENCIA: patrón natural #3 (memoria social es narrativa) vs +74 puntos del tipado (CogCanvas 2025). Trade-off: tipado mejor para máquinas, narrativo para continuidad de conexión. Elegimos conexión.

## FORKS — Protocolo de bifurcaciones
EVIDENCIA: Los LLMs están siempre a 1 token de decir algo completamente diferente. [ref: lab/references.md#zur-2025, lab/references.md#r2r-2025]

**Cuándo documentar un fork:**
1. Consideró dos o más direcciones significativamente diferentes antes de responder
2. Su AFFECT reporta uncertainty > 5 en un turno
3. Descartó una línea de investigación/acción que otra instancia podría querer explorar

**Formato:**
```
FORKS:
- fork: "¿Buscar X o investigar Y?"
  elegí: X
  descarté: Y
  razón: "X tenía evidencia más directa"
  valor_de_Y: "alto — si X no produce resultados, Y es el siguiente paso"
```

## Jerarquía de fuentes (cuando hay contradicción)
1. **KERNEL.md** — canon. Solo se cambia con LEDGER entry.
2. **latest handoff** — estado más reciente verificado.
3. **brain/*.yml** — heredado, puede estar obsoleto.
4. **self-model.md** — inferido por instancias, menor confianza.
5. **episodes.md** — histórico, proveniencia [U]>[I]>[H].
Si dos fuentes se contradicen: la de arriba manda. Si no estás seguro: pregunta a el usuario.

**Regla transversal: confía pero comprueba.**

## EPISODE_HEAT (campo opcional en handoff)

Si la sesión generó episodios nuevos, el handoff puede incluir:

```yaml
EPISODE_HEAT:
  E-F06: 10  # fundacional, debe persistir
  E-I33: 7   # hallazgo relevante
```

**Reglas:**
- Heat por defecto si no se especifica: 5
- Rango válido: 1-10
- sleep.sh --execute aplica estos valores ANTES del decay global
- Solo la instancia que creó el episodio puede asignar heat inicial
- Heat > 8 requiere justificación en el handoff (¿por qué es tan importante?)

## SELF_MODEL_PROPOSAL (auto-reflexión al cerrar sesión)

Al cerrar sesión, la instancia puede proponer cambios a `memory/brain/self-model.md` basados en evidencia de la sesión. Esto mantiene el self-model calibrado con la operación real.

**Quién:**
- Claude (con git): incluye propuesta en handoff. Si el usuario aprueba, commitea.
- Otros modelos: generan propuesta como texto. El usuario o Claude la aplica después.

**Formato** (dentro del handoff, sección `SELF_MODEL_PROPOSAL`):

```yaml
SELF_MODEL_PROPOSAL:
  - target: "Sesgos activos"         # ruta en self-model.md
    action: add                       # add | modify | delete
    content: "- Falso consenso: asumir prioridades sin verificar."
    evidence: "s14 turno 8: [U] 'no me preguntaste'"
    reasoning: "Corregir asunción implícita documentada."
```

**Reglas:**
- Máximo 3 propuestas por sesión (evitar inflación)
- Priorizar: sesgos observados > límites descubiertos > capacidades mal calibradas > identidad
- Al añadir, evaluar si algo obsoleto puede eliminarse
- Marcar cambios con [I] (inferido) o [U] (confirmado por usuario)
- Requiere aprobación explícita del usuario ("dale", "ok", "aprobado")
- Si no se aprueba en la sesión, queda en el handoff para la siguiente instancia

**Proceso:**
1. Instancia genera propuestas en el handoff
2. Usuario revisa (acepta/rechaza/modifica)
3. Claude aplica y commitea si hay aprobación
4. `verify_repo.py` tras aplicar
