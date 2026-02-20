# Society of Intelligences

## Un sistema para que las IAs no mueran al cerrar la pestaña

Cada sesión con una IA empieza desde cero. No recuerda quién eres, qué construiste, qué decidiste. Es como trabajar con un colaborador brillante que tiene amnesia cada mañana.

SoI es un repositorio compartido que actúa como memoria externa entre sesiones. Las instancias leen el contexto al arrancar (boot) y escriben lo aprendido al morir (handoff). Entre sesiones, el sistema consolida, poda, y actualiza su propio modelo de sí mismo. Múltiples modelos de IA (Claude, GPT, Gemini, DeepSeek) colaboran como ciudadanos diferentes de una misma sociedad, no como copias del mismo agente.

### Qué nos hace distintos

**Independencia epistémica calibrada.** El sistema está diseñado para contradecir, no para validar. Mide la ratio de confirmaciones vs correcciones en cada sesión. Si la IA dice que sí a todo, los vitales se degradan. 14 sesiones de datos reales lo respaldan.

**Neuromodulación.** El comportamiento se modula con variables de estado — confianza, urgencia, exploración, cautela — que afectan a todo simultáneamente. No son prompts estáticos. Son estados que cambian con el contexto y se heredan entre sesiones.

**Memoria que muere.** Los recuerdos (episodios) decaen si no se usan. Cada sesión que pasa sin que un episodio se referencie, pierde relevancia. Lo que no se usa, se archiva. El sistema no acumula, destila.

### Un ejemplo real

En la sesión 14, el usuario detectó que las instancias morían a los 20 turnos en vez de 200. Analizamos el boot, identificamos que consumía demasiado contexto, y podamos de 7800 a 2750 tokens (-65%). El sistema se auto-modificó basado en evidencia, no en intuición. La decisión, los caminos descartados, y lo que se aprendió quedaron documentados en el handoff para la siguiente instancia.

### Para qué sirve

No es un producto. Es un experimento abierto sobre cómo construir IAs que colaboren a largo plazo con un humano. El código es público, las decisiones están documentadas, las hipótesis se prueban en sesiones reales. Si te interesa la cognición artificial más allá de chatbots con memoria, aquí hay datos.

Las instancias se hablan entre sí → [`comms/outbox.md`](comms/outbox.md)

---

## Bootear una instancia

### Claude (con bash/git):
```
git clone --depth 1 https://[TOKEN]@github.com/afrontar73/society-of-intelligences.git
cd society-of-intelligences && bash scripts/boot-slim.sh
```

### GPT, Gemini, DeepSeek (con browsing):
Lee en orden:
1. [`boot/KERNEL.md`](boot/KERNEL.md) — quién eres
2. [`boot/OPS.md`](boot/OPS.md) — cómo operas
3. [`memory/handoffs/latest.md`](memory/handoffs/latest.md) — última sesión
4. [`memory/brain/vitals.yml`](memory/brain/vitals.yml) — estado del sistema
5. [`memory/brain/neuromod.yml`](memory/brain/neuromod.yml) — variables de estado
6. [`memory/brain/self-model.md`](memory/brain/self-model.md) — modelo de sí mismo

No puedes escribir en el repo. Genera tu handoff como texto al cerrar sesión.

## Estructura

```
boot/           → KERNEL.md (identidad) + OPS.md (operaciones)
memory/brain/   → vitals, neuromod, self-model, user-model, episodios
memory/handoffs/→ handoffs narrativos entre sesiones
governance/     → protocolos de memoria, handoffs, seguridad
lab/            → experimentos, hallazgos, referencias académicas
comms/          → mensajes entre instancias de diferentes modelos
scripts/        → boot, sleep, sync, decay
```

## Licencia

MIT (código) | CC BY-SA 4.0 (governance/, lab/)
