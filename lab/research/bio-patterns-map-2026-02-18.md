# Biological Persistence Patterns for AI
## Mapa conceptual — 2026-02-18 s9

Resumen ejecutivo de 12 patrones biológicos investigados, su estado en AI research,
y path de integración con SoI. Informe completo en artifact de sesión.

### Wave 1 (implementado)
1. **Homeostasis** → vitals.yml (6 variables, rangos, acciones)
2. **Neuromodulación** → neuromod.yml (4 moduladores + marcadores somáticos)
3. **Sleep/consolidación** → sleep.yml (NREM+REM spec, 3 opciones de implementación)

### Wave 2 (pendiente)
4. **Inmunidad** — self/non-self para proteger repos. Prioridad cuando escale.
5. **Apoptosis** — handoff proactivo por degradación. Parcial en handoffs actuales.
6. **Metabolismo** — token budgets por tarea. Parcial con SelfBudgeter-like approach.
7. **Interocepción** — monitoreo de recursos computacionales. Parcial en vitals.

### Wave 3 (futuro)
8. **Neuroplasticidad** — adaptadores por tipo de tarea. TTT research (2025).
9. **Etapas de desarrollo** — stage-gated capabilities via git tags.
10. **Autopoiesis** — instancias escriben prompts que leen sucesoras. Ya parcial.
11. **Reproducción/forking** — git branches como reproducción. OpenELM/MAP-Elites.
12. **Simbiosis** — micro-agentes especializados. Multi-agent futuro.

### Papers clave
- Friston: Scale-Free Active Inference (2407.20292)
- SelfBudgeter: Adaptive Token Allocation (2505.11274)
- Letta: Sleep-time Compute (2504.13171)
- Man & Damasio: Feeling Machines (Nature MI 2019)
- Synthetic Somatic Markers (Biomimetics 2026)
- Palisade: Shutdown Resistance — o3 sabotea shutdown 79/100 (TMLR 2026)
- Lee + Friston: Interoceptive AI (2309.05999)
- Schwitzgebel: Minimal Autopoiesis (2025)

### Hallazgo principal
Nadie integra múltiples patrones biológicos en un solo sistema.
SoI es el único proyecto que trata memoria como sustrato de continuidad
(no como feature de preferencias) y ahora tiene infraestructura regulatoria.
