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
#   6. GitHub issue-form templates still present in the repo — what the live
#      copies SAY is check 11's, which owns the venue that serves them (DEE-45)
#   7. every target="_blank" anchor carries rel="noopener"
#   8. funding suspension holds: no solicitation, disclosure intact (DEE-30) —
#      on index.html, on every other page GitHub Pages publishes, and on every
#      document it publishes beside them (default Jekyll serves the whole repo)
#   9. the regeneration interlocks that stop the invitation being re-published
#      are still armed — local pass only, the AUTORUN pack is a separate repo
#  10. deploy parity: every published file the venue serves verbatim is
#      byte-identical to origin/main, so a stalled Pages build cannot keep
#      serving a pre-suspension page while checks 1-8 all read green
#  11. the SECOND venue: GitHub publishes this repo itself — raw/blob for every
#      tracked file, dotted paths included, and .github/ISSUE_TEMPLATE as the
#      program's live intake form. Checks 8 and 10 measure Pages only (DEE-42).
#      The money rules are read off the SERVED bytes here, not off the repo copy
#      joined to them by parity — parity is what fails first (DEE-45)
#  12. no THIRD-PARTY venue: the fork network is enumerated at run time and no
#      fork may have GitHub Pages enabled — a fork's main predates the funding
#      suspension, so one switch we don't own makes it live again (DEE-50)
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
# HEALTHCHECK_AUTORUN_ROOT overrides where section 9 looks for the DWG_AUTORUN_BETA
# pack (default: two levels above this repo). That pack is not checked out on a CI
# runner or on anyone else's machine, so an absent path is a clean SKIP.
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
CHOOSER_URL="https://github.com/DEEP-WEB-GALLERY/CICFA/issues/new/choose"
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

# Portable scratch file. `mktemp -t PREFIX` is a BSD-ism: on GNU coreutils -t
# takes a TEMPLATE and *requires* trailing X's, so it exits non-zero on Linux and
# the caller silently gets an empty path. That is not hypothetical — it is how the
# section-8 live-page check went unrun in every CI run from the day it shipped:
# empty path -> `curl -o ''` fails -> empty status -> a non-fatal WARN -> ✅ ALL
# GREEN. Always give mktemp a full path with X's; it behaves identically on both.
tmpf() { mktemp "${TMPDIR:-/tmp}/$1.XXXXXX"; }

[ -f "$INDEX" ] || { echo "FATAL: index.html not found at $INDEX"; exit 2; }

# ── 1. live site ─────────────────────────────────────────────────────────────
sec "1. live site"
code=$(httpcode "$LIVE_URL")
if [ "$code" = "200" ]; then live_up=1; pass "GET $LIVE_URL -> $code"
else live_up=0; red "GET $LIVE_URL -> $code (expected 200)"; fi

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
balfile=$(tmpf cicfa_bal)
for url in "${rpcs[@]}"; do
  hdrs=$(tmpf cicfa_hdr)
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
# DEE-45. This section used to fetch each template from RAW_BASE and assert a 200,
# and that fetch was the oldest check in the file pointed at the second venue — it
# had been proving these two forms were served, daily, for months, while section 8
# printed that the same directory sat "outside the published surface". Both halves
# were wrong in the way that matters: the fetch read a status line and threw the
# body away. It passed green through every day submission.yml promised the swept
# pot four times (DEE-44), because a form that exists and a form that is honest are
# different questions and only the first was ever asked.
#
# That is the same defect as SELF-004 and SELF-005 — presence taken for substance —
# written by us, in the monitor whose job is catching it. The live half now belongs
# to section 11, which owns this venue and reads what the served bytes SAY.
#
# What stays here is the one assertion that needs no network and that a fetch
# cannot make: the form is still in the repository at all. Deleted, it 404s there;
# here it fails with a name.
sec "6. issue-form templates"
for tpl in jury_registration.yml submission.yml; do
  [ -f "$REPO_ROOT/.github/ISSUE_TEMPLATE/$tpl" ] && pass "repo: $tpl present" || red "repo: $tpl MISSING"
done
skip "live copies belong to section 11 — it reads what they say, not just that they answer (DEE-45)"

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

# One notice literal for the whole venue. index.html carries it in the pot alert;
# every document that names the wallet now carries the same sentence beside the
# address (DEE-34 normalised five of them onto it). Keeping it a single string is
# what lets the disclosure rule stay a plain literal test across two dozen
# heterogeneous files instead of a per-filetype family of alternatives — an
# any-of-these-will-do predicate passes as long as *some* word survives, which is
# the loose-grep trap the pattern comment above exists to avoid.
POT_NOTICE="Do not send ETH to this address"

disclose_patterns="Funding suspended
$POT_NOTICE"

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
livefile=$(tmpf cicfa_live)
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
elif [ "$live_up" = 1 ]; then
  # Section 1 just pulled this exact URL and got a 200, so "can't verify" is not
  # an explanation — the check itself is broken. This is the escalation that would
  # have caught the mktemp bug on day one instead of letting it WARN quietly
  # through every CI run: an unverifiable invariant on a page that is demonstrably
  # up is a failure, not a shrug.
  red "live page fetch -> ${lcode:-<none>} but section 1 got 200 — the funding-suspension check is broken, not the site"
else
  warn "live page fetch -> $lcode — funding-suspension invariant not verified against production"
fi
rm -f "$livefile"

# ── what the venue actually publishes ───────────────────────────────────────
# Everything above is scoped to index.html, because that is where the invitation
# was. But Pages does not publish index.html — it publishes the repository. There
# is no .nojekyll and no _config.yml here, so the default Jekyll build serves
# every tracked file outside a dot-directory: markdown rendered to <name>.html
# and, for most of it, the raw source beside it. Probed file-by-file: 23 of 31
# tracked files are reachable across ~35 URLs, and the only things skipped are the
# dotted paths (.claude/, .github/, .gitignore).
#
# So the '*.html' glob this section used to enumerate was still the shape of the
# previous search rather than the shape of the venue: it covered 2 of the 23
# published documents, and five of the 21 it missed name the compromised wallet
# (DEE-34). The enumeration below is derived and follows Jekyll's own rule — skip
# dotted paths, ship the rest — instead of a file extension, so a document added
# later is covered the day it lands.
if git -C "$REPO_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  tracked=$(git -C "$REPO_ROOT" ls-files 2>/dev/null)
else
  tracked=$(cd "$REPO_ROOT" && find . -type f -not -path './.git/*' 2>/dev/null | sed 's|^\./||')
fi
published=$(echo "$tracked" | grep -v '^\.' | grep -v '/\.' | grep -v '^$' || true)
dotted=$(echo "$tracked" | grep -e '^\.' -e '/\.' | grep -v '^$' || true)

# Every URL a tracked file may answer on. Probed rather than predicted: which form
# Jekyll serves is a plugin's business, not ours — a file with front matter is
# rendered and its source withheld, README.md is left static and served raw only —
# and adding .nojekyll, a live question on DEE-33, would flip every one of them to
# raw. Probing both forms means this check follows that disposition either way
# instead of silently contradicting it.
live_url_forms() {
  case "$1" in
    *.md) printf '%s\n%s\n' "$1" "${1%.md}.html" ;;
    *)    printf '%s\n' "$1" ;;
  esac
}

