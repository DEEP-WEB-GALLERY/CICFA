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
| Assuming the *pages* are the published surface | There is no `.nojekyll` and no `_config.yml`, so Pages builds this repo with **default Jekyll: every tracked file outside a dot-directory is published** — markdown rendered to `<name>.html` *and*, for most of it, the raw source served beside it. 23 of 31 tracked files are reachable across ~35 URLs, including `scripts/healthcheck.sh` itself (`application/x-sh`). An `.html` glob covers 2 of them. That left 21 published documents — five naming the compromised pot wallet — outside the funding-suspension invariant (DEE-34). | `healthcheck.sh` §8 enumerates the surface by **Jekyll's rule** (skip dotted paths, ship the rest), not by extension, and probes both URL forms per file rather than predicting which one Jekyll serves. Every run prints what it excluded. If you add `.nojekyll`, the raw forms keep answering and the check follows — but that changes the extent of an accessioned artwork, so it is a **board decision** (DEE-33), not a cleanup. |
| Loosening a narrow grep to stop it false-failing | The docs that *document* the mitigation quote the invitation in order to forbid it (`CLAUDE.md` §5, and §8's own pattern list). Extending §8's solicitation patterns to markdown red-FAILs both immediately, and the tempting repair — a looser pattern, or an any-of-these-will-do disclosure predicate — false-passes forever after. | Keep the literal tests literal. Normalise the *documents* onto one canonical notice sentence (`Do not send ETH to this address`, `POT_NOTICE` in the script) instead of teaching the check every phrasing. §8 applies solicitation patterns to `.html` only, on purpose, and says so where it does it. |
| Reading a green health check as "the live site is current" | Checks 1–9 verify that the site is *up* and that the repo is *right*; until §10 nothing verified they were the same thing. A stalled or failed Pages build serves the previous commit forever, and the pass stays green through it — 200 OK, tree clean and equal to `origin/main`, §8 markers passing against bytes from before the fix. The funding suspension is exactly this shape of change, so the failure mode is "the invitation is still live and every monitor says fine". | `healthcheck.sh` §10 compares live bytes to `origin/main` bytes per verbatim-published file. If it WARNs "build probably still in flight", re-run after the deploy rather than dismissing it; if it FAILs, the venue is serving something this repo did not publish — check the Pages build before touching content. |
| Asking what the platform publishes, but only asking one platform | Pages is not the only publisher. GitHub serves every tracked file itself at `raw.githubusercontent.com` and `/blob/main/` — **dot-directories included** — and compiles `.github/ISSUE_TEMPLATE/` into the program's live intake form at `/issues/new/choose`. So the paths §8 correctly excludes as "Jekyll skips these" are published anyway, by something else. The intake form is one of them: it promised the swept pot's ETH five times, one click from a page reading FUNDING SUSPENDED, while the monitor printed those paths as *outside the published surface* every run (DEE-42). | `healthcheck.sh` §11 covers the second venue on its own rules — raw-vs-`origin/main` parity for the dotted set, the pot-address rule, a two-sided check on the issue chooser, a **pin** (`PAYOUT_PIN`) on the payout promises that are standing by board decision, and — since DEE-45 — the pot-address, payout and disclosure rules read off the **bytes raw actually returns**, not off the repo copy joined to them by parity. Do not merge the two venues into one wider glob: `.claude/` and `.github/workflows/` genuinely are not published *as documents* by Jekyll. Two venues, two rules. |
| Auditing only the venues you control | A fork shares git objects with its parent in both directions, and `mnrrxyz/CICFA` was forked 2026-03-19 — four months before the sweep — so its `main` **is** the pre-suspension page: invitation, click-to-copy, payment QR, compromised address. Today nothing renders it (`has_pages: false`, `/pages` 404s). That is one setting, owned by a third party, between us and a working donation page for a thief's wallet at a URL we cannot take down (DEE-50). | `healthcheck.sh` §12 enumerates the fork network **at run time** and asserts `has_pages == false` for every entry, forks-of-forks included. Never hard-code a fork name — the fork list is the instrument, so a fork created tomorrow is a new measurement. A rate-limited or failed API call is a WARN, never a PASS. Do not "fix" a fork by contacting, cloning or PRing it; and do not add a check on its bytes, which are unfixable by design. |
| Adding a check whose failure is permanent | Tempting for history: the pot invitation is still served at `raw…/5113c57/index.html` and always will be, because history is append-only. A check for that red-FAILs forever, and a permanent red teaches everyone to read red as noise — the same defect as a green that hides a check which never ran, arriving from the other direction. | Only assert things that can be true. Where an exposure is real but unfixable, say so once in prose (here, and §12's closing SKIP line) instead of encoding it as a standing failure. |
| Asserting that a file is **there** and calling it checked | §6 fetched both intake templates from `raw` and asserted a 200 — for months, green every day, through the whole period `submission.yml` promised the swept pot four times (DEE-44). A status line is not a reading. The same shape sits one level up: a content rule that runs on the working-tree copy and reaches the served copy only through a parity test is asserting about a file nobody serves, and it holds only while working tree, `origin/main` and `raw` are identical — which §2 reports as a **WARN**, not a precondition. Parity also cannot triage: it says the bytes differ, not that a submitter is being promised a swept pot (DEE-45). | Read the body you already downloaded. §11 now runs the money rules on the fetched bytes and §6 keeps only the assertion that needs no network (the file still exists in the repo). When a check cannot be made to fire on demand, that is the finding — red-test every content rule against a tampered local mirror before believing it. |
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
live, every `target="_blank"` carries `rel="noopener"`, — §11 — the second venue
GitHub publishes itself, and — §12 — no *fork* of this repo has Pages enabled.
Config is parsed straight out of
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

**§10 asks the one question the other nine don't: is the live site *this repo*?**
Sections 1–9 establish that the site is healthy and that the repo is correct — and both
can be true while the venue serves an older commit, because a Pages build can fail or
stall and keep serving the last good deploy indefinitely. Nothing in 1–9 notices: the
site answers 200, the tree is clean and equal to `origin/main`, and §8's markers pass
against whatever bytes are up there. For the funding suspension that gap is the whole
risk, since the suspension *is* a change to published bytes — the fix can be committed,
pushed and verified in the repo while the page a visitor reads still asks for ETH. §10
compares, per published file Jekyll copies verbatim, the bytes served at its own path
against **`origin/main`** (not `HEAD` — the venue was given what was pushed). Files whose
pushed copy has front matter are excluded: Jekyll renders those and withholds the source,
so §8 checks the rendered form's content instead. Two softenings keep it from crying
wolf — a non-200 is a WARN (which form Jekyll serves is a live disposition question,
DEE-33, and §1 already owns liveness), and a divergence within `DEPLOY_GRACE` (900s) of
the pushed commit is a WARN, because a build in flight is not a stale deploy. Only
200-with-different-bytes past the grace window is hard-red; that cannot be anything but
a stale or altered deploy. Pure HTTP + git, so **CI covers it**.

**§11 asks the question §§8 and 10 don't: *which* publisher?** Both of those measure
GitHub Pages. GitHub publishes this repository a second way — raw and blob for every
tracked file, dot-directories included, and `.github/ISSUE_TEMPLATE/` rendered into the
live intake form at `/issues/new/choose` (a 302 to login for anonymous readers, i.e.
served to exactly the population that can submit). Verified 2026-07-26: raw and blob
answer 200 for `.github/ISSUE_TEMPLATE/submission.yml` while Pages correctly 404s the
same path. §11 takes the **dotted set §8 skips** — the other 23 files are already
checked there — and applies rules graded by the direction money moves. *Money in* is
hard-red and is the same rule as §8: the compromised address published here without the
notice, or the chooser blurb inviting contributions (checked against the `name`/`url`/
`about` values only, never the whole file — `config.yml` documents the phrase `339a5cb`
removed from it, and a whole-file grep would red-FAIL on that documentation forever).
*Money out* was a standing WARN until DEE-44: `submission.yml` promised the pot four
times and `jury_registration.yml` once, none of them touched since March. Those five
promises are **gone** (`6d43e46`), and §11 changed job in the same commit — it no longer
reports a standing defect, it *holds a landed fix*, two-sided like §8's page rule: a
payout promise reappearing is red, and the suspension statement going missing is red.
The board ruling that ordered it, in one line: an assertion under a pending board
question waits, an inducement to a stranger's irreversible act does not. What is still
board-held is narrower and still WARNed every run — the juror wallet stays `required`
because the wallet *is* the vote (EIP-191), and `index.html`'s Unlock Condition 05 stays
put under DEE-30 q3. §11 pins the whole surface (`PAYOUT_PIN`: path, promise-line count,
and the `required` of the `id: wallet` input — the *field*, not the prose about it) and
restates it every run, so the decision stays a decision instead of decaying into an
oversight nobody remembers making. Drift off the pin is a WARN, not a failure: **if the
board answers DEE-30 q3 and the forms are edited again, update `PAYOUT_PIN` in the same
commit.** Parity reuses §10's shape and `DEPLOY_GRACE`, since raw's cache lags a push the
way a build does. Plain HTTP to `github.com`, so **CI covers it** too.

**§12 asks the question §§8, 10 and 11 all assume away: is this repository published by
anyone but us?** Those three measure two venues we own. GitHub gives a fork the parent's
objects — both directions — so the one fork of this repo, taken 2026-03-19 off `5113c572`,
carries the page as it read before the sweep. Nothing renders it today: `has_pages` is
`false` and `/repos/{fork}/pages` 404s, so the exposure is a setting away, and the setting
belongs to someone else. §12 fetches `/repos/DEEP-WEB-GALLERY/CICFA/forks` **at run time**
(following forks-of-forks, bounded by `FORK_API_MAX_CALLS`) and hard-reds on any fork with
Pages enabled. Two disciplines make it trustworthy rather than decorative. First, **no
hard-coded fork name** — the list is the instrument, so a fork created tomorrow is checked
the day it appears, and `FORK_PIN` is a *receipt* whose only job is to make a change in the
network visible (WARN, either direction; update it in the same commit when the change is
legitimate). Second, **a rate-limited or failed API call is a WARN and never a PASS**:
anonymous GitHub allows 60 requests an hour per IP, so set `HEALTHCHECK_GH_TOKEN` locally
or let the workflow's `GITHUB_TOKEN` lift it — a green that hides a check which never ran
is the exact failure §8 was built to prevent. What §12 deliberately does **not** do: touch
the fork in any way (read-only public API — no clone, issue or PR), and assert anything
about the fork's own bytes, which serve the March page and always will.

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
