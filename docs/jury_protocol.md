# Jury Protocol

How the CICFA jury votes. Operational mechanics for jurors and operations.

---

## Composition

- **5 seats per operation**, fixed.
- **First-come, first-seated** — seats fill from `.github/ISSUE_TEMPLATE/jury_registration.yml` submissions in order received.
- Operations may close the jury before launch or accept rolling registrations through deadline — decided per operation in `workflows/03c_<op>_golive.md`.
- Each seat is bound to **one wallet**. That wallet is the juror's voting credential for the operation.

---

## Wallet binding

At registration the juror provides an ETH address. That address is the juror's seat. The same address must sign every vote in that operation. If a juror loses access mid-operation, they surface to operations immediately — re-seating requires `@MarketDepravation` sign-off.

Wallets are public. Jurors don't have to reveal real-world identity beyond a handle, but the wallet is on the record.

---

## Voting mechanics

CICFA uses **off-chain signatures via EIP-191** — no gas, no on-chain transaction for the votes themselves. The signatures are then published publicly alongside the verdict, making the vote verifiable by anyone who can run `ecrecover`.

### Vote structure

After deadline close, operations sends each seated juror a single voting prompt containing every valid submission. The prompt's structure (one per submission):

```
operation:    001
submission:   SUB-NNN
title:        <finding title>
register:     A | B | A+B
vote:         approve | reject
juror_wallet: 0x…
timestamp:    YYYY-MM-DDTHH:MM:SSZ
```

The juror signs each line (or a hashed concatenation of their full ballot — implementation detail of the off-chain signing tool) with `personal_sign` from their registered wallet.

### Ballot rules

- One vote per juror per submission. Simple majority decides (3 of 5).
- **No abstentions.** A juror who fails to vote on a submission is treated as `reject` for tie-breaking purposes.
- A juror may publish a brief reasoning (one paragraph) attached to their signed ballot. Optional, not required.
- If multiple submissions are approved, the jury also signs a **ranking** in a second pass — the top-ranked receives the ETH pool, the rest receive credit + archive inclusion.

### Verification

Anyone can verify a vote:
1. Take the published signature
2. Take the published vote-line / ballot hash
3. Run `ecrecover(messageHash, signature)` → address
4. Confirm address matches the juror's registered wallet

If verification fails, the vote is discarded. If verification fails repeatedly for one juror, operations and `@MarketDepravation` decide on re-seating.

---

## Approve / reject criteria

See `agents/jury_reviewer.md` for the full criteria. Summary:

**Approve when:** the finding is real, specific, in-register, and ethically sound.

**Reject when:** the submission is vague, recycles a known critique without new specificity, includes exploit code (Register B), or crosses the ethical line (`onboarding/ethics.md`).

---

## Conflicts of interest

At registration, jurors confirm "no undisclosed conflict of interest with [target institution]." A conflict that emerges mid-operation must be surfaced to operations before voting on the affected submission.

Recusal is allowed: the juror signs an explicit `recuse` for that submission. The remaining jurors decide. Tie among 4 → operations escalates to `@MarketDepravation`.

Silent voting under conflict is grounds for invalidation of the verdict and removal from future juries.

---

## Timing

| Stage | Window |
|---|---|
| Open call deadline | Operation-specific (see `workflows/03a_*` + `03c_*`) |
| Voting prompt sent | within 24h of deadline close |
| Voting window | 7 days |
| Verdict published | within 24h of voting close |
| ETH transfer (Register A) | within 7 days of verdict |
| Disclosure window (Register B) | day-of-verdict + 30 days |

---

## What gets published

Per operation, after verdict:

- The verdict itself (per-submission `approved` / `rejected` + ranking if applicable)
- Every juror's wallet address
- Every juror's signature on every vote
- Any juror's optional reasoning paragraph
- The on-chain tx hash of the ETH transfer

What does NOT get published:
- Juror real-world identities (unless self-disclosed in their handle)
- Inter-juror discussion threads
- Submissions that were rejected (content is private; count is public)
- Register B finding content during the 30-day disclosure window
