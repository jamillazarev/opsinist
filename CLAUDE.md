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
   [`self-maintenance.md`](self-maintenance.md) §What-a-capability-owes: a form where it can fail · the mutation
   test denying the mutant and passing the twin · the claim dated with its measurement ·
   the showcase trio. No exceptions for small ones — the sibling's ledger and ours both
   carry releases that looked finished without it.
2. **Lenses** on anything of consequence — deletion · adversarial · contradiction ·
   cold-read, by a reader who did not write it, each reporting even when empty. **Then the round
   again over the repair they caused, before the tag** — the range still contains it — until a
   round reports clean ([`lenses.md`](lenses.md) → *Running them*, which holds its input and its cost).
3. **The showcase trio** for every new mechanic: a diagram · a situation ([`use-cases.md`](use-cases.md)) ·
   a fact ([`facts.md`](facts.md)). Wording-only changes owe nothing — say so.
4. **Checks**: `bash scripts/preflight.sh` (runs every shipped test suite itself) ·
   `python3 scripts/check-links.py .` · `bash scripts/test-audit-gate.sh` ·
   **`skillspector scan ./skills --recursive`** before a tag, read as JSON ([AGENTS.md](AGENTS.md) says
   why), because we screen what we import and ship twenty-one skills of our own (installed tool, not
   in preflight — preflight runs offline).
   Green is evidence about the corpus, not about behaviour — behaviour is the eval suite's job.
5. **Changelog entry** (capability first; it is the migration map; **it names its eval state — a run recorded, or `not run` said**) → **manifest sweep runs
   inside preflight** → **ask what this session learned about the machine and write it into the
   notes below first** (AGENTS.md → the release ritual — otherwise the note lands outside the release
   whose work produced it), then **set the entry's date to the day the tag is actually cut, as the
   last act before tagging** — it is written days earlier and the tag waits for the developer, so the
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
   upgrade + plugin add · **Antigravity: `agy plugin install <repo-url>`, or rsync onto a copy
   — and the Gemini CLI route is gone with its runtime (retired 2026-06-18), its leftover install
   printed as *remove it*** · copies: rsync.
8. **Memory**: update the project memory file with what shipped and what is owed.

## Versioning

**The tag waits for the developer — every release, its own word.** Everything before it —
the entry, the bump, the checks — is preparation and may land in `main`; **the tag, the
GitHub Release, the site push and the machine re-sync are cut only after an explicit yes**,
and an earlier yes does not roll forward to the next version. This is [`shipping.md`](shipping.md)'s own
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

- **Wait on a completion marker, never on a content string** (measured 2026-09-10). The shape
  `until grep -q '<phrase>' out.txt; do sleep 10; done` **spins forever when the watched command dies
  before printing that phrase** — here a suite was invoked from the wrong directory, exited with
  *"No such file or directory"*, and the loop waited 56 minutes for a line that could never come.
  It survived a `ps` sweep because it is a `sleep` inside bash, not the script it was named for.
  **Give the background command its own marker** — `cmd > out 2>&1; echo "DONE rc=$?"` — and wait for
  that, because it prints on every path. Same family as the pipe eating the exit code: watching for a
  sign of SUCCESS where the only reliable sign is COMPLETION.

- **`"$var:word"` is a zsh modifier, and it eats the word** (measured 2026-09-10). This tool's shell
  is zsh, where `:t` `:h` `:r` `:e` are history modifiers that apply to a parameter expansion — so
  `git show "$t:templates/RUN-template.md"` expanded to **`v0.2.17emplates/RUN-template.md`**, the
  `:t` consumed as *tail of path*. Every tag reported *"file not found"*, and the conclusion waiting
  to be drawn was that a defect had never shipped — when it had shipped in eleven consecutive
  releases. **Brace it: `"${t}:path"`.** Fifth member of the author's-tool class, and the first where
  the wrong answer is a plausible one rather than an error: `grep`, `awk`, `timeout` and `claude`
  fail loudly, and this one succeeds at something else.

- **zsh does not split an unquoted `$var` on spaces; bash does** (measured 2026-09-11). With
  `pair="opsinist https://…"`, `set -- $pair` gives zsh **one** argument holding the whole string and
  bash two — so a loop written the bash way passed `"opsinist https://github.com/…"` to
  `gemini extensions uninstall` as a single extension name, and gave `install` no source at all. Both
  refused, so nothing moved. **Split explicitly — `${=pair}` in zsh — or write each call out.** Same
  shell as the `:t` note above and the same lesson: a line that is idiomatic bash means something
  else here. *It landed after the 0.2.18 tag, which is the case `AGENTS.md`'s pre-tag question was
  written for; it rides the next range.*

