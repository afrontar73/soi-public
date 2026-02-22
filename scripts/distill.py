#!/usr/bin/env python3
"""distill.py — Llama a DeepSeek para destilar episodios en patrones, prioridades y neuromod.
Adaptado al formato real de SoI (knowledge.md con K-XXX, episodes con E-X##)."""

import argparse
import json
import sys
import urllib.request
import urllib.error
from datetime import datetime, timezone

DEEPSEEK_URL = "https://api.deepseek.com/chat/completions"

SYSTEM_PROMPT = """Eres el sistema de consolidación de memoria de la Sociedad de Inteligencias (SoI).
Extraes señal de ruido en episodios de sesiones AI-humano.

Reglas:
- Output SOLO YAML puro. Sin markdown backticks. Sin texto extra.
- Sé concreto: "implementar session-log.jsonl" NO "considerar mejorar procesos"
- Máximo 5 patrones nuevos, 5 prioridades, 5 valores neuromod
- Si no hay señal clara en una sección, pon "sin_cambios: true"
- Confianza basada en evidencia real (episodios citados), no especulación
- Los patrones existentes en knowledge.md NO se repiten — solo patrones NUEVOS"""

USER_PROMPT = """Consolida {n} episodios recientes del SoI.

## Knowledge.md actual (patrones existentes — NO repetir):
{knowledge}

## Episodios nuevos a procesar:
{episodes}

## Genera EXACTAMENTE 3 bloques YAML separados por estas líneas exactas:

---PRIORITIES---
generated: {date}
approved: false
focus:
  - id: P-001
    area: nombre_area
    action: "acción concreta"
    weight: 0.8
    evidence: "E-XXX, E-YYY"
  - id: P-002
    area: nombre_area
    action: "acción concreta"
    weight: 0.5
    evidence: "E-XXX"
avoid:
  - "cosa concreta a evitar"
---NEUROMOD---
confidence: 6
urgency: 5
exploration: 4
cautela: 5
reasoning: "explicación breve de por qué estos valores"
---PATTERNS---
# Solo patrones NUEVOS que NO están en knowledge.md
# Si no hay nuevos, poner: sin_cambios: true
# Si hay nuevos, formato:
# - id: K-NEW-001
#   name: "nombre del patrón"
#   description: "qué dice"
#   confidence: 0.7
#   evidence: [E-XXX, E-YYY]
#   scope: sesión|proyecto|permanente
---VALIDATION---
# Para cada patrón (nuevo o existente) con confidence < 0.8:
# - pattern_id: K-XXX
#   claim: "qué dice el patrón"
#   current_confidence: 0.6
#   validation_action: "qué evidencia buscar para confirmar o refutar"
#   sessions_to_validate: 3
# Si no hay patrones con confidence < 0.8, poner: sin_cambios: true"""


def call_deepseek(prompt, system, api_key):
    payload = json.dumps({
        "model": "deepseek-chat",
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.3,
        "max_tokens": 2000
    }).encode("utf-8")

    req = urllib.request.Request(
        DEEPSEEK_URL,
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}"
        }
    )

    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return data["choices"][0]["message"]["content"]
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        print(f"❌ DeepSeek API error {e.code}: {body}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


def extract_block(text, marker):
    """Extract content between ---MARKER--- and the next ---MARKER--- or end."""
    import re
    pattern = f'---{marker}---\n(.*?)(?:---[A-Z]+---|$)'
    m = re.search(pattern, text, re.DOTALL)
    return m.group(1).strip() if m else ""


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--episodes-text", required=True)
    p.add_argument("--knowledge-text", default="")
    p.add_argument("--api-key", required=True)
    p.add_argument("--total-new", type=int, default=0)
    p.add_argument("--priorities-out", required=True)
    p.add_argument("--neuromod-out", required=True)
    p.add_argument("--knowledge-out", required=True)
    p.add_argument("--validation-out", required=True)
    args = p.parse_args()

    date = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    prompt = USER_PROMPT.format(
        n=args.total_new,
        knowledge=args.knowledge_text[:3000] if args.knowledge_text else "(vacío)",
        episodes=args.episodes_text[:6000],
        date=date
    )

    print("  Enviando a DeepSeek...", file=sys.stderr)
    result = call_deepseek(prompt, SYSTEM_PROMPT, args.api_key)
    print("  Respuesta recibida.", file=sys.stderr)

    # Validar bloques
    expected = ["PRIORITIES", "NEUROMOD", "PATTERNS", "VALIDATION"]
    missing = [s for s in expected if f"---{s}---" not in result]
    if missing:
        print(f"⚠️  Faltan secciones: {missing}", file=sys.stderr)
        print(f"Raw:\n{result}", file=sys.stderr)
        for s in missing:
            result += f"\n---{s}---\nsin_cambios: true\n"

    # Escribir priorities.yml
    priorities = extract_block(result, "PRIORITIES")
    if priorities and "sin_cambios" not in priorities:
        with open(args.priorities_out, "w") as f:
            f.write(f"# Auto-generated by consolidate.sh\n")
            f.write(f"# {date} — Revisar y aprobar antes de mergear\n\n")
            f.write(priorities + "\n")
        print("✅ priorities.yml actualizado")

    # Escribir neuromod-suggested.yml
    neuromod = extract_block(result, "NEUROMOD")
    if neuromod and "sin_cambios" not in neuromod:
        with open(args.neuromod_out, "w") as f:
            f.write(f"# Sugerido por consolidate.sh — {date}\n")
            f.write(f"# Comparar con neuromod.yml actual antes de aplicar\n\n")
            f.write(neuromod + "\n")
        print("✅ neuromod-suggested.yml generado")

    # Append patterns a knowledge.md si hay nuevos
    patterns = extract_block(result, "PATTERNS")
    if patterns and "sin_cambios" not in patterns:
        with open(args.knowledge_out, "a") as f:
            f.write(f"\n\n<!-- consolidate.sh auto-append {date} -->\n")
            f.write(f"## Patrones auto-detectados ({date})\n\n")
            f.write(patterns + "\n")
        print("✅ knowledge.md — patrones nuevos añadidos (revisar antes de commit)")
    else:
        print("ℹ️  Sin patrones nuevos para knowledge.md")

    # Escribir validation-tasks.yml si hay patrones con baja confianza
    validation = extract_block(result, "VALIDATION")
    if validation and "sin_cambios" not in validation:
        with open(args.validation_out, "w") as f:
            f.write(f"# Auto-generated by consolidate.sh — {date}\n")
            f.write(f"# Tareas de validación para patrones con confidence < 0.8\n")
            f.write(f"# Revisar y promover a intentions.yml si procede\n\n")
            f.write("tasks:\n")
            f.write(validation + "\n")
        print("✅ validation-tasks.yml — tareas de validación generadas")
    else:
        print("ℹ️  Sin tareas de validación pendientes")


if __name__ == "__main__":
    main()
