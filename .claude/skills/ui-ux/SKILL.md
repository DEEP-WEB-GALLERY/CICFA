---
name: ui-ux
description: UI/UX design skill for DWG/CICFA interfaces. Use this skill whenever making decisions about layout, component structure, navigation, interaction patterns, information architecture, form design, user flows, or usability in any CICFA or DWG web output. Trigger when the user asks how to organize a page, what a component should look like or behave, how to handle a user interaction, where to place a UI element, or when reviewing or building any HTML template, bounty site, marketplace UI, or submission form. Also trigger when the user asks whether something "feels right" or "works" from a design or usability perspective. This skill governs the interaction layer — load cicfa-aesthetic for visual tokens, load this skill for decisions about structure, behavior, and user flow.
---

# UI/UX Skill — DWG / CICFA Interfaces

This skill governs how interfaces are structured, how users move through them, and how interaction feedback is communicated. The visual layer (palette, typography, glyphs) is owned by the `cicfa-aesthetic` skill. This skill sits above that — it's about the logic of the interface, not the skin.

Load both skills when building or reviewing any CICFA or DWG UI. They operate in tandem.

---

## Design Posture

CICFA interfaces perform a function before they communicate a feeling. The UX register follows from the conceptual register: **bureaucratic-uncanny**.

That means:

- Every interaction should feel like it was designed by an institution that takes itself seriously
- Feedback is terse and procedural, not warm ("SUBMISSION LOGGED." not "Thanks for your submission!")
- The user is a participant in an operation, not a customer having an experience
- Confusion is sometimes intentional — but disorientation must be legible, not accidental

When in doubt, ask: does this feel like it came from a government portal that was quietly repurposed for symbolic crime? If yes, proceed.

---

## Layout Principles

### Column Discipline
Follow the 64-character column rule from the cicfa-aesthetic skill. This applies to layout, not just text:

- Keep content blocks narrow and left-aligned where possible
- Use full-width only for structural elements (nav bars, section dividers, tables)
- Resist the urge to fill space — density is achieved through information, not decoration

### Vertical Rhythm
Line height of 1.6–1.8. Use vertical whitespace to denote hierarchy, not horizontal. A blank line is a structural signal, not wasted space.

### Section Hierarchy
Use a flat, label-driven hierarchy over nested visual containers:

```
[SECTION LABEL]
───────────────
content here
content here

[NEXT SECTION]
───────────────
```

Avoid card-grid layouts, modals with heavy chrome, or sidebar navigation. These read as consumer-web patterns.

### Sticky Navigation
Top bar only. Keep it minimal: operation ID on the left, navigation anchors on the right. Height: 44px. Content: status indicator, site ID, and 3–5 anchor links max.

---

## Component Patterns

### Status Indicators
Always use the glyph system from cicfa-aesthetic. Never use colored pills, badges with gradients, or icon-font indicators.

Status text should always follow the ALL CAPS label convention:
```
● [ACTIVE]
○ [CLOSED]
▲ [WARNING]
```

For live/real-time state, a pulsing dot is acceptable (`animation: dot-pulse`). Use it sparingly — one per page.

### Forms and Submission
Forms are where most user friction lives. Treat them as terminal input, not consumer onboarding:

- Labels go above fields, ALL CAPS, small letter-spacing
- Field borders: 1px solid `--border`. No rounded corners. Ever.
- Focus state: change border color to `--accent` or `--accent2`. Do not use box-shadow glow effects.
- Placeholder text: lowercase, dim color, treated as ghost instruction not label replacement
- Submit button: full-width on mobile, left-aligned on desktop. Label is imperative: `SUBMIT FINDING` not `Submit`
- Error states: inline, above the field, prefixed with `▲ ` and accent color

Example form field structure:
```html
<label>SUBMISSION REGISTER</label>
<select>…</select>
<label>VULNERABILITY TITLE</label>
<input type="text" placeholder="brief identifier, not the full description">
<label>DESCRIPTION</label>
<textarea placeholder="operational detail. what you found. what it reveals."></textarea>
```

### Tables and Listings
Prefer `<table>` or `<pre>`-formatted ASCII tables over card grids for data listings.

- Use `border-collapse: collapse` with 1px borders on `--border`
- Column headers: ALL CAPS
- Alternating row shading: subtle, e.g., `rgba(255,255,255,0.02)` on dark palette
- Clickable rows: indicate with a `▶` prefix on hover, not a background color flood

### Buttons and Pills
Two button types only:

**Primary action** — solid fill, accent color:
```css
background: var(--accent);
color: var(--bg);
padding: 0.5rem 1.5rem;
border: none;
font-family: var(--mono);
letter-spacing: 0.1em;
text-transform: uppercase;
cursor: pointer;
border-radius: 0;
```