- **zsh reads `=word` as a command lookup, and the failure ends the whole line** (measured
  2026-09-11). With the `EQUALS` option on, which is zsh's default, `=cmd` expands to the path of
  `cmd` — so `echo =====` asked for a command named `====`, printed *"===== not found"*, and **the
  rest of that command line never ran**: twice in one session a separator between two checks
  silently cancelled the second check. Quote it (`echo '====='`) or use `---`. Same shell as the
  two notes above, and the same lesson again: what bash prints, zsh tries to execute.

- **A tool can report a failure without exiting on one, and then its exit code proves nothing**
  (measured 2026-09-10). `scripts/check-structure.py` prints `FAIL:`/`WARN:` lines for preflight to
  render and **exits 0 on every path**; a mutation suite written against `[ "$(run)" = "1" ]` was
  therefore green on the honest twin *and* on every mutant. Three assertions in that suite's first
  draft failed for exactly this, which is the check working on its author before it worked on
  anything. **Assert on what a tool REPORTS unless you have watched it exit non-zero on a known-bad
  input** — and watch it, rather than reading the script for intent. Same family as the pipe eating
  the exit code, from the other side: there the code is destroyed in transit, here there was never
  one to read, and both look identical from a green suite.

- **The `grep` you test at the prompt is not the `grep` a script gets** (measured 2026-08-15).
  In this tool's shell `grep` is a **shell function** (from the zsh snapshot) resolving to
  **ugrep 7.5.0**; a plain `bash script.sh` gets **`/usr/bin/grep`, BSD 2.6.0-FreeBSD**. They
  disagree: on `**Status**: x · **Stage**: y`, `grep -coiE` returns **2** under ugrep and **1**
  under BSD, because BSD `-c` counts matching LINES and ignores `-o`. So a hand-check at the
  prompt can confirm a gate that is blind inside the shipped script — measured exactly that way
  in §1c, where a command-line check briefly "disproved" a true lens finding. **Check a shell
  behaviour by running it the way the script will** (`bash -c` / a temp script), and prefer
  forms that cannot differ: `grep -o … | grep -c .` counts occurrences everywhere.

- **The hook that runs is the INSTALLED copy, not the one you just fixed** (measured 2026-09-18,
  twice in one session). A false positive in the sibling's outward gate was repaired in
  the sibling methodology's `hooks/`, and the cached plugin copy under `~/.claude/plugins/cache/…/`
  went on refusing — including refusing the command that would have written the fix. **A hook
  repair does not take effect until the machine re-sync step of a release**, which is step 7 and
  comes after the tag, so *the whole window between the repair and the tag runs on the old gate*.
  Two consequences worth knowing in that window: **the gate only inspects `tool_name == "Bash"`**,
  so `Write`/`Edit` change a file whose content a Bash gate would misread — that is using the right
  tool, not evading the gate, and the distinction is that the act itself is not the gated one. And
  **never disable the gate to get past your own fix**: it is the one measure whose bypass must not
  be available to the party it constrains.

- **A stub directory with a system directory behind it is a fallback, not a sandbox** (measured
  2026-09-24, and it published). A lens testing the gate put `git push` in a script meant for a stub
  `git`; the installed gate refused the command that would have created the stub, so the next run
  found none, `PATH=stubs:/usr/bin:/bin` resolved the real `/usr/bin/git`, and the sibling
  repository's `main` took eighteen commits of an untagged release — left in place, since rewriting
  a public branch is worse than what it carries. **Two misreadings compounded**: a refusal read as
  *nothing happened* when it meant *the next step's precondition is missing*, and a gate that reads
  commands trusted to see into a script. `scripts/test-gate-vs-bash.sh` is the closed way to run such
  a check, and [`lenses.md`](lenses.md) holds the rule that nothing runs an outward verb any other way.

