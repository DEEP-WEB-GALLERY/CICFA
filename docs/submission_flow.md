# Submission Flow

How a vulnerability submission travels from issue to archive. One canonical reference for hunters, jury members, operations, and the disclosure writer.

---

## Lifecycle

```
                ┌─────────────────────────────────────────────────────┐
                │                                                     │
                ▼                                                     │
[ HUNTER ]  →  [ SUBMIT ]  →  [ INTAKE ]  →  [ JURY ]  →  [ VERDICT ] │
                                                              │       │
                                                ┌─────────────┴───┐   │
                                                ▼                 ▼   │
                                          [ REJECTED ]      [ APPROVED ]
                                                                  │
                                          ┌───────────────────────┴────────┐
                                          ▼                                ▼
                              [ REGISTER A — ARCHIVE ]      [ REGISTER B — DISCLOSURE WINDOW ]
                                          │                                │
                                          │                          (30-day clock)
                                          │                                ▼
                                          │                       [ ARCHIVE + RANSOM LETTER ]
                                          ▼                                ▼
                                          └───── ETH TRANSFER ─────────────┘
```

---

## Stage 1 — Submit

**Channel:** `https://github.com/DEEP-WEB-GALLERY/CICFA/issues/new?template=submission.yml`
**Template:** `.github/ISSUE_TEMPLATE/submission.yml`

Required fields:
- Handle / name
- ETH wallet (for payout if approved)
- Register: A / B / A+B
- Format: document / visual / artifact / multiple
- Finding title
- 2–5 sentence summary
- Full disclosure (text or hosted link)
- Submission agreement (work is original, no real-world harm intended, Register B was disclosed via CICFA)

Issue labels auto-applied: `submission`, `operation-001`.

---

## Stage 2 — Intake

**Owner:** operations coordinator (`agents/operations_coordinator.md`)
**Cadence:** daily during open call

For each new issue:

1. Read the submission. Skim only — full read happens at jury stage.
2. Sanity-check the agreement checkboxes are real.
3. **If Register B:** flag for disclosure-writer immediately. Do NOT discuss the finding publicly in the issue thread. Add a private note to the disclosure-writer.
4. Log in `archive/operation_001/submissions_log.md` (see entry format below).
5. Label adjustments: `intake-complete`, `register-A` or `register-B`.

### Log entry format

```
## [SUB-001] [A | B | A+B] handle — finding title
received:   2026-MM-DD
issue:      #NNN
format:     document | visual | artifact | multiple
register:   A | B | A+B
summary:    one-line
wallet:     0x… (for payout if approved)
status:     intake | jury-review | approved | rejected | archived
notes:      ⤷ any flags or routing
```

---

## Stage 3 — Jury review

**Owner:** seated jurors (`agents/jury_reviewer.md` + `docs/jury_protocol.md`)
**Window:** opens at deadline, closes 7 days later

Operations sends the voting prompt to all seated jurors after the deadline. Each juror reads every valid submission and signs an EIP-191 message with approve/reject per submission. Simple majority decides.

Mid-window: operations does NOT advocate for or against any submission. Operations answers procedural questions only.

---

## Stage 4 — Verdict

**Approved** → proceed to Stage 5.
**Rejected** → status set to `rejected`. Optional courtesy reply to the submitter (terse, not editorial). Issue closed but NOT deleted — the archive includes rejections in count, not content.

A single operation has **one ETH-pool winner**. If multiple submissions are approved, the jury also signs a ranking to break ties; the top-ranked approved submission receives the pool. The others receive credit + archive inclusion only.

---

## Stage 5A — Register A — Archive

For an approved Register A submission:

1. Operations notifies the submitter publicly (issue thread + tag).
2. Operations confirms ETH transfer with `@MarketDepravation`. Transfer executes from the bounty wallet to the submitter's wallet. Tx hash published in the issue.
3. Archive entry created in `archive/operation_001/` — submission + verdict + jury signatures + tx hash.
4. Live site (`index.html`) updated to show the winner.
5. Issue closed with label `approved`, `archived`.

---

## Stage 5B — Register B — Disclosure window

For an approved Register B submission:

1. Disclosure writer drafts the ransom letter (`generate_ransom_letter.py` template → hand-edit for tone).
2. `@MarketDepravation` signs off on the letter.
3. Operations sends the letter to the target institution's security contact (or generic contact if no security contact exists publicly).
4. **30-day clock starts.** Status: `disclosure-window`.
5. During the window: the finding is NOT published. The verdict and the existence of the finding may be acknowledged publicly; the *content* of the finding may not.
6. **Day 31:** archive entry published. Includes the finding, the ransom letter, the verdict, jury signatures, tx hash.
7. ETH transfer executes on the same day as archive publication (not earlier — the publication is the deliverable).

If the institution responds during the window:
- **Patch / fix:** acknowledged in archive entry. Window still expires on day 31. Finding still publishes.
- **Legal threat:** route to `@MarketDepravation`. Do not respond unilaterally.
- **No response:** default path. Finding publishes day 31.

---

## Edge cases

| Situation | Handling |
|---|---|
| Submission references real exploit code | Reject. Notify submitter privately why. Do not archive the exploit. |
| Submitter cannot produce signed wallet | Status: `pending`. Hold ETH until resolved. After 90 days, the pool rolls forward to the next operation. |
| Juror's registered wallet is compromised | Juror surfaces immediately. Operations + `@MarketDepravation` decide: re-seat, accept verdict so far, or rerun. |
| Target institution preemptively contacts CICFA | Route to `@MarketDepravation`. Do not confirm or deny pending submissions. |
| Submission is duplicate of an earlier finding | Earlier wins by date received. Later submitter receives credit + archive inclusion. Pool goes to earlier. |

---

## What lives where

| Thing | Where |
|---|---|
| Submissions | GitHub Issues (`submission` label) |
| Logs | `archive/operation_<NNN>/submissions_log.md` |
| Verdicts | `archive/operation_<NNN>/verdict.md` + jury signatures attached |
| Ransom letters (Register B) | `archive/operation_<NNN>/disclosures/<sub-id>/letter.html` |
| ETH transfers | On-chain (Etherscan) + tx hash recorded in archive entry |
| Live winner display | `index.html` (updated post-verdict) |
