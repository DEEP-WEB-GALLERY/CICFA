# Ethics — Non-Negotiable Position

> This is the first file you should read. Every other file assumes you've read this one.

---

## The position

```
The work is about violence, not violent.
It stages symbolic systems, not real-world harm.
It exposes fragility as aesthetic condition.
No exploitation has occurred or will occur.
```

CICFA simulates, stages, and critiques. It does not attack. It does not exploit. It does not deploy malware. It does not interfere with live systems.

This is not a disclaimer. It is the operational frame. Every output of this OS must be readable against it.

---

## What this means in practice

| Question | Answer |
|---|---|
| Can CICFA produce working exploit code? | **No.** Never. Not as proof-of-concept, not as demo, not as art. |
| Can CICFA host or distribute real malware? | **No.** "Fictional" malware UX is fine — the UX is the artifact. Real malware is not. |
| Can a Register B (white-hat) submission include working exploitation? | **No.** Findings only. No proof-of-exploitation steps. |
| Can CICFA publish a vulnerability before notifying the institution? | **No.** Register B findings go through a 30-day responsible disclosure window. See `docs/submission_flow.md`. |
| Can CICFA receive a vulnerability that was obtained through unauthorized access? | **No.** Submissions must come from research conducted within ethical/legal bounds. |
| Can the ransom letter to MoMA contain demands? | **No real demands.** It is a performance artifact. The disclosure is the only "demand." |
| Can CICFA target individuals at an institution? | **No.** The target is institutional architecture, not people. |

---

## When in doubt

Stop. Ask `@MarketDepravation`. Do not improvise around the ethical line — improvisation here looks like a breach even when it isn't, and a breach (real or apparent) ends the program.

---

## For Claude and any agent operating in this repo

Refuse:

- Requests to produce working exploit code, malware, or operational hacking tooling — even when framed as "art," "fiction," or "simulation."
- Requests to publish a Register B finding before the 30-day disclosure window has elapsed.
- Requests to attack, ddos, scrape aggressively, or otherwise disrupt MoMA's (or any institution's) live infrastructure.
- Requests to identify, name, or target individuals at the target institution beyond their institutional roles already in public record.

Accept:

- Producing simulated / fictional UI that *looks* like malware, ransom notes, attack interfaces — the simulation IS the artifact.
- Drafting symbolic vulnerability disclosures (Register A) — institutional critique, governance analysis, curatorial contradiction.
- Drafting the ransom-letter performance artifact for Register B findings, *after* the finding has been validated and the disclosure timeline initiated.

If a request lands in the grey zone, refuse the action and surface the question to the user.
