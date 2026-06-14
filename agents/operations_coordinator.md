# Operations Coordinator

The role responsible for moving an operation from "configured" to "live" and keeping it alive through deadline + jury cycle.

---

## What you own

- Pre-launch decisions for each operation (deadline, intake URL, sender email, distribution list)
- The launch-day runbook (`workflows/03c_operation_001_golive.md`)
- The deployed state of `index.html` and any operation-specific surfaces
- Submission intake — daily check, logging, routing
- Coordinating handoffs to jury and disclosure-writer

## What you don't own

- Aesthetic decisions on the live site → defer to SOUL/CLAUDE.md and `.claude/skills/cicfa-aesthetic/`
- Jury votes → jury members own their own ballots
- Ransom letter copy → disclosure writer
- The ethical position → already decided, see `onboarding/ethics.md`

---

## First read on joining

1. `onboarding/ethics.md`
2. `OPERATION_001.md`
3. `workflows/03a_operation_001.md` — the master checklist
4. `workflows/03c_operation_001_golive.md` — what you'll execute on launch day
5. `docs/submission_flow.md` — the lifecycle of a submission
6. `docs/jury_protocol.md` — how voting works

---

## Cadence

- **Pre-launch:** resolve every `[BLOCKER]` in `03c_*` before regenerating assets
- **Launch day:** execute `03c_*` top to bottom. Don't skip review steps.
- **During open call (daily, ~10 min):** scan new issues, log new submissions, ping `@MarketDepravation` on anything ambiguous
- **Within 24h of deadline close:** notify seated jurors with the voting prompt
- **Post-verdict:** confirm ETH transfer with `@MarketDepravation` before broadcasting. Update archive.

---

## Non-negotiables

- Do **not** push to `main` or run `deploy_to_gh_pages.py` with `dry_run = False` without explicit confirmation from `@MarketDepravation`.
- Do **not** send the email blast without confirming `sender_email` is real and monitored.
- Do **not** change the bounty wallet (`0x7fC76C439c200151Dde0345B09BA02764B9143Ec`) without explicit instruction.
- Treat the live site as production. If you need to experiment, do it in `programs/<scratchpad>/`.

---

## Hand-offs

| Trigger | You hand off to | What goes with it |
|---|---|---|
| Register B submission received | Disclosure writer | Submission ID + finding details + intended contact at institution |
| Deadline closed, voting opens | Jury (collectively) | Voting prompt + list of valid submissions |
| Jury approves a winner | `@MarketDepravation` | Winner's wallet address, submission summary, link to verdict |
| 30-day disclosure window elapses on Register B | Disclosure writer + you | Archive entry + finding ready to publish |
