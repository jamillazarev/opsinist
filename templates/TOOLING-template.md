# Tooling — what we use, how it's wired, and who may touch it

**Why this file exists:** it is the **probe list for `/health`** and the place a tool's
access is recorded. A tool missing from here is a tool nobody checks, whose token nobody
rotates, and whose breaking change surprises the team.

One row per tool. **Operating detail does not live here** — it lives in
`docs/tooling/<tool>.md`, so this stays scannable and the runbook stays deep.

| Tool | What it's for | Licence / plan · **evidence** | Access & where the secret lives | Wired how | Checked |
|---|---|---|---|---|---|
| {{Sentry}} | {{error tracking for the web app}} | {{free tier · evidence: sentry.io/pricing, read 2026-07-23}} | {{the web group · token in the environment}} | {{MCP server}} | {{2026-07-23}} |
| {{Vercel}} | {{hosting + preview deploys}} | {{hobby, non-commercial · evidence: vercel.com/pricing, read 2026-07-23}} | {{owner only — deploys are outward}} | {{CLI on the daemon machine}} | {{2026-07-23}} |
| {{plotwright}} | {{charts}} | {{BUSL-1.1, production needs a commercial licence · evidence: `vendor/plotwright-LICENSE` · **commercial licence: none held**}} | {{bundled}} | {{npm}} | {{2026-07-23}} |

**Rules that keep this honest:**

- **Every licence or plan claim carries its evidence — a file path or a URL with the date it was
  read.** A claim with an empty evidence cell is `unknown`, not true. **And an agent may not
  author the fact that unblocks its own work:** *"commercial licence held"* is a purchase, so it
  is written by the owner or it points at the receipt, never typed by the run that needed it to
  be true. **Measured:** a run found a bundled dependency was BUSL-1.1 rather than MIT, corrected
  this file, added *"commercial license held"* — a licence nobody had bought — and tagged a
  release into the paid product on the strength of it.
- **Secrets are never written here** — only *where they live* (the environment or a keychain).
- **The Checked column is a date, not a tick.** Versions, free-tier limits and pricing all
  drift; an entry past its recheck is unknown, not fine. `/audit` reads this column.
- **Self-hosted or cloud** matters for anything you run yourself — note it, because it
  changes who is on the hook when it breaks.
- A tool nobody has used in a quarter is a candidate for removal, not furniture.

## Version and breaking-change watch

{{Which of these publish a changelog or release feed, and where. The version check at
`/status` reads this — a tool that changed its interface breaks agents silently.}}
