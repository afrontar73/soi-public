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