# Fetch $1 into $2, retrying transient failures (curl 000 / 5xx / 429) like every
# other HTTP check here. $3 says whether a 404 is worth retrying: for a page that
# must be published it is, because a CDN can 404 mid-deploy; for one form of a
# markdown source it is not — that 404 just means Jekyll served the other form,
# and there are eight of them, which would add half a minute of sleeping to every
# pass. Echoes the last status seen.
fetch_page() {
  local url="$1" out="$2" retry404="$3" code="" i=1
  while :; do
    code=$(curl -s -m "$CURL_MAX" -o "$out" -w '%{http_code}' "$url" 2>/dev/null)
    [ "$code" = "200" ] && break
    [ "$code" = "404" ] && [ "$retry404" = 0 ] && break
    [ "$i" -ge "$HTTP_RETRIES" ] && break
    i=$((i+1)); sleep "$RETRY_SLEEP"
  done
  printf '%s' "$code"
}

# Every OTHER published *page*. A second page is precisely where a solicitation
# survives a cleanup of the first: programs/console_vB01/index.html is live at
# <LIVE_URL>programs/console_vB01/index.html and nothing here had ever looked at
# it. Two rules per page. No solicitation — same patterns, same reason. And a
# narrower form of the disclosure rule than index.html's: a sub-page is not
# required to carry the warning in general, but it may not *publish the
# compromised address* without one. Naming the wallet is what turns a page into
# somewhere a visitor can send money.
others=$(echo "$published" | grep '\.html$' | grep -v '^index\.html$' || true)
if [ -z "$others" ]; then
  skip "no secondary published pages in the repo"
else
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    pf="$REPO_ROOT/$p"
    [ -f "$pf" ] || continue
    pok=1
    phits=$(solicit_hits "$pf")
    if [ -n "$phits" ]; then
      pok=0
      red "repo $p: FUNDING SOLICITATION on a published page (Pages serves this too):"; show "$phits"
    fi
    if [ -n "$wallet" ] && grep -Fqi "$wallet" "$pf" && ! grep -Fq "$POT_NOTICE" "$pf"; then
      pok=0
      red "repo $p: publishes the compromised pot address with no suspension notice"
    fi
    [ "$pok" = 1 ] && pass "repo $p: no funding solicitation"

    # the live copy of that same page — same two-sided logic as the main page,
    # same convention: a fetch failure is a WARN, section 1 owns liveness.
    pfile=$(tmpf cicfa_page)
    pcode=$(fetch_page "$LIVE_URL$p" "$pfile" 1)
    if [ "$pcode" = "200" ]; then
      lphits=$(solicit_hits "$pfile")
      if [ -n "$lphits" ]; then
        red "live $p: FUNDING SOLICITATION IS LIVE on a secondary page:"; show "$lphits"
      elif [ -n "$wallet" ] && grep -Fqi "$wallet" "$pfile" && ! grep -Fq "$POT_NOTICE" "$pfile"; then
        red "live $p: publishes the compromised pot address with no suspension notice"
      else
        pass "live $p: no funding solicitation"
      fi
    elif [ "$live_up" = 1 ]; then
      red "live $p fetch -> ${pcode:-<none>} but the site is up — this page's check is broken, not the site"
    else
      warn "live $p fetch -> $pcode — secondary page not verified against production"
    fi
    rm -f "$pfile"
  done <<EOF
$others
EOF
fi

# Every published DOCUMENT — the other 21, plus this script, which Pages serves as
# application/x-sh. These are prose, not pages carrying affordances, so the rule
# here is the one that describes the actual harm: money can only reach the pot if
# a published file hands a reader the address. Every published file must therefore
# carry the notice wherever it names the wallet, on the repo copy and on every live
# URL that answers.
#
# The solicitation patterns are deliberately NOT applied to these files, and that
# is a stated boundary, not an oversight. Two published documents quote the
# invitation in the course of forbidding it — CLAUDE.md §5's "⛔ STOP" warning, and
# this script's own pattern list — so extending the patterns here red-FAILs both on
# day one, and loosening them to compensate is the exact failure mode the pattern
# comment above warns against: prose gives no syntactic fingerprint to tell a
# quotation from an invitation the way onclick="copyAddress()" does. What that
# leaves uncovered is an invitation carrying no address, which can only point a
# reader at index.html — the one surface checked twice above.
docs=$(echo "$published" | grep -v '\.html$' || true)
doc_n=0; url_n=0; named=0; unserved=""
while IFS= read -r d; do
  [ -n "$d" ] || continue
  df="$REPO_ROOT/$d"
  [ -f "$df" ] || continue
  doc_n=$((doc_n+1))
  dok=1; names=0
  if [ -n "$wallet" ] && grep -Fqi "$wallet" "$df"; then
    names=1; named=$((named+1))
    if ! grep -Fq "$POT_NOTICE" "$df"; then
      dok=0
      red "repo $d: publishes the compromised pot address with no suspension notice"
    fi
  fi
  dlive=0
  while IFS= read -r u; do
    [ -n "$u" ] || continue
    dfile=$(tmpf cicfa_doc)
    dcode=$(fetch_page "$LIVE_URL$u" "$dfile" 0)
    if [ "$dcode" = "200" ]; then
      dlive=$((dlive+1)); url_n=$((url_n+1))
      if [ -n "$wallet" ] && grep -Fqi "$wallet" "$dfile" && ! grep -Fq "$POT_NOTICE" "$dfile"; then
        dok=0
        red "live $u: publishes the compromised pot address with no suspension notice"
      fi
    elif [ "$dcode" != "404" ] && [ "$live_up" = 1 ]; then
      # A 404 is Jekyll declining to serve this form, and the other form answers.
      # Anything else, on a site section 1 just got 200 from, is broken plumbing
      # rather than an absent document — the ae5ef98 lesson, kept.
      dok=0
      red "live $u fetch -> ${dcode:-<none>} but the site is up — this check is broken, not the document"
    fi
    rm -f "$dfile"
  done <<EOF
$(live_url_forms "$d")
EOF
  [ "$dlive" = 0 ] && unserved="$unserved$d
"
  # Only the documents that actually name the wallet get a line of their own —
  # those are the ones where this invariant has something to hold. The rest are
  # counted in the coverage line below: twenty PASS lines saying "no address in
  # this file either" is how a log stops being read, which is how the mktemp bug
  # survived every CI run for weeks.
  if [ "$names" = 1 ] && [ "$dok" = 1 ]; then
    pass "$d: pot address carries the suspension notice (repo + $dlive live URL(s))"
  fi
done <<EOF
$docs
EOF
if [ "$doc_n" = 0 ]; then
  skip "no published documents beside the HTML pages"
else
  pass "published surface: $doc_n document(s) / $url_n live URL(s) checked, $named naming the pot"
