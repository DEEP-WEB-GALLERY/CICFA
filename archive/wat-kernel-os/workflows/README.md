# `workflows/` — W in WAT

Operational runbooks. Markdown checklists the OS executes step-by-step with a human or agent operator.

---

## How to read these

Each workflow is one of two shapes:

- **Identity / framing** (e.g. `00_program_identity.md`) — context to load before doing anything else. Read once per session.
- **Operation** (e.g. `03a_*`, `03c_*`) — a numbered checklist with `[ ]` boxes. Execute top-to-bottom. Surface blockers as `[BLOCKER]` tags.

Frontmatter contains:
- `description` — when to load this workflow
- `trigger` — phrases that should activate it
- `parent` — what workflow it descends from (if any)
- `skills` / `tools` — what harnesses it depends on

---

## Index

| File | Purpose | Status |
|---|---|---|
| `00_program_identity.md` | What CICFA is, components, framing. Load at session start. | Mirror of AUTORUN canonical |
| `03a_operation_001.md` | Master checklist for Operation 001 (MOMA.SYM) — assets → deploy → intake → disclosure → archive | Mirror of AUTORUN canonical |
| `03c_operation_001_golive.md` | **Launch-day runbook.** Pre-launch decisions, config checklist, command-by-command sequence, post-launch monitoring. | Repo-local (canonical here) |

---

## Adding a new workflow

1. Number it. Workflow numbers are program-level (`00`–`05` reserved for framing / main site / philosophy) and operation-level (`03a`, `03b`, `03c` for Operation 001 stages; `04a` etc. for Operation 002).
2. Add frontmatter (`name`, `description`, `trigger`).
3. Use `[ ]` checkboxes for executable steps. Use `[BLOCKER]` tags for steps that gate on an open decision.
4. End with an "Agent Notes" section — what an agent operator should be careful about.
5. Add it to the table above.

---

## Mirrors vs. canonical

`00_program_identity.md` and `03a_operation_001.md` are mirrored from `DWG_AUTORUN_BETA/workflows/`. They are the canonical source for *the team* (this repo), but the AUTORUN copies remain the source of truth for the generator pipeline. If you edit one, mirror the change.

`03c_operation_001_golive.md` is canonical here — written for this repo and not yet upstream.
