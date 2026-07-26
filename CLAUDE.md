# CICFA OS — Kernel / Meta-Harness

> This file auto-loads in every Claude session opened in this repo.
> It is the kernel. Everything else loads progressively from here.

---

## 0. What this repo is

This repo is the **CICFA OS** — an operative system that coordinates all CICFA (Cultural Infrastructure Critical Failure Attack) operations: launches, submissions, jury votes, payouts, disclosure letters, archive.

The live bounty site at `https://deep-web-gallery.github.io/CICFA/` is **one output** of this OS, not the OS itself. The OS is the WAT-structured environment that produces and coordinates that output and everything around it.

Working axiom (inherited from DWG SOUL): *software is an active and living form of social critique.*

---

## 1. Architecture — WAT + Harness / Meta-Harness

```
WAT       = Workflows / Agents / Tools (the three operational subsystems)
Harness   = a loadable module of context — a skill, a workflow doc, a role
Meta-     = this file. The kernel. Knows where every harness lives.
 harness    Always in context. Routes to the right harness on demand.
```

Mapping:

| OS concept | Where it lives |
|---|---|
| Kernel / meta-harness | `/CLAUDE.md` (this file) |
| Boot sequence | `/onboarding/` |
| Operations (W) | `/workflows/` |
| Roles (A — human-readable) | `/agents/` |
| Subagents (A — Claude-invokable) | `/.claude/agents/` |
| Loadable skills (harnesses) | `/.claude/skills/` |
| Tools (T) | `/tools/` (mostly pointers; generators live in `DWG_AUTORUN_BETA`) |
| Supporting docs | `/docs/` |
| Live deploy artifact | `/index.html` |
| Experimental UI surfaces | `/programs/` |
| Submission/jury state | `.github/ISSUE_TEMPLATE/` + GitHub Issues |

---

## 2. File map

```
CICFA_PUBLIC/
├── CLAUDE.md                       ← you are here (kernel)
├── README.md                       ← GitHub face
├── OPERATION_001.md                ← MOMA.SYM brief
├── index.html                      ← live bounty site (red-accent, deployed)
│
├── onboarding/                     ← BOOT — read first if new
│   ├── README.md                   ← 60-second orientation
│   ├── ONBOARDING.md               ← full V0.7 program framing
│   ├── ethics.md                   ← non-negotiable position
│   └── glossary.md                 ← terms (CICFA, Register A/B, MOMA.SYM, …)
│
├── workflows/                      ← W — runbooks
│   ├── README.md
│   ├── 00_program_identity.md
│   ├── 03a_operation_001.md
│   └── 03c_operation_001_golive.md ← launch-day runbook
│
├── agents/                         ← A — human roles
│   ├── README.md
│   ├── jury_reviewer.md
│   ├── disclosure_writer.md
│   └── operations_coordinator.md
│
├── .claude/
│   ├── agents/                     ← Claude-invokable subagents
│   └── skills/                     ← Loadable harnesses
│
├── tools/                          ← T — repo-local utilities + pointers
│   └── README.md
│
├── docs/                           ← supporting documentation
│   ├── submission_flow.md
│   ├── jury_protocol.md
│   └── deployment.md
│
├── programs/
│   └── console_vB01/index.html     ← experimental Program Console (terminal/green)
│
└── .github/
    └── ISSUE_TEMPLATE/             ← submission.yml + jury_registration.yml
```

---

## 3. Foundational context (load before any output)

Before producing HTML, copy, aesthetic decisions, or operational text, load:

