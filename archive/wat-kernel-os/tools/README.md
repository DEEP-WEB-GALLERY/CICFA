# `tools/` — T in WAT

Mostly pointers. The real generators live in `DWG_AUTORUN_BETA/tools/`. This folder is for repo-local utilities only — small scripts that operate on this repo's own state.

---

## External generators (in `DWG_AUTORUN_BETA/tools/`)

These are the canonical tools for producing CICFA assets. Do **not** duplicate them here — they live in AUTORUN as a deliberate separation: the OS coordinates, the generators produce.

| Generator | What it produces | When to run |
|---|---|---|
| `generate_bounty_site.py` | The full red-accent `index.html` (live site) | ⛔ **Do not run — see `CLAUDE.md` §5.** The template is the March original: it would re-publish the funding invitation for a wallet whose key is compromised (DEE-30) and revert seven fixes (DEE-14/15/19/22/23/28/30). Edit `index.html` here directly. |
| `generate_open_call.py` | `.tmp/open_call.html` — secondary deploy asset | Pre-launch (`workflows/03c_*` STEP 2) |
| `generate_social_posts.py` | `.tmp/social_posts.md` — Twitter / IG / Mastodon copy | Pre-launch (`workflows/03c_*` STEP 2) |
| `generate_email_blast.py` | `.tmp/email_blast.md` — email campaign copy | Pre-launch (`workflows/03c_*` STEP 2) |
| `generate_ransom_letter.py` | `.tmp/ransom_letter.html` — Register B disclosure artifact | When a Register B submission is approved (`docs/submission_flow.md` Stage 5B) |
| `deploy_to_gh_pages.py` | Pushes `.tmp/bounty_site/index.html` to this repo's `main` | ⛔ **Do not run.** Its source artifact `.tmp/bounty_site/index.html` is a March render that still carries the funding invitation and QR (DEE-30). The script now refuses while funding is suspended; don't clear the interlock to get past it. Commit + push from `CICFA_PUBLIC` instead. |

### Invocation pattern

```bash
cd /Users/boris/Documents/DWG/DWG_AUTORUN_BETA
python3 tools/<generator>.py
# review output in .tmp/
# then either commit + push from CICFA_PUBLIC, or run deploy_to_gh_pages.py
```

### CONFIG fields

Each generator has a `CONFIG` dict at the top of its file. Field names must match what the launch runbook lists (`workflows/03c_operation_001_golive.md` STEP 1). If they drift, fix the doc to match the code — the code is the source of truth for field names.

---

## Repo-local utilities (this folder)

None yet. If you write one, follow these rules:

1. **Don't reinvent generators.** If it produces an asset, it belongs in AUTORUN.
2. **Operate on repo state.** Small scripts for log-merging, archive entry templating, etc.
3. **Pure Python, stdlib-only where possible.** Avoid adding dependencies — this repo is mostly static.
4. **Add to the table below when you create one.**

| Script | Purpose |
|---|---|
| _(none yet)_ | |

---

## See also

- `workflows/03c_operation_001_golive.md` — uses the generators above on launch day
- `docs/deployment.md` — how `deploy_to_gh_pages.py` interacts with this repo's Pages setup
- `docs/submission_flow.md` Stage 5B — when `generate_ransom_letter.py` fires
