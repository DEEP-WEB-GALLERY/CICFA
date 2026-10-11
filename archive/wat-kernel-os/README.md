# archive/wat-kernel-os — the pre-canon operating system (frozen)

```
STATUS    FROZEN — superseded 2026-10-11
PERIOD    2026-03-17 → 2026-10-11
WAS       the "CICFA OS": a CLAUDE.md kernel + workflows/ (W) + agents/ (A) + tools/ (T) + docs/, living in this public repo
NOW       CICFA-OS Mark I — the private repo DEEP-WEB-GALLERY/cicfa-os (4C harness, COMANDO Canon); this repo is its published face
```

These files are kept verbatim, with their history (`git log --follow`). Their paths, links and
statuses describe the program as it was designed in March 2026 — a GitHub-Issues intake, a
self-assembling jury, an ETH pot — none of which ran: no jury was seated, no submission was received,
the pot was compromised (DEE-30). Nothing here is a runbook to execute.

The system carried **no verifiable version number** ("CICFA OS v2.1.4" on the page was copy; "v2"
in a commit named the page). It is archived under its own description, not renumbered.

## Where each thing went

| Was (this repo) | Now |
|---|---|
| `workflows/00_program_identity.md` | `cicfa-os/context/identity/program.md` (imported; three lines annotated as superseded) |
| `workflows/README.md` | frozen here; the numbering convention is retired |
| `agents/operations_coordinator.md` | `cicfa-os/capabilities/agents/AG_OPS_COORDINATOR.md` (dormant) |
| `agents/jury_reviewer.md` | `cicfa-os/capabilities/agents/AG_OPS_JURY.md` (dormant; human + subagent modes) |
| `agents/disclosure_writer.md` | `cicfa-os/capabilities/agents/AG_OPS_DISCLOSURE.md` (dormant) |
| `docs/submission_flow.md` | `cicfa-os/capabilities/workflows/WF_OPS_SUBMISSION.md` (reference design) — public copy stays here |
| `docs/jury_protocol.md` | `cicfa-os/capabilities/workflows/WF_OPS_JURY.md` (reference design) — public copy stays here |
| `docs/claude_project_context.md` | frozen here (a snapshot of 2026-05-22) |
| `tools/README.md` | `cicfa-os/connections/TL_CORE_AUTORUN.md` (frozen generators) |
| the `CLAUDE.md` kernel | `cicfa-os/CICFA-OS.md` (boot spec) + `cicfa-os/CLAUDE.md` (Charter); the ⛔ warnings → `cicfa-os/context/knowledge/2026-07-10_dee-30-pot-compromise.md`; this repo keeps a thin Charter |
| `.claude/agents/jury-reviewer.md`, `.claude/skills/*` | `cicfa-os/.claude/` (removed from the tree here; in history) |
| `OPERATION_001.md`, `index.html`, `workflows/03a`, `03c` | `archive/operation-001_moma-sym/` (the operation's own record) |

```
0x7fC76C439c200151Dde0345B09BA02764B9143Ec — COMPROMISED (DEE-30). Funding suspended.
Do not send ETH to this address.
```
