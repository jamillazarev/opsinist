# This is the skill's own repository

Development of the skill, not use of it. **Reading this from inside another project means the
routing went wrong**: a project built *with* the skill carries its own generated `CLAUDE.md`,
and that guide governs there — this file governs only work on this source tree (runtimes load
a plugin's skills, never its root guide, so the two cannot meet by accident). **The full contract is [AGENTS.md](AGENTS.md)** —
read it before changing anything of consequence; [GLOSSARY.md](GLOSSARY.md) and
[PATTERNS.md](PATTERNS.md) before writing prose others will read. What follows is the loop
this file exists to stop anyone re-deriving per session.

## The session loop

1. **Change** — one home per rule; cite patterns, never restate; anchors are headings.
   When a rule does not hold, the repair is **a form, not a stronger sentence** (measured).
   **Any new capability meets the capability bar before it ships** — the four clauses of
   `self-maintenance.md` §What-a-capability-owes: a form where it can fail · the mutation
   test denying the mutant and passing the twin · the claim dated with its measurement ·
   the showcase trio. No exceptions for small ones — the sibling's ledger and ours both
   carry releases that looked finished without it.
2. **Lenses** on anything of consequence — deletion · adversarial · contradiction ·
   cold-read, by a reader who did not write it, each reporting even when empty.
3. **The showcase trio** for every new mechanic: a diagram · a situation (`use-cases.md`) ·
   a fact (`facts.md`). Wording-only changes owe nothing — say so.
4. **Checks**: `bash scripts/preflight.sh` (runs every shipped test suite itself) ·
   `python3 scripts/check-links.py .` · `bash scripts/test-audit-gate.sh`. Green is evidence
   about the corpus, not about behaviour — behaviour is the eval suite's job.
5. **Changelog entry** (capability first; it is the migration map; **it names its eval state — a run recorded, or `not run` said**) → **manifest sweep runs
   inside preflight** → **set the entry's date to the day the tag is actually cut, as the last
   act before tagging** — it is written days earlier and the tag waits for the developer, so the
   two dates drift by however long that takes and a reader takes the heading for the ship date
   (measured 2026-08-22: 0.2.8 and 0.4.7 both said 08-16 against tags cut 08-20; preflight §1a-ter
   now compares them) → tag → **GitHub Release whose notes are the entry whole, with the
   entry's own heading collapsed to the bare italic date, and whose TITLE is `X.Y.Z — <headline>`
   — no `v`, an em dash. The last two releases used `vX.Y.Z: <headline>` and broke a run of
   fifteen** (spotted 2026-08-22 on the release list, where the odd ones stand out at a glance) — the title already carries
   version and name, and a repeated heading is the first thing every reader scrolls past:
   `python3 -c "…"` strips `## X.Y.Z — DATE` to `*DATE*`, then `gh release create` with
   `--notes-file`.
   **And a correction to a FROZEN entry re-publishes that release in the same breath.** Release
   notes are a snapshot taken once; a marked correction reaches `CHANGELOG.md` and the site and
   never the page most people read, so the file admits an error the release goes on repeating.
   Measured 2026-08-29, after the owner spotted two correction blocks on the site against one on
   GitHub: **eight releases across the two repositories had drifted this way**, every missing
   block dated after its own tag. `bash scripts/check-releases.sh` compares every published
   release against its entry and prints the one command each gap needs (`--emit <dir>` writes the
   files); it is a report, not a gate, because it needs the network and preflight runs offline.
   Its first draft flagged 23 of 35 — all but three by a single blank line — so both sides are
   normalised before comparison: **a check that cries wolf is a check nobody reads.**
6. **Site — BOTH generators, then BUILD IT.** `cd ~/Dev/ai`, then this repo's own
   (`scripts/generate-opsinist.py ~/Dev/opsinist`) **and the sibling's**
   (`scripts/generate.py <its repo>`) — **and then `npm run build`, which must exit 0 before the
   commit.** This step regenerated and pushed without ever building for as long as it has
   existed, and a failed production build is invisible from here: Vercel keeps serving the last
   good deployment, so the site looks merely *stale* rather than broken. It has happened twice —
   `aec3c0d`, whose fix sat on one machine for days, and `cc3b9c0` on 2026-08-29, where **a
   changelog sentence mentioning an unfilled `{{…}}` template cell killed the build**: VitePress
   compiles every page as a Vue template, so `{{ }}` is an expression *even inside backticks*.
   Both generators escape it now (`vue_safe`), and the build is the check that the escape held. This step named only
   the first for as long as it has existed, so the sibling's pages went stale by two releases —
   found 2026-08-20, its changelog page still showing a date corrected before that tag was cut,
   i.e. the site describing a version that shipped under a different one. A release touches one
   repository; the site carries both. Commit
   and push that repo too; a release that skips this ships docs describing the previous
   version. New page-worthy files need a route in the generator first.
7. **Installs on this machine**: `bash scripts/find-installs.sh`, follow each row's route,
   run it again, read every row at the new version. **The script's output is the canon, not
   any remembered count** — machines differ, installs come and go, and a runtime the script
   does not know yet is added to it when met (assume incompleteness). This machine's current
   routes, as examples only: Claude marketplace update + plugin update · Codex marketplace
   upgrade + plugin add · Gemini: publish the Release, then uninstall +
   `install <repo-url> --consent` (its update follows releases, not tags) · copies: rsync.
8. **Memory**: update the project memory file with what shipped and what is owed.

## Versioning

**The tag waits for the developer — every release, its own word.** Everything before it —
the entry, the bump, the checks — is preparation and may land in `main`; **the tag, the
GitHub Release, the site push and the machine re-sync are cut only after an explicit yes**,
and an earlier yes does not roll forward to the next version. This is `shipping.md`'s own
law — *deploy and announce are outward, owner-confirmed every time* — applied to the one
repository where it is easiest to forget.

**Evidence moves without a tag; a rule moves with one.** Run records, RUNS entries, verdicts —
plain commits. Anything that changes behaviour or format — a release, however small, so
nothing accumulates outside versions.

## Machine notes

- **A pipe eats the exit code**: `preflight.sh | tail` gates nothing — capture the code
  first (`cmd > /tmp/out 2>&1; echo $?`), then read the tail. Measured on this repo: a red
  preflight rode a green pipeline into main. **And pipefail resurrects it in mirror**: under
  `set -o pipefail`, `cmd | grep -q` returns *cmd's* failure even when grep **matched** — a
  found phrase read as absent (measured 2026-08-14 in the company-preflight suite). **`( … || true )`
  does NOT fix it** — verified under bash the same week: `grep -q` exits on its first match and
  SIGPIPEs the producer, and a subshell's `|| true` cannot catch a signal that lands on the left
  side of a pipe. **Count instead**: `grep -c` drains its input, so nothing can signal it —
  `[ "$(… | grep -c pattern)" -gt 0 ]`. Measured again 2026-08-16 at rc=141 on a large input with
  the match on line 1, in a check written the day before by someone who had read this note.

- **The `grep` you test at the prompt is not the `grep` a script gets** (measured 2026-08-15).
  In this tool's shell `grep` is a **shell function** (from the zsh snapshot) resolving to
  **ugrep 7.5.0**; a plain `bash script.sh` gets **`/usr/bin/grep`, BSD 2.6.0-FreeBSD**. They
  disagree: on `**Status**: x · **Stage**: y`, `grep -coiE` returns **2** under ugrep and **1**
  under BSD, because BSD `-c` counts matching LINES and ignores `-o`. So a hand-check at the
  prompt can confirm a gate that is blind inside the shipped script — measured exactly that way
  in §1c, where a command-line check briefly "disproved" a true lens finding. **Check a shell
  behaviour by running it the way the script will** (`bash -c` / a temp script), and prefer
  forms that cannot differ: `grep -o … | grep -c .` counts occurrences everywhere.

- **`timeout` is Homebrew's, not macOS's** (measured 2026-08-20): a suite that wrapped calls in
  `timeout 90` was green on this machine and failed every assertion with **127** on a macos-latest
  runner. Third instance of the grep/awk class — the tool the author has is not the tool the
  target gets. Where the bound is belt-and-braces, make it conditional (`${_TMO:+$_TMO 90}`);
  where it does real work, warn once at top level that runs are unbounded — never inside a loop.

- **The author's-tool class has a fourth member, and it is not in Homebrew** (measured
  2026-08-22): `claude` lives in `~/.local/bin`, so stripping Homebrew from PATH — the trick that
  reproduced the `timeout` failure — did **not** reproduce this one. CI failed five eval-guard
  assertions with **exit 2, "no claude CLI on PATH"**, while every local run and every
  Homebrew-stripped run was green. **What reproduced it was `env -i PATH=/usr/bin:/bin`** — a
  runner has the system tools and nothing the author installed, by any route. When a CI failure
  will not reproduce, strip the environment to the system, not to a package manager.

