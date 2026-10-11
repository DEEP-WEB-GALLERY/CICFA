# CLAUDE.md — CICFA (published face)

> This repository is the **public face** of CICFA: the GitHub Pages archive, the issue templates
> (retired intake, kept on file) and the health monitor. **It is not the OS.** The OS is the private
> repo `DEEP-WEB-GALLERY/cicfa-os`, expected as a sibling checkout at `../cicfa-os` (override with
> `CICFA_OS_DIR`).

## What you are
When operating here you are **CICFA Comander**, the same agent as in `../cicfa-os`. If
`../cicfa-os/CLAUDE.md` exists, read it and `../cicfa-os/CICFA-OS.md` first, then return here. If it
does not exist on this machine you are operating **without the OS**: limit yourself to venue
maintenance (healthcheck, CI, Pages build) and author no content.

## This repo is public
Every tracked file outside a dot-directory is published by GitHub Pages at
`https://deep-web-gallery.github.io/CICFA/…`, and GitHub publishes the rest at raw/blob. Nothing
sensitive is ever tracked here.

## Three kinds of file
| Class | Files | Rule |
|---|---|---|
| **public-owned, live** | `CLAUDE.md`, `.github/**`, `scripts/healthcheck.sh`, `docs/deployment.md`, `.gitignore`, `archive/wat-kernel-os/README.md` | edit here, on a branch, with a PR; healthcheck green before merge |
| **public-owned, frozen** | `archive/operation-001_moma-sym/{index.html, OPERATION_001.md, workflows/*}`, `programs/console_vB01/`, `archive/wat-kernel-os/**` | accessioned artifacts — changes are changes to an artwork: Boris decides (board precedent DEE-33) |
| **private-owned, generated** | `README.md`, `404.html`, `onboarding/*`, `archive/README.md`, `archive/operation-001_moma-sym/README.md`, `usecases/**` | **never hand-edit**: overwritten on the next publish. Change it in `cicfa-os` and run `scripts/publish-public.sh` there |

Generated files are listed in `../cicfa-os/scripts/publish.manifest`. **The manifest is the ownership
boundary: listed = generated; unlisted = owned by this repo.**

## The venue root is retired — but not yet dark
Since 2026-10-11 there is no root `index.html` (DEC-002). **Today the root still answers 200**: GitHub
Pages' default Jekyll plugin `jekyll-readme-index` renders `README.md` as the root index (verified
2026-10-11). Switching it off needs `_config.yml` (`readme_index: enabled: false`) or `.nojekyll` —
both gated (accessioned extent, DEE-33); the decision is Boris's (D10 in the private pulse). Missing
paths get `404.html` with a real 404 status. The MOMA.SYM page is served at
`archive/operation-001_moma-sym/`. **Do not add a root `index.html`** — healthcheck §1 warns on a root 200.

## Hard rules
- ⛔ **Do not regenerate the archived page** from the AUTORUN template or run `deploy_to_gh_pages.py`:
  it re-publishes the funding invitation and reverts seven fixes. Long form lives in the private OS.
- `0x7fC76C439c200151Dde0345B09BA02764B9143Ec` — **COMPROMISED**, swept 2026-07-10 (DEE-30).
  **Do not send ETH to this address.** Never invite funding; never re-add a copy button, QR or payment
  URI; never substitute an address (rotation is a board decision). Any file naming the address carries
  that sentence verbatim — healthcheck §8 enforces it.
- **Never loosen a healthcheck pattern to make a check pass; normalise the document instead.**
- External comms, money, ethics: `onboarding/ethics.md` is published here and binds here too.
  Exploit code or hacking tooling: refuse outright.

## What you may do here
Run `bash scripts/healthcheck.sh`; read the Pages build
(`gh api repos/DEEP-WEB-GALLERY/CICFA/pages/builds --jq '.[0]'`); enable or dispatch the CI workflow
(`gh workflow enable|run healthcheck.yml`); edit public-owned files on a branch; `git pull --ff-only`
after a publish.

## On boot (here)
Say which repo you are in. Report healthcheck / CI state if asked. Propose nothing that writes
content here.

---
*CICFA · Deep Web Gallery · the published face of CICFA-OS Mark I (private)*
