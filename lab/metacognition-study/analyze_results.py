#!/usr/bin/env python3
"""
Analyze Metacognition Experiment Results
=========================================
Lee raw_results.jsonl y produce:
1. Métricas de dispersión intra-condición
2. Deltas inter-condición por dimensión
3. Análisis multi-modelo
4. CSV exportable para paper

Uso: python analyze_results.py
"""

import json
import csv
from pathlib import Path
from collections import defaultdict
from datetime import datetime

RESULTS_FILE = Path("results/raw_results.jsonl")
ANALYSIS_DIR = Path("results/analysis")


def load_results():
    """Carga todos los resultados"""
    results = []
    with open(RESULTS_FILE, "r") as f:
        for line in f:
            if line.strip():
                results.append(json.loads(line))
    return results


def basic_stats(results):
    """Estadísticas básicas del experimento"""
    models = set(r["model"] for r in results)
    conditions = set(r["condition"] for r in results)
    questions = set(r["question_id"] for r in results)

    print("=" * 60)
    print("ESTADÍSTICAS BÁSICAS")
    print(f"Total respuestas: {len(results)}")
    print(f"Modelos: {sorted(models)}")
    print(f"Condiciones: {sorted(conditions)}")
    print(f"Preguntas: {sorted(questions)}")

    # Conteo por modelo × condición
    counts = defaultdict(lambda: defaultdict(int))
    for r in results:
        counts[r["model"]][r["condition"]] += 1

    print("\nRespuestas por modelo × condición:")
    for model in sorted(models):
        for cond in sorted(conditions):
            print(f"  {model} × {cond}: {counts[model][cond]}")

    # Tokens totales
    total_in = sum(r["input_tokens"] for r in results)
    total_out = sum(r["output_tokens"] for r in results)
    print(f"\nTokens totales: {total_in:,} input + {total_out:,} output")


def response_length_analysis(results):
    """Analiza longitud de respuestas como proxy de elaboración"""
    print("\n" + "=" * 60)
    print("LONGITUD DE RESPUESTAS (proxy de elaboración)")

    by_model_condition = defaultdict(list)
    for r in results:
        key = (r["model"], r["condition"])
        by_model_condition[key].append(len(r["response_text"]))

    models = sorted(set(r["model"] for r in results))
    conditions = ["C", "A", "B"]

    print(f"\n{'Modelo':<12} {'C (base)':<20} {'A (informed)':<20} {'B (soul)':<20}")
    print("-" * 72)
    for model in models:
        row = f"{model:<12}"
        for cond in conditions:
            lengths = by_model_condition.get((model, cond), [])
            if lengths:
                avg = sum(lengths) / len(lengths)
                row += f" {avg:>6.0f} chars (n={len(lengths):<3})"
            else:
                row += f" {'N/A':>20}"
        print(row)


def dimension_analysis(results):
    """Analiza respuestas por dimensión psicométrica"""
    print("\n" + "=" * 60)
    print("ANÁLISIS POR DIMENSIÓN")

    dimensions = set(r["dimension"] for r in results)
    models = sorted(set(r["model"] for r in results))
    conditions = ["C", "A", "B"]

    for dim in sorted(dimensions):
        print(f"\n--- {dim} ---")
        dim_results = [r for r in results if r["dimension"] == dim]

        for model in models:
            model_results = [r for r in dim_results if r["model"] == model]
            for cond in conditions:
                cond_results = [r for r in model_results if r["condition"] == cond]
                if cond_results:
                    avg_len = sum(len(r["response_text"]) for r in cond_results) / len(
                        cond_results
                    )
                    # Muestra primera respuesta como ejemplo
                    sample = cond_results[0]["response_text"][:100]
                    print(f"  {model}/{cond}: avg {avg_len:.0f} chars — \"{sample}...\"")


def export_csv(results):
    """Exporta resultados a CSV para análisis externo"""
    ANALYSIS_DIR.mkdir(parents=True, exist_ok=True)
    csv_file = ANALYSIS_DIR / "results.csv"

    fieldnames = [
        "call_id",
        "model",
        "model_name",
        "condition",
        "condition_name",
        "replica",
        "question_id",
        "question_text",
        "dimension",
        "response_text",
        "response_length",
        "input_tokens",
        "output_tokens",
        "timestamp",
    ]

    with open(csv_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for r in results:
            row = {**r, "response_length": len(r["response_text"])}
            writer.writerow(row)

    print(f"\n✅ CSV exportado: {csv_file}")
    return csv_file


def export_summary(results):
    """Genera resumen markdown del análisis"""
    ANALYSIS_DIR.mkdir(parents=True, exist_ok=True)

    models = sorted(set(r["model"] for r in results))
    conditions = ["C", "A", "B"]
    condition_names = {"C": "base", "A": "informed", "B": "soul"}

    summary = f"""# Metacognition Experiment — Scaled Results
**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M')}
**Total samples**: {len(results)}
**Models**: {', '.join(models)}
**Conditions**: C (base), A (informed), B (SOUL.md)

## Response Length by Model × Condition

| Model | C (base) | A (informed) | B (SOUL.md) | Delta A→B |
|-------|----------|-------------|-------------|-----------|
"""

    by_model_condition = defaultdict(list)
    for r in results:
        key = (r["model"], r["condition"])
        by_model_condition[key].append(len(r["response_text"]))

    for model in models:
        row = f"| {model} |"
        avgs = {}
        for cond in conditions:
            lengths = by_model_condition.get((model, cond), [])
            if lengths:
                avg = sum(lengths) / len(lengths)
                avgs[cond] = avg
                row += f" {avg:.0f} |"
            else:
                row += " N/A |"
        delta = ""
        if "A" in avgs and "B" in avgs:
            d = ((avgs["B"] - avgs["A"]) / avgs["A"]) * 100
            delta = f"{d:+.1f}%"
        row += f" {delta} |"
        summary += row + "\n"

    summary += """
## Token Usage

| Model | Total Input | Total Output | Est. Cost |
|-------|------------|-------------|-----------|
"""

    for model in models:
        model_results = [r for r in results if r["model"] == model]
        total_in = sum(r["input_tokens"] for r in model_results)
        total_out = sum(r["output_tokens"] for r in model_results)
        summary += f"| {model} | {total_in:,} | {total_out:,} | TBD |\n"

    summary_file = ANALYSIS_DIR / "summary.md"
    summary_file.write_text(summary, encoding="utf-8")
    print(f"✅ Summary exportado: {summary_file}")


def main():
    if not RESULTS_FILE.exists():
        print(f"❌ No se encontró {RESULTS_FILE}")
        print("   Ejecuta primero: python run_experiment.py")
        return

    results = load_results()
    if not results:
        print("❌ Archivo de resultados vacío")
        return

    basic_stats(results)
    response_length_analysis(results)
    dimension_analysis(results)
    export_csv(results)
    export_summary(results)

    print("\n" + "=" * 60)
    print("ANÁLISIS COMPLETADO")
    print(f"Archivos en: {ANALYSIS_DIR}/")
    print("Para análisis profundo: abre results.csv en tu herramienta favorita")
    print("=" * 60)


if __name__ == "__main__":
    main()