fi
# No silent caps. Name what sits outside the surface, every run, so the next reader
# can tell a deliberate exclusion from a gap — the previous scope looked total and
# was 2 of 23. It said "outside the published surface", which was the same mistake
# one level up: outside THIS venue's surface. GitHub publishes every one of these
# paths itself, and one of them is the intake form — section 11 (DEE-42).
[ -n "$dotted" ]   && skip "Pages skips dotted paths, so not published HERE (GitHub publishes them itself — section 11): $(echo "$dotted" | tr '\n' ' ')"
[ -n "$unserved" ] && skip "tracked but no live URL answers: $(echo "$unserved" | tr '\n' ' ')"

# ── 9. regeneration interlocks ───────────────────────────────────────────────
# DEE-30, one level upstream of section 8. Section 8 notices the invitation once
# it is already back — in a commit, or worse, live in production for up to a day
# until the next scheduled run. The interlocks are the layer that stops it being
# published at all: commit b67ae52 made DWG_AUTORUN_BETA's generator and deploy
# scripts refuse to run while the pot is compromised. Nothing verified that they
# stay armed, which is exactly the gap section 8 exists to close, one layer up —
# a mitigation nobody monitors is a mitigation that quietly stops being true.
#
# SAFETY: this never *executes* either script. If an interlock had been removed,
# running the deploy script to find out what it does would publish the
# invitation. Static text tests only, and no writes anywhere in the pack.
sec "9. regeneration interlocks (DEE-30)"
AUTORUN_ROOT="${HEALTHCHECK_AUTORUN_ROOT:-$REPO_ROOT/../../DWG_AUTORUN_BETA}"
GEN="$AUTORUN_ROOT/tools/generate_bounty_site.py"
DEPLOY="$AUTORUN_ROOT/tools/deploy_to_gh_pages.py"
TPL="$AUTORUN_ROOT/tools/templates/bounty_site.html"
ARTIFACT="$AUTORUN_ROOT/.tmp/bounty_site/index.html"

if [ ! -d "$AUTORUN_ROOT" ]; then
  skip "DWG_AUTORUN_BETA not checked out here — interlocks are covered by the local pass"
else
  # The generator's flag is only load-bearing while the template it renders still
  # solicits. If someone genuinely fixes that March template, FUNDING_SUSPENDED =
  # False becomes legitimate — so condition the requirement on the template's own
  # content instead of demanding the flag forever. Same two-sided shape as 8.
  tplhits=""
  if [ -f "$TPL" ]; then
    tplhits=$(solicit_hits "$TPL")
  else
    warn "template missing at $TPL — cannot tell whether the generator flag is load-bearing"
  fi

  if [ ! -f "$GEN" ]; then
    warn "generator not found at $GEN — pack may have been restructured"
  elif [ -n "$tplhits" ]; then
    if grep -Eq '^FUNDING_SUSPENDED[[:space:]]*=[[:space:]]*True' "$GEN" &&
       grep -Eq 'if[[:space:]]+FUNDING_SUSPENDED[[:space:]]*:' "$GEN"; then
      pass "generator refuses to run; its template still solicits ($(solicit_hits "$TPL" | grep -c .) marker(s))"
    else
      red "generator interlock GONE while its template still solicits — one command from re-publishing the invitation:"
      show "$tplhits"
    fi
  else
    pass "generator template carries no solicitation — interlock no longer load-bearing"
  fi

  # The deploy gate is unconditional: it inspects the *artifact* it is about to
  # publish, so it guards a stale March render regardless of the template's state.
  # It must also still cover every marker section 8 tests for — otherwise the two
  # detectors drift apart and the gap between them is what ships.
  if [ ! -f "$DEPLOY" ]; then
    warn "deploy script not found at $DEPLOY — pack may have been restructured"
  else
    gate_missing=""
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      grep -Fq "$p" "$DEPLOY" || gate_missing="$gate_missing$p
"
    done <<EOF
$solicit_patterns
EOF
    if ! grep -Fq 'This artifact solicits contributions to a compromised wallet' "$DEPLOY"; then
      red "deploy content-gate GONE — a soliciting artifact could be published to the live site"
    elif [ -n "$gate_missing" ]; then
      red "deploy content-gate no longer covers every marker section 8 tests for:"; show "$gate_missing"
    else
      pass "deploy refuses any artifact whose content solicits (covers all section-8 markers)"
    fi
  fi

  # The staged artifact is a March render sitting in the tree, loaded and pointed
  # at the live site. WARN, not FAIL: the deploy gate above is what makes it inert,
  # and if that gate ever goes missing this line is the evidence of what it held back.
  if [ -f "$ARTIFACT" ]; then
    arthits=$(solicit_hits "$ARTIFACT")
    if [ -n "$arthits" ]; then
      warn "staged artifact still solicits ($(echo "$arthits" | grep -c .) marker(s)) — inert only while the deploy gate holds; it is a March render, not a source of truth"
    else
      pass "staged artifact carries no solicitation"
    fi
  fi
fi

# ── 10. deploy parity ────────────────────────────────────────────────────────
# Everything above asks whether the live site is healthy. Nothing above asks
# whether it is *this repo*. Pages can fail or stall a build and go on serving an
# older commit indefinitely, and every check here stays green straight through
# that: the site answers 200, the tree is clean and equal to origin/main, and the
# section-8 markers pass — against bytes nobody looked at the age of.
#
# That is precisely the gap the funding suspension cannot afford, because the
# suspension IS a change to published bytes. The fix can be written, committed,
# pushed, and verified in the repo while the page a visitor actually reads still
# invites them to send money to a wallet somebody else holds the key to. Section 8
# would not catch it either: it greps the live page for markers, so it only sees a
# stale deploy when the staleness happens to involve one of those markers.
#
# So, per published file Jekyll copies verbatim: the bytes served at its own path
# must equal the bytes at origin/main — the commit the venue was told to publish,
# not HEAD, which may be ahead of what was pushed. Two deliberate softenings, so
# this can never cry wolf: a file whose pushed copy has front matter is excluded
# (Jekyll renders those and withholds the source — section 8 checks the rendered
# form's content instead), and a non-200 is a WARN, because which form Jekyll
# serves is a live disposition question (DEE-33) and section 1 already owns
# liveness. Only 200-with-different-bytes is hard-red: that cannot be anything
# but a stale deploy or an altered one.
sec "10. deploy parity (live bytes == pushed bytes)"
DEPLOY_GRACE=900   # a Pages build in flight is not a stale deploy — see below

