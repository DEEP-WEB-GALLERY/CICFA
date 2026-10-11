# Glossary

Terms you'll see across the CICFA repositories. Revised 2026-10-11 for the two-repo model; entries
that describe the March-2026 program are kept and marked as such.

---

## CICFA

**Cultural Infrastructure Critical Failure Attack.** The program. Applies bug-bounty methodology to cultural institutions.

## CICFA OS

The operating system that coordinates the program — a private repo (`DEEP-WEB-GALLERY/cicfa-os`, **CICFA-OS Mark I**, built on the COMANDO Canon). The public repo `DEEP-WEB-GALLERY/CICFA` is its **published face**: the GitHub Pages archive, the record, and the health monitor. Generated files there are never edited by hand.

## CICFA Comander

The orchestration agent of the OS — a role any sufficiently-capable model assumes in the private repo. Canon spelling, one "m". It orchestrates; the principal decides.

## DWG

**Deep Web Gallery.** The parent org. CICFA is one of DWG's programs. The org identity lives in DWG's own repository (SOUL).

## DWG-CICFA-01

The program code for CICFA. Used in metadata, status bars, and signage.

## vB.01

The label of the March-2026 program release ("B" for the public/beta cycle). Historical: it appears in the archived artifacts and is not continued. The OS is versioned by **Mark**; the platform by its own number; use cases by their identifier.

## #W3SP / #UHP / #DCP

DWG's three programs:
- **#W3SP** — Web3Suicide Program (blockchain / P2P critique). Sibling to CICFA.
- **#UHP** — Uncreating Humans Program (cognitive architectures, bots as artistic agents).
- **#DCP** — Digital Clinique Program (machinic desire, non-human subjectivities).

CICFA sits in #W3SP's adjacent zone — both critique ultra-liberal market logic via infrastructure aesthetics.

---

## cicfa.lol

The program's live venue — `CICFA // BOUNTY LOGIC`, a "curated bounty exchange" (v0.1 as declared by its interface), built by Manu. Missions are broadcast, backed, claimed, curated and settled there. A separate codebase from the OS.

## Mission

A unit of work on cicfa.lol: `demand` or `offer`, with `objective / brief / rules`, a pool, backers, claims, curation verdicts and a settlement.

## Operation

A discrete CICFA campaign of the March-2026 design, targeting one institution, with a code (`OPERATION 001`), a codename (`MOMA.SYM`), a deadline, a jury, and an archive entry.

## Operation 001 / MOMA.SYM

The first and only operation. Target: Museum of Modern Art, NYC. **Status: archived as a past test (2026-10-11).** No jury was seated, no submission was received, the pot was compromised. Record: `archive/operation-001_moma-sym/`.

## Target

The institution under critique for a given operation. Operation 001 target = MoMA. **No target is named for anything current.**

## UseCase B0.1

The investigation of the first complete performance — the bounty circuit (commission → execution → evidence → evaluation → distribution) as the artwork. `B0.1` is the identifier given by the principal; it does not inherit from vB.01. Public rendering: `usecases/B0.1/`.

## Ensayo 0

The rehearsal designed to test the circuit end to end on cicfa.lol without a real institution or real money. See `usecases/B0.1/ensayo-0.md`.

---

## Register A — Symbolic / Conceptual

A vulnerability in the *institutional architecture* itself. Governance contradictions, curatorial blindspots, funding conflicts, canon-formation power. Submission format is open — written, visual, web artifact.

## Register B — Technical / White Hat

A real opsec or security finding in the target's public digital infrastructure. **Findings only — no exploitation, no proof-of-attack.** CICFA handles responsible disclosure: 30-day window before publication; the letter to the institution is part of the performance.

## Dual register

A submission that combines A + B. Often the strongest — a technical finding interpreted symbolically.

---

## Jury

The March-2026 design: a 5-seat panel, first-come-first-seated, wallet-signed votes (EIP-191), simple majority. **It was never seated.** The design is kept as the reference for independent human review (`archive/wat-kernel-os/docs/jury_protocol.md`).

## Curation

What cicfa.lol calls its review: verdicts issued under the heading `CICFA CURATION`, today by language models. Whether and how humans rule next to them is an open question of B0.1.

## Disclosure

The act of naming a vulnerability — written, visual, or hosted. The disclosure is the work; the archive is the work.

## Ransom letter

A styled letter sent to the target institution after a Register B finding is validated. A performance artifact, not a demand. Its generator lives in the frozen AUTORUN pipeline.

## Responsible disclosure window

The 30-day period between notifying the institution and publishing the finding in the archive.

## The archive is the work

Operative principle: the long-term value of CICFA is the archive of disclosures and circuits it produces, not any single operation.

---

## Bounty pool / pot

ETH held in the Operation 001 bounty wallet (`0x7fC76C439c200151Dde0345B09BA02764B9143Ec`), funded by contributors, to be transferred to a winning submitter on jury approval — as designed.

> ⚠ **The pot is compromised and funding is suspended.** The wallet's private key is held by a
> third party. The only contribution the pot ever received — Ξ0.000662, sent 2026-03-19 — was
> swept out on 2026-07-10, along with 76 other wallets drained by the same address. What remains
> is gas dust. Nothing can be paid out of this address, and nothing should be sent to it.
> **Do not send ETH to this address.** Tracked as DEE-30; whether the pot is rotated, left
> suspended or retired is an open board decision.

## Bounty wallet

`0x7fC76C439c200151Dde0345B09BA02764B9143Ec`. **Compromised** (see above). Not fundable; not to be substituted on anyone's own authority. **Do not send ETH to this address.** Rotation requires a key the gallery holds, which makes it a board decision rather than a config change.

## Pool (cicfa.lol)

The per-mission ETH amount shown on the platform, fed by named backers and settled, today, on the Sepolia test network. The custody mechanism behind it is not known from outside.

---

## 4C

The structure of the OS: **Context** (who we are, what we know) · **Connections** (live data and integrations) · **Capabilities** (agents, workflows, skills) · **Cadence** (pulse, decisions, routines, runs, evidence).

## WAT

Workflows / Agents / Tools — the vocabulary inside 4C. Cards are named `WF_*`, `AG_*`, `TL_*` with an AREA token (CORE / OPS / LAB / PLAT / ARCH).

## Skill

A `.claude/skills/<name>/SKILL.md` file — a loadable module of context the runtime discovers by description.

## Agent (capital-A)

A subagent with its own context window, defined by a pointer in `.claude/agents/<name>.md` whose canonical card lives in `capabilities/agents/`.

## Workflow

A `WF_*` card: trigger, inputs, steps with who does each, outputs, definition of done, failure taxonomy.

## Publish

The one-way flow that copies listed files from the private OS to the public repo. The manifest is the ownership boundary; listed files are generated.

---

## Mercado Central

The speculative marketplace module imagined in the program framing — deep-web aesthetics, trading in institutional vulnerabilities. **cicfa.lol is, in effect, this module** in its first working form.

## Hijack Environment

A planned CICFA module — high-fidelity mirror sites that destabilize institutional narratives. Not built.

---

## DWG_AUTORUN_BETA

A private DWG repo holding the March-2026 generators and templates. **Frozen**: regenerating the operation page from it would re-publish the funding invitation. The OS references it; it never runs it.

## SOUL

DWG's private identity repo. The canonical org identity and aesthetic rules. Loaded before any aesthetic decision; never paraphrased from memory.

## DEE-xx

Issue identifiers of the DWG agent tracker where the pot's security decisions (DEE-30, DEE-33) and the venue's maintenance history live. Read-only from the OS.
