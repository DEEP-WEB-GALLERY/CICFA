# CICFA OS — Project Context (snapshot: 2026-05-22)

> Paste-ready context block for seeding a Claude chat / project with the
> current state of this repo. Regenerate when the structure changes.

## What this is
CICFA = Cultural Infrastructure Critical Failure Attack. A bug-bounty-shaped
art program run by DWG (Deep Web Gallery). This repo (CICFA_PUBLIC) is the
CICFA OS — the operative system that coordinates all CICFA operations:
launches, submissions, jury votes, payouts, disclosure letters, archive.
The live site at https://deep-web-gallery.github.io/CICFA/ is ONE OUTPUT of
this OS, not the OS itself.

Working axiom (from parent org DWG):
"software is an active and living form of social critique."

The work is about violence, not violent. It stages symbolic systems, not
real-world harm. No real exploit code, no real hacking tooling, ever.

## Architecture — WAT + Harness / Meta-Harness
- WAT     = Workflows / Agents / Tools — the three operational subsystems
- Harness = a loadable module of context (a skill, workflow doc, role doc)
- Meta-harness = /CLAUDE.md, the kernel; always in context; routes to
  the right harness on demand.

Mapping:
  Kernel / meta-harness   → /CLAUDE.md
  Boot sequence           → /onboarding/
  Operations (W)          → /workflows/
  Roles (A, human-read)   → /agents/
  Subagents (A, Claude)   → /.claude/agents/
  Loadable skills         → /.claude/skills/
  Tools (T)               → /tools/ (mostly pointers; generators live in DWG_AUTORUN_BETA)
  Supporting docs         → /docs/
  Live deploy artifact    → /index.html (red-accent bounty site)
  Experimental UI         → /programs/console_vB01/index.html (green-terminal Program Console)
  Submission/jury state   → .github/ISSUE_TEMPLATE/ + GitHub Issues

## Current file tree (2026-05-22)
```
CICFA_PUBLIC/
├── CLAUDE.md                       (kernel / meta-harness)
├── README.md                       (GitHub face)
├── OPERATION_001.md                (MOMA.SYM operational brief)
├── index.html                      (live bounty site, red accent #ff2d2d)
├── onboarding/
│   ├── README.md  ONBOARDING.md  ethics.md  glossary.md
├── workflows/
│   ├── README.md
│   ├── 00_program_identity.md
│   ├── 03a_operation_001.md
│   └── 03c_operation_001_golive.md
├── agents/                         (human-readable role docs)
│   ├── README.md
│   ├── jury_reviewer.md
│   ├── disclosure_writer.md
│   └── operations_coordinator.md
├── .claude/
│   ├── agents/jury-reviewer.md     (Claude-invokable subagent)
│   └── skills/
│       ├── cicfa-aesthetic/SKILL.md
│       └── ui-ux/SKILL.md
├── tools/README.md                 (pointer doc; generators live elsewhere)
├── docs/
│   ├── submission_flow.md
│   ├── jury_protocol.md
│   └── deployment.md
├── programs/console_vB01/index.html
└── .github/ISSUE_TEMPLATE/         (submission.yml, jury_registration.yml)
```

## Active operation
OPERATION 001 — MOMA.SYM (code: DWG-CICFA-01). Bounty open; submissions
intake via GitHub Issues using the templates above. Two registers:
  Register A = symbolic / conceptual finding (curatorial, ethical, semiotic)
  Register B = technical white-hat finding (responsible disclosure path)

## Bounty wallet (do not change without explicit instruction)
0x7fC76C439c200151Dde0345B09BA02764B9143Ec

## Aesthetic (non-negotiable, inherited from DWG SOUL)
- Near-black backgrounds. Monospace. Terminal voice.
- Threat red #ff2d2d and system green #00ffcc as accents.
- No startup/gallery aesthetics — no white backgrounds, no card grids,
  no friendly toasts, no sans-serif headers, no reassuring copy.
- Tone: ironic and sincere simultaneously; preserve internal contradiction.
- Reference operations by their codes (DWG-CICFA-01, MOMA.SYM, OPERATION 001).

## Sibling repos this OS calls (NOT in this repo)
- /Users/boris/Documents/DWG/SOUL/             — org identity, palette, aesthetic source of truth
- /Users/boris/Documents/DWG/DWG_AUTORUN_BETA/ — generator pipeline (bounty site, open call, social, email, ransom letter); templates in tools/templates/
- /Users/boris/Documents/DWG/CICFA/            — private operational material (PDFs, MOMA TEST notes, recordings)
- /Users/boris/Documents/DWG/DWG_AI/           — unrelated artist-agent studio; do not touch

Generators stay in AUTORUN. Do not duplicate them into this repo.

## Editing / deploy model
- Direct edits to index.html or programs/*/index.html → commit → push to
  main → GitHub Pages serves from main (Pages-from-branch).
- Systematic regen: edit Jinja2 templates in DWG_AUTORUN_BETA/tools/templates/
  → run generate_bounty_site.py → review .tmp/bounty_site/index.html →
  deploy_to_gh_pages.py.
- Operations: open numbered runbook in /workflows/.

## Recent commits (most recent first, at snapshot time)
```
5113c57 deploy: CICFA bounty site v2 — Operation 001 MOMA.SYM
c52efa5 Add conceptual framework: pentest x crowdsourcing x bug bounty
e3172c6 Remove social preview image and generator
5eb95d7 Fix URLs to DEEP-WEB-GALLERY org, add social preview
f626739 Remove CONTRIBUTE section
e9a5b28 Launch CICFA — Operation 001 MOMA.SYM
```

## How to use this context in a chat
Treat /CLAUDE.md as the kernel — route to skills/workflows/docs instead of
inlining everything. For aesthetic decisions defer to SOUL/CLAUDE.md and
the cicfa-aesthetic skill. For structural / interaction decisions defer
to the ui-ux skill. For operational decisions open the matching workflow.
