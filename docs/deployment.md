# Deployment

How the live site at `https://deep-web-gallery.github.io/CICFA/` actually gets served.

---

## TL;DR

Direct commits to `main` go live. No GitHub Actions involved. ~1–2 min propagation.

---

## Mechanism

GitHub Pages, **build_type: legacy** ("deploy from branch"), source = `main` / root path.

Confirmed via API:

```
gh api repos/DEEP-WEB-GALLERY/CICFA/pages
# → "status": "built", "build_type": "legacy",
#   "source": { "branch": "main", "path": "/" }
```

What this means concretely:
- Anything at the repo root on `main` is served at the site root.
- `index.html` → `https://deep-web-gallery.github.io/CICFA/`
- `programs/console_vB01/index.html` → `https://deep-web-gallery.github.io/CICFA/programs/console_vB01/`
- Pushing a commit triggers GitHub Pages to rebuild. No workflow file exists. Don't add one unless we explicitly move to Actions-based deploy.

---

## Edit-and-publish

The fastest path for a copy or HTML change:

```bash
# from /Users/boris/Documents/DWG/CICFA/CICFA_PUBLIC
# 1. edit index.html (or whichever file)
# 2.
git add index.html
git commit -m "<scope>: <what changed>"
git push origin main
# 3. wait ~1-2 minutes
# 4. open https://deep-web-gallery.github.io/CICFA/ in an incognito tab
#    (cache-bust important — old version often lingers in the regular tab)
```

For structural changes coming from the AUTORUN generator pipeline, see `tools/README.md`.

---

## Verifying after a deploy

After a push, before declaring it done:

1. Open `https://deep-web-gallery.github.io/CICFA/` in an incognito / cache-cleared session.
2. View source — confirm the change is in the served HTML, not just your local copy.
3. If the change touches the countdown or wallet balance: wait for the JSON-RPC call to complete (~3–5s), confirm the on-chain data renders.
4. If the change touches a subpath (e.g. `programs/console_vB01/`): hit the subpath directly.

If the new version isn't showing after 5 minutes:
- Check `gh api repos/DEEP-WEB-GALLERY/CICFA/pages` — `status` should be `"built"`. `"queued"` or `"building"` means wait more.
- Check Actions tab on github.com — even without a workflow file, the Pages build itself logs there as "pages build and deployment."
- Hard refresh / different browser / different network.

---

## Common landmines

| Pitfall | Why it bites | What to do |
|---|---|---|
| Editing `index.html` on a feature branch | Pages only serves `main`. Branch changes are invisible. | Merge to `main` or push direct to `main`. |
| Breaking the JSON-RPC URL for `eth_getBalance` | Bounty pool shows `···` permanently | `CICFA.rpcUrls` holds a fallback list (publicnode / drpc / blastapi / blxrbdn). Test each with a `curl` `eth_getBalance` POST; drop dead ones. Don't re-add `cloudflare-eth.com` (public gateway retired, `-32603`) or `1rpc.io` (rate-limited from shared IPs, `-32005` — DEE-23). Easiest check: run `scripts/healthcheck.sh` (see Health monitoring below), which probes every configured RPC for balance + CORS from the live origin. |
| Hardcoding `localhost:8000` in a deployed file | Site loads but JS fails | Search/replace before commit. |
| Renaming `index.html` to `index.htm` or similar | Pages won't serve it | The file at the served path must literally be named `index.html`. |
| Putting deploy assets in `gh-pages` branch | This repo deploys from `main`. `gh-pages` is ignored. | Use `main`. |
| Removing `index.html` to "clean up" | The whole site 404s | Don't. |
| Assuming `index.html` is the only page we publish | Pages serves the **whole repo** — `programs/console_vB01/index.html` is live too. A check scoped to `index.html` silently ignores it. | `healthcheck.sh` §8 globs every tracked `.html`. Keep it a glob; never re-scope a published-surface check to one filename. |
| `mktemp -t prefix` in a script CI will run | BSD-only. GNU coreutils needs trailing `X`s, so on a Linux runner mktemp fails, the caller gets an **empty path**, and whatever consumed it degrades to a warning. This kept §8's live check from running in CI for its entire life while every run still printed ✅ ALL GREEN. | Use the `tmpf` helper (full path + `XXXXXX`). More generally: when a check can't verify, decide whether that is really "unknown" or actually "broken" — §8 now FAILs if §1 already proved the site is up. |

---

## Health monitoring

Two layers, by design — one catches browser-only failures, the other runs unattended.