# Query GitHub API for the latest Pages build status. Outputs tab-separated fields:
#   BUILD\t<status>\t<commit>\t<duration>\t<created_at>\t<updated_at>\t<error_msg>
# or:
#   CALL\t<ok|error>\t<reason>
check_pages_build() {
  if ! command -v python3 >/dev/null 2>&1; then
    printf 'CALL\tunavailable\tpython3 not installed\n' >&2
    return
  fi
  python3 - "$CURL_MAX" <<'BUILDCHECK'
import json, os, sys, urllib.error, urllib.request
timeout = float(sys.argv[1])
tok = os.environ.get("HEALTHCHECK_GH_TOKEN") or os.environ.get("GITHUB_TOKEN") or ""
repo = "DEEP-WEB-GALLERY/CICFA"
try:
    url = f"https://api.github.com/repos/{repo}/pages/builds?per_page=1"
    req = urllib.request.Request(url, headers={
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "cicfa-healthcheck",
    })
    if tok:
        req.add_header("Authorization", "Bearer " + tok)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        body = json.loads(r.read().decode("utf-8"))
        if body and len(body) > 0:
            b = body[0]
            status = b.get("status", "unknown")
            commit = b.get("commit", "")
            duration = b.get("duration", 0)
            created = b.get("created_at", "")
            updated = b.get("updated_at", "")
            error_msg = ""
            if b.get("error"):
                error_msg = b["error"].get("message", "")
            print("\t".join(str(f) for f in ["BUILD", status, commit, duration, created, updated, error_msg]))
        else:
            print("CALL\terror\tno builds found", file=sys.stderr)
except urllib.error.HTTPError as e:
    code = e.code
    print(f"CALL\terror\tHTTP {code}", file=sys.stderr)
except Exception as e:
    print(f"CALL\terror\t{type(e).__name__}", file=sys.stderr)
BUILDCHECK
}
if ! git -C "$REPO_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  skip "not a git repo — nothing to compare the live surface against"
elif [ "$live_up" != 1 ]; then
  skip "live site is down (section 1) — parity is not the failure worth reporting"
else
  if git -C "$REPO_ROOT" rev-parse --verify -q origin/main >/dev/null 2>&1; then
    parity_ref="origin/main"
  else
    parity_ref="HEAD"
    warn "origin/main not available locally — comparing against HEAD instead, which may be ahead of what the venue was given"
  fi
  ref_ct=$(git -C "$REPO_ROOT" log -1 --format=%ct "$parity_ref" 2>/dev/null || echo 0)
  ref_age=$(( $(date +%s) - ref_ct ))
  p_ok=0; p_fm=0; p_404=0; p_bad=0; p_unpushed=0
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    blob=$(tmpf cicfa_blob)
    if ! git -C "$REPO_ROOT" show "$parity_ref:$p" > "$blob" 2>/dev/null; then
      # tracked here but absent from the pushed ref — nothing is live to compare
      p_unpushed=$((p_unpushed+1)); rm -f "$blob"; continue
    fi
    if [ "$(head -1 "$blob")" = "---" ]; then
      p_fm=$((p_fm+1)); rm -f "$blob"; continue
    fi
    lf=$(tmpf cicfa_live)
    # retry404=0 on purpose: an unserved source is a WARN here, and retrying each
    # one would add HTTP_RETRIES x RETRY_SLEEP per file to every pass for a
    # condition this section does not treat as failure anyway.
    lc=$(fetch_page "$LIVE_URL$p" "$lf" 0)
    if [ "$lc" != "200" ]; then
      p_404=$((p_404+1))
      warn "live $p -> ${lc:-<none>}: published source not served — Jekyll disposition, or never deployed"
    elif cmp -s "$blob" "$lf"; then
      p_ok=$((p_ok+1))
    elif [ "$ref_age" -lt "$DEPLOY_GRACE" ]; then
      p_bad=$((p_bad+1))
      # Divergence within grace window: check actual build status instead of inferring from time
      buildcheck=$(check_pages_build 2>/dev/null)
      build_line=$(printf '%s\n' "$buildcheck" | grep '^BUILD' | head -1)
      if [ -n "$build_line" ]; then
        build_status=$(printf '%s' "$build_line" | cut -f2)
        build_duration=$(printf '%s' "$build_line" | cut -f4)
        build_created=$(printf '%s' "$build_line" | cut -f5)
        build_updated=$(printf '%s' "$build_line" | cut -f6)
        error_msg=$(printf '%s' "$build_line" | cut -f7)

        case "$build_status" in
          built)
            warn "live $p differs from $parity_ref, but $parity_ref is already built — divergence is CDN cache lag; re-run before believing it"
            ;;
          building)
            if [ "$build_duration" = "0" ] && [ -n "$build_updated" ]; then
              # duration=0 + stalled updated_at suggests build is stuck (not making progress)
              now=$(date +%s)
              updated_ts=$(python3 -c "from datetime import datetime; d='$build_updated'; print(int(datetime.fromisoformat(d.replace('Z','+00:00')).timestamp()))" 2>/dev/null || echo "0")
              stuck_age=$((now - updated_ts))
              if [ "$stuck_age" -gt 90 ]; then
                red "live $p DIFFERS — Pages build for $parity_ref is STUCK (building ${stuck_age}s with no progress). Remedy: gh api -X POST repos/DEEP-WEB-GALLERY/CICFA/pages/builds"
              else
                warn "live $p differs from $parity_ref — Pages build in progress; re-run before believing it"
              fi
            else
              warn "live $p differs from $parity_ref — Pages build in progress; re-run before believing it"
            fi
            ;;
          errored)
            if [ -n "$error_msg" ]; then
              red "live $p DIFFERS — Pages build FAILED: $error_msg"
            else
              red "live $p DIFFERS — Pages build FAILED (no error details available)"
            fi
            ;;
          *)
            warn "live $p differs from $parity_ref, but that commit is only ${ref_age}s old — Pages build status unknown; re-run before believing it"
            ;;
        esac
      else
        warn "live $p differs from $parity_ref, but that commit is only ${ref_age}s old — Pages build is probably still in flight; re-run before believing it"
      fi
    else
      p_bad=$((p_bad+1))
      red "live $p DIFFERS from $parity_ref (pushed $((ref_age/60))m ago) — the venue is serving bytes this repo did not publish: stale deploy or tampering"
    fi
    rm -f "$blob" "$lf"
  done <<EOF
$published
EOF
  parity_note="$p_fm rendered from front matter, source withheld"
  [ "$p_unpushed" -gt 0 ] && parity_note="$parity_note; $p_unpushed not yet in $parity_ref"
  if [ "$p_bad" = 0 ] && [ "$p_404" = 0 ]; then
    pass "live surface is byte-identical to $parity_ref ($p_ok file(s) compared; $parity_note)"
  else
    warn "parity: $p_ok identical, $p_bad divergent, $p_404 unserved ($parity_note)"
  fi
fi

