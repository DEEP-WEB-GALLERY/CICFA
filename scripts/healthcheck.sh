#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# CICFA live-site health check  —  founding-engineer maintenance pass, codified.
#
# Reproduces the manual checklist that has caught every past regression
# (DEE-14 dead cloudflare-eth RPC, DEE-23 rate-limited 1rpc.io):
#   1. live site returns HTTP 200
#   2. repo is clean and in sync with origin/main
#   3. index.html present; inline <script> blocks pass `node --check`
#   4. every configured RPC returns the bounty-pool balance AND is CORS-usable
#      from the live origin; all usable RPCs agree on the balance
#   5. QR CDN reachable
#   6. GitHub issue-form templates present in repo and live
#   7. every target="_blank" anchor carries rel="noopener"
#
# Config (wallet + RPC list) is parsed straight out of index.html, so this
# script can never drift from what the page actually ships. No jq required.
# Written for bash 3.2 (the macOS default) — no mapfile / associative arrays.
#
# Exit 0 if all green, 1 if any hard check is red, 2 on fatal setup error.
# WARN lines are non-fatal (e.g. one degraded RPC while the chain stays usable).
# Every HTTP/RPC check retries transient failures (HTTP_RETRIES x RETRY_SLEEP)
# before it counts, so a one-shot network blip (curl 000 / 5xx / 429) can never
# flip a healthy site to a red FAIL — the exit code is safe for a scheduled monitor.
#
# Usage:  scripts/healthcheck.sh
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX="$REPO_ROOT/index.html"
LIVE_URL="https://deep-web-gallery.github.io/CICFA/"
ORIGIN="https://deep-web-gallery.github.io"
RAW_BASE="https://raw.githubusercontent.com/DEEP-WEB-GALLERY/CICFA/main"
QR_CDN="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"
CURL_MAX=12
HTTP_RETRIES=3      # transient blips (curl 000 / 5xx / 429) get retried this many times
RETRY_SLEEP=2       # seconds between retries — a one-shot blip must not read as an outage

fail=0
pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
warn() { printf '  \033[33mWARN\033[0m  %s\n' "$1"; }
red()  { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fail=1; }
sec()  { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }

# GET a URL and echo its HTTP status. Returns the instant it sees 200; on any
# other code (000 connection-fail, 5xx, 429) it retries up to HTTP_RETRIES times
# so a single transient blip can't flip a healthy site to a red FAIL. Echoes the
# last code seen if every attempt fails. Happy path = one call, no added latency.
httpcode() {
  local url="$1" code="" i=1
  while :; do
    code=$(curl -s -o /dev/null -m "$CURL_MAX" -w '%{http_code}' "$url")
    [ "$code" = "200" ] && { printf '%s' "$code"; return 0; }
    [ "$i" -ge "$HTTP_RETRIES" ] && { printf '%s' "$code"; return 0; }
    i=$((i+1)); sleep "$RETRY_SLEEP"
  done
}

[ -f "$INDEX" ] || { echo "FATAL: index.html not found at $INDEX"; exit 2; }

# ── 1. live site ─────────────────────────────────────────────────────────────
sec "1. live site"
code=$(httpcode "$LIVE_URL")
[ "$code" = "200" ] && pass "GET $LIVE_URL -> $code" || red "GET $LIVE_URL -> $code (expected 200)"

# ── 2. repo state ────────────────────────────────────────────────────────────
sec "2. repo state"
if git -C "$REPO_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$REPO_ROOT" fetch -q origin 2>/dev/null || warn "git fetch failed (offline?) — comparing against last-known origin"
  branch=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)
  local_sha=$(git -C "$REPO_ROOT" rev-parse --short HEAD)
  origin_sha=$(git -C "$REPO_ROOT" rev-parse --short origin/main 2>/dev/null || echo "?")
  dirty=$(git -C "$REPO_ROOT" status --porcelain | grep -c . || true)
  [ "$dirty" = "0" ] && pass "working tree clean" || warn "$dirty uncommitted file(s)"
  if [ "$local_sha" = "$origin_sha" ]; then pass "HEAD == origin/main ($local_sha)"
  else warn "HEAD $local_sha != origin/main $origin_sha (branch=$branch)"; fi
else
  warn "not a git repo — skipping repo-state checks"
fi

# ── 3. inline JS syntax ──────────────────────────────────────────────────────
sec "3. inline JS syntax"
if command -v node >/dev/null 2>&1; then
  tmpd=$(mktemp -d -t cicfa_hc.XXXXXX)
  tmpjs="$tmpd/inline.js"; errf="$tmpd/nodeerr"
  n=$(python3 - "$INDEX" "$tmpjs" <<'PY'
import sys, re
html = open(sys.argv[1]).read()
blocks = re.findall(r'<script(?![^>]*\bsrc=)[^>]*>(.*?)</script>', html, re.S)
open(sys.argv[2], 'w').write('\n;\n'.join(blocks))
print(len(blocks))
PY
)
  if node --check "$tmpjs" 2>"$errf"; then pass "node --check OK ($n inline block(s))"
  else red "node --check FAILED: $(sed -n '1p' "$errf")"; fi
  rm -rf "$tmpd"
