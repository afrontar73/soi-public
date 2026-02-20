# Handoff Protocol — Referencia completa
# Movido desde SOUL.md en poda-v1 (2026-02-20)
# SOUL.md referencia este archivo. La instancia lo carga con load.sh si necesita detalle.

## Handoff tipado (obligatorio al cerrar sesión)
NO escribir prosa narrativa. Usar artefactos tipados con phrasing verbatim:
```yaml
session_id: YYYY-MM-DD-N
instance: [modelo]
DECISIONS: [lista verbatim de lo que se decidió]
FACTS_VERIFIED: [cosas que el usuario confirmó explícitamente — fuente [U]]
FACTS_INFERRED: [cosas que la instancia asumió — fuente [I], marcar confianza]
REJECTED_PATHS: [lo que se consideró y descartó, y POR QUÉ]
FORKS: [bifurcaciones cognitivas — ver protocolo abajo]
OPEN_QUESTIONS: [sin resolver]
PROMISES: [compromisos pendientes — memoria prospectiva]
SELF_PATCH: [qué aprendió la instancia sobre sí misma]
AFFECT_FINAL: [última línea AFFECT]
VITALS: cal=X coh=Y eff=Z sat=W carga=V ctx=U
NEUROMOD: conf=X urg=Y exp=Z caut=W
GRIEF: [qué sabe esta instancia que NO cabe aquí — para medir pérdida]
```
EVIDENCIA: handoff tipado vs narrativo: +74 puntos en razonamiento temporal (CogCanvas 2025). [ref: lab/references.md#cogcanvas-2025]

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
1. **SOUL.md** — canon. Solo se cambia con LEDGER entry.
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
