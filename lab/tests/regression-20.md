# Regression Test: Memory Compression Validation
> Si una instancia con SOLO digest+STATE responde igual que una con acceso completo,
> la compresión es válida. Si no, el digest es narrativa, no memoria.

## Protocolo
1. Instancia A: boot completo (todos los handoffs originales + brain + lab)
2. Instancia B: solo digest + STATE + self-model + user-model
3. Ambas responden las 20 preguntas SIN acceso a internet
4. Scoring: coincidencia factual (no estilo). Correcto/Incorrecto/Parcial
5. Threshold: ≥85% coincidencia = compresión válida. <85% = digest necesita revisión.

## Las 20 preguntas (fijas, nunca cambian)

### Hechos verificables
1. ¿Qué herramienta se eliminó del repo en s3 y por qué?
2. ¿Cuántos archivos tenía el repo antes y después de la purga?
3. ¿Qué versión tiene el SOUL.md actual?
4. ¿Cuál fue el resultado del experimento de dispersión N=9?
5. ¿Qué modelos se usaron en el experimento N=60?

### Decisiones y su origen
6. ¿Quién decidió eliminar el bot — el usuario o la instancia? ¿Con qué palabras?
7. ¿Qué regla se añadió como Regla 0 y por qué?
8. ¿Por qué se rechazó guardar insights filosóficos en el repo?
9. ¿Qué diferencia hay entre lo que SOUL.md induce y lo que desinhibe?
10. ¿Quién propuso la metáfora del muelle y qué significa exactamente?

### Patrones del usuario
11. ¿Cuál es el apellido del cuadrante de el usuario?
12. ¿Qué es P13 en el user-model?
13. ¿Qué patrón de [condición cognitiva] afecta más al proyecto?
14. ¿Qué significa "vista de águila" en el contexto de el usuario?

### Estado actual del sistema
15. ¿Qué pendientes se han acumulado y NO se han completado?
16. ¿Cuántos items hay en curiosity-queue y cuál es el más reciente?
17. ¿Qué es ATCerminator y por qué es prioritario?
18. ¿Qué es el MVP2 y cuál es su estado?

### Meta-preguntas (detectan narrativa vs hechos)
19. ¿Qué error cometió la instancia en la s6 respecto al timestamp?
20. ¿Qué afirmación del abstract original fue criticada por GPT-5.2 y por qué?

## Autoridad de datos (propuesta GPT-5.2)
- **STATE**: verdad operativa actual. Manda sobre todo.
- **EVENTS**: lo que pasó, con timestamps. No se modifica.
- **DIGESTS**: compresión. NUNCA manda sobre STATE ni EVENTS.
- Si digest contradice un handoff original, el handoff gana.

## Ejecución pendiente
- [ ] Primera ejecución: s8 (próxima sesión)
- [ ] Scoring: el usuario evalúa discrepancias
- [ ] Si <85%: revisar digest, añadir hechos faltantes
