# OPERATION 001 // MOMA.SYM — accession record

```
STATUS        ARCHIVED — PAST TEST
POT           COMPROMISED — DEE-30 — swept 2026-07-10
JURY          NEVER SEATED — 0/5
SUBMISSIONS   0 — no issue of any kind was ever opened on DEEP-WEB-GALLERY/CICFA (verified 2026-10-11)
PAGE          kept published as the record → ./index.html
RUNBOOKS      ./workflows/ (frozen) · brief: ./OPERATION_001.md
```

## What it was

The first CICFA bounty operation. One named target (the Museum of Modern Art, NYC); two registers —
A, symbolic (governance, curation, funding contradictions) and B, technical white-hat (findings only,
30-day disclosure); a self-assembling 5-seat jury with wallet-signed votes; intake through GitHub
issue templates; a mainnet ETH pot. The reward promise drifted between surfaces — the README and the
brief said "No cash. No crypto."; the master runbook promised an "ETH bounty pool". A page in the
DWG terminal aesthetic announced a breach window that never closed because it never really opened.

## Timeline (verified in the public repo's history unless marked)

| Date | Event |
|---|---|
| 2026-02-17 | onboarding draft PDF (file date, not a commit) |
| 2026-03-16 | program framing V0.7; screenshot and screen recording (file dates) |
| 2026-03-17 | go-live plan note; launch commit `e9a5b28`; conceptual-framework commit `c52efa5` |
| 2026-03-18 | page v2 deployed (`5113c57`) |
| 2026-03-19 | the only contribution the pot ever received (Ξ0.000662); fork `mnrrxyz/CICFA` taken |
| 2026-05-22 | project-context snapshot |
| 2026-07-10 | the pot is swept (nonce 0 — the first and only send from the wallet was the theft) to a collector that drained 77 wallets in twelve days |
| 2026-07-20 | `scripts/healthcheck.sh` added (`849909e`) |
| 2026-07-24 | funding solicitation removed from the page (`8a9b87a`) |
| 2026-07-26 | jury status told the truth (`935e744`); payout promises removed from the forms (`6d43e46`); last commit of the operation (`c1a2955`) |
| 2026-10-11 | archived; page moved to this path; the site root retired (404 by design) |

## What happened

No jury. No submissions. One contribution, and it was stolen. From July on, the repo's engineering
went into guarding a dead pot — sections 8 to 12 of the health monitor exist because of it.

## What was learned — what any next circuit must answer

1. A named target plus an open call, without a funded and custodied pool and a staffed review, is a
   page, not a performance. **The circuit executes end to end or it isn't the work.**
2. A pot whose key the gallery does not hold is not a pot. **Custody and settlement are design
   requirements, not configuration; rehearse on a test network before any real pool.**
3. A review body that self-assembles from volunteers never assembles. **Review is designed and
   staffed before publication; machines may organize evidence, humans rule.**
4. Naming the target before rules, funding and review exist commits the program to an antagonism it
   cannot carry. **Institution-agnostic until the rules are published; naming is step 1 of the circuit,
   not of the repository.**
5. Writing the "reference vulnerabilities" ourselves was a predetermined accusation. **The reward
   pays for the research, not for an accusation decided in advance.**
6. The reward promise drifted between surfaces. **One rule set, published before the first claim,
   identical everywhere.**
7. The monitoring outlived the operation. **Keep it: security invariants are cheap to keep and must
   survive the archive.**

## Standing security rule

```
0x7fC76C439c200151Dde0345B09BA02764B9143Ec — COMPROMISED
// the private key is held by a third party · swept 2026-07-10 (DEE-30)
// Funding suspended. Do not send ETH to this address.
// never invite funding · never re-add a copy button, a QR code or a payment URI
// rotation is a board decision, not an edit
// the health monitor (§8, §11, §12) keeps running against this archive
// the fork mnrrxyz/CICFA must keep GitHub Pages off
```

## Status edits made to `index.html` on archiving (2026-10-11)

The only rewrites. Everything else is verbatim. The `pot-alert` and `fund-alert` blocks were not
touched: the monitor greps them for `Funding suspended` and `Do not send ETH to this address`.

| Element | Was | Now |
|---|---|---|
| `<title>` | `MOMA.SYM — CICFA Bounty Program` | `MOMA.SYM — CICFA Operation 001 — ARCHIVED` |
| meta description | "…Take the challenge." | "…archived past test (2026-03 → 2026-07). Funding suspended — the pot address is compromised." |
| status badge | `ACTIVE` | `ARCHIVED` |
| target pill | `BREACH WINDOW OPEN // MoMA SELECTED` | `BREACH WINDOW CLOSED // PAST TEST // RECORD` |
| breach modal subtitle | `OPERATION 001 ACTIVE // TARGET ACQUIRED` | `OPERATION 001 ARCHIVED // RECORD ONLY` |
| boot line | `status: BREACH WINDOW OPEN` | `status: ARCHIVED — PAST TEST 2026-03 → 2026-07` |
| alert marquee | breach window active / submit your findings | archived · jury never seated · submissions 0 · pot compromised · the program continues at cicfa.lol |
| hunt call to action | `⊗ Take the Challenge` | `⊗ Read the Record` |
| submit links | GitHub issue template | cicfa.lol (intake closed 2026-10-11) |
| self-link in the footer | the site root | this page |
| banner above the hero | — | three lines: `OPERATION 001 // MOMA.SYM — ARCHIVED · PAST TEST · 2026-03-17 → 2026-07-26` / `// no jury seated. no submissions. pot compromised 2026-07-10 (DEE-30). the page stays published as the record.` / `// the program continues at cicfa.lol — nothing on this page accepts findings or money any more.` |

```
// what remains is the record. the record is the work.
```
