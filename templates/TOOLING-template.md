# Tooling — what we use, how it's wired, and who may touch it

**Why this file exists:** it is the **probe list for `/health`** and the place a tool's
access is recorded. A tool missing from here is a tool nobody checks, whose token nobody
rotates, and whose breaking change surprises the team.

**Every row says what it REPLACES**, and `we had none` is a complete answer — often the true
one, because the work was not being done at all. A tool arrives in a minute and is maintained
for a year, and the rung above choosing one is asking whether the work already had a way
(`choosing-tools.md`). The guard refuses a row that leaves it blank **unless a line in `_ops/DECISIONS.md` names this tool** and says what came before — either place counts, and the guard says so when it refuses. It does not judge the
answer, only its absence.

One row per tool. **Operating detail does not live here** — it lives in
`_ops/runbooks/<tool>.md`, so this stays scannable and the runbook stays deep.

**Where a native file declares the tool, *Wired how* names that file and the row does not repeat
its version** — `.mcp.json` for an MCP server, `mise.toml` for a runtime, a CLI tool or a system
package. The file is the truth for *what and which version*; this row is the truth for *why*. The
guard holds them to each other in both directions: an entry in the file with no row here, and a row
here naming a file that does not declare it, are both refused (`tooling.md` → *What the project
needs from the machine*). **The *Tool* cell is the entry's own name in that file** — the server's
key in `.mcp.json`, the tool's key in `mise.toml` — because that is how the guard finds it.

**Two columns answer questions nobody asks unprompted.** *Wired how* names **what the service
ships and which of it you took** — an MCP server, a CLI, an SDK, an agent skill, a documentation
endpoint — because each one is work you do not have to write, and the question only gets asked where
there is a cell to answer it. **`checked 2026-09-18 · none found` is a complete answer**; an empty
cell is not, because it cannot be told apart from nobody having looked. And *Gone when* is the
condition that retires the row: **a dependency with no removal condition never leaves.** Write the
observable one — *when the platform ships it*, *when the free tier stops covering us*, *when the
feature it serves is cut* — not *when we don't need it*.

| Tool | What it's for | **Replaces** | Licence / plan · **evidence** | Access & where the secret lives | Wired how · **what it ships** | **Gone when** | Checked |
|---|---|---|---|---|---|---|---|
| {{sentry}} | {{error tracking for the web app}} | {{the log-grepping we did by hand}} | {{free tier · evidence: sentry.io/pricing, read 2026-07-23}} | {{the web group · `${SENTRY_TOKEN}` from the environment}} | {{`.mcp.json` · ships MCP (taken) · CLI · SDK — checked 2026-07-23}} | {{the runtime reports errors itself, or the app stops having users}} | {{2026-07-23}} |
| {{ffmpeg}} | {{cutting the demo videos}} | {{we had none — clips went out uncut}} | {{LGPL · evidence: ffmpeg.org/legal.html, read 2026-07-23}} | {{none}} | {{`mise.toml` · CLI only — checked 2026-07-23 · no MCP, no SDK we need}} | {{we stop shipping video}} | {{2026-07-23}} |
| {{the host}} | {{hosting + previews}} | {{we had none — nothing was published}} | {{hobby, non-commercial · evidence: its pricing page, read 2026-07-23}} | {{owner only — publishing is outward}} | {{CLI on the daemon machine · ships CLI (taken) · API · MCP — checked 2026-07-23}} | {{the non-commercial plan stops applying to us}} | {{2026-07-23}} |
| {{plotwright}} | {{charts}} | {{screenshots pasted by hand}} | {{BUSL-1.1, production needs a commercial licence · evidence: `vendor/plotwright-LICENSE` · **commercial licence: none held**}} | {{bundled}} | {{npm · library only — checked 2026-07-23}} | {{**the day this ships to a paying user** — the licence decides it, not us}} | {{2026-07-23}} |

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
