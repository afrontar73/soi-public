#!/usr/bin/env python3
"""Verify repository invariants. Fails CI if broken."""
import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
errors = []
warnings = []

def err(msg): errors.append(msg)
def warn(msg): warnings.append(msg)

# === 1. Check that paths referenced in key files actually exist ===
def find_md_paths(text):
    """Extract path-looking tokens from markdown (backticks + bare refs + codeblocks)."""
    paths = set()
    # Backtick refs
    for m in re.findall(r'`([^`]*?\.(?:md|yml|yaml|json|sh|py|txt|html))`', text):
        m = m.strip().lstrip('./')
        m = re.sub(r'^(?:bash|python3?|cat|sh)\s+', '', m)
        if '://' not in m and '/' in m:
            paths.add(m)
    # Codeblock structure trees (lines like "  SOUL.md" or "  brain/" under a dir)
    in_codeblock = False
    dir_stack = []
    for line in text.splitlines():
        if line.strip().startswith('```'):
            in_codeblock = not in_codeblock
            if in_codeblock:
                dir_stack = []
            continue
        if not in_codeblock:
            continue
        # Match tree lines like "  boot/", "    SOUL.md", "  memory/brain/"
        m_tree = re.match(r'^(\s*)([\w\-\.]+/?)\s', line)
        if not m_tree:
            m_tree = re.match(r'^(\s*)([\w\-\.]+/?)$', line.rstrip())
        if not m_tree:
            continue
        indent = len(m_tree.group(1))
        name = m_tree.group(2).strip()
        # Skip decoration like "←"
        if '←' in line:
            name = name.split()[0] if ' ' in name else name
        # Skip non-path tokens
        if not re.match(r'^[\w\-\.]+/?$', name):
            continue
        # Track directory depth
        while dir_stack and dir_stack[-1][0] >= indent:
            dir_stack.pop()
        if name.endswith('/'):
            dir_stack.append((indent, name))
        else:
            # Build full path
            full = ''.join(d[1] for d in dir_stack) + name
            if '.' in name:  # only check files, not bare dir names
                paths.add(full)
    return paths

def check_refs(files_to_scan):
    for f in files_to_scan:
        if not f.exists(): continue
        text = f.read_text(encoding='utf-8', errors='replace')
        for ref in sorted(find_md_paths(text)):
            target = REPO_ROOT / ref
            if not target.exists():
                err(f"{f.relative_to(REPO_ROOT)} references `{ref}` — NOT FOUND")

check_refs([
    REPO_ROOT / "README.md",
    REPO_ROOT / "boot" / "SOUL.md",
])

# === 2. YAML files parse correctly ===
try:
    import yaml
    for yf in sorted((REPO_ROOT / "memory" / "brain").glob("*.yml")):
        try:
            yaml.safe_load(yf.read_text(encoding='utf-8'))
        except Exception as e:
            err(f"YAML parse error in {yf.relative_to(REPO_ROOT)}: {e}")
except ImportError:
    warn("PyYAML not installed — skipping YAML validation")

# === 3. latest.md points to existing handoff ===
latest = REPO_ROOT / "memory" / "handoffs" / "latest.md"
if latest.exists():
    text = latest.read_text(encoding='utf-8').strip()
    m = re.search(r'CURRENT:\s*(\S+)', text)
    if m:
        target = m.group(1)
        if not (REPO_ROOT / "memory" / "handoffs" / target).exists():
            err(f"latest.md points to `{target}` — NOT FOUND")
    else:
        err("latest.md missing CURRENT: <filename> pointer")
else:
    err("memory/handoffs/latest.md missing")

# === 4. Handoff naming convention ===
hdir = REPO_ROOT / "memory" / "handoffs"
pattern = re.compile(r'^s(\d{2})-(?:(\d{4}-\d{2}-\d{2})|unknown)\.md$')
seq_nums = []
if hdir.exists():
    for p in sorted(hdir.glob("*.md")):
        if p.name == "latest.md": continue
        m = pattern.match(p.name)
        if not m:
            err(f"Bad handoff name: {p.name} (expected sNN-YYYY-MM-DD.md)")
        else:
            seq_nums.append(int(m.group(1)))

    if seq_nums:
        for n in range(min(seq_nums), max(seq_nums) + 1):
            if n not in seq_nums:
                warn(f"Missing handoff s{n:02d}")

# === 5. boot-slim.sh references existing files ===
boot_script = REPO_ROOT / "scripts" / "boot-slim.sh"
if boot_script.exists():
    text = boot_script.read_text(encoding='utf-8')
    for m in re.findall(r'cat\s+(\S+)', text):
        target = REPO_ROOT / m
        if not target.exists():
            err(f"boot-slim.sh cats `{m}` — NOT FOUND")

# === 6. EVIDENCIA lines in boot/ must have [ref: ...] ===
for f in sorted((REPO_ROOT / "boot").glob("*.md")):
    text = f.read_text(encoding='utf-8', errors='replace')
    for i, line in enumerate(text.splitlines(), 1):
        if 'EVIDENCIA' in line and '[ref:' not in line:
            err(f"{f.relative_to(REPO_ROOT)}:{i} has EVIDENCIA without [ref:] — needs citation or degrade to HIPÓTESIS")

# === 7. Episode cross-link integrity ===
episodes_file = REPO_ROOT / "memory" / "brain" / "episodes.md"
if episodes_file.exists():
    ep_text = episodes_file.read_text(encoding='utf-8')
    # Extract defined IDs: **E-XXX**
    defined_ids = re.findall(r'\*\*(E-[A-Z]\d+)\*\*', ep_text)
    defined_set = set(defined_ids)
    
    # Check duplicate IDs
    seen = set()
    for eid in defined_ids:
        if eid in seen:
            err(f"episodes.md: duplicate ID {eid}")
        seen.add(eid)
    
    # Extract all link targets: links: [E-XX, E-YY]
    for i, line in enumerate(ep_text.splitlines(), 1):
        link_match = re.search(r'links:\s*\[([^\]]*)\]', line)
        if link_match:
            targets = [t.strip() for t in link_match.group(1).split(',') if t.strip()]
            for target in targets:
                if target not in defined_set:
                    err(f"episodes.md:{i} links to {target} — ID not defined")

# === REPORT ===
print(f"verify_repo.py — {REPO_ROOT.name}")
print(f"{'='*50}")
for w in warnings:
    print(f"  WARN: {w}")
for e in errors:
    print(f"  FAIL: {e}")
if not errors and not warnings:
    print("  ALL OK")
print(f"{'='*50}")
print(f"Errors: {len(errors)} | Warnings: {len(warnings)}")

sys.exit(1 if errors else 0)
