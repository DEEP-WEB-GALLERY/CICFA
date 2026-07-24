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

Then append a row below with the date, verdict, the HEAD the pass ran against,
the on-chain balance, and any notable drift. Keep it terse: the ledger is a
trend signal, not prose.

**Second layer.** The scheduled GitHub Action
(`.github/workflows/healthcheck.yml`, 06:17 UTC cron, in practice starting ~08:40 UTC
because GitHub queues scheduled jobs) runs the same script with
`HEALTHCHECK_SKIP_RPC=1` and covers the days between local passes. Check it with
`gh run list --workflow=healthcheck.yml`; note its verdict in the row when it is
the relevant signal.

Columns: **Date (UTC)** · **Verdict** · **HEAD** · **Bounty balance (wei / ETH)** · **Notes**

| Date | Verdict | HEAD | Balance (wei / ETH) | Notes |
|------|---------|------|----------------------|-------|
| 2026-07-24 | ✅ ALL GREEN | `fb743c5` | `21000000000000` / `0.000021` | Full pass from residential IP. Site 200; tree clean, HEAD == origin/main; inline JS `node --check` OK (2 blocks); 4/4 RPCs browser-usable and agreeing on `0x1319718a5000`; QR CDN 200; both issue templates repo + live; anchor `rel=noopener` intact. Scheduled CI layer green on 4/4 consecutive daily runs (07-21 → 07-24). Balance unchanged since 07-19 (pool dormant, expected). |