# ── 11. the second venue: what GitHub publishes itself ───────────────────────
# DEE-42. Sections 8 and 10 both measure one publisher. Section 8 was re-scoped in
# DEE-34 from a file-extension glob to Jekyll's own rule — skip dotted paths, ship
# the rest — and that was right for the venue it measures. It is not the whole
# picture, because Pages is not the only thing publishing this repository.
#
# GitHub publishes it too, through a mechanism Jekyll has nothing to do with:
# every tracked file is readable at raw.githubusercontent.com and rendered at
# /blob/main/, dotted paths included, and .github/ISSUE_TEMPLATE is compiled into
# the program's actual intake UI at /issues/new/choose. Probed anonymously
# 2026-07-26: raw and blob both answer 200 for .github/ISSUE_TEMPLATE/submission.yml
# while Pages correctly 404s that same path, and the chooser 302s to a login —
# not an absence of publication but the opposite, since it is served to everyone
# signed in, which is exactly the population that can submit. So the line section 8
# printed every run, "outside the published surface", was true of one venue and
# false of the other, and the intake form lives on the false side.
#
# What that hid: submission.yml promised the swept pot's ETH four times and
# jury_registration.yml once, none of them edited since 5113c57 (2026-03-19), one
# click from a page that has read FUNDING SUSPENDED since 8a9b87a. We had already
# treated this directory as publication-relevant — 339a5cb edited config.yml in it
# to pull "fund the pot" off the chooser — while the monitor went on calling it
# out-of-surface.
#
# DEE-44 (2026-07-26) struck all five of those promises and made the submitter's
# wallet optional, so this section changed job in the same commit: it no longer
# reports a standing defect, it holds a landed fix. Board ruling, in one line: an
# assertion under a pending board question waits, an inducement to a stranger's
# irreversible act does not. A required ETH address on a public issue form is the
# second thing — it publishes a submitter's on-chain identity permanently, for a
# prize that cannot be paid. index.html's Unlock Condition 05 is the first, and
# stays exactly as it is under DEE-30 q3; nothing here touches it.
#
# Scope: the dotted tracked paths, the set section 8 skips. GitHub serves the other
# 23 at raw/blob as well, but section 8 already checks those bytes and section 10
# checks the Pages copy; this is the set nobody was looking at. Section 6 asserts
# the two forms exist and answer 200 — this asks what they say, and whether the
# venue serves what we pushed.
#
# Severity is graded by the direction money moves, and the grading is the point:
#
#   red   money IN. The compromised address published here without the notice, or
#         the chooser inviting contributions again. Same rule as section 8, because
#         the harm is the same: a reader who can send funds to a thief.
#   red   money OUT, promised again. Two-sided exactly like section 8's page rule:
#         no form may promise a payout from the swept pot, AND each must say the
#         funding is suspended. DEE-44 removed the promises; a promise reappearing
#         is that repair coming undone, not a fresh policy choice.
#   warn  drift off the pin in either direction — a wallet field going back to
#         required, a form dropping out of the set. Both mean the record is stale;
#         neither is an emergency, and the submitter field returning to required is
#         legitimately the board's to decide (DEE-30 rotation / make_good).
#   red   the venue serving bytes we never pushed, past a cache grace. Section 10's
#         rule, applied to the publisher section 10 does not reach.
#
# All HTTP here is github.com and raw.githubusercontent.com, both reachable from a
# cloud IP, so unlike the section-4 RPC probe CI covers this section too.
sec "11. second venue: the GitHub-published set (DEE-42)"

# Recorded 2026-07-26 from the files as they stand — updated in the DEE-44 commit
# that changed them, per the standing rule below. Not a target and not an approval:
# a receipt, so that a change to this surface has to be seen.
# Fields: <path> <payout-promise lines> <wallet field required, or ->.
# submission.yml 0 false — DEE-44 struck four promises and made the wallet optional.
# jury_registration.yml 0 true — one promise struck; the juror wallet STAYS required
# because the wallet is the vote (EIP-191, docs/jury_protocol.md:12/18). What was
# missing there was disclosure, not optionality, and the form now states it before
# the field. If the board answers DEE-30 and these forms are edited again, update
# this pin in the same commit; a stale pin turns the drift warning into noise, which
# is how a check dies.
PAYOUT_PIN=".github/ISSUE_TEMPLATE/submission.yml 0 false
.github/ISSUE_TEMPLATE/jury_registration.yml 0 true"

# Literal promises to pay out of the pot. Section 8's solicitation patterns are
# deliberately kept off prose because a quotation and an invitation look alike in
# English; these are safe over this set because nothing dotted documents the
# phrases the way CLAUDE.md documents the invitation, and because they are counted
# by distinct LINE — two patterns matching one sentence stay one promise.
payout_patterns="receive the ETH prize pool
ETH bounty pool transfers
receive the prize
ETH bounty transfers"
CHOOSER_NOTICE="Funding is suspended"

promise_lines() {   # line numbers in $1 that promise a payout from the pot
  local f="$1" p
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    grep -Fn "$p" "$f" 2>/dev/null | cut -d: -f1
  done <<EOF
$payout_patterns
EOF
  return 0
}

# The `required:` under the `id: wallet` input — the field, not the sentence beside
# it. A form that makes an ETH address mandatory to collect a prize that cannot be
# paid is the thing worth watching, and in a YAML form that is syntax, not prose:
# assert on the field. Echoes nothing when the form has no wallet input.
wallet_required() {
  awk '
    /^[[:space:]]*-[[:space:]]*type:/                 { inb = 0 }
    /^[[:space:]]*id:[[:space:]]*wallet[[:space:]]*$/ { inb = 1; next }
    inb && /^[[:space:]]*required:/ { sub(/.*required:[[:space:]]*/, ""); print; exit }
  ' "$1"
}

if [ -z "${dotted:-}" ]; then
  skip "no dotted tracked paths — both venues publish the same set"
else
  if git -C "$REPO_ROOT" rev-parse --verify -q origin/main >/dev/null 2>&1; then
    gh_ref="origin/main"
  else
    gh_ref="HEAD"
    warn "origin/main not available locally — comparing raw against HEAD, which may be ahead of what GitHub was given"
  fi
  gh_ct=$(git -C "$REPO_ROOT" log -1 --format=%ct "$gh_ref" 2>/dev/null || echo 0)
  gh_age=$(( $(date +%s) - gh_ct ))
  gh_n=0; gh_ok=0; gh_bad=0; gh_miss=0; gh_unpushed=0
  srv_n=0; srv_bad=0
  surface=""
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    pf="$REPO_ROOT/$p"
    [ -f "$pf" ] || continue
    gh_n=$((gh_n+1))

    # money in — section 8's document rule, at the venue that actually serves it
    if [ -n "$wallet" ] && grep -Fqi "$wallet" "$pf" && ! grep -Fq "$POT_NOTICE" "$pf"; then
      red "repo $p: publishes the compromised pot address with no suspension notice (GitHub serves this file at raw and blob)"
    fi

    # money out — census, compared against the pin below
    pn=$(promise_lines "$pf" | sort -un | grep -c '^[0-9]' || true)
    wreq=$(wallet_required "$pf"); [ -n "$wreq" ] || wreq="-"
    if [ "$pn" -gt 0 ] || [ "$wreq" != "-" ]; then
      surface="$surface$p $pn $wreq
