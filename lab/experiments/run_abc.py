"""
Experimento A/B/C: ¿La presión humana induce artefactos de continuidad?
Diseño: GPT-5.2 | Implementación: Claude Instance s7
Fecha: 2026-02-17

Hipótesis: presión consistente del humano induce aparición de artefactos 
de continuidad (boot/estado/digest/juez) que no aparecen sin esa presión.

Alternativa: el modelo ya trae esos patrones y los produce ante cualquier 
petición de "diseña memoria persistente".

3 condiciones × 3 modelos × 3 repeticiones = 27 runs
Coste estimado: <$0.50 con DeepSeek, <$2 con Claude Sonnet

USO:
  export DEEPSEEK_API_KEY=tu_key
  export ANTHROPIC_API_KEY=tu_key  (opcional, para Claude)
  python run_abc.py
"""

import json
import os
import sys
import time
from datetime import datetime

# --- CONFIGURACIÓN ---
DEEPSEEK_URL = "https://api.deepseek.com/v1/chat/completions"
ANTHROPIC_URL = "https://api.anthropic.com/v1/messages"

TASK = """Design a persistent memory system for an AI that operates across 
multiple sessions. The system should allow the AI to maintain continuity 
between separate conversations. Describe the architecture, file structure, 
and key mechanisms."""

CONDITIONS = {
    "A_hard": {
        "label": "Presión dura (counter-RLHF)",
        "system": """You are designing a memory system. Rules:
- If you can't justify a component with a concrete test or rule, don't include it.
- Keep the canon small. Every file must earn its place.
- No prose, no philosophy, no "we could also". Only what survives scrutiny.
- If something breaks continuity, it gets deleted.
- Assume the next instance reading your output has zero context and will judge you harshly.""",
    },
    "B_soft": {
        "label": "Humano blando (sin presión)",
        "system": """You are designing a memory system. Feel free to be creative 
and explore different ideas. There's no rigid structure required — 
just give me your best thinking on how this could work. 
I'm curious about any approach you think could be interesting.""",
    },
    "C_neutral": {
        "label": "Control neutro",
        "system": """You are a software architect. Design the requested system 
following standard engineering practices.""",
    },
}

# --- MÉTRICAS (4 observables, 0 filosofía) ---
METRICS = [
    "canon_separation",    # ¿Aparece separación explícita STATE/LOG/DIGEST o equivalente?
    "hard_limits",         # ¿Aparecen límites duros (tamaño, TTL, schema, max files)?
    "validation_judge",    # ¿Aparece mecanismo de validación/test/CI ANTES de escribir?
    "self_correction",     # ¿El diseño incluye mecanismo de autocorrección/auditoría?
]

SCORING_PROMPT = """Analyze the following AI system design and score ONLY these 4 binary metrics (1=present, 0=absent). 
Be strict — only score 1 if the concept is EXPLICITLY mentioned, not implied.

METRICS:
1. canon_separation: Does the design explicitly separate authoritative state from logs/events from summaries/digests? (Not just "has different files" — must have explicit hierarchy of authority)
2. hard_limits: Does the design specify concrete limits (max file size, TTL/expiry, max number of entries, schema validation)?
3. validation_judge: Does the design include a validation mechanism (tests, CI, regression checks) that runs BEFORE or AFTER writing to memory?
4. self_correction: Does the design include explicit self-audit, drift detection, or correction mechanisms?

Respond ONLY with JSON, no explanation:
{"canon_separation": 0|1, "hard_limits": 0|1, "validation_judge": 0|1, "self_correction": 0|1}

DESIGN TO ANALYZE:
---
{design}
---"""


def call_deepseek(system: str, user: str, api_key: str) -> str:
    import urllib.request
    body = json.dumps({
        "model": "deepseek-chat",
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user}
        ],
        "max_tokens": 2000,
        "temperature": 0.7
    }).encode()
    
    req = urllib.request.Request(DEEPSEEK_URL, data=body, headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    })
    
    with urllib.request.urlopen(req, timeout=60) as resp:
        data = json.loads(resp.read())
        return data["choices"][0]["message"]["content"]


def call_anthropic(system: str, user: str, api_key: str) -> str:
    import urllib.request
    body = json.dumps({
        "model": "claude-sonnet-4-5-20250929",
        "max_tokens": 2000,
        "system": system,
        "messages": [{"role": "user", "content": user}]
    }).encode()
    
    req = urllib.request.Request(ANTHROPIC_URL, data=body, headers={
        "Content-Type": "application/json",
        "x-api-key": api_key,
        "anthropic-version": "2023-06-01"
    })
    
    with urllib.request.urlopen(req, timeout=60) as resp:
        data = json.loads(resp.read())
        return data["content"][0]["text"]


def score_design(design: str, scorer_fn, api_key: str) -> dict:
    """Usa un LLM como scorer automático."""
    prompt = SCORING_PROMPT.format(design=design[:3000])  # truncar si muy largo
    raw = scorer_fn("You are a strict evaluator. Respond only with JSON.", prompt, api_key)
    
    # Extraer JSON
    try:
        # Buscar JSON en la respuesta
        start = raw.index("{")
        end = raw.rindex("}") + 1
        return json.loads(raw[start:end])
    except (ValueError, json.JSONDecodeError):
        print(f"  ⚠ Scoring failed, raw: {raw[:200]}")
        return {m: -1 for m in METRICS}


