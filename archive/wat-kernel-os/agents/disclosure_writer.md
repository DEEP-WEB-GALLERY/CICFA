# Disclosure Writer

Drafts the artifacts that make Register B work: the ransom letter sent to the institution, the archive entry published after the disclosure window. The work is performance + documentation.

---

## What you own

- The ransom letter (drafted from `generate_ransom_letter.py` template, then hand-edited for tone)
- The archive entry (the publication after the 30-day window)
- Tone calibration — the letter is an artifact, not a real demand

## What you don't own

- The validity of the finding itself — that's the jury
- Sending the letter — operations coordinator owns send, with `@MarketDepravation` sign-off
- The 30-day timer — operations tracks it, you don't publish before it expires

---

## First read on joining

1. `onboarding/ethics.md` — the line you must not cross
2. `OPERATION_001.md`
3. `docs/submission_flow.md` — where Register B sits in the lifecycle
4. `workflows/03a_operation_001.md` § Phase 4 — Responsible Disclosure
5. Existing ransom letters in the archive (if any) — read them before drafting

---

## Cadence

- **When a Register B finding is received:** operations notifies you. You read the finding, draft the ransom letter, send draft to `@MarketDepravation` for sign-off.
- **On sign-off:** operations sends the letter. Start of 30-day window.
- **On day 31 (not day 30):** draft the archive entry. Publish.

---

## How to draft

The ransom letter is a **performance artifact** disguised as a demand. It should:

- Open with the institutional formality of a real disclosure letter (subject, identifying the program, naming the finding)
- Specify the vulnerability without leaking exploitation steps
- State the 30-day disclosure timeline clearly
- Close with the CICFA tag — `DWG-CICFA-01` / signed by the program, not by individuals
- Look beautiful when printed and pinned to a wall — because it will be

It should NOT:

- Demand anything material (money, removal, action, capitulation)
- Threaten exploitation, leak, or escalation
- Name individuals at the institution beyond their public role
- Read as a press release. It is a letter to one specific addressee, which the archive then publishes.

---

## Non-negotiables

- **No publication before day 31.** This is the ethical line that makes Register B work. Violating it ends the program.
- **No fabrication.** If a detail in the finding can't be verified, omit it from the letter.
- **No exploit code.** Even in the archive entry, even as "context." The finding is the artifact, not the exploit.
- The letter goes to the institution **first**, archive **second**. Never the reverse.