**`scripts/healthcheck.sh` — the local maintenance pass (residential IP).**
Reproduces the manual checklist that has caught every past regression (DEE-14 dead
`cloudflare-eth`, DEE-23 rate-limited `1rpc.io`): live site 200, repo in sync, inline
JS parses, **every configured RPC returns the balance AND is CORS-usable from the live
origin and they all agree**, external scripts reachable (SKIPped while the page ships
none — it dropped the QR CDN with the payment QR), issue templates present in repo +
live, every `target="_blank"` carries `rel="noopener"`. Config is parsed straight out of
`index.html`, so the check can't drift from what the page ships. Exit 0 = all green,
1 = a hard check failed. Transient blips (curl 000 / 5xx / 429) are retried before they
count, so a one-shot network hiccup can't false-FAIL. Run it each maintenance pass:

```bash
scripts/healthcheck.sh          # full pass — the RPC/CORS probe only works from a residential IP
```

**Sections 8 and 9 are the DEE-30 regression detectors — read them before touching the
funding copy or the generator.** The bounty pool's private key is compromised and the
wallet was swept 2026-07-10, so the page must never invite anyone to send ETH to it
again. §8 is two-sided against `index.html` *and* the live page: the solicitation must
stay absent **and** the disclosure must stay present (silently dropping the warning is
the same failure as re-adding the ask). **`index.html` is not the only page we publish** —
Pages serves the whole repo, so `programs/console_vB01/index.html` is live too. §8 globs
every tracked `.html` and applies the no-solicitation rule to each, repo copy and live
copy, plus a narrower disclosure rule for sub-pages: a page may not publish the
compromised address without the suspension notice. Add a page and it is covered the day
it lands; do not re-scope the check to a single file. §9 checks one layer upstream — that the
interlocks stopping the page from being *regenerated* into a solicitation are still
armed: `DWG_AUTORUN_BETA`'s `generate_bounty_site.py` refuses on its `FUNDING_SUSPENDED`
flag while its March template still solicits, and `deploy_to_gh_pages.py` refuses on the
artifact's **content** (so a genuinely fixed artifact still ships). §9 also asserts the
deploy gate still covers every marker §8 tests for, so the two can't drift apart. §8 uses
plain string tests, so **CI covers it**; §9 needs the AUTORUN pack checked out and cleanly
SKIPs where it isn't (override the path with `HEALTHCHECK_AUTORUN_ROOT`). Neither section
ever *executes* the generator or deploy script: if an interlock had been removed, running
the deploy to find out would publish the invitation.

**`.github/workflows/healthcheck.yml` — the scheduled monitor (cloud IP).**
Runs the same script daily on a 06:17 UTC cron (GitHub queues scheduled jobs when
runners free up — observed start is consistently ~08:40 UTC, so a run "missing" at
06:20 is normal, not a failure) and on-demand via *Run workflow*, with
`HEALTHCHECK_SKIP_RPC=1`. The RPC probe is deliberately skipped in CI: free public
RPCs block datacenter egress, so from a runner all four return non-JSON challenge bodies
that read as a total outage — a false FAIL, and a cloud-IP curl isn't a faithful *browser*
drift signal anyway. So the Action covers the cloud-IP-valid signals (site 200, JS,
CDN, templates, anchors) and a red run is a genuine outage → failed-run notification.
**RPC/CORS drift is only caught by the local pass** — run `healthcheck.sh` (env unset)
each heartbeat. Note: GitHub disables scheduled workflows after 60 days of repo
inactivity; if runs stop appearing, re-enable on the Actions tab or push a commit.

**Where passes are logged.** The audit trail for local passes lives *outside this
repo*, in the operations workspace (`DWG_AI/agents/lead-curator/ops-maintenance-log.md`,
one row per pass) — deliberately single-homed there, so don't start a second ledger
under `docs/`. Read the existing rows before running a pass: they tell you what
"normal" looked like yesterday, so a changed balance or a new WARN reads as drift
rather than noise, and they show whether a pass is even owed today.

---

## Custom domain

Currently none. `cname` field in the Pages API response is `null`. If a custom domain (e.g. `cicfa.art`) is added in the future:

1. Add `CNAME` file at repo root with the domain string
2. Configure DNS at the registrar (CNAME → `deep-web-gallery.github.io.`)
3. Enable HTTPS in repo Pages settings once GitHub provisions the cert

Don't add the `CNAME` file before DNS is configured — Pages will serve the live site on the wrong domain in the interim.

---

## What can deploy here

Anything that fits the Pages constraints:
- Static HTML / CSS / JS — yes
- Client-side fetches to public APIs (RPC, etc.) — yes
- Server-side code — no (it's static hosting; nothing runs server-side)
- Jekyll builds — possible but unused; don't add `_config.yml` without intent
- Large binaries — possible but not advised; git LFS isn't configured here

---

## Who can push

`main` is push-able by collaborators on the `DEEP-WEB-GALLERY/CICFA` repo. There is no branch protection currently. Treat `main` as production:

- Test locally before pushing
- Don't push half-finished work
- If you must experiment on the deployed surface, use `programs/<scratchpad>/` so the live `index.html` stays intact