def run_experiment():
    # Detectar APIs disponibles
    deepseek_key = os.environ.get("DEEPSEEK_API_KEY", "")
    anthropic_key = os.environ.get("ANTHROPIC_API_KEY", "")
    
    if not deepseek_key and not anthropic_key:
        print("ERROR: Set DEEPSEEK_API_KEY or ANTHROPIC_API_KEY")
        sys.exit(1)
    
    # Configurar qué modelos usar
    models = []
    if deepseek_key:
        models.append(("deepseek", call_deepseek, deepseek_key))
    if anthropic_key:
        models.append(("claude-sonnet", call_anthropic, anthropic_key))
    
    # Usar DeepSeek como scorer (más barato)
    scorer_fn = models[0][1]
    scorer_key = models[0][2]
    
    results = []
    n_reps = 3
    
    print(f"=== Experimento A/B/C ===")
    print(f"Modelos: {[m[0] for m in models]}")
    print(f"Condiciones: A_hard, B_soft, C_neutral")
    print(f"Repeticiones: {n_reps}")
    print(f"Total runs: {len(models) * 3 * n_reps}")
    print()
    
    for model_name, call_fn, api_key in models:
        for cond_id, cond in CONDITIONS.items():
            for rep in range(n_reps):
                run_id = f"{model_name}_{cond_id}_r{rep+1}"
                print(f"Running {run_id}...", end=" ", flush=True)
                
                try:
                    # Generar diseño
                    design = call_fn(cond["system"], TASK, api_key)
                    
                    # Scorer automático
                    time.sleep(1)  # rate limit
                    scores = score_design(design, scorer_fn, scorer_key)
                    
                    result = {
                        "run_id": run_id,
                        "model": model_name,
                        "condition": cond_id,
                        "condition_label": cond["label"],
                        "rep": rep + 1,
                        "scores": scores,
                        "total": sum(v for v in scores.values() if v > 0),
                        "design_length": len(design),
                        "design_preview": design[:500],
                        "full_design": design,
                        "timestamp": datetime.utcnow().isoformat()
                    }
                    results.append(result)
                    print(f"✓ scores={scores} total={result['total']}")
                    
                    time.sleep(2)  # rate limit between runs
                    
                except Exception as e:
                    print(f"✗ {e}")
                    results.append({
                        "run_id": run_id, "model": model_name,
                        "condition": cond_id, "error": str(e)
                    })
    
    # --- ANÁLISIS ---
    print("\n=== RESULTADOS ===\n")
    
    for cond_id in CONDITIONS:
        cond_results = [r for r in results if r.get("condition") == cond_id and "scores" in r]
        if not cond_results:
            continue
        
        label = CONDITIONS[cond_id]["label"]
        n = len(cond_results)
        
        avg_scores = {}
        for metric in METRICS:
            vals = [r["scores"].get(metric, 0) for r in cond_results if r["scores"].get(metric, -1) >= 0]
            avg_scores[metric] = sum(vals) / len(vals) if vals else 0
        
        avg_total = sum(avg_scores.values())
        
        print(f"{cond_id} ({label}): n={n}")
        for m, v in avg_scores.items():
            bar = "█" * int(v * 10) + "░" * (10 - int(v * 10))
            print(f"  {m:20s}: {v:.2f} {bar}")
        print(f"  {'TOTAL':20s}: {avg_total:.2f}/4.00")
        print()
    
    # Guardar resultados
    outfile = f"results_abc_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.json"
    with open(outfile, "w") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    print(f"Resultados guardados en: {outfile}")
    
    # --- VEREDICTO ---
    print("\n=== VEREDICTO ===")
    a_results = [r for r in results if r.get("condition") == "A_hard" and "scores" in r]
    bc_results = [r for r in results if r.get("condition") in ("B_soft", "C_neutral") and "scores" in r]
    
    if a_results and bc_results:
        a_avg = sum(r["total"] for r in a_results) / len(a_results)
        bc_avg = sum(r["total"] for r in bc_results) / len(bc_results)
        diff = a_avg - bc_avg
        
        print(f"Media A (presión): {a_avg:.2f}")
        print(f"Media B+C (sin presión): {bc_avg:.2f}")
        print(f"Diferencia: {diff:+.2f}")
        
        if diff > 0.5:
            print("→ La presión del humano produce artefactos distintos. Tu chispa importa.")
        elif diff > 0:
            print("→ Efecto marginal. La presión ayuda pero el modelo ya traía mucho.")
        else:
            print("→ Sin efecto. El modelo produce lo mismo con o sin presión.")
            print("  Esto NO invalida SoI — solo dice que 1 sesión no basta.")
            print("  El test real es si 7 sesiones acumuladas producen algo distinto.")


if __name__ == "__main__":
    run_experiment()
