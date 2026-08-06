# This is the skill's own repository

Development of the skill, not use of it. **The full contract is [AGENTS.md](AGENTS.md)** —
read it before changing anything of consequence; [GLOSSARY.md](GLOSSARY.md) and
[PATTERNS.md](PATTERNS.md) before writing prose others will read. What follows is the loop
this file exists to stop anyone re-deriving per session.

## The session loop

1. **Change** — one home per rule; cite patterns, never restate; anchors are headings.
   When a rule does not hold, the repair is **a form, not a stronger sentence** (measured).
2. **Lenses** on anything of consequence — deletion · adversarial · contradiction ·
   cold-read, by a reader who did not write it, each reporting even when empty.
3. **The showcase trio** for every new mechanic: a diagram · a situation (`use-cases.md`) ·
   a fact (`facts.md`). Wording-only changes owe nothing — say so.
4. **Checks**: `bash scripts/preflight.sh` (runs every shipped test suite itself) ·
   `python3 scripts/check-links.py .` · `bash scripts/test-audit-gate.sh`. Green is evidence
   about the corpus, not about behaviour — behaviour is the eval suite's job.
5. **Changelog entry** (capability first; it is the migration map) → **manifest sweep runs
   inside preflight** → tag → **GitHub Release whose notes are the entry whole**
   (`gh release create vX --notes-file …`).
6. **Site**: `cd ~/Dev/ai && python3 scripts/generate-opsinist.py ~/Dev/opsinist` — commit
   and push that repo too; a release that skips this ships docs describing the previous
   version. New page-worthy files need a route in the generator first.
7. **Installs on this machine**: `bash scripts/find-installs.sh`, follow each row's route
   (Claude: marketplace update + plugin update · Codex: marketplace upgrade + plugin add ·
   Gemini: publish the Release, then uninstall + `install <repo-url> --consent` — its update
   follows releases, not tags · copies: rsync), then run it again and read every row.
8. **Memory**: update the project memory file with what shipped and what is owed.

## Versioning

**Evidence moves without a tag; a rule moves with one.** Run records, RUNS entries, verdicts —
plain commits. Anything that changes behaviour or format — a release, however small, so
nothing accumulates outside versions.

## Machine notes

- Eval clean-room: homes under the session scratchpad need their **own** keychain entries
  (`Claude Code-credentials-<sha256(home)[:8]>`) and their own logins for long rounds —
  copied tokens lose the refresh race. Details and traps: `evals/RUNS.md`.
- BSD `find -delete` on the `/tmp` symlink is a silent no-op — resolve the physical path.
- Plugin `PreToolUse` hooks do not fire under `claude -p` (measured); `SessionStart` does.
- GitHub issues land as triage: read, classify, fix or decline with a reason, close with
  the reasoning in a comment.
