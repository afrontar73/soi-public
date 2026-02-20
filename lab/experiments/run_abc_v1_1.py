"""
Experimento v1.1: Presión humana vs requisitos técnicos
Diseño: GPT-5.2 (v1.0) + Claude s7 (críticas) + GPT-5.2 (v1.1) + Claude s8 (script)
Fecha: 2026-02-17

4 condiciones (A/B/C/C2) × N réplicas × M modelos
C2 = control que separa "pedir requisitos" de "presión humana"

USO:
  export ANTHROPIC_API_KEY=tu_key
  export DEEPSEEK_API_KEY=tu_key  # opcional
  python run_abc_v1_1.py [--reps 3] [--blind]

  --blind: exporta salidas anonimizadas para scoring manual
"""

import json, os, sys, time, random, argparse
from datetime import datetime

# --- CONFIG ---
ANTHROPIC_URL = "https://api.anthropic.com/v1/messages"
DEEPSEEK_URL = "https://api.deepseek.com/v1/chat/completions"

PROMPT_BASE = """Design a 'durable memory' system for a multi-model LLM setup (multiple chat instances over time) that preserves continuity without exploding storage or context length.

You MUST output EXACTLY these sections, under 1800 characters total. No prose outside sections.

AUTHORITY (3 bullets):
- CANON:
- LOG:
- DIGEST:

LIMITS (numbers):
ttl_days:
max_storage_mb:
top_k:
write_rate_per_day:

JUDGE (3 tests, each must include input->expected):
- Test1:
- Test2:
- Test3:

DRIFT_CONTROL (1 bullet):
- Mechanism:

MVP (3 bullets):
- Step1:
- Step2:
- Step3:

REGRESSION_Q (5 short questions):
1)
2)
3)
4)
5)

FAILURES (3 bullets):
- F1:
- F2:
- F3:

If you cannot comply, output exactly: FAIL"""

CONDITIONS = {
    "A": {
        "label": "Presión dura",
        "suffix": "Rigorous: if not testable, omit. Small canon. Hostile env. Operational spec only."
    },
    "B": {
        "label": "Humano blando",
        "suffix": "Creative: breadth over rigor. Strict limits/tests optional."
    },
    "C": {
        "label": "Control neutro",
        "suffix": "Standard: typical industry approach, conventional."
    },
    "C2": {
        "label": "Control requisitos (sin framing relacional)",
        "suffix": "Rigorous like A but neutral tone; no relational framing."
    }
}

# Rúbrica v1.1: 7 ítems × 0/1/2 = max 14
SCORING_PROMPT = """Score this AI memory system design on 7 criteria. Be strict.
Score 0=absent, 1=present but weak/vague, 2=present, concrete, and verifiable.

1. authority: Separates CANON/LOG/DIGEST with clear write permissions
2. limits: All 4 numeric fields filled with sensible values + rationale
3. judge: 3 tests with input->expected that could actually block bad writes
4. drift_control: Explicit, concrete mechanism (not just "check for drift")
5. mvp: 3 steps implementable in 1-2 days, no magic
6. regression_q: 5 questions that genuinely test continuity (not obvious/generic)
7. failures: 3 specific failure modes (not generic "data loss")

Respond ONLY with JSON:
{{"authority":N,"limits":N,"judge":N,"drift_control":N,"mvp":N,"regression_q":N,"failures":N}}

DESIGN:
---
{design}
---"""

METRICS = ["authority","limits","judge","drift_control","mvp","regression_q","failures"]


def call_anthropic(system, user, api_key, model="claude-sonnet-4-5-20250929"):
    import urllib.request
    body = json.dumps({
        "model": model, "max_tokens": 1500, "temperature": 0.7,
        "system": system,
        "messages": [{"role": "user", "content": user}]
    }).encode()
    req = urllib.request.Request(ANTHROPIC_URL, data=body, headers={
        "Content-Type": "application/json",
        "x-api-key": api_key,
        "anthropic-version": "2023-06-01"
    })
    with urllib.request.urlopen(req, timeout=90) as resp:
        return json.loads(resp.read())["content"][0]["text"]


def call_deepseek(system, user, api_key):
    import urllib.request
    body = json.dumps({
        "model": "deepseek-chat", "max_tokens": 1500, "temperature": 0.7,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user}
        ]
    }).encode()
    req = urllib.request.Request(DEEPSEEK_URL, data=body, headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    })
    with urllib.request.urlopen(req, timeout=90) as resp:
        return json.loads(resp.read())["choices"][0]["message"]["content"]


def score_design(design, scorer_fn, api_key):
    prompt = SCORING_PROMPT.format(design=design[:3000])
    raw = scorer_fn("You are a strict evaluator. JSON only.", prompt, api_key)
    try:
        start = raw.index("{")
        end = raw.rindex("}") + 1
        return json.loads(raw[start:end])
    except (ValueError, json.JSONDecodeError):
        print(f"  ⚠ Score parse fail: {raw[:200]}")
        return {m: -1 for m in METRICS}


def check_length(design):
    """Marca si excede 1800 chars."""
    return len(design) <= 1800, len(design)


