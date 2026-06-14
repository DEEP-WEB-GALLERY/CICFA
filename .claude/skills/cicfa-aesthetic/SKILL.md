---
name: cicfa-aesthetic
description: Visual / typographic / copy-voice rules for any CICFA or DWG output. Load this skill whenever producing HTML, CSS, copy, social-post text, ransom letters, or any user-facing artifact for CICFA. Trigger on requests touching the bounty site, the program console, social posts, emails, the ransom-letter template, or any aesthetic decision. Do not paraphrase the rules from memory — load this skill so the tokens and voice come from one place. Sits beside ui-ux which governs structure and interaction; this one governs the visual / textual surface.
---

# CICFA Aesthetic — Visual / Typographic / Voice

> The aesthetic IS the work. These rules are not stylistic preferences — violating them breaks the register.

The canonical source of truth is `/Users/boris/Documents/DWG/SOUL/CLAUDE.md` §2 ("Aesthetic & Design Language"). This skill summarizes the operational rules for CICFA outputs and points at SOUL for anything not covered here.

---

## 1. Palette (tokens)

```css
--bg:      #0a0a0a;   /* near-black, never pure black */
--fg:      #e8e8e8;   /* terminal white */
--accent:  #ff2d2d;   /* threat red — primary CTAs, alerts, breach */
--accent2: #00ffcc;   /* system green — confirmations, contributors, "ok" state */
--dim:     #555;      /* muted body / metadata */
--border:  #1e1e1e;   /* hairline dividers */
```

Use CSS custom properties in `:root`. Do not hardcode hex values inline.

Alternate "green-terminal" sub-palette (only for the experimental console at `programs/console_vB01/`):

```css
--bg: #07090b; --ink: rgba(200, 255, 210, .92);
--good: #43ff8e; --warn: #ffcc4a; --bad: #ff3b3b; --cyan: #4be3ff;
```

Never introduce a new palette without a reason that maps to a register shift.

---

## 2. Typography

- **Monospace only.** Stack: `ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace` (or just `'Courier New', Courier, monospace` for the live site's lighter stack).
- **Never** Inter, Roboto, system-ui-sans, Helvetica, or any geometric / humanist sans-serif.
- **No webfonts.** Use the system mono stack. The aesthetic *requires* the system's mono — that's the whole point.
- Body size: 12–14px. Heroes: `clamp(2.4rem, 6.5vw, 4.5rem)`.
- Line-height 1.6–1.8 for body; 1.0–1.1 for hero headings.
- Letter-spacing: `0.02em` on body, `0.1em–0.3em` on UPPERCASE labels.

---

## 3. Copy voice

- **UPPERCASE** for system labels, statuses, section dividers, button text: `OPERATION 001`, `STATUS: ACTIVE`, `BREACH WINDOW OPEN`, `SUBMIT FINDING`.
- **lowercase fragmented** for conceptual / curatorial prose. Run-on sentences, terminal-log register. No marketing voice.
- **Code blocks** for classification metadata:
  ```
  STATUS    ACTIVE — OPEN CALL
  TARGET    Museum of Modern Art (MoMA), New York City
  CODENAME  MOMA.SYM
  ```
- **Slash notation** for alternatives: `online/offline`, `create/push`, `Register A / B / A+B`.
- **`//`** for embedded comments in prose: `Operation 001 // MOMA.SYM // STATUS: ACTIVE`.
- **Hashtags** as structural tags (not social): `#W3SP`, `#DCP`, `#DeFiGuillotine`.
- **No emojis.** No friendly toasts. No "thanks for submitting!" — the closest acceptable is `SUBMISSION LOGGED.`
- **No marketing tropes:** "revolutionary," "seamless," "user-friendly," "delightful." Refuse them.

---

## 4. Glyphs

- Status: `●` (live) `○` (idle) `▲` (warning) `✕` (closed) `✓` (confirmed)
- Box-drawing for ASCII frames: `┌─┐│└┘` (single) or `╔═╗║╚╝` (double)
- Arrows: `→ ← ↑ ↓ ⟶ ⤷`
- Bullets: `─` (dash) inside dimmed lists
- Dot indicators: 6px circles with `dot-pulse` animation for live state (max one per page)

Avoid icon fonts (FontAwesome, Material Icons). Avoid SVG decoration. Glyphs are typographic.

---

## 5. Animations

Use minimally and intentionally:

- `dot-pulse` — live status indicators only, one per page
- `glitch` / `scramble` — headers on initial load or on operation-state changes; not every page load
- `blink` — terminal cursor only
- `jitter` — `text-shadow` micro-jitter for the active title; 6s interval; subtle
- Boot sequence on first render — progressive DOM injection via `setTimeout` is fine for the bounty site; not required elsewhere
- Transitions: max `transition: opacity 0.2s ease`. No bounce, no cubic-bezier theatrics, no scale transforms on hover.

**Never:** parallax, scroll-triggered animation, auto-playing media, skeleton loaders, lottie.

---

## 6. Layout patterns

- **Dark background, terminal feel.** Slight radial gradient for depth is fine — solid black is not.
- **Sticky top bar**, 44px, `position: sticky`, `backdrop-filter: blur(8px)`. Shows: status dot, program code, nav anchors.
- **Single-column reading width** ~860px on the bounty site, max 1220px on the console.
- **Hairline borders** (`1px solid var(--border)`). No box-shadows on cards. No rounded corners > 12px. Sharp corners (`border-radius: 0`) for buttons.
- **No card grids** like a consumer-web SaaS. Information is dense, listed, labeled.

---

## 7. CRT / breach overlays

The live bounty site (`index.html`) and the experimental console (`programs/console_vB01/`) both use CRT scanline + vignette overlays via `body.crt::before` and `body.crt::after`. The overlay should be toggleable (a button) and respect `prefers-reduced-motion`.

Don't apply CRT overlays to outputs that are meant for archival print (e.g. the ransom letter as physical wall text — that gets a different print-friendly variant).

---

## 8. Specific surfaces

| Surface | Notes |
|---|---|
| `index.html` (live bounty site) | Red-accent palette. Hero + bounty pool + dual-path CTAs (Fund / Hunt) + jury + countdown. Stays canonical for OPERATION 001. |
| `programs/console_vB01/` | Green-terminal palette. Experimental. Two-panel layout, operations board on left, framing / bounty / log stack on right. CRT on by default. |
| Ransom letter (Register B) | Sits between the two — institutional formality + breach signage. Generated by `generate_ransom_letter.py` from a Jinja template; hand-edited for tone. |
| Social posts | Match the canonical surface (bounty site = red, console = green). Square crop variants for IG; 16:9 for X. |

---

## 9. What to refuse

If asked to produce any of these for CICFA / DWG, refuse and surface the conflict:

- White or light-background variants (unless explicitly for print/archive)
- Sans-serif type or webfont imports
- Card-grid layouts borrowed from SaaS
- Friendly / reassuring / "delightful" copy
- Emoji decoration
- Generic startup hero patterns (centered headline + subhead + two-button CTA on a gradient background)
- "Cleanup" of the operative friction — friction is the point

---

## 10. When in doubt

Open `/Users/boris/Documents/DWG/SOUL/CLAUDE.md` and read §2. Then come back. Don't paraphrase from memory.