**Secondary / nav pill** — transparent with border:
```css
background: transparent;
border: 1px solid var(--border);
color: var(--dim);
/* same padding/font as primary */
```

Hover state for both: opacity reduction (`opacity: 0.75`) or border color shift. No color transitions, no scale transforms.

### QR Codes
When displaying QR codes (e.g., wallet addresses, submission links):

- Center within a fixed-width box, padded, bordered
- Label above: `[SCAN / QR]`
- Include a plain-text fallback address below, truncated if long, with a copy button
- Light background for QR render area even on dark palette (QR requires contrast)

---

## Navigation and Information Architecture

### Page Structure Template
For a standard CICFA operation page:

```
[TOP BAR — sticky]
  ID / STATUS DOT / SITE LABEL        NAV ANCHORS

[HERO / HEADER SECTION]
  Operation name, status, brief operative description

[STATUS PANEL]
  Live bounty pool, submission count, deadline

[SUBMISSION REGISTER]
  Register A / Register B tabs or sections

[FORM]
  Submission inputs

[ARCHIVE / LEDGER]
  Past submissions, sortable

[FOOTER]
  Program code, links, contact
```

### Scroll Anchors vs. Pages
Single-page scroll with anchor links is preferred over multi-page routing for operation sites. It reads as a briefing document, which fits the register.

Use `scroll-behavior: smooth` and ensure anchor IDs are stable so they can be linked externally.

### Mobile Responsiveness
These are not mobile-first interfaces, but they must not break on mobile:

- Stack layout columns on screens under 768px
- Nav pills collapse to a single row that scrolls horizontally (no hamburger menu — too consumer-web)
- Form elements go full-width on mobile
- Table overflow: `overflow-x: auto` on a wrapper div, not `overflow: hidden`

---

## Interaction Design

### Feedback Timing
Immediate feedback on all user actions. Do not wait for server responses to show state change:

- Button click → instant visual state change (opacity drop)
- Form submission → show `[PROCESSING…]` state while awaiting response
- Success → replace form with confirmation block, not a toast/snackbar

### Animations
Use minimally and intentionally:

- `dot-pulse` — for live status indicators only
- `glitch` or `scramble` text effects — for headers on initial load, or when an operation state changes. Not on every page load by default.
- No entrance animations, parallax, or scroll-triggered effects

Transitions where used: `transition: opacity 0.2s ease` maximum. No bounce, no spring, no cubic-bezier theatrics.

### Copy and Paste
Wallet addresses, submission IDs, and operation codes should always be copyable:

- Add a small `[COPY]` button or `title="click to copy"` where relevant
- Use `navigator.clipboard.writeText()` — no flash-based fallbacks
- On copy: brief text swap (`[COPIED]`) that reverts after 1.5s

---

## UX Anti-Patterns to Avoid

These patterns read as consumer-web or startup and break the register:

| Anti-pattern | Why it's wrong |
|---|---|
| Modal dialogs with overlay | Interrupts the operational flow; feels like an app, not a system |
| Floating action buttons | Mobile-app pattern, wrong context |
| Skeleton loaders | Too polished; a brief `[LOADING…]` text is correct |
| Inline error toast notifications | Use inline field errors, not pop-up feedback |
| Accordion-heavy layouts | Hides content; these interfaces should surface information |
| Carousel/slider components | Never appropriate for this context |
| Auto-playing media | Violates the bureaucratic register |
| Cookie consent banners | If needed, integrate as a top-bar notice, not a modal overlay |

---

## Accessibility Baseline

Correctness of aesthetic does not excuse inaccessibility. Minimum requirements:

- All form inputs have associated `<label>` elements (not just placeholders)
- Color alone does not convey state — always pair color with a text label or glyph
- Focus indicators are visible (do not use `outline: none` without replacement)
- `aria-label` on icon-only buttons
- Sufficient contrast: minimum 4.5:1 for body text against background. The dark palette (`#e8e8e8` on `#0a0a0a`) passes at ~14:1. Do not compromise this with dim-colored body copy.

---

## Working with cicfa-aesthetic

This skill governs structure and behavior. `cicfa-aesthetic` governs the visual tokens. Use them together:

- Need to know what color to use for an error state? → `cicfa-aesthetic`
- Need to know where to put the error message on the page? → this skill
- Need the font stack? → `cicfa-aesthetic`
- Need to know how to structure the form around the font? → this skill
- Building a new component from scratch? → load both

When they appear to conflict, defer to `cicfa-aesthetic` for any token-level decision (color, type, glyph). Defer to this skill for layout, hierarchy, and interaction logic.
