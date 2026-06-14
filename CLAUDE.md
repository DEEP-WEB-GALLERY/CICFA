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

**Operations** (launching, intake, jury, disclosure):
open the relevant file in `workflows/`. Each is a numbered runbook.

---

## 6. Bounty wallet (do not change without explicit instruction)

`0x7fC76C439c200151Dde0345B09BA02764B9143Ec` — referenced in `index.html`.

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
- Change the bounty wallet address without explicit instruction.

---

*This file is the kernel. Everything else is loaded from here. If something here is wrong, fix it — every session reads this first.*