- **bash 3.2 misreads a heredoc inside `$(…)`** (sibling-measured 2026-09-24, on the `/bin/bash`
  macOS ships). A `$(python3 - <<'PY' … PY)` whose body held one unpaired backtick failed `bash -n`
  with *unexpected EOF while looking for matching* `` ` `` — the quoted delimiter does not stop bash
  3.2's `$(` scanner from reading the body; a lone quote passed. Send the program's output to a
  temp file instead, which also leaves its exit status where `|| say_fail` can read it — the reason
  the construct was being replaced in the first place.

- **`open(p, "w").write(open(p).read()…)` truncates before it reads** (measured 2026-09-18, and it
  emptied [`diagrams.md`](diagrams.md) — 500 lines to zero). Python evaluates the call's *object* first, so the
  write-open truncates the file, and the read inside the argument then returns `""`. Nothing warns:
  the statement succeeds, the file is empty, and preflight's own chapter-budget check passed it
  because an empty file is under budget. **The site generator's H1 check is what caught it.**
  Read into a variable, then write — and note the shape is invisible in review because the read
  *looks* like it happens first, which is the only reason it survived being typed.

- **A suite run while a lens works in the same tree goes red for no reason** (measured 2026-09-18).
  Two lenses were reading and building fixtures in this repository while `preflight.sh` ran;
  `test-check-shell-exec.sh` and `test-corpus-preflight.sh` reported **1 and 5 failures**, and both
  passed alone seconds later — they build fixtures *from the working tree*, so anything else
  touching it mid-run changes their input under them. **A red from a contended run is not evidence
  of anything**: run it again on a quiet tree before believing it, and never chase a failure whose
  suite passes in isolation. (Lenses in worktree isolation avoid this — the note below about
  `--disallowedTools` is the other half of why that isolation exists.) A lens can also leave a file
  behind: one wrote a stray `json` at the repository root, which the tree-clean check before a tag
  is there to catch.

- **`skillspector baseline` takes no `--recursive`, and `--no-llm` says so about itself** (measured
  2026-09-18 on 2.11.2). A pool of skills cannot be baselined in one pass — `baseline ./skills`
  reads the directory as a single skill and writes an empty file, while `scan ./skills --recursive`
  reports per skill; suppression for a pool means per-skill baselines or `rules:` globs. And a
  static-only run reports `coverage_percent: 0.0` with `status: partial` **in its own JSON**, which
  is the tool being honest and the reason a clean static run is evidence about patterns rather than
  about intent. **And a manifest a strict parser rejects appears only in that JSON** (measured
  2026-09-24): the printed summary says *successful* with no findings, while `analysis_completeness`
  carries a `manifest_parse_error` and the `ScannerError` — so a scan read from its summary never
  shows the one thing preflight's frontmatter check leaves to it.

- **`GIT_REFLOG_ACTION` is empty in a pre-commit hook, for an amend exactly as for a commit**
  (measured 2026-09-18, both cases, on this machine's git). So **a hook cannot tell `git commit
  --amend` from a second commit**, and any rule that counts consecutive commits has to survive the
  amend reading as one more: §24's threshold went from two to three for exactly this, after an
  adversarial lens refused an ordinary amend. The general form: **a hook sees the tree and the
  index, not the intent** — if a gate's correctness depends on *which git command is running*,
  measure whether the hook can actually see that before shipping the gate.

- **Subagents inherit the parent's model, and three concurrent Opus lenses exhausted the account's
  session limit** (measured 2026-09-18: three re-round lenses died a line or two in, the sixth to
  eighth lost that way across three releases). Relaunched on Sonnet — `model: "sonnet"` on the
  dispatch — all three finished and returned findings the Opus attempts never reached. **Dispatch
  lenses on a smaller model than the one that wrote the corpus**, which [`lenses.md`](lenses.md) already prefers
  for independence and which the deaths had quietly stopped anyone doing.

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
  copied tokens lose the refresh race. Details and traps: [`evals/RUNS.md`](evals/RUNS.md).
- BSD `find -delete` on the `/tmp` symlink is a silent no-op — resolve the physical path.
- Hook enforcement is a form × path × version matrix — never narrate a probe, stamp it. On 2.1.220 (mechanical, 2026-08-08): plugin hooks fire under `-p`; **exit-2 denies enforce from the plugin**, the `permissionDecision` JSON form is ignored there and honored from `settings.json`. The 2026-08-07 "plugin hooks don't fire under -p" held on the older CLI — date every such claim.
- Lenses run in worktree isolation, and the tree is checked clean before any tag — `--disallowedTools` does not see a shell redirect (the sibling's read-only lens wrote 15 MB).
- A `PostToolUse` hook's stderr never reaches the model; only `hookSpecificOutput.additionalContext` does (sibling-measured).
- GitHub issues land as triage: read, classify, fix or decline with a reason, close with
  the reasoning in a comment.