- **Two delivery routes on one install directory, and the second breaks the first** (measured
  2026-08-23). A release was rsync'd on top of a git *clone*, so the clone's own documented route
  — `git pull --ff-only` — refused from then on and for every release after: *"Your local changes
  would be overwritten."* **The output is the trap**: git prints `Aborting` and
  `Updating <old>..<new>` on adjacent lines, so a glance reads it as success while the install
  sits versions behind. Recovery is a **guarded** `stash push` → pull → `stash pop` — **never
  `reset --hard`**, which is repo-wide and took an unrelated file the day this was written. The
  guard is not optional: `stash push` exits **0 having saved nothing** when the only difference is
  a submodule gitlink, and the `pop` then drops whatever was already on the stack into your tree
  (measured 2026-08-28). Compare `refs/stash` across the push; `find-installs.sh` prints the whole
  line. The untracked eval artifacts in the way had to be compared against `origin/main` **before**
  removing them — they were byte-identical, which is a thing to verify and not assume.
  **Both `find-installs.sh` flag a clone with tracked files that differ from HEAD *and exist in
  HEAD* — `--no-renames --diff-filter=MDT` — anywhere in the enclosing repository, since the route
  is repo-wide, and say how many are under the install.** Every clause is load-bearing: `MDRT`'s
  `R` rows name a rename's *destination*, absent from HEAD, and the per-path
  `restore --staged --worktree --source=HEAD` the flag prints would delete those. **The count is a
  warning, never a verdict** — a staged-new or untracked file at a path an incoming commit *adds*
  also aborts the pull, with the count at 0, so the pull itself is the only exact test and it is
  free to run. The flag says **AT RISK**, because
  a modified file blocks a fast-forward only when an incoming commit touches it — a certainty
  after an rsync, which rewrites exactly what the next release changes. The Antigravity row also
  picks its route from what the directory IS; the two routes are mutually destructive and it had
  printed one flat route beside a flag saying *do not rsync onto a clone*.
  **Check what an install IS before choosing how to move it.**

- Eval clean-room: homes under the session scratchpad need their **own** keychain entries
  (`Claude Code-credentials-<sha256(home)[:8]>`) and their own logins for long rounds —
  copied tokens lose the refresh race. Details and traps: `evals/RUNS.md`.
- BSD `find -delete` on the `/tmp` symlink is a silent no-op — resolve the physical path.
- Hook enforcement is a form × path × version matrix — never narrate a probe, stamp it. On 2.1.220 (mechanical, 2026-08-08): plugin hooks fire under `-p`; **exit-2 denies enforce from the plugin**, the `permissionDecision` JSON form is ignored there and honored from `settings.json`. The 2026-08-07 "plugin hooks don't fire under -p" held on the older CLI — date every such claim.
- Lenses run in worktree isolation, and the tree is checked clean before any tag — `--disallowedTools` does not see a shell redirect (the sibling's read-only lens wrote 15 MB).
- A `PostToolUse` hook's stderr never reaches the model; only `hookSpecificOutput.additionalContext` does (sibling-measured).
- GitHub issues land as triage: read, classify, fix or decline with a reason, close with
  the reasoning in a comment.