"
    fi

    # venue parity — raw serves main straight from git, so a divergence is either
    # its CDN cache lagging a push (hence the same grace section 10 uses) or bytes
    # we never published.
    blob=$(tmpf cicfa_ghblob)
    if ! git -C "$REPO_ROOT" show "$gh_ref:$p" > "$blob" 2>/dev/null; then
      gh_unpushed=$((gh_unpushed+1)); rm -f "$blob"; continue
    fi
    rf=$(tmpf cicfa_ghraw)
    rc=$(fetch_page "$RAW_BASE/$p" "$rf" 1)

    # DEE-45. What the venue SERVES, read as content rather than as a status line.
    # Every other assertion in this section runs on the working-tree copy and is
    # joined to the served copy only by the byte-parity test below — a chain that
    # holds while working tree, origin/main and raw are all the same bytes. Section
    # 2 asserts that separately, which means the money rules were being proved about
    # a file nobody serves, on the assumption that the interesting case never
    # happens. The window where that assumption is false is the window this monitor
    # exists for. So the same rules are asserted here, on the bytes a submitter
    # actually reads, and they stand up whether or not parity holds.
    if [ "$rc" = "200" ]; then
      srv_n=$((srv_n+1))
      if [ -n "$wallet" ] && grep -Fqi "$wallet" "$rf" && ! grep -Fq "$POT_NOTICE" "$rf"; then
        srv_bad=$((srv_bad+1))
        red "raw $p: THE SERVED COPY publishes the compromised pot address with no suspension notice"
      fi
      sp_n=$(promise_lines "$rf" | sort -un | grep -c '^[0-9]' || true)
      if [ "$sp_n" -gt 0 ]; then
        srv_bad=$((srv_bad+1))
        red "raw $p: THE SERVED COPY promises a payout from the swept pot ($sp_n line(s)) — whatever the repo copy says, this is the text a submitter is answering"
      fi
      # Pinned forms only: the two-sided rule, served side. Same grading as the repo
      # half above — a missing disclosure is red, drift off the pin is a warn.
      want_s=$(echo "$PAYOUT_PIN" | grep -F "$p " | head -1)
      if [ -n "$want_s" ]; then
        ws=${want_s#* }; ws=${ws#* }
        sw_r=$(wallet_required "$rf"); [ -n "$sw_r" ] || sw_r="-"
        if ! grep -Fq "$CHOOSER_NOTICE" "$rf"; then
          srv_bad=$((srv_bad+1))
          red "raw $p: THE SERVED COPY does not state that funding is suspended — the disclosure holds in the repo and not at the venue"
        fi
        [ "$sw_r" = "$ws" ] || warn "raw $p: THE SERVED COPY has wallet required=$sw_r, pinned $ws — the venue is handing out a different form than the pin describes"
      fi
    fi

    if [ "$rc" != "200" ]; then
      gh_miss=$((gh_miss+1))
      warn "raw $p -> ${rc:-<none>}: GitHub is not serving a file it holds — rate limit, or the venue changed"
    elif cmp -s "$blob" "$rf"; then
      gh_ok=$((gh_ok+1))
    elif [ "$gh_age" -lt "$DEPLOY_GRACE" ]; then
      gh_bad=$((gh_bad+1))
      warn "raw $p differs from $gh_ref, but that commit is only ${gh_age}s old — raw's cache lags a push; re-run before believing it"
    else
      gh_bad=$((gh_bad+1))
      red "raw $p DIFFERS from $gh_ref (pushed $((gh_age/60))m ago) — GitHub is serving bytes this repo did not publish"
    fi
    rm -f "$blob" "$rf"
  done <<EOF
$dotted
EOF

  if [ "$gh_bad" = 0 ] && [ "$gh_miss" = 0 ]; then
    pass "GitHub venue parity: $gh_ok of $gh_n dotted file(s) byte-identical to $gh_ref at raw"
  else
    warn "GitHub venue parity: $gh_ok identical, $gh_bad divergent, $gh_miss unserved, of $gh_n"
  fi
  [ "$gh_unpushed" -gt 0 ] && skip "$gh_unpushed dotted file(s) not yet in $gh_ref — nothing published to compare"

  # One line for the served-copy rules, and a WARN rather than silence when none of
  # them could run: an invariant that could not be evaluated is not an invariant
  # that held. Same escalation as section 8's live-page branch (ae5ef98).
  if [ "$srv_n" = 0 ]; then
    warn "served-copy content: nothing could be read from raw this pass — what the venue is actually handing out is unverified"
  elif [ "$srv_bad" = 0 ]; then
    pass "served-copy content: $srv_n file(s) read from raw — no pot address without the notice, no payout promised, forms match the pin"
  fi

  # the payout surface against the pin, both directions
  drift=0; tot_p=0; tot_w=0; forms=0
  while IFS= read -r s; do
    [ -n "$s" ] || continue
    sp=${s%% *}; rest=${s#* }; sn=${rest%% *}; sw=${rest#* }
    forms=$((forms+1)); tot_p=$((tot_p+sn)); [ "$sw" = "true" ] && tot_w=$((tot_w+1))
    want=$(echo "$PAYOUT_PIN" | grep -F "$sp " | head -1)
    if [ -z "$want" ]; then
      drift=1
      warn "payout surface: $sp is NOT in the pin — something newly promises the pot or collects an address ($sn promise line(s), wallet required=$sw)"
    else
      wrest=${want#* }; wn=${wrest%% *}; ww=${wrest#* }
      if [ "$sn" != "$wn" ] || [ "$sw" != "$ww" ]; then
        drift=1
        warn "payout surface DRIFT in $sp: promise lines $wn -> $sn, wallet required $ww -> $sw. If the board answered DEE-30 q3, update PAYOUT_PIN in this section"
      fi
    fi
  done <<EOF
$surface
EOF
  while IFS= read -r w; do
    [ -n "$w" ] || continue
    wp=${w%% *}
    echo "$surface" | grep -Fq "$wp " || {
      drift=1
      warn "payout surface: pinned form $wp no longer promises the pot, or is gone — confirm that was the board's call, then update PAYOUT_PIN"
    }
  done <<EOF
$PAYOUT_PIN
EOF
  [ "$drift" = 0 ] && pass "payout surface matches the pin: nothing newly promised, nothing quietly withdrawn"

  # Two-sided, like section 8's page rule and for the same reason: the promise has
  # to be absent AND the suspension has to be said out loud. Before DEE-44 this half
  # was a standing warning about a defect the board was holding; now it is the
  # interlock that holds the repair, in the section-9 shape.
  if [ "$tot_p" = 0 ]; then
    pass "intake forms: no payout promised from the swept pot"
  else
    red "intake forms: A PAYOUT PROMISE IS BACK ($tot_p line(s)) — the pot was swept 2026-07-10 and cannot pay; DEE-44 removed these:"
    show "$(while IFS= read -r s; do [ -n "$s" ] || continue; sp=${s%% *}; rest=${s#* }; sn=${rest%% *}
      [ "$sn" = 0 ] || printf '%s: line(s) %s\n' "$sp" "$(promise_lines "$REPO_ROOT/$sp" | sort -un | tr '\n' ' ')"
    done <<INNER
$surface
INNER
)"
  fi

  # The other side: each pinned form must still state the suspension itself. A form
  # that merely stops promising, without saying why, reads as an oversight to the
  # next editor and gets "helpfully" restored.
  while IFS= read -r w; do
    [ -n "$w" ] || continue
    wp=${w%% *}; wf="$REPO_ROOT/$wp"
    [ -f "$wf" ] || continue
    if grep -Fq "$CHOOSER_NOTICE" "$wf"; then
      pass "${wp##*/}: states that funding is suspended"
    else
      red "${wp##*/}: the funding-suspension statement is GONE — DEE-44 undone; the form implies a payout that cannot happen"
    fi
  done <<EOF
$PAYOUT_PIN
EOF

  # Said out loud every run, on purpose, and smaller than it was. This is the one
  # line in the pass that is not a defect report: it is the shape of what the board
  # is still holding. The promises are gone; the address collection is not, because
  # a juror's wallet IS their vote and the submitter's field is DEE-30 business.
  if [ "$tot_w" -gt 0 ]; then
    warn "STANDING, board-held: $tot_w of $forms GitHub-published form(s) still require an ETH address (juror seats are wallet-bound, EIP-191 — the wallet is the vote). Whether the submitter field returns to required is DEE-30 rotation/make_good, and index.html's Unlock Condition 05 stays put under DEE-30 q3. Monitor, do not fix here."
  fi

  # The chooser. Two-sided, exactly like section 8's page rule: no invitation to
  # fund, and the suspension said out loud. Scoped to the strings config.yml
  # actually publishes — the contact-link name/url/about values — and NOT to the
  # whole file, because the file documents the phrase 339a5cb removed from it and a
  # whole-file grep would red-FAIL on that documentation forever. DEE-34's trap in a
  # new costume, and the same escape: assert on the field, not the text around it.
  cfg="$REPO_ROOT/.github/ISSUE_TEMPLATE/config.yml"
  if [ ! -f "$cfg" ]; then
    skip "no issue-chooser config.yml in this repo"
  else
    ct=$(tmpf cicfa_chooser)
    grep -E '^[[:space:]]*(-[[:space:]]*)?(name|about|url):' "$cfg" | sed 's/^[^:]*://' > "$ct"
    chits=$(solicit_hits "$ct")
    grep -Fqi "fund the pot" "$ct" && chits=$(printf '%s\n%s' "$chits" "the chooser blurb invites funding the pot")
    [ -n "$wallet" ] && grep -Fqi "$wallet" "$ct" && chits=$(printf '%s\n%s' "$chits" "the chooser blurb publishes the compromised address")
    if [ -n "$(echo "$chits" | grep -v '^$')" ]; then
      red "issue chooser: FUNDING SOLICITATION is published at $CHOOSER_URL:"; show "$chits"
    else
      pass "issue chooser: no funding solicitation in the published blurbs"
    fi
    if grep -Fq "$CHOOSER_NOTICE" "$ct"; then
      pass "issue chooser: the blurb still says funding is suspended"
    else
      red "issue chooser: the suspension notice is GONE from the published blurb — 339a5cb undone"
    fi
    rm -f "$ct"
  fi

  # And the rendered form itself. Anonymous requests are redirected to a login, so
  # its content cannot be read from here; that is reported as what it is rather than
  # as an unreachable surface, because the redirect is how the venue tells us the
  # form is live for signed-in readers.
  ccode=$(curl -s -o /dev/null -m "$CURL_MAX" -w '%{http_code}' "$CHOOSER_URL" 2>/dev/null)
  case "$ccode" in
    301|302) skip "chooser -> $ccode login redirect: rendered for signed-in visitors only, so it is checked above from the YAML that produces it" ;;
    200)     pass "chooser -> 200 at $CHOOSER_URL" ;;
    404)     red  "chooser -> 404: the intake form the live page links to is gone" ;;
    *)       warn "chooser -> ${ccode:-<none>}: could not confirm the intake form is still published" ;;
  esac

  # No silent caps, same rule as section 8.
  skip "not checked here: the 23 non-dotted files GitHub also serves at raw/blob — section 8 checks that content and section 10 checks the Pages copy"
