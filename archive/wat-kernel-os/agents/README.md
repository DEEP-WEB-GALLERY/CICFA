# `agents/` — A in WAT

Human-readable role definitions. Each file describes one operational role: what they do, what they read first, what they hand off, what they don't touch.

These mirror the Claude-invokable subagents in `.claude/agents/`. Files here are for people — files there are for Claude. They should stay in sync.

---

## Roles

| File | Role | Owns | Hands off to |
|---|---|---|---|
| `operations_coordinator.md` | Launches operations, runs `workflows/03c_*` on launch day | Decisions, configuration, distribution | Disclosure writer (Register B) / jury (any approved) |
| `jury_reviewer.md` | Reviews submissions, casts wallet-signed vote | Jury verdicts | Operations coordinator (transfers ETH on approval) |
| `disclosure_writer.md` | Drafts ransom letters + archive entries for Register B findings | Disclosure performance artifacts | Operations coordinator (sends to institution + opens 30-day clock) |

---

## Adding a new role

1. Create `<role>.md` here. Mirror with `.claude/agents/<role>.md` (lowercase-kebab name).
2. In the human-readable doc, cover: purpose, first-read list, weekly cadence, hand-off points, non-negotiables.
3. In the Claude-readable doc, use frontmatter (`name`, `description`, tool list) so the harness can invoke it.

---

## Why mirror?

The OS treats human roles and Claude subagents as the same role at different scales. A jury member reviews submissions; the `jury-reviewer` subagent can pre-screen submissions, summarize them, flag conflicts. Same job, two operators.

When you change one, change the other. If they drift, the OS lies.
