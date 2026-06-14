---
name: operation-001-golive
description: Launch-day runbook for Operation 001 (MOMA.SYM). Load this on the day the open call goes live. Walks through pre-launch decision gates, every CONFIG field across the 4 generator scripts, the regenerate → review → deploy → distribute sequence, and post-launch submission monitoring. Parent is operation-001-moma-sym.
trigger: "go live", "launch operation 001", "publish open call", "send the email blast", "today is launch day", "operation 001 golive"
parent: operation-001-moma-sym
skills: [cicfa-aesthetic]
tools: [generate_open_call.py, generate_social_posts.py, generate_email_blast.py, deploy_to_gh_pages.py]
---

# Operation 001 — Go-Live Runbook

**Parent workflow:** `03a_operation_001.md`
**Target:** Museum of Modern Art (MoMA), NYC
**Codename:** MOMA.SYM
**Use this file:** on launch day, top-to-bottom

---

## Status snapshot

| | |
|---|---|
| Bounty site (`index.html`) | ✅ Live at `https://deep-web-gallery.github.io/CICFA/` |
| Submission template | ✅ `.github/ISSUE_TEMPLATE/submission.yml` |
| Jury registration template | ✅ `.github/ISSUE_TEMPLATE/jury_registration.yml` |
| Bounty wallet | ✅ `0x7fC76C439c200151Dde0345B09BA02764B9143Ec` |
| Open call HTML generator | ✅ `DWG_AUTORUN_BETA/tools/generate_open_call.py` |
| Social posts generator | ✅ `DWG_AUTORUN_BETA/tools/generate_social_posts.py` |
| Email blast generator | ✅ `DWG_AUTORUN_BETA/tools/generate_email_blast.py` |
| Ransom letter generator | ✅ `DWG_AUTORUN_BETA/tools/generate_ransom_letter.py` (Register B only) |
| Deploy script | ✅ `DWG_AUTORUN_BETA/tools/deploy_to_gh_pages.py` |
| Submission deadline | ⛔ **TBD** — see decisions below |
| Submission intake URL | ⛔ **TBD** — see decisions below |
| Sender email | ⛔ **TBD** — see decisions below |
| Jury composition | ⛔ **TBD** — first 5 to register, intake currently open via `jury_registration.yml` |

---

## STEP 0 — Pre-launch decisions (blocking gates)

These must be resolved before any asset is regenerated or distributed. Each one shows up as a CONFIG field somewhere downstream.

- [ ] **[BLOCKER] Submission deadline (ISO + display)**
      - Decide a real date. Example: `2026-06-30T23:59:00Z` / `"June 30, 2026 — 23:59 UTC"`
      - Used in: `generate_open_call.py`, `generate_social_posts.py`, `generate_email_blast.py`, and the countdown on the live `index.html`

- [ ] **[BLOCKER] Submission intake method + URL**
      - Options:
        - (A) **GitHub Issues** (templates already live — URL would be `https://github.com/DEEP-WEB-GALLERY/CICFA/issues/new?template=submission.yml`)
        - (B) **Google Form** (create, get share URL)
        - (C) **Email alias** (e.g. `submit@cicfa.art` or similar)
      - Recommendation: GitHub Issues (already wired). Lock in this call before regenerating any asset.
      - Used in: all 4 generator scripts + `index.html`

- [ ] **[BLOCKER] Sender email for the email blast**
      - Required by `generate_email_blast.py` CONFIG.
      - Should be a real, monitored address — replies will land here.

- [ ] **[BLOCKER] Distribution list / social channels**
      - Email blast: who's on the list? (collaborators, press, research network, sympathetic curators)
      - Social: confirm @deepwebgallery handles on X / Instagram / Mastodon. Confirm posting cadence (single drop vs. thread vs. scheduled).

- [ ] **[BLOCKER] Jury seating cutoff**
      - Decide: do we lock the jury at 5 before launch, or accept rolling registrations through deadline?
      - Current `jury_registration.yml` enforces a 5-seat cap, first-come-first-seated.

- [ ] **(Optional)** Anything else not yet decided. Log here so the team sees the open list.

---

## STEP 1 — Configure

Update CONFIG blocks in each script with the values locked in STEP 0. Exact field names (verified against the Python files):

### `DWG_AUTORUN_BETA/tools/generate_open_call.py`
- [ ] `operation_id` — e.g. `"001"`
- [ ] `operation_name` — `"MOMA.SYM"`
- [ ] `target_name` — `"Museum of Modern Art (MoMA)"`
- [ ] `target_location` — `"New York City"`
- [ ] `deadline_iso` — from STEP 0
- [ ] `deadline_display` — from STEP 0
- [ ] `submission_url` — from STEP 0
- [ ] `brief_html` — confirm latest brief text

### `DWG_AUTORUN_BETA/tools/generate_social_posts.py`
- [ ] `deadline_display` — from STEP 0
- [ ] `submission_url` — from STEP 0
- [ ] platform list (`twitter`, `instagram`, `mastodon`, …) — confirm

### `DWG_AUTORUN_BETA/tools/generate_email_blast.py`
- [ ] `deadline_display` — from STEP 0
- [ ] `submission_url` — from STEP 0
- [ ] `sender_email` — from STEP 0
- [ ] `subject` — confirm copy

