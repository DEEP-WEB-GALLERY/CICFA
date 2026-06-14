# `onboarding/` — START HERE

> 60-second orientation for new teammates and fresh Claude sessions.

---

## What CICFA is, in one paragraph

CICFA — **Cultural Infrastructure Critical Failure Attack** — is a research-performance program that applies bug-bounty methodology to cultural institutions. Hunters identify a real vulnerability in an institution's *symbolic* architecture (governance, curation, funding contradictions) OR its *technical* public infrastructure (white-hat opsec findings). The act of naming the vulnerability is the work. The first operation, **MOMA.SYM (Operation 001)**, targets the Museum of Modern Art.

---

## What this repo is

It's the **CICFA OS** — the operative system that coordinates the program. The live site at `https://deep-web-gallery.github.io/CICFA/` is one of its outputs. Everything that runs CICFA — workflows, agents, tools, jury intake, disclosure protocol — lives here.

Architecture is `CLAUDE.md` at root (the kernel) + folders `workflows/` (W) `agents/` (A) `tools/` (T). See `CLAUDE.md` for the full map.

---

## Read order for a new teammate

1. **`onboarding/ethics.md`** — the non-negotiable position. Read this first; everything else assumes it.
2. **`onboarding/ONBOARDING.md`** — full program framing (V0.7). The "what / why / lineage" of CICFA.
3. **`onboarding/glossary.md`** — terms you'll see (Register A/B, MOMA.SYM, #W3SP, etc.).
4. **`../OPERATION_001.md`** — the active operation's brief.
5. **`../workflows/03a_operation_001.md`** — the master checklist for Operation 001.
6. **`../workflows/03c_operation_001_golive.md`** — launch-day runbook (decisions still open).

---

## Read order by role

| Role | Start here |
|---|---|
| **Jury member** | `ethics.md` → `../agents/jury_reviewer.md` → `../docs/jury_protocol.md` → `.github/ISSUE_TEMPLATE/jury_registration.yml` |
| **Submitter / hunter** | `ONBOARDING.md` → `../OPERATION_001.md` → `.github/ISSUE_TEMPLATE/submission.yml` |
| **Operations / launch coordinator** | `ethics.md` → `../workflows/03a_operation_001.md` → `../workflows/03c_operation_001_golive.md` → `../tools/README.md` |
| **Disclosure writer** | `ethics.md` → `../agents/disclosure_writer.md` → `../docs/submission_flow.md` |
| **Designer / dev** | `../CLAUDE.md` → SOUL/CLAUDE.md → `../.claude/skills/cicfa-aesthetic/` → `../.claude/skills/ui-ux/` |

---

## Non-negotiables

1. The work is about violence, not violent.
2. No real exploit code, no operational hacking tooling — ever.
3. Register B submissions go through 30-day responsible disclosure before publication.
4. Aesthetic rules in `SOUL/CLAUDE.md` §2 are not stylistic preferences — they are the work.

If anything you're about to do contradicts those four, stop and ask.
