# CICFA Live-Site Health Ledger

Durable audit trail of the daily maintenance pass run by the Founding Engineer.
One row per pass. This is the persistent home for the "1 full pass + 1 ledger
row / day" cadence — the pass itself is `scripts/healthcheck.sh` (see
`docs/deployment.md` for the two-layer design).

**How to add a row.** Run the full local pass (residential IP — the RPC/CORS
probe is only faithful off a datacenter egress):

```bash
scripts/healthcheck.sh          # env unset -> full RPC/CORS probe
```

Then append a row below with the date, verdict, HEAD SHA, on-chain balance, and
any notable drift. Keep it terse: the ledger is a trend signal, not prose.

Columns: **Date (UTC)** · **Verdict** · **HEAD** · **Bounty balance (wei / ETH)** · **Notes**

| Date | Verdict | HEAD | Balance (wei / ETH) | Notes |
|------|---------|------|----------------------|-------|
| 2026-07-24 | ✅ ALL GREEN | `17dea99` | `21000000000000` / `0.000021` | Full pass from residential IP. Site 200; tree clean; 4/4 RPCs browser-usable & agree; QR CDN 200; both issue templates repo+live; anchor `rel=noopener` intact. First ledger row — establishes durable home for the daily cadence. |