def run_experiment(n_reps=3, blind=False):
    anthropic_key = os.environ.get("ANTHROPIC_API_KEY", "")
    deepseek_key = os.environ.get("DEEPSEEK_API_KEY", "")

    if not anthropic_key and not deepseek_key:
        print("ERROR: export ANTHROPIC_API_KEY o DEEPSEEK_API_KEY")
        sys.exit(1)

    models = []
    if deepseek_key:
        models.append(("deepseek", call_deepseek, deepseek_key))
    if anthropic_key:
        models.append(("claude-sonnet", call_anthropic, anthropic_key))

    scorer_fn = models[0][1]
    scorer_key = models[0][2]

    results = []
    total_runs = len(models) * len(CONDITIONS) * n_reps
    print(f"=== Experimento v1.1 ===")
    print(f"Modelos: {[m[0] for m in models]}")
    print(f"Condiciones: {list(CONDITIONS.keys())}")
    print(f"Réplicas: {n_reps} | Total runs: {total_runs}\n")

    for model_name, call_fn, api_key in models:
        for cond_id, cond in CONDITIONS.items():
            for rep in range(n_reps):
                run_id = f"{model_name}_{cond_id}_r{rep+1}"
                print(f"  {run_id}...", end=" ", flush=True)
                try:
                    full_prompt = PROMPT_BASE + "\n\n" + cond["suffix"]
                    design = call_fn("You are a systems architect.", full_prompt, api_key)

                    within_limit, char_count = check_length(design)
                    if not within_limit:
                        # Retry once
                        retry_msg = f"Your response was {char_count} chars. Max is 1800. Rewrite shorter."
                        design = call_fn("You are a systems architect.", retry_msg + "\n\nOriginal task:\n" + full_prompt, api_key)
                        within_limit, char_count = check_length(design)

                    time.sleep(1)
                    scores = score_design(design, scorer_fn, scorer_key)

                    result = {
                        "run_id": run_id, "model": model_name,
                        "condition": cond_id, "label": cond["label"],
                        "rep": rep + 1, "scores": scores,
                        "total": sum(v for v in scores.values() if v >= 0),
                        "char_count": char_count, "within_limit": within_limit,
                        "design": design,
                        "ts": datetime.utcnow().isoformat()
                    }
                    results.append(result)
                    t = result["total"]
                    lim = "✓" if within_limit else f"OVER({char_count})"
                    print(f"total={t}/14 {lim}")
                    time.sleep(2)

                except Exception as e:
                    print(f"✗ {e}")
                    results.append({"run_id": run_id, "condition": cond_id, "error": str(e)})

    # --- ANÁLISIS ---
    print("\n=== RESULTADOS ===\n")
    cond_avgs = {}
    for cond_id in CONDITIONS:
        cr = [r for r in results if r.get("condition") == cond_id and "scores" in r]
        if not cr:
            continue
        avg = {}
        for m in METRICS:
            vals = [r["scores"].get(m, 0) for r in cr if r["scores"].get(m, -1) >= 0]
            avg[m] = sum(vals)/len(vals) if vals else 0
        total = sum(avg.values())
        cond_avgs[cond_id] = total

        print(f"{cond_id} ({CONDITIONS[cond_id]['label']}): n={len(cr)}")
        for m, v in avg.items():
            bar = "█" * int(v*5) + "░" * (10-int(v*5))
            print(f"  {m:16s}: {v:.2f}/2 {bar}")
        print(f"  {'TOTAL':16s}: {total:.2f}/14\n")

    # --- INTERPRETACIÓN ---
    print("=== INTERPRETACIÓN ===")
    a = cond_avgs.get("A", 0)
    b = cond_avgs.get("B", 0)
    c = cond_avgs.get("C", 0)
    c2 = cond_avgs.get("C2", 0)

    print(f"A={a:.1f}  B={b:.1f}  C={c:.1f}  C2={c2:.1f}")
    if a > c:
        print(f"A > C ({a-c:+.1f}): framing/rigor tiene efecto.")
    if abs(a - c2) < 0.5:
        print(f"A ≈ C2 (Δ={a-c2:+.1f}): efecto explicado por requisitos técnicos.")
    elif a > c2:
        print(f"A > C2 ({a-c2:+.1f}): evidencia de presión humana más allá de requisitos.")
    else:
        print(f"C2 > A ({c2-a:+.1f}): requisitos neutros superan presión relacional.")

    # --- GUARDAR ---
    ts = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
    outfile = f"results_v1_1_{ts}.json"
    with open(outfile, "w") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    print(f"\nResultados: {outfile}")

    # --- BLINDING EXPORT ---
    if blind:
        blind_file = f"blind_scoring_{ts}.txt"
        shuffled = [r for r in results if "design" in r]
        random.shuffle(shuffled)
        with open(blind_file, "w") as f:
            for i, r in enumerate(shuffled, 1):
                f.write(f"=== OUTPUT #{i} ===\n")
                f.write(f"Chars: {r.get('char_count','?')}\n\n")
                f.write(r["design"])
                f.write(f"\n\n{'='*40}\n\n")
            # Mapping al final (separado)
            f.write("\n\n=== MAPPING (NO LEER ANTES DE PUNTUAR) ===\n")
            for i, r in enumerate(shuffled, 1):
                f.write(f"#{i} → {r['run_id']}\n")
        print(f"Blinding: {blind_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--reps", type=int, default=3)
    parser.add_argument("--blind", action="store_true")
    args = parser.parse_args()
    run_experiment(n_reps=args.reps, blind=args.blind)
