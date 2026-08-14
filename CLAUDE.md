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
   inside preflight** → tag → **GitHub Release whose notes are the entry whole, with the
   entry's own heading collapsed to the bare italic date** — the title already carries
   version and name, and a repeated heading is the first thing every reader scrolls past:
   `python3 -c "…"` strips `## X.Y.Z — DATE` to `*DATE*`, then
   `gh release create vX --notes-file …`.
6. **Site**: `cd ~/Dev/ai && python3 scripts/generate-opsinist.py ~/Dev/opsinist` — commit
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
  found phrase read as absent (measured 2026-08-14 in the company-preflight suite). Wrap the
  left side in `(… || true)` when the pipe's verdict is the right side's.

- Eval clean-room: homes under the session scratchpad need their **own** keychain entries
  (`Claude Code-credentials-<sha256(home)[:8]>`) and their own logins for long rounds —
  copied tokens lose the refresh race. Details and traps: `evals/RUNS.md`.
- BSD `find -delete` on the `/tmp` symlink is a silent no-op — resolve the physical path.
- Hook enforcement is a form × path × version matrix — never narrate a probe, stamp it. On 2.1.220 (mechanical, 2026-08-08): plugin hooks fire under `-p`; **exit-2 denies enforce from the plugin**, the `permissionDecision` JSON form is ignored there and honored from `settings.json`. The 2026-08-07 "plugin hooks don't fire under -p" held on the older CLI — date every such claim.
- Lenses run in worktree isolation, and the tree is checked clean before any tag — `--disallowedTools` does not see a shell redirect (the sibling's read-only lens wrote 15 MB).
- A `PostToolUse` hook's stderr never reaches the model; only `hookSpecificOutput.additionalContext` does (sibling-measured).
- GitHub issues land as triage: read, classify, fix or decline with a reason, close with
  the reasoning in a comment.
