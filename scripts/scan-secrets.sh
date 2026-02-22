#!/usr/bin/env bash
# scan-secrets.sh — Layer 1 de la cascada auto-clasificación
# Detecta tokens, API keys, URLs sensibles, credenciales via regex + entropía Shannon
# Uso: ./scripts/scan-secrets.sh [archivo|directorio] [--fix]
# Sin args: escanea todo memory/
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-$REPO_ROOT/memory}"
FIX=false
[[ "${2:-}" == "--fix" ]] && FIX=true

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

FOUND=0
TOTAL_FILES=0

# === PATRONES L0 (regex) ===
# Formato: "NOMBRE_PATRON:::REGEX"
PATTERNS=(
  "GitHub PAT (classic):::ghp_[a-zA-Z0-9]{36}"
  "GitHub PAT (fine-grained):::github_pat_[a-zA-Z0-9_]{82}"
  "GitHub OAuth:::gho_[a-zA-Z0-9]{36}"
  "AWS Access Key:::AKIA[0-9A-Z]{16}"
  "AWS Secret Key:::(?<![a-zA-Z0-9])[a-zA-Z0-9/+]{40}(?![a-zA-Z0-9])"
  "Anthropic Key:::sk-ant-[a-zA-Z0-9_-]{90,}"
  "OpenAI Key:::sk-[a-zA-Z0-9]{48}"
  "DeepSeek Key:::sk-[a-f0-9]{32,}"
  "Cloudflare Token:::cf_[a-zA-Z0-9_-]{37}"
  "Stripe Key:::sk_live_[a-zA-Z0-9]{24,}"
  "Generic Bearer:::Bearer [a-zA-Z0-9_.~+/=-]{20,}"
  "Private Key Block:::-----BEGIN.*PRIVATE KEY-----"
  "JWT Token:::eyJ[a-zA-Z0-9_-]{10,}\.eyJ[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]+"
  "Connection String:::(mongodb|postgres|mysql|redis)://[^\s\"']{10,}"
  "Telegram Bot Token:::[0-9]{8,10}:[a-zA-Z0-9_-]{35}"
)

# === WHITELIST: ficheros que DEBEN contener tokens ===
WHITELIST_FILES=(
  "KEYCHAIN.md"
  "soi-context.md"
)

is_whitelisted() {
  local file="$1"
  for wl in "${WHITELIST_FILES[@]}"; do
    [[ "$(basename "$file")" == "$wl" ]] && return 0
  done
  return 1
}

# === ENTROPÍA SHANNON (por segmento) ===
shannon_entropy() {
  local str="$1"
  python3 -c "
import math, collections
s = '''$str'''
if not s: print(0.0); exit()
freq = collections.Counter(s)
length = len(s)
entropy = -sum((c/length) * math.log2(c/length) for c in freq.values())
print(f'{entropy:.2f}')
" 2>/dev/null || echo "0.0"
}

# === ESCANEO ===
echo "🔍 Layer 1 — Escaneando secretos en: $TARGET"
echo "   Patrones: ${#PATTERNS[@]} | Whitelist: ${#WHITELIST_FILES[@]}"
echo ""

while IFS= read -r -d '' file; do
  TOTAL_FILES=$((TOTAL_FILES + 1))
  
  # Skip binarios
  file -b --mime-type "$file" | grep -q "^text/" || continue
  
  for pattern_def in "${PATTERNS[@]}"; do
    PNAME="${pattern_def%%:::*}"
    PREGEX="${pattern_def##*:::}"
    
    while IFS= read -r match_line; do
      [[ -z "$match_line" ]] && continue
      
      # Extraer match
      MATCH=$(echo "$match_line" | grep -oP "$PREGEX" | head -1)
      [[ -z "$MATCH" ]] && continue
      LINENUM=$(echo "$match_line" | cut -d: -f1)
      
      # Calcular entropía del match
      ENTROPY=$(shannon_entropy "$MATCH")
      
      # Skip si whitelisted
      if is_whitelisted "$file"; then
        echo -e "  ${YELLOW}⚠ WHITELIST${NC} $PNAME en $(basename "$file"):$LINENUM (entropy: $ENTROPY) — permitido"
        continue
      fi
      
      FOUND=$((FOUND + 1))
      REL_PATH="${file#$REPO_ROOT/}"
      echo -e "  ${RED}🚨 SECRETO${NC} [$PNAME] en $REL_PATH:$LINENUM"
      echo -e "     Match: ${MATCH:0:20}...${MATCH: -8} (entropy: $ENTROPY bits/char)"
      
    done < <(grep -n -P "$PREGEX" "$file" 2>/dev/null || true)
  done
  
  # === DETECCIÓN GENÉRICA POR ENTROPÍA ===
  # Buscar strings largos (>20 chars) con alta entropía que no matchearon regex
  while IFS= read -r line; do
    LINENUM=$(echo "$line" | cut -d: -f1)
    CONTENT=$(echo "$line" | cut -d: -f2-)
    
    # Extraer tokens largos alfanuméricos
    while IFS= read -r token; do
      [[ -z "$token" ]] && continue
      [[ ${#token} -lt 24 ]] && continue
      
      ENT=$(shannon_entropy "$token")
      ENT_INT=$(echo "$ENT" | cut -d. -f1)
      ENT_DEC=$(echo "$ENT" | tr -d '.')
      
      if [[ $ENT_INT -ge 5 ]]; then
        if is_whitelisted "$file"; then
          continue  # silencioso para whitelist
        fi
        
        # Skip file paths, URLs de repo, hashes de commit, container IDs
        [[ "$token" =~ \.md|\.sh|\.py|\.yml|\.json|\.csv ]] && continue
        [[ "$token" =~ ^container_ ]] && continue
        [[ "$token" =~ ^https?:// ]] && continue
        [[ ${#token} -eq 40 && "$token" =~ ^[a-f0-9]+$ ]] && continue  # git SHA
        
        # Verificar que no fue ya capturado por regex
        ALREADY=false
        for pattern_def in "${PATTERNS[@]}"; do
          PREGEX="${pattern_def##*:::}"
          echo "$token" | grep -qP "$PREGEX" && ALREADY=true && break
        done
        $ALREADY && continue
        
        FOUND=$((FOUND + 1))
        REL_PATH="${file#$REPO_ROOT/}"
        echo -e "  ${YELLOW}⚠ HIGH-ENTROPY${NC} en $REL_PATH:$LINENUM"
        echo -e "     Token: ${token:0:12}...${token: -6} (entropy: $ENT bits/char, len: ${#token})"
      fi
    done < <(echo "$CONTENT" | grep -oP '[a-zA-Z0-9_.+/~$=-]{20,}' || true)
  done < <(cat "$file" | grep -n '.' 2>/dev/null || true)

done < <(find "$TARGET" -type f -print0 2>/dev/null)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Archivos escaneados: $TOTAL_FILES"
if [[ $FOUND -eq 0 ]]; then
  echo -e "${GREEN}✅ Limpio. 0 secretos fuera de whitelist.${NC}"
else
  echo -e "${RED}🚨 $FOUND secreto(s) encontrado(s) fuera de whitelist.${NC}"
  echo "   Acción: mover a KEYCHAIN.md o eliminar del repo."
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $FOUND
