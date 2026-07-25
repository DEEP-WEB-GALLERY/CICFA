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
#      from the live origin; all usable RPCs agree on the balance; and nobody has
#      sent new funds to the compromised pot address (DEE-30 inbound guard)
#   5. QR CDN reachable — only if the page still loads an external script
#   6. GitHub issue-form templates present in repo and live
#   7. every target="_blank" anchor carries rel="noopener"
#   8. funding suspension holds: no solicitation, disclosure intact (DEE-30)
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
# HEALTHCHECK_SKIP_RPC=1 skips the section-4 RPC live-probe. Set it when running
# from a datacenter/cloud IP (e.g. a CI runner): the free public RPC endpoints
# block cloud egress, returning non-JSON challenge bodies that read as a total
# outage even though the site is fine — a false positive, and a cloud-IP curl is
# not a faithful *browser* drift signal anyway. RPC/CORS drift is therefore
# verified only by the local maintenance pass (residential IP), which leaves
# this env unset. The scheduled GitHub Action sets it (see .github/workflows).
#
# Usage:  scripts/healthcheck.sh              # full pass (local / residential IP)
#         HEALTHCHECK_SKIP_RPC=1 scripts/healthcheck.sh   # skip RPC probe (CI)
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX="$REPO_ROOT/index.html"
LIVE_URL="https://deep-web-gallery.github.io/CICFA/"
ORIGIN="https://deep-web-gallery.github.io"
RAW_BASE="https://raw.githubusercontent.com/DEEP-WEB-GALLERY/CICFA/main"
QR_CDN="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"
# The gas dust the 2026-07-10 sweep left behind (0.0000210 ETH). The pot's key is
# in someone else's hands, so this is not a floor to grow from — it is a ceiling.
# Any balance ABOVE it means somebody funded a wallet that will be emptied.
POT_SWEPT_WEI=21000000000000
CURL_MAX=12
HTTP_RETRIES=3      # transient blips (curl 000 / 5xx / 429) get retried this many times
RETRY_SLEEP=2       # seconds between retries — a one-shot blip must not read as an outage

fail=0
pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
warn() { printf '  \033[33mWARN\033[0m  %s\n' "$1"; }
red()  { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fail=1; }
skip() { printf '  \033[36mSKIP\033[0m  %s\n' "$1"; }   # intentional, non-fatal, not counted
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
# Read the address out of the CICFA config line, not "the first 0x… in the file".
# Those were the same string until the page had to publish a second, hostile
# address (the wallet that swept the pot on 2026-07-10), which sits above the
# config — at which point the loose grep silently pointed this whole section at
# the drainer's balance and still reported ALL GREEN. A monitor must name what it
# is watching.
wallet=$(grep -oE 'walletAddress:[[:space:]]*"0x[a-fA-F0-9]{40}"' "$INDEX" | head -1 | grep -oE '0x[a-fA-F0-9]{40}')
[ -n "$wallet" ] && echo "  wallet: $wallet (from CICFA.walletAddress)" || red "could not parse walletAddress from index.html"

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

if [ -n "${HEALTHCHECK_SKIP_RPC:-}" ]; then
  skip "RPC live-probe skipped (HEALTHCHECK_SKIP_RPC set — datacenter/cloud IP)"
  echo "        Free public RPCs block cloud egress: all endpoints return non-JSON"
  echo "        challenge bodies, indistinguishable from a real outage (false FAIL),"
  echo "        and a cloud-IP curl is not a faithful browser-drift signal. RPC/CORS"
  echo "        drift is verified by the local maintenance pass (residential IP)."
else
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
elif [ "$distinct" -eq 1 ]; then
  agreed=$(sort -u "$balfile" | head -1)
  pass "all usable RPCs agree: $agreed"
  # Unexpected-inbound guard (DEE-30). Every other check here asks "is the page
  # working?". This one asks "has anyone been hurt?" — the address stays published
  # so the record can be checked, which means a visitor can still pay the thief by
  # hand. If that happens we have hours, not weeks, to notice: the sweeper emptied
  # five of its other victims within minutes of gas-funding them.
  wei=$(python3 -c "print(int('$agreed',16))" 2>/dev/null || echo "")
  if [ -z "$wei" ]; then warn "could not decode balance $agreed — inbound guard not evaluated"
  elif [ "$wei" -gt "$POT_SWEPT_WEI" ]; then
    red "POT HAS BEEN FUNDED: $wei wei > post-sweep baseline $POT_SWEPT_WEI."
    printf '        Someone sent ETH to a wallet whose key is compromised (DEE-30).\n'
    printf '        It will be swept. Pull the tx list, identify the sender, escalate now:\n'
    printf '        https://eth.blockscout.com/api?module=account&action=txlist&address=%s\n' "$wallet"
  elif [ "$wei" -lt "$POT_SWEPT_WEI" ]; then
    warn "balance $wei wei is BELOW the post-sweep baseline $POT_SWEPT_WEI — the leftover dust moved too (nothing of ours at risk, but the sweeper is still working this address)"
  else
    pass "no inbound since the sweep (balance still exactly the $POT_SWEPT_WEI wei gas dust)"
  fi
fi
rm -f "$balfile"
fi