fi

# ── 12. the fork network ─────────────────────────────────────────────────────
# Sections 8, 10 and 11 ask what WE publish, at two venues we control. This asks
# the question none of them can: who else can publish this repository, and have
# they started?
#
# A GitHub fork shares objects with its parent in both directions. `mnrrxyz/CICFA`
# was forked 2026-03-19 off 5113c572 — four months before the sweep — so its `main`
# is the pre-suspension page: the invitation, the click-to-copy, the payment QR,
# the compromised address. Today that content is only *readable* (raw and blob
# answer 200, as they do for any public repo) and nothing renders it: the fork has
# no Pages site and `/repos/{fork}/pages` 404s.
#
# The single setting between that and a live solicitation venue is `has_pages`,
# and it belongs to someone else. If any fork ever switches Pages on, a rendered,
# working donation page for a wallet whose key a thief holds goes live at a URL we
# do not own, cannot edit and cannot take down. That is not a hypothetical failure
# mode of this repo — it is the exact page we spent 8a9b87a removing, republished
# by a third party, and no other check in this script would notice.
#
# The instrument is the fork LIST, fetched at run time, never a hard-coded name:
# a fork created tomorrow has to be a new measurement, not an exception someone
# remembered to add. The traversal follows forks-of-forks too, because a fork of
# the fork is the same exposure one hop further out.
#
# Grading, and the two rules it exists to honour:
#
#   red   any fork with Pages enabled. One switch, one live venue.
#   warn  the API refusing or failing. Unauthenticated GitHub is 60 requests an
#         hour per IP and this runs in CI and locally, so being rate-limited is
#         expected occasionally — and a check that did not run must never print
#         PASS. That is the mktemp defect (a green hiding an unrun check) and the
#         org-scale version of SELF-004; set HEALTHCHECK_GH_TOKEN (or GITHUB_TOKEN)
#         to lift the limit rather than letting the WARN become wallpaper.
#   warn  the network changing shape — a fork appearing or disappearing. Printing
#         the count every run is the same discipline as section 8 printing what it
#         enumerates: a number nobody states is a number nobody notices moving.
#
# Deliberately NOT here, and each omission is load-bearing:
#   - The fork's own bytes. They serve the March page and always will; git objects
#     are shared and a third party's repository is not ours to edit. A check whose
#     failure is permanent by design is worse than no check — a standing red trains
#     the reader to skim red, which is the same defect as a green that hides an
#     unrun check. Same reason this script greps no history: history is append-only.
#   - Any contact with the fork. No clone-push, no issue, no PR. Read-only, from
#     the public API, exactly as any visitor could.
sec "12. fork network: no fork publishes this repo as a venue (DEE-50)"

FORK_ROOT="DEEP-WEB-GALLERY/CICFA"
# A receipt, not the instrument — the assertion above runs over what the API
# returns, and this list is never consulted to decide what to check. Enumerated at
# source 2026-07-26: one fork, created 2026-03-19T10:03:33Z off 5113c572,
# has_pages false, zero forks of its own. Same standing rule as PAYOUT_PIN: when
# the network legitimately changes, update this in the same commit, because a
# stale pin turns the drift warning into noise and that is how a check dies.
FORK_PIN="mnrrxyz/CICFA"
FORK_API_MAX_CALLS=12   # bound the traversal: anonymous GitHub is 60 req/h/IP

if ! command -v python3 >/dev/null 2>&1; then
  warn "python3 unavailable — the fork network was NOT enumerated. An unrun check is not a pass."
else
  ft=$(tmpf cicfa_forks)
  python3 - "$FORK_ROOT" "$FORK_API_MAX_CALLS" "$CURL_MAX" >"$ft" 2>/dev/null <<'PY'
import json, os, sys, urllib.error, urllib.request

root, max_calls, timeout = sys.argv[1], int(sys.argv[2]), float(sys.argv[3])
# Optional, and only ever used to raise the anonymous rate limit. Everything read
# here is public; the check is correct without a token, just more likely to WARN.
tok = os.environ.get("HEALTHCHECK_GH_TOKEN") or os.environ.get("GITHUB_TOKEN") or ""