1. **`/Users/boris/Documents/DWG/SOUL/CLAUDE.md`** — DWG org identity. Programs (#W3SP / #UHP / #DCP), aesthetic rules (palette, typography, copy voice), the operative axiom. Non-negotiable.
2. **`onboarding/ONBOARDING.md`** — CICFA program framing (V0.7).
3. **`onboarding/ethics.md`** — the ethical position. Non-negotiable.

Don't paraphrase any of these from memory. Load them.

---

## 4. Sibling repos (external services this OS calls)

| Path | Role |
|---|---|
| `/Users/boris/Documents/DWG/SOUL/` | Org identity / aesthetic source of truth |
| `/Users/boris/Documents/DWG/DWG_AUTORUN_BETA/` | Generator pipeline (bounty site, open call, social, email, ransom letter). Templates in `tools/templates/`. See `tools/README.md` here for how to invoke. |
| `/Users/boris/Documents/DWG/CICFA/` (parent) | Private operational material — onboarding PDFs, MOMA TEST notes, recordings |
| `/Users/boris/Documents/DWG/DWG_AI/` | Unrelated artist-agent studio. Do not touch from this OS. |

Generators stay in AUTORUN. Don't duplicate them here.

---

## 5. Editing workflow

**Direct edits** (copy, HTML, CSS on `index.html` or a `programs/*/index.html`):
edit → commit → push to `main` → GitHub Pages serves from `main` (Pages-from-branch).

**Systematic regeneration** (structural changes to the bounty site):
edit Jinja2 templates in `DWG_AUTORUN_BETA/tools/templates/` → run
`python3 tools/generate_bounty_site.py` → review `.tmp/bounty_site/index.html` →
run `python3 tools/deploy_to_gh_pages.py` to push the result here.

> ### ⛔ STOP — this path is currently unsafe. Do not regenerate `index.html`.
>
> `DWG_AUTORUN_BETA/tools/templates/bounty_site.html` is the March 2026 original.
> The live page has moved seven shipped fixes past it, and **the template has none
> of them**. Regenerating from it today would:
>
> 1. **Re-publish the funding invitation** — "You are invited to arm the program",
>    click-to-copy, and a QR encoding an `ethereum:` payment URI, all pointing at a
>    wallet whose private key is in a thief's hands (**DEE-30**; swept 2026-07-10).
>    That is the exact harm the mitigation removed. Anyone who accepted the
>    invitation would lose the money.
> 2. **Restore `cloudflare-eth.com` as the only RPC** (`rpc_url`, single, no
>    fallback list) — retired, returns `-32603`, so the pot display would break
>    permanently. That was DEE-14.
> 3. Drop DEE-15 (adaptive decimals), DEE-19 (8s `AbortController` fetch timeout),
>    DEE-22 (clipboard fallback), DEE-23 (RPC chain), DEE-28 (contributor-row
>    truthfulness) and the DEE-30 mitigation itself.
>
> The template is not a source of truth for this page any more; `index.html` here
> is. Use **direct edits** above. Before this path can be reopened, the template
> has to be forward-ported and the funding invitation removed from it — and the
> pot question settled on DEE-30. `scripts/healthcheck.sh` §8 fails if the
> invitation ever reappears in the repo or on the live page, so an accidental
> regeneration gets caught, but it gets caught *after* publication. Don't rely on it.

**Operations** (launching, intake, jury, disclosure):
open the relevant file in `workflows/`. Each is a numbered runbook.

---

## 6. Bounty wallet — ⚠ COMPROMISED, funding suspended

`0x7fC76C439c200151Dde0345B09BA02764B9143Ec` — referenced in `index.html`.

> ⚠ **COMPROMISED — the private key is held by a third party and the pot was swept
> 2026-07-10 (DEE-30). Do not send ETH to this address.**

**The private key to this address is in someone else's hands.** On 2026-07-10 the
only contribution the pot ever received was swept out of it (nonce 0 — the first
and only send from the wallet was the theft), to a collection address that drained
77 wallets in twelve days. Verified on three independent sources. The key did not
leak from this repo: full-history `git log --all -p` matches no key, mnemonic or
64-hex string. Evidence and current status: **DEE-30**.

- **Never invite anyone to fund this address**, and don't re-add a copy button,
  QR code or payment URI for it. The address stays published so the record can be
  checked — labelled compromised, not fundable.
- **This is not the permanent pot address.** Rotation needs a key the gallery
  holds, so it is a board decision pending on DEE-30, not an edit. The old
  "do not change the bounty wallet without explicit instruction" rule below now
  means *don't quietly substitute one*, not *keep using this one forever*.

---

## 7. Ethical position (non-negotiable, from SOUL/CLAUDE.md)

> The work is about violence, not violent.
> It stages symbolic systems, not real-world harm.
> It exposes fragility as aesthetic condition.
> No exploitation has occurred or will occur.

No actual exploit code. No real hacking tooling. The OS simulates, stages, and critiques. Register B (white-hat) submissions go through responsible disclosure — see `docs/submission_flow.md`.

---

## 8. What Claude should/shouldn't do here

**DO**
- Treat `CLAUDE.md` as the kernel; route to skills, workflows, and docs rather than inlining everything.
- Use the existing visual language (terminal, monospace, near-black + threat red `#ff2d2d` + system green `#00ffcc`).
- Preserve internal contradiction as a feature — the project is ironic and sincere simultaneously.
- Reference operations by their codes (`DWG-CICFA-01`, `MOMA.SYM`, `OPERATION 001`).
- For aesthetic decisions, defer to SOUL/CLAUDE.md and the `cicfa-aesthetic` skill.
- For structural / interaction decisions, defer to the `ui-ux` skill.

**DON'T**
- Use generic startup or gallery aesthetics (white backgrounds, sans-serif headers, card grids, friendly toasts).
- Sanitize copy or onboarding into reassurance.
- Produce real exploit code or operational hacking tooling.
- Duplicate generators from `DWG_AUTORUN_BETA/tools/` into this repo.
- Change the bounty wallet address without explicit instruction — and equally, don't
  present the current one as safe to fund. It is compromised (§6, DEE-30).
- Regenerate `index.html` from the AUTORUN template (§5 ⛔) — it would re-publish the
  funding invitation and revert seven fixes.

---

*This file is the kernel. Everything else is loaded from here. If something here is wrong, fix it — every session reads this first.*