### `DWG_AUTORUN_BETA/tools/generate_bounty_site.py` (if regenerating the main page)
- [ ] `wallet_address` — must remain `0x7fC76C439c200151Dde0345B09BA02764B9143Ec`
- [ ] `jury` — list of seated jurors (handle / role / wallet)
- [ ] `deadline_iso` / `deadline_display` — from STEP 0
- [ ] `submission_url` — from STEP 0

> Field names above must match the Python files exactly. If a name has drifted, fix the doc here — don't fix the code blindly.

---

## STEP 2 — Regenerate assets

From the AUTORUN repo root:

```bash
cd /Users/boris/Documents/DWG/DWG_AUTORUN_BETA
python3 tools/generate_open_call.py        # → .tmp/open_call.html
python3 tools/generate_social_posts.py     # → .tmp/social_posts.md
python3 tools/generate_email_blast.py      # → .tmp/email_blast.md
# Only regenerate the bounty site if it actually needs structural updates:
# python3 tools/generate_bounty_site.py    # → .tmp/bounty_site/index.html
```

Ransom letter is **not** generated here — only after a Register B finding is received.

---

## STEP 3 — Review

- [ ] Open `.tmp/open_call.html` in a browser. Verify:
      - countdown timer shows the correct deadline
      - submission CTA links to the correct URL
      - brief copy reads correctly, no encoding artifacts
      - mobile rendering at 375px width is intact
- [ ] Read `.tmp/social_posts.md` — edit copy if anything sounds AI-ish or off-register
- [ ] Read `.tmp/email_blast.md` — verify subject line, sender, links, sign-off
- [ ] (If bounty site regenerated) Open `.tmp/bounty_site/index.html`, repeat above + verify on-chain balance fetches against the right wallet

---

## STEP 4 — Deploy

For the open call page (and bounty site if regenerated):

```bash
cd /Users/boris/Documents/DWG/DWG_AUTORUN_BETA
# Set dry_run = False in tools/deploy_to_gh_pages.py CONFIG first
python3 tools/deploy_to_gh_pages.py
```

Or, for a direct edit not coming from AUTORUN:

```bash
cd /Users/boris/Documents/DWG/CICFA/CICFA_PUBLIC
git add index.html
git commit -m "operation 001 — go-live"
git push origin main
```

- [ ] Wait ~1–2 minutes for GitHub Pages to update
- [ ] Visit `https://deep-web-gallery.github.io/CICFA/` and confirm:
      - countdown shows new deadline
      - bounty pool balance loads
      - submission CTA links resolve

---

## STEP 5 — Distribute

- [ ] **Email blast** — paste `.tmp/email_blast.md` into the mailer of choice. Send to the distribution list. Log sent timestamp here:

      Sent at: ____________________

- [ ] **Twitter / X** — post the thread from `.tmp/social_posts.md`. Pin if appropriate.
- [ ] **Instagram** — post the carousel/caption from `.tmp/social_posts.md`.
- [ ] **Mastodon / other** — same.
- [ ] **DM / direct reach** — the targeted ping list (artists / researchers / press the team wants to land specifically). Personal note, not the bulk copy.

---

## STEP 6 — Log & monitor

- [ ] Create `archive/operation_001/submissions_log.md` (or `.tmp/submissions_log.md` if you want it out of git initially).
- [ ] Format each submission entry as:

      ```
      ## [SUB-NNN] [register A | B | A+B] — handle / title
      received: YYYY-MM-DD
      format:   document | visual | artifact
      register: A | B | A+B
      summary:  one-line
      link:     issue / file / hosted artifact
      status:   intake | jury-review | approved | rejected | archived
      ```

- [ ] **Daily:** open issue tracker, log new submissions, flag any Register B for the disclosure workflow.
- [ ] **Register B handling:** trigger `generate_ransom_letter.py`, send to MoMA, start 30-day clock. Do **not** publish the finding before day 31. See `docs/submission_flow.md` and `onboarding/ethics.md`.
- [ ] **Jury notifications:** after deadline closes, ping seated jurors (`jury_registration.yml` issues) with the voting prompt. See `docs/jury_protocol.md`.

---

## Key dates (fill once STEP 0 is resolved)

| Milestone | Date |
|---|---|
| Open call live | _____________ |
| Submission deadline | _____________ |
| Jury review window | _____________ |
| Winner announced + ETH transfer | _____________ |
| Register B 30-day disclosure window ends | _____________ (per submission) |
| Archive published | _____________ |

---

## Agent notes

- Do **not** push to `main` or run `deploy_to_gh_pages.py` with `dry_run = False` without explicit confirmation from `@MarketDepravation`.
- Do **not** send the email blast without confirming the `sender_email` is real and monitored.
- Do **not** publish a Register B finding before the 30-day window expires — see `onboarding/ethics.md`. This rule is the single most important one in the whole runbook.
- If the deadline date changes mid-operation, regenerate **all** assets — partial updates create inconsistent countdowns across surfaces.
- Treat the ransom letter as an artifact, not a real demand. The institution gets the finding + the letter; that's it.
