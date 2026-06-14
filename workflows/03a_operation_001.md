---
name: operation-001-moma-sym
description: The step-by-step execution checklist for CICFA's first bounty operation targeting MoMA. Load this when running, deploying, or updating Operation 001 — generating assets, deploying to GitHub Pages, managing submissions, handling responsible disclosure, or archiving the operation. Parent workflow is bounty-logic.
trigger: "Operation 001", "MOMA.SYM", "generate assets", "deploy bounty site", "publish open call", "social posts for MoMA", "submission intake", "jury review", "ransom letter for MoMA"
parent: bounty-logic
skills: [cicfa-aesthetic]
tools: [generate_bounty_site.py, deploy_to_gh_pages.py, generate_open_call.py, generate_social_posts.py, generate_email_blast.py, generate_ransom_letter.py]
---

# Operation 001: MOMA.SYM
**Parent workflow:** 03_bounty_logic.md
**Target:** Museum of Modern Art (MoMA), NYC
**Status:** Active

---

## Objective
Run the first CICFA bounty operation. Invite participants to identify and disclose vulnerabilities in MoMA's institutional architecture — symbolic, conceptual, or real (white-hat technical). Surface the disclosure as performance.

---

## Challenge Brief

> **MOMA.SYM — Vulnerability Disclosure Program**
>
> MoMA has been selected as the first target of the CICFA Bounty Program.
>
> You are invited to identify and document a vulnerability in its institutional architecture.
>
> **Register A — Symbolic / Conceptual**
> A structural contradiction. A power leak. A governance exploit. A curatorial blindspot. Who gets shown? Who funds the walls? What gets redacted in the press release? Institutional critique as vulnerability disclosure.
>
> **Register B — Technical / Operational (White Hat)**
> A real security or opsec finding in MoMA's public digital infrastructure. No exploitation. No harm. Submit through CICFA. The act of surfacing the flaw is the work. We handle responsible disclosure.
>
> Both registers are valid. They can coexist in one submission.
>
> **Submit:** Written document (1–3 pages) / Visual diagram / Web artifact
>
> **Reward:** ETH bounty pool (on-chain, transferred on jury approval). CICFA dashboard credit. Exhibition attribution if selected.

---

## Publishing Checklist

### Phase 1 — Generate Assets
- [ ] Set `wallet_address` (and optionally `wallet_ens`) in `tools/generate_bounty_site.py` CONFIG
- [ ] Add jury member handles to `CONFIG["jury"]` in `tools/generate_bounty_site.py`
- [ ] Confirm `submission_url` (Google Form or email alias) and `deadline_iso` before running
- [ ] Run `python tools/generate_bounty_site.py` → `.tmp/bounty_site/index.html`
- [ ] Preview in browser — verify: boot sequence, BREACH modal, live pot display, both CTA buttons, QR code, countdown timer
- [ ] Run `python tools/generate_open_call.py` → `.tmp/open_call.html` (secondary asset)
- [ ] Run `python tools/generate_social_posts.py` → `.tmp/social_posts.md`
- [ ] Run `python tools/generate_email_blast.py` → `.tmp/email_blast.md`
- [ ] Review all outputs, edit as needed

### Phase 2 — Deploy
- [ ] Set `target_repo` in `tools/deploy_to_gh_pages.py` CONFIG (absolute path to local CICF repo)
- [ ] Set `dry_run = False` in `tools/deploy_to_gh_pages.py` CONFIG
- [ ] Run `python tools/deploy_to_gh_pages.py` — pushes to gh-pages branch
- [ ] Verify live at https://boris-maker.github.io/CICF/ (allow 1-2 min for GitHub Pages to update)
- [ ] Publish Instagram post (from `social_posts.md`)
- [ ] Publish X/Twitter thread (from `social_posts.md`)
- [ ] Send email blast (from `email_blast.md`)

### Phase 3 — Intake
- [ ] Monitor submission inbox
- [ ] Log each submission in `.tmp/submissions_log.md` (date, format, register A/B, brief summary)
- [ ] Flag any white-hat technical submissions for ransom letter workflow (see below)

### Phase 4 — Responsible Disclosure (White-Hat Submissions Only)
- [ ] Run `python tools/generate_ransom_letter.py` with finding details
- [ ] Review `.tmp/ransom_letter.html`
- [ ] Send to MoMA security contact (or general contact if none listed) — this act is part of the performance
- [ ] Wait 30-day disclosure window
- [ ] After window: publish finding in CICFA archive alongside the ransom letter as artifact

### Phase 5 — Review & Archive
- [ ] Review all submissions after deadline
- [ ] Select submissions for exhibition / archive
- [ ] Notify selected participants
- [ ] Update CICFA dashboard with credits
- [ ] Archive operation in `workflows/archive/operation_001/`

---

## Key Dates
| Milestone | Date |
|-----------|------|
| Open call live | TBD |
| Submission deadline | TBD |
| Review complete | TBD |
| Archive published | TBD |

---

## Submission Intake
- Method: TBD (Google Form / email alias)
- Fields: Name or handle, submission format, register (A / B / both), file/link, brief description

---

## MoMA Symbolic Vulnerability Notes
Reference points for participants (can be included in open call):
- Corporate board composition and sponsorship conflicts (BP, Goldman Sachs, etc.)
- Expansion history (PS1 acquisition, global franchise ambitions)
- Canon formation: whose work enters the permanent collection, whose doesn't
- Labor disputes and staff unionization (2021 MOMA workers strike)
- Ticket pricing as access barrier vs. "public" institution narrative
- Digital infrastructure: website, API, ticketing system opsec

---

## Agent Notes
- Do not create submission intake infrastructure without confirming the method with @MarketDepravation
- Do not publish anything to GitHub Pages or social without explicit confirmation
- Deadline dates must be confirmed before generating assets with hardcoded dates
- Wallet address must be confirmed before generating the bounty site — do not use a placeholder in production
- Jury composition must be confirmed before deploy — empty jury section undermines the protocol's legitimacy
- When a jury-approved winner is identified: confirm ETH transfer with @MarketDepravation before executing