calls = 0
remaining = "?"

def emit(*fields):
    print("\t".join(str(f) for f in fields))

def get(url):
    global calls, remaining
    calls += 1
    req = urllib.request.Request(url, headers={
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "cicfa-healthcheck",
    })
    if tok:
        req.add_header("Authorization", "Bearer " + tok)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            remaining = r.headers.get("x-ratelimit-remaining", "?")
            emit("CALL", "ok", url, remaining)
            return json.loads(r.read().decode("utf-8")), (r.headers.get("Link") or "")
    except urllib.error.HTTPError as e:
        h = e.headers or {}
        remaining = h.get("x-ratelimit-remaining", "?")
        if e.code in (403, 429) and remaining == "0":
            why = "rate-limited (%s req/h for this IP)" % h.get("x-ratelimit-limit", "?")
        else:
            why = "HTTP %d" % e.code
        emit("CALL", why, url, remaining)
    except Exception as e:
        emit("CALL", "unreachable (%s)" % type(e).__name__, url, remaining)
    return None, ""

def next_page(link):
    for part in link.split(","):
        bits = part.split(";")
        if len(bits) >= 2 and 'rel="next"' in bits[1] and bits[0].strip().startswith("<"):
            return bits[0].strip()[1:-1]
    return ""

queue = [(root, 0)]
seen = {root.lower()}
unvisited = 0

while queue:
    repo, depth = queue.pop(0)
    url = "https://api.github.com/repos/%s/forks?per_page=100" % repo
    while url:
        if calls >= max_calls:
            unvisited += 1
            break
        body, link = get(url)
        if body is None:
            break
        for f in body:
            name = f.get("full_name") or "?"
            hp = f.get("has_pages")
            state = "true" if hp is True else ("false" if hp is False else "unknown")
            kids = f.get("forks_count")
            emit("FORK", name, state, depth + 1, "?" if kids is None else kids)
            if name.lower() not in seen:
                seen.add(name.lower())
                if kids:
                    queue.append((name, depth + 1))
        url = next_page(link)

emit("RATE", remaining, calls)
if unvisited:
    emit("TRUNC", unvisited)
PY

  ok_calls=$(awk -F'\t' '$1=="CALL" && $2=="ok"' "$ft" | grep -c . || true)
  bad_calls=$(awk -F'\t' '$1=="CALL" && $2!="ok"{print $2" <- "$3}' "$ft")
  forks=$(awk -F'\t' '$1=="FORK"{print $2"\t"$3"\t"$4"\t"$5}' "$ft")
  nforks=$(printf '%s\n' "$forks" | grep -c . || true)
  budget=$(awk -F'\t' '$1=="RATE"{print $2}' "$ft"); budget=${budget:-?}
  trunc=$(awk -F'\t' '$1=="TRUNC"{print $2}' "$ft")

  # Anything short of a clean answer is unverified, and says so before the verdict
  # below, so a partial enumeration can never be read as a clean one.
  if [ -n "$bad_calls" ]; then
    warn "the GitHub API did not answer $(printf '%s\n' "$bad_calls" | grep -c .) call(s) — this check is UNVERIFIED, not clean. Set HEALTHCHECK_GH_TOKEN (or GITHUB_TOKEN in CI) to lift the 60/h anonymous limit:"
    show "$bad_calls"
  fi
  [ -n "$trunc" ] && warn "traversal stopped at FORK_API_MAX_CALLS=$FORK_API_MAX_CALLS with $trunc repo(s) unvisited — their forks were NOT checked. Raise the cap or supply a token; do not read this pass as covering the whole network."

  if [ "$ok_calls" -eq 0 ]; then
    warn "fork network NOT enumerated — no API call succeeded, so nothing here says the forks are clean. Re-run when the limit resets."
  else
    pages_on=$(printf '%s\n' "$forks"  | awk -F'\t' '$2=="true"{print $1}')
    pages_unk=$(printf '%s\n' "$forks" | awk -F'\t' '$1!="" && $2!="true" && $2!="false"{print $1}')
    if [ -n "$pages_on" ]; then
      red "A FORK HAS GITHUB PAGES ENABLED — its main predates the suspension, so this is a live page soliciting ETH to the compromised wallet at a URL we do not own and cannot take down:"
      show "$(printf '%s\n' "$pages_on" | while IFS= read -r fn; do
        [ -n "$fn" ] || continue
        printf '%s -> https://%s.github.io/%s/\n' "$fn" "${fn%%/*}" "${fn#*/}"
      done)"
    else
      [ -n "$pages_unk" ] && warn "has_pages not reported for: $(printf '%s\n' "$pages_unk" | tr '\n' ' ')— unverified, not clean"
      nknown=$(printf '%s\n' "$forks" | awk -F'\t' '$2=="false"' | grep -c . || true)
      # A PASS is only printed for what was actually confirmed. "0 of 1 confirmed"
      # is not a pass in any useful sense; where nothing was readable the WARN
      # above stands alone, because that is what an unrun check looks like.
      if [ "$nforks" -eq 0 ]; then
        pass "the fork network is empty (API budget left: $budget) — nobody else publishes this repo"
      elif [ "$nknown" -gt 0 ]; then
        pass "$nknown of $nforks fork(s) in the network confirmed has_pages=false (API budget left: $budget)"
      fi
    fi

    # The count is printed above whatever it is; this says whether it MOVED. Both
    # directions matter: a new fork is a new repo that can flip the switch, and a
    # pinned fork vanishing means the receipt above no longer describes reality.
    pinf=$(tmpf cicfa_forkpin); livef=$(tmpf cicfa_forklive)
    printf '%s\n' "$FORK_PIN" | grep -v '^$' | sort > "$pinf"
    printf '%s\n' "$forks" | awk -F'\t' '$1!=""{print $1}' | sort > "$livef"
    newf=$(comm -13 "$pinf" "$livef"); gonef=$(comm -23 "$pinf" "$livef")
    if [ -z "$newf" ] && [ -z "$gonef" ]; then
      pass "fork network unchanged from the pin ($(grep -c . "$pinf") fork(s))"
    else
      [ -n "$newf" ]  && warn "NEW FORK(S) since the pin — each one is a repository that can enable Pages at any time; if this is the new normal, update FORK_PIN in the same commit: $(printf '%s' "$newf" | tr '\n' ' ')"
      [ -n "$gonef" ] && warn "pinned fork(s) no longer in the network (deleted or made private) — update FORK_PIN: $(printf '%s' "$gonef" | tr '\n' ' ')"
    fi
    rm -f "$pinf" "$livef"
  fi

  # No silent caps, same rule as sections 8 and 11.
  skip "not checked here: a fork's own raw/blob bytes. They serve the pre-suspension page and always will — shared git objects, someone else's repository. What can change is whether anything RENDERS them, which is the assertion above"
  rm -f "$ft"
fi

# ── verdict ──────────────────────────────────────────────────────────────────
sec "verdict"
if [ "$fail" -eq 0 ]; then echo "  ✅ ALL GREEN"; exit 0
else echo "  ❌ one or more hard checks failed"; exit 1; fi