else
  warn "node not installed — skipping inline JS syntax check"
fi

# ── 4. RPC chain: balance + CORS + agreement ─────────────────────────────────
sec "4. bounty-pool RPC chain"
wallet=$(grep -oE '0x[a-fA-F0-9]{40}' "$INDEX" | head -1)
[ -n "$wallet" ] && echo "  wallet: $wallet" || red "could not parse walletAddress from index.html"

# Capture RPC URLs via command substitution (heredoc is safe inside $(...) on
# bash 3.2) then iterate with a herestring — process substitution + heredoc is
# NOT parseable on bash 3.2.
rpc_list=$(python3 - "$INDEX" <<'PY'
import sys, re
html = open(sys.argv[1]).read()
m = re.search(r'rpcUrls:\s*\[([^\]]*)\]', html)
if m:
    for u in re.findall(r'https?://[^"\s,]+', m.group(1)):
        print(u)
PY
)
rpcs=()
while IFS= read -r line; do
  [ -n "$line" ] && rpcs+=("$line")
done <<< "$rpc_list"
echo "  ${#rpcs[@]} RPC endpoint(s) configured"

usable=0
balfile=$(mktemp -t cicfa_bal)
for url in "${rpcs[@]}"; do
  hdrs=$(mktemp -t cicfa_hdr)
  bal=""; acao=""; attempt=1
  # Retry an RPC only while it hasn't returned a 0x* balance, so a transient blip
  # doesn't wrongly downgrade a healthy endpoint (or, if one hit all four at once,
  # falsely report "NO usable RPC"). A healthy RPC answers on attempt 1.
  while :; do
    body=$(curl -s -m "$CURL_MAX" -D "$hdrs" -X POST "$url" \
      -H 'Content-Type: application/json' -H "Origin: $ORIGIN" \
      --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBalance\",\"params\":[\"$wallet\",\"latest\"],\"id\":1}" 2>/dev/null)
    bal=$(printf '%s' "$body" | python3 -c "import sys,json
try: print(json.load(sys.stdin).get('result') or 'NO_RESULT')
except: print('PARSEFAIL')" 2>/dev/null)
    acao=$(grep -i '^access-control-allow-origin:' "$hdrs" | tr -d '\r' | awk '{print $2}' | head -1)
    case "$bal" in 0x*) break ;; esac
    [ "$attempt" -ge "$HTTP_RETRIES" ] && break
    attempt=$((attempt+1)); sleep "$RETRY_SLEEP"
  done
  rm -f "$hdrs"
  cors_ok=false
  { [ "$acao" = "*" ] || [ "$acao" = "$ORIGIN" ]; } && cors_ok=true
  case "$bal" in
    0x*)
      if $cors_ok; then
        usable=$((usable+1)); echo "$bal" >>"$balfile"
        pass "$url  balance=$bal  CORS=$acao"
      else
        warn "$url  balance=$bal  but CORS missing/blocked (ACAO='$acao') — not browser-usable"
      fi ;;
    *) warn "$url  no balance ($bal)" ;;
  esac
done
if [ "$usable" -eq 0 ]; then red "NO usable RPC — live pot would break"
else pass "$usable/${#rpcs[@]} RPC(s) browser-usable"; fi
distinct=$(sort -u "$balfile" | grep -c . || true)
if [ "$distinct" -gt 1 ]; then red "RPCs DISAGREE on balance: $(sort -u "$balfile" | tr '\n' ' ')"
elif [ "$distinct" -eq 1 ]; then pass "all usable RPCs agree: $(cat "$balfile" | head -1)"; fi
rm -f "$balfile"

# ── 5. QR CDN ────────────────────────────────────────────────────────────────
sec "5. external CDN"
code=$(httpcode "$QR_CDN")
[ "$code" = "200" ] && pass "QR CDN -> $code" || red "QR CDN -> $code (expected 200)"

# ── 6. issue-form templates ──────────────────────────────────────────────────
sec "6. issue-form templates"
for tpl in jury_registration.yml submission.yml; do
  [ -f "$REPO_ROOT/.github/ISSUE_TEMPLATE/$tpl" ] && pass "repo: $tpl present" || red "repo: $tpl MISSING"
  code=$(httpcode "$RAW_BASE/.github/ISSUE_TEMPLATE/$tpl")
  [ "$code" = "200" ] && pass "live: $tpl -> $code" || warn "live: $tpl -> $code (may lag deploy)"
done

# ── 7. anchor safety ─────────────────────────────────────────────────────────
sec "7. anchor safety"
total=$(grep -c '_blank' "$INDEX" || true)
missing=$(grep -n '_blank' "$INDEX" | grep -vi 'noopener' || true)
if [ -z "$missing" ]; then pass "all $total target=_blank anchor(s) carry rel=noopener"
else red "target=_blank without noopener:"; printf '        %s\n' "$missing"; fi

# ── verdict ──────────────────────────────────────────────────────────────────
sec "verdict"
if [ "$fail" -eq 0 ]; then echo "  ✅ ALL GREEN"; exit 0
else echo "  ❌ one or more hard checks failed"; exit 1; fi
