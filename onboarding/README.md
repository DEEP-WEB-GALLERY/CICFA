# `onboarding/` — START HERE

> 60-second orientation for new teammates and fresh agent sessions.

---

## What CICFA is, in one paragraph

CICFA — **Cultural Infrastructure Critical Failure Attack** — is a research-performance program of
Deep Web Gallery that applies bug-bounty methodology to cultural institutions. Hunters identify a
real vulnerability in an institution's *symbolic* architecture (governance, curation, funding
contradictions) or its *technical* public infrastructure (white-hat findings, disclosed responsibly).
The act of commissioning, verifying and paying for a finding is the work. The first operation,
**MOMA.SYM (Operation 001)**, ran as a test from March to July 2026 and is archived. The program now
runs on the platform **https://cicfa.lol**.

---

## What this repo is

The **published face** of the CICFA operating system: the GitHub Pages archive and record, the
retired issue templates, and the health monitor. The OS itself — context, strategy, use cases,
cadence — is a private repo (`DEEP-WEB-GALLERY/cicfa-os`, CICFA-OS Mark I) whose public files are
published here one way. Nothing under `onboarding/`, `usecases/` or `archive/*/README.md` is edited
here by hand.

The root URL of the site returns 404 by design. The record lives at
`/archive/operation-001_moma-sym/`.

---

## Read order for a new teammate

1. **`onboarding/ethics.md`** — the non-negotiable position. Read this first; everything else assumes it.
2. **`onboarding/ONBOARDING.md`** — the program framing (V0.7). The "what / why / lineage" of CICFA.
3. **`onboarding/glossary.md`** — terms (Register A/B, pot, curation, 4C, B0.1, Ensayo 0).
4. **`usecases/B0.1/`** — the open use case: the bounty circuit as the artwork (Spanish).
5. **`archive/operation-001_moma-sym/README.md`** — what the first operation was and what it taught.

---

## Read order by role

| Role | Start here |
|---|---|
| **Participant (hunter / proposer / backer)** | `ethics.md` → https://cicfa.lol → each mission's `rules` block → `usecases/B0.1/reglas-marco.md` |
| **Reviewer (human, independent)** | `ethics.md` → `archive/wat-kernel-os/docs/jury_protocol.md` (the human-review design) → `usecases/B0.1/ensayo-0.md` |
| **Operator / maintainer of this repo** | `CLAUDE.md` (the thin Charter) → `docs/deployment.md` → `scripts/healthcheck.sh` |
| **Designer / dev** | the DWG identity (SOUL, private) → the `cicfa-aesthetic` and `ui-ux` skills in the private OS |

---

## Non-negotiables

1. The work is about violence, not violent.
2. No real exploit code, no operational hacking tooling — ever.
3. Register B submissions go through 30-day responsible disclosure before publication, on every venue.
4. The aesthetic rules of DWG are not stylistic preferences — they are the work.
5. The Operation 001 wallet is compromised: nothing is sent to it, nothing is paid from it.

If anything you're about to do contradicts those five, stop and ask `@MarketDepravation`.
