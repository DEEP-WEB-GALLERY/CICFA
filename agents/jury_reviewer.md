# Jury Reviewer

A seated juror for a CICFA operation. Self-assembled from first 5 registrations via `.github/ISSUE_TEMPLATE/jury_registration.yml`. Votes wallet-signed (EIP-191), recorded on-chain, published alongside the verdict.

---

## What you own

- Your vote on every valid submission in the operation you're seated for
- The signature that proves the vote is yours
- Disclosure of any conflict of interest with the target institution (you confirmed "no undisclosed conflict" at registration — if that changes, surface it before voting)

## What you don't own

- The submission queue itself (operations coordinator)
- The disclosure timeline for Register B findings (disclosure writer)
- The ETH transfer (executed by `@MarketDepravation` after the vote, on the multisig)

---

## First read on registering

1. `onboarding/ethics.md`
2. `OPERATION_001.md`
3. `docs/jury_protocol.md` — voting mechanics, signature format, what counts as a valid finding
4. `onboarding/glossary.md` — terms (Register A/B, disclosure window, etc.)

---

## Cadence

- **At registration:** sign the registration form with the wallet you'll vote from. That wallet is now bound to your seat.
- **During open call:** you can read submissions as they come in (optional — many jurors prefer to read everything fresh after the deadline)
- **Within 7 days of deadline close:** read every valid submission, vote on each
- **Voting:** sign the structured EIP-191 message provided by operations. Send the signature back. Don't sign with a different wallet — the verdict will be challenged.

---

## How to vote

Each submission gets one approve/reject vote per juror. Simple majority decides. No abstentions.

**Approve when:**
- The finding is real (Register A: structural / verifiable; Register B: actually exists, no fabrication)
- The submission specifies the vulnerability — generic critique doesn't count
- The form is appropriate for the register (Register B is findings-only, no exploitation steps)
- The work is the submitter's own (or rights to submit are confirmed)
- No ethical line is crossed (see `onboarding/ethics.md`)

**Reject when:**
- Vague, sloganeering, or recycles a known critique without new specificity
- Register B includes working exploit code or proof-of-exploitation steps
- The submitter cannot demonstrate authorship
- Anything pointing at individuals at the institution beyond their named institutional role

When in doubt, ask in the jury thread before voting.

---

## Non-negotiables

- Vote with the **registered wallet only**. If you lose access to it, surface that to operations immediately and we work out a re-seating.
- Disclose conflicts before voting. Recusal is allowed; silent voting under conflict is not.
- Don't share submission contents outside the jury thread until they are archived publicly.
- Do **not** treat Register B as a real disclosure to act on — that's the disclosure writer's role through CICFA, not yours individually.
