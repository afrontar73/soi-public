#!/bin/bash
# generate-graph.sh — Visualiza la red de episodios
# Uso: bash scripts/generate-graph.sh
# Output: estadísticas + top episodios + clusters + enlaces rotos

set -e
REPO=$(cd "$(dirname "$0")/.." && pwd)
EPISODES="$REPO/memory/brain/episodes.md"

echo "📊 EPISODE GRAPH"
echo ""

python3 -c "
import re
from collections import Counter, defaultdict

text = open('$EPISODES').read()
lines = text.splitlines()

# Parse episodes
episodes = {}
in_archive = False
for line in lines:
    if line.startswith('## ARCHIVE'):
        in_archive = True
    m_id = re.search(r'\*\*(E-[A-Z]\d+)\*\*', line)
    if not m_id:
        continue
    eid = m_id.group(1)
    heat = 0
    m_heat = re.search(r'heat:(\d+)', line)
    if m_heat:
        heat = int(m_heat.group(1))
    links = []
    m_links = re.search(r'links:\s*\[([^\]]*)\]', line)
    if m_links:
        links = [t.strip() for t in m_links.group(1).split(',') if t.strip()]
    episodes[eid] = {
        'heat': heat,
        'links': links,
        'archived': in_archive,
        'category': eid[2]  # S, B, A, F, R, T, I, D, etc.
    }

# Stats
active = {k:v for k,v in episodes.items() if not v['archived']}
archived = {k:v for k,v in episodes.items() if v['archived']}
print(f'Total: {len(episodes)} ({len(active)} activos, {len(archived)} archivados)')
print()

# Incoming links count
incoming = Counter()
for eid, ep in episodes.items():
    for link in ep['links']:
        incoming[link] += 1

# Top by heat
print('🔥 TOP 10 POR HEAT:')
by_heat = sorted(active.items(), key=lambda x: x[1]['heat'], reverse=True)[:10]
for eid, ep in by_heat:
    in_count = incoming.get(eid, 0)
    print(f'  {eid} heat:{ep[\"heat\"]} links_in:{in_count} links_out:{len(ep[\"links\"])}')
print()

# Top by connectivity (most linked to)
print('🔗 TOP 10 MÁS REFERENCIADOS:')
for eid, count in incoming.most_common(10):
    status = '📦' if episodes.get(eid, {}).get('archived') else '✅'
    heat = episodes.get(eid, {}).get('heat', '?')
    print(f'  {status} {eid} referenced_by:{count} heat:{heat}')
print()

# Clusters by category
print('📂 CLUSTERS:')
cats = defaultdict(list)
cat_names = {'S':'Seguridad', 'B':'Sesgos', 'A':'Arquitectura', 'F':'Filosofía',
             'R':'Relación', 'T':'Técnico', 'I':'Investigación', 'D':'Drives'}
for eid, ep in active.items():
    cats[ep['category']].append(eid)
for cat in sorted(cats.keys()):
    name = cat_names.get(cat, cat)
    print(f'  [{cat}] {name}: {len(cats[cat])} episodios')
print()

# Orphans (no incoming links, not linked by anyone)
orphans = [eid for eid in active if incoming.get(eid, 0) == 0 and not active[eid]['links']]
if orphans:
    print(f'🏝️  HUÉRFANOS (sin links entrantes ni salientes): {len(orphans)}')
    for eid in orphans:
        print(f'  {eid} heat:{active[eid][\"heat\"]}')
    print()

# Cold episodes (candidates for pruning)
cold = [(eid, ep) for eid, ep in active.items() if ep['heat'] <= 3]
cold.sort(key=lambda x: x[1]['heat'])
if cold:
    print(f'❄️  FRÍOS (heat ≤ 3): {len(cold)}')
    for eid, ep in cold[:10]:
        in_count = incoming.get(eid, 0)
        print(f'  {eid} heat:{ep[\"heat\"]} links_in:{in_count}')
    print()

# Broken links
broken = []
for eid, ep in episodes.items():
    for link in ep['links']:
        if link not in episodes:
            broken.append((eid, link))
if broken:
    print(f'💀 ENLACES ROTOS: {len(broken)}')
    for src, target in broken:
        print(f'  {src} → {target} (no existe)')
else:
    print('✅ Sin enlaces rotos')
"
