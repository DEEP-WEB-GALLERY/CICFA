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

---

## Health monitoring

Two layers, by design — one catches browser-only failures, the other runs unattended.

**`scripts/healthcheck.sh` — the local maintenance pass (residential IP).**
Reproduces the manual checklist that has caught every past regression (DEE-14 dead
`cloudflare-eth`, DEE-23 rate-limited `1rpc.io`): live site 200, repo in sync, inline
JS parses, **every configured RPC returns the balance AND is CORS-usable from the live
origin and they all agree**, QR CDN reachable, issue templates present in repo + live,
every `target="_blank"` carries `rel="noopener"`. Config is parsed straight out of
`index.html`, so the check can't drift from what the page ships. Exit 0 = all green,
1 = a hard check failed. Transient blips (curl 000 / 5xx / 429) are retried before they
count, so a one-shot network hiccup can't false-FAIL. Run it each maintenance pass:

```bash
scripts/healthcheck.sh          # full pass — the RPC/CORS probe only works from a residential IP
```

**`.github/workflows/healthcheck.yml` — the scheduled monitor (cloud IP).**
Runs the same script daily at 06:17 UTC (and on-demand via *Run workflow*) with
`HEALTHCHECK_SKIP_RPC=1`. The RPC probe is deliberately skipped in CI: free public
RPCs block datacenter egress, so from a runner all four return non-JSON challenge bodies
that read as a total outage — a false FAIL, and a cloud-IP curl isn't a faithful *browser*
drift signal anyway. So the Action covers the cloud-IP-valid signals (site 200, JS,
CDN, templates, anchors) and a red run is a genuine outage → failed-run notification.
**RPC/CORS drift is only caught by the local pass** — run `healthcheck.sh` (env unset)
each heartbeat. Note: GitHub disables scheduled workflows after 60 days of repo
inactivity; if runs stop appearing, re-enable on the Actions tab or push a commit.

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
