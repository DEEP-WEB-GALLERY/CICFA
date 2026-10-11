```
> ARCHIVE
> ───────
> past tests. nothing here executes. the archive is the work.
```

| Directory | What | Period | Status |
|---|---|---|---|
| `operation-001_moma-sym/` | Operation 001 — MOMA.SYM. The first bounty operation; target Museum of Modern Art, NYC; two registers; self-assembling jury; mainnet pot. | 2026-03-17 → 2026-07-26 | **ARCHIVED · PAST TEST · POT COMPROMISED (DEE-30)** |
| `wat-kernel-os/` | The pre-canon operating system that ran the program from this repo: workflows, roles, docs, tools pointers. Replaced by CICFA-OS Mark I (private). | 2026-03 → 2026-10 | **FROZEN** |

## Paths

The live page moved on 2026-10-11.

| Was | Is |
|---|---|
| `https://deep-web-gallery.github.io/CICFA/` (root) | **404 by design.** The root is retired; a minimal `404.html` points here. |
| `/index.html` | `/archive/operation-001_moma-sym/` — the MOMA.SYM page, still served, status-edited, labelled as record |
| `/OPERATION_001.md` | `/archive/operation-001_moma-sym/OPERATION_001.md` |
| `/workflows/03a_operation_001.md`, `/workflows/03c_operation_001_golive.md` | `/archive/operation-001_moma-sym/workflows/` (frozen runbooks) |
| `/workflows/README.md`, `/workflows/00_program_identity.md` | `/archive/wat-kernel-os/workflows/` |
| `/agents/*.md` | `/archive/wat-kernel-os/agents/` |
| `/docs/submission_flow.md`, `/docs/jury_protocol.md`, `/docs/claude_project_context.md` | `/archive/wat-kernel-os/docs/` |
| `/tools/README.md` | `/archive/wat-kernel-os/tools/README.md` |
| `/programs/console_vB01/` | unchanged (experimental console; accessioned URL) |

## Archival rules

1. **Move, don't rewrite.** Archived files keep their text, stale links included. The only rewrites
   are status edits listed in the item's `README.md` (what was changed, from what, to what).
2. **Every archived file that names the pot wallet keeps the notice.** GitHub Pages publishes the
   archive; the health monitor reads it.
3. **Nothing in `archive/` is a runbook to execute.** The frozen runbooks describe a program that no
   longer runs this way.
4. **Convention**: `archive/<slug>/` with a `README.md` carrying `status`, `period`, `archived`.

```
0x7fC76C439c200151Dde0345B09BA02764B9143Ec — COMPROMISED (DEE-30). Funding suspended.
Do not send ETH to this address.
```