# ── 5. external scripts ──────────────────────────────────────────────────────
# Derived from index.html rather than asserted, like the wallet/RPC config above:
# the page dropped its only remote script when funding was suspended (the QR
# encoded a payment URI for the compromised pot address). A monitor that kept
# checking a CDN the page no longer loads would report on nothing, and would go
# red for an outage that could not affect us.
sec "5. external scripts"
ext=$(grep -c '<script[^>]*src=' "$INDEX" || true)
if [ "$ext" -eq 0 ]; then
  skip "page ships no external scripts — nothing to reach"
else
  code=$(httpcode "$QR_CDN")
  [ "$code" = "200" ] && pass "QR CDN -> $code" || red "QR CDN -> $code (expected 200)"
fi

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

# ── 8. funding-suspension invariant ──────────────────────────────────────────
# DEE-30. The pot's private key is in someone else's hands and the wallet was
# swept on 2026-07-10, so the page must never again invite anyone to send ETH to
# it. This is the regression detector for that mitigation, and it is deliberately
# two-sided: the solicitation must stay ABSENT *and* the disclosure must stay
# PRESENT. Silently dropping the warning is the same failure as re-adding the ask.
#
# It exists because the mitigation is a regeneration away from being undone.
# DWG_AUTORUN_BETA/tools/templates/bounty_site.html — which CLAUDE.md §5 documents
# as the sanctioned way to make structural changes to this page — is the March
# original: it still carries "You are invited to arm the program", the
# click-to-copy affordance and the `ethereum:` payment QR, and it predates every
# fix from DEE-14 through DEE-30. Nothing in this repo would have noticed the
# invitation coming back. Now something does, within a day, in CI.
#
# All plain string tests against shipped HTML, so this runs from any IP: unlike
# the section-4 RPC probe, CI *does* cover this check.
sec "8. funding-suspension invariant (DEE-30)"

# Each pattern is the narrowest form that only the affordance can match. The
# loose forms are unusable: `ethereum:`, `copyAddress` and `qrcodejs` all still
# appear on the page inside the comments explaining their own removal, so
# grepping for those would false-FAIL forever.
solicit_patterns="invited to arm
increases the prize
To fund the bounty
onclick=\"copyAddress()\"
new QRCode
ethereum:' +"

disclose_patterns="Funding suspended
Do not send ETH to this address"

solicit_hits() {   # echo every solicitation pattern present in file $1
  local f="$1" p
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    grep -Fq "$p" "$f" && echo "$p"
  done <<EOF
$solicit_patterns
EOF
  return 0
}

show() { echo "$1" | while IFS= read -r h; do [ -n "$h" ] && echo "        - $h"; done; }

# repo copy — deterministic, no network, so a bad commit is caught before deploy
hits=$(solicit_hits "$INDEX")
if [ -z "$hits" ]; then pass "repo index.html: no funding solicitation"
else red "repo index.html: FUNDING SOLICITATION IS BACK — the pot key is compromised (DEE-30):"; show "$hits"; fi

missing_disc=""
while IFS= read -r p; do
  [ -n "$p" ] || continue
  grep -Fq "$p" "$INDEX" || missing_disc="$missing_disc$p
"
done <<EOF
$disclose_patterns
EOF
if [ -z "$missing_disc" ]; then pass "repo index.html: compromise disclosure present"
else red "repo index.html: compromise disclosure MISSING — page no longer warns visitors:"; show "$missing_disc"; fi

# live copy — this is the surface a visitor's money actually leaves from. A fetch
# failure is a WARN (can't verify), never a FAIL: section 1 already owns liveness.
livefile=$(mktemp -t cicfa_live)
lattempt=1
while :; do
  lcode=$(curl -s -m "$CURL_MAX" -o "$livefile" -w '%{http_code}' "$LIVE_URL" 2>/dev/null)
  [ "$lcode" = "200" ] && break
  [ "$lattempt" -ge "$HTTP_RETRIES" ] && break
  lattempt=$((lattempt+1)); sleep "$RETRY_SLEEP"
done
if [ "$lcode" = "200" ]; then
  lhits=$(solicit_hits "$livefile")
  if [ -z "$lhits" ]; then pass "live page: no funding solicitation"
  else red "live page: FUNDING SOLICITATION IS LIVE — visitors are being asked to fund a swept wallet:"; show "$lhits"; fi
  if grep -Fq "Funding suspended" "$livefile"; then pass "live page: compromise disclosure present"
  else red "live page: compromise disclosure MISSING"; fi
  lext=$(grep -c '<script[^>]*src=' "$livefile" || true)
  if [ "$lext" -eq 0 ]; then pass "live page: ships zero external scripts (QR CDN stays gone)"
  else warn "live page: $lext external script(s) — the QR CDN was removed with the payment QR; verify what came back"; fi
else
  warn "live page fetch -> $lcode — funding-suspension invariant not verified against production"
fi
rm -f "$livefile"

# ── verdict ──────────────────────────────────────────────────────────────────
sec "verdict"
if [ "$fail" -eq 0 ]; then echo "  ✅ ALL GREEN"; exit 0
else echo "  ❌ one or more hard checks failed"; exit 1; fi
