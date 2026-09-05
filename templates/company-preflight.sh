#!/usr/bin/env bash
# guard-version: 0.2.15   <!-- stamped from the skill at ship time; read by the check below -->
# Docs guard for a company the advisor built — install it into the company's own repo, not ours.
#
#   cp templates/company-preflight.sh <repo>/_ops/scripts/preflight.sh
#   cp scripts/transition.py scripts/new-id.py  <repo>/_ops/scripts/
#   bash _ops/scripts/preflight.sh --install     # wires it as a pre-commit hook
#
# All three, and in that order: §1 refuses a wired project whose doors are absent, so copying
# only this file produces a repository in which no commit can be made — measured by following
# this recipe as it was first written.
#
# It guards the five things this methodology insists on and nobody remembers unprompted:
# the docs the guide promises exist, the doors it points at are installed and are
# commands, recorded facts have not silently expired, the decisions log is append-only,
# and the architecture map still describes the repo.
#
# Deliberately small. A hook that cries wolf is a hook people bypass with --no-verify.
#
# WHAT THIS CANNOT SEE, said plainly rather than left to be discovered: it is a pre-commit hook,
# so a MERGE runs none of it. A task refused on a branch — committed there with --no-verify —
# lands in `main` through `git merge` with no gate invoked at all (measured 2026-08-15). That is
# generic to pre-commit hooks and it bears on everything below, because these gates enforce what
# a commit CREATES and a merge creates everything while running nothing. If the project's history
# matters more than its commits, run this same file over the merge result in CI; a hook is the
# author's own guard rail, not the repository's.
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

SENTINEL="# managed by opsinist company-preflight"

if [ "${1:-}" = "--install" ]; then
  # Must be a real repo with a real hooks dir. In a worktree .git is a FILE, and with
  # core.hooksPath (husky, lefthook) the hooks live elsewhere — writing blind there
  # reports success while installing nothing.
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "  x not inside a git repository — nothing installed"; exit 1; }
  hookdir=$(git config --get core.hooksPath 2>/dev/null || true)
  if [ -n "$hookdir" ]; then
    echo "  x this repo uses core.hooksPath=$hookdir (husky, lefthook or similar)."
    echo "    Add to your existing pre-commit instead:  bash _ops/scripts/preflight.sh || exit 1"
    exit 1
  fi
  hookdir=$(git rev-parse --git-path hooks 2>/dev/null) || hookdir="$root/.git/hooks"
  hook="$hookdir/pre-commit"

  # Only ever replace a hook this script wrote. A substring test on the script name is
  # not enough: the chaining line we print below contains that same name, so a chained
  # gitleaks hook would look like ours and get overwritten — deleting a real control.
  if [ -e "$hook" ] || [ -L "$hook" ]; then
    if ! grep -qF "$SENTINEL" "$hook" 2>/dev/null; then
      echo "  x $hook already exists and was not written by this script."
      echo "    Not touching it - it may be your secret scan or test gate."
      echo "    Chain it by adding this line to it:  bash _ops/scripts/preflight.sh || exit 1"
      exit 1
    fi
  fi

  mkdir -p "$hookdir" || { echo "  x cannot create $hookdir"; exit 1; }
  tmp="$hook.opsinist-tmp.$$"
  printf '#!/bin/sh\n%s\nexec bash _ops/scripts/preflight.sh\n' "$SENTINEL" > "$tmp" || {
    echo "  x cannot write $tmp"; exit 1; }
  chmod +x "$tmp" && mv -f "$tmp" "$hook" || {
    rm -f "$tmp"; echo "  x cannot install $hook"; exit 1; }
  echo "pre-commit hook installed at $hook"; exit 0
fi

fail=0; warn=0
# Temp files this run makes are removed on every exit path, including a refusal. A guard that
# leaves litter in /tmp on each commit is a guard someone eventually notices for the wrong reason.
_cpf_tmp=""
trap 'rm -f $_cpf_tmp' EXIT HUP INT TERM
say_fail() { echo "  ✗ $1"; fail=1; }
say_warn() { echo "  ! $1"; warn=1; }
# hits <grep-args…> — reads stdin, true when at least one line matches. See the note above:
# this exists so no gate in this file can be silenced by the size of what it is reading.
# Reads STDIN only — with file arguments `grep -c` prints `path:count` per file and the
# integer test below dies on it. Every call site here pipes.
hits() { [ "$( grep -c "$@" 2>/dev/null | head -1 || true )" -gt 0 ] 2>/dev/null; }
# The INDEX, not the worktree: a gate that reads the file on disk is a gate the author
# passes by fixing it in the editor after staging the broken one. Defined here with the
# other helpers — it used to sit two hundred lines below its first use.
staged() { git show ":$1" 2>/dev/null; }
# NUL-separated, because a path holding a space word-splits out of an unquoted `for` loop and
# every gate downstream of it goes silent — not one refusal, no diagnostic, exit 0. Measured
# 2026-08-15: byte-identical hand-edits to `_ops/tasks/T-CTL002-control.md` and to
# `_ops/tasks/T-BYP001 hand edit.md`, staged one at a time, produced two refusals and zero.
# §16 has used this form since it was written and carries a comment explaining why; the eight
# sections written after it did not get it. §1d transliterates non-ASCII and a space is ASCII,
# so nothing in this file forbade the name either.
# `"$@"` carries the pathspec too, and that is the point: **git does the filtering, so no path ever
# passes through a line-oriented tool.** The first repair sent NUL records through `grep -zE '^…$'`,
# which closed the space case and left the newline one wide open — BSD grep still treats \n as a
# line terminator for ^ and $ inside a -z record, so a single filename containing a newline was
# DROPPED by the filter and every gate downstream went silent at exit 0. Measured 2026-08-15
# (pass ten): `printf '_ops/tasks/T-x\ny.md\0' | grep -zE '^_ops/tasks/.*\.md$'` returns nothing,
# while `git ls-files -z -- '_ops/tasks/*.md'` returns the record intact. git's `*` crosses `/`
# exactly as the `.*` it replaces did, so the matched set is unchanged apart from the hole.
changed() { git -c core.quotePath=false diff --cached --name-only -z "$@" 2>/dev/null || true; }
# state_homes — how many places a task keeps its state, on a stream, examples excluded. Counting
# OCCURRENCES (`-o … | grep -c .`), never `grep -co`, which counts matching LINES under BSD grep
# and would score `**Status**: x · **Stage**: y` as one.
# The indent clause is not decoration: `migrate-layout.py` skips a four-space or tab-indented line
# as an example (its line 104), and this function did not — so an ordinary prose commit whose
# example is written as an indented block, which is plain markdown, was REFUSED by §1c while the
# migration looking at the same file reported nothing to fix. Measured 2026-08-15 (pass ten): the
# reader had no path at all, one tool refusing and the other saying there was no problem. The two
# now agree on what an example is — and so does `transition.py`, which is the one that matters:
# it read and REWROTE an indented field the guard had just gone blind to, so the repair for a
# false refusal opened the exact divergence §1c exists to prevent. All three skip a fence, a
# blockquote at any indent, and four spaces or a tab. Measured 2026-08-16 (pass eleven).
# staged_diff <path> — the staged diff for a file, PAIRED with its rename source when it has one.
# Restricting `git diff` to a single path defeats rename detection: git has nothing to pair the
# new path with, so it prints the file as wholly added — every line a `+`, not one `-`. Measured
# 2026-08-15 (pass ten): `git mv` plus a hand-flipped status in one commit scored `R098` and drew
# ZERO refusals, because §14 requires a removed state line and a rename-blind diff has none. That
# is the whole gate walked through by renaming the file first.
# record_task <stream> — the task a run record DECLARES, read from stdin. Format-agnostic, like
# every other check in §1f (`hits -iF "$need"`), because a record that names its task on a `task:`
# line rather than in a title or a `**Task**` row is still a record: the one rigid reader in an
# otherwise loose section is the reader that silently counts zero. The id is bounded on both sides
# so `T-AB` never matches inside `T-ABCD`.
record_task() {
  # **Both bracketing parts are optional, and one pipe may be crossed.** Measured 2026-08-21
  # (pass twelve, three lenses and the critic): the mandatory separator before the id made
  # `# T-ABC123 — title` — line 1 of this repository's own TASK template — read as EMPTY, and
  # `[^|]*` could not cross a table pipe, so `| **Task** | T-ABC123 |` — line 10 of its RUN
  # template — read as empty too. Two of the four shapes the corpus itself prescribes were
  # invisible to the reader that decides whether a run record declares a task, which silently
  # voided §1f's neighbour count and the escalation gate built on it. One pipe only, so a
  # DECLARATION still differs from a MENTION: `see also T-ZZZ999`, `blocked_by: T-ZZZ999` and a
  # distant `| notes | related to T-ZZZ999 |` all still read empty, which is what §1f needs.
  grep -m1 -oiE '(^#[^#]|\*\*task\*\*|^[[:space:]]*task[[:space:]]*:)(([^|]*\|)?[^|]*[^0-9A-Za-z-])?(T-[0-9A-Za-z-]+)' \
    | grep -oE 'T-[0-9A-Za-z-]+' | tail -1
}

# rename_src <new-path> — the path a staged rename came FROM, or empty. Extracted so that every
# gate reasoning about "before" reads the right side of a rename, not an empty file at a path that
# never existed.
#
# A NUL stream, because line mode C-QUOTES any path holding a control character, a quote or a
  # backslash — and `-c core.quotePath=false` only turns off the non-ASCII half of that. So for a
  # path with a tab, `$3` was `"_ops/tasks/T-REN2\tx.md"` while the loop handed in the raw path:
  # never equal, no source found, and the diff fell back to the rename-BLIND form. That is the
  # exact bypass this helper was written to close, reopened by one tab in a filename — measured
  # 2026-08-15 (pass eleven), rc=0 where the ordinary-named control refuses. A newline in the name
  # additionally killed `awk -v n="$1"` outright ("newline in string"), four times per commit.
  # `-z` emits STATUS\0OLD\0NEW\0 with raw paths and no quoting at all.
  #
  # The case patterns lead with `(` — `(R*|C*)` not `R*|C*` — because bash 3.2's
  # command-substitution scanner miscounts the `)` that closes a case pattern and dies with
  # "syntax error near unexpected token ';;'". macOS ships 3.2.57, so this file must not use the
  # bare form inside `$( … )`.
rename_src() {
  git diff --cached --name-status -M -z 2>/dev/null | {
    _st=""; _a=""; _found=""
    while IFS= read -r -d '' _f; do
      if [ -z "$_st" ]; then _st=$_f; continue; fi
      case "$_st" in
        (R*|C*)
          if [ -z "$_a" ]; then _a=$_f; continue; fi
          [ "$_f" = "$1" ] && { printf '%s' "$_a"; _found=yes; break; }
          _st=""; _a="" ;;
        (*) _st=""; _a="" ;;
      esac
    done
    [ -n "$_found" ] || true
  }
}
staged_diff() {
  _src=$(rename_src "$1")
  if [ -n "${_src:-}" ]; then
    git diff --cached -U0 -M -- "$_src" "$1" 2>/dev/null || true
  else
    git diff --cached -U0 -- "$1" 2>/dev/null || true
  fi
}
state_homes() {
  awk '/^[[:space:]]*(```|~~~)/{f=!f; next} f{next} /^[[:space:]]*>/{next} /^(\t| {4})/{next} {print}' \
    | grep -ooiE '(\*\*)?(status|stage|статус|стадия)(\*\*)?[[:space:]]*:' \
    | grep -c . || true
}

echo "preflight — docs"

# 1 · the docs the guide promises. An agent sent to a file that is not there improvises, and
#     improvisation is how conventions drift — but these four arrive when they have content,
#     so their absence is a warning here and not a refusal. A project that creates them empty
#     on day one has four files its owner reads past forever, which is the worse trade.
#     (Why it changed, with the measurement, is the skill's changelog for 0.2.7.)
for f in _ops/ROADMAP.md _ops/TEAM.md _ops/TOOLING.md _ops/DECISIONS.md; do
  [ -f "$f" ] || say_warn "$f is missing — the guide points every agent at it. Deferred on \
purpose until it has something to hold (a roadmap · a role · a tool · the first decision); once \
it does, create it, because an agent sent to a file that is not there improvises"
done
#     Absent is deferred; DELETED is not. §2, §3 and §9 are each keyed on one of these files
#     existing, so retiring a file retires its gate — which would let the constrained party
#     delete a check instead of satisfying it.
# `DR`, not `D`: git detects renames by default, so a `git mv` is not a delete and would
# otherwise pass. Emptying the file reaches the same end, so a staged truncation counts too.
gone=$(git diff --cached --name-status --diff-filter=DR 2>/dev/null \
  | awk '{print $2}' \
  | grep -E '^_ops/(ROADMAP|TEAM|TOOLING|DECISIONS)\.md$' || true)
emptied=""
for f in _ops/ROADMAP.md _ops/TEAM.md _ops/TOOLING.md _ops/DECISIONS.md; do
  git ls-files --error-unmatch "$f" >/dev/null 2>&1 || continue
  staged_size=$(git show ":$f" 2>/dev/null | tr -d '[:space:]' | wc -c | tr -d ' ')
  had=$(git show "HEAD:$f" 2>/dev/null | tr -d '[:space:]' | wc -c | tr -d ' ')
  # Emptied, or GUTTED. `staged_size -eq 0` was the whole test, so `printf '.' > _ops/TOOLING.md`
  # passed as a living file while §2 and §9 — both keyed on that file having rows — went silent.
  # The constrained party could retire a check by hollowing it rather than deleting it. Measured
  # 2026-08-15 (pass nine). A file that had real content and keeps under a fifth of it counts;
  # the DECISIONS escape below is the same escape, so an honest large trim still has one.
  if [ "${had:-0}" -gt 0 ] && { [ "${staged_size:-1}" -eq 0 ] \
       || { [ "${had:-0}" -ge 200 ] && [ $(( ${staged_size:-0} * 5 )) -lt "${had:-0}" ]; }; }; then
    emptied="$emptied $f"
  fi
done
# The escape: a staged `_ops/DECISIONS.md` line naming the file and saying it is retired. A
# gate with no exit is a gate people pass with --no-verify, which is what this file is against.
retired_ok=""
# **When the retired file IS `_ops/DECISIONS.md`, its own remedy cannot be performed.** The escape
# asks for an added line inside that file, and the commit's whole content is that the file stops
# existing at that path — so deleting it, renaming it, or emptying it were all refused with an
# instruction nobody could follow. Measured 2026-08-21 (pass twelve). In that one case the
# retirement line is read from the WHOLE staged diff: it must still be written, dated and
# specific, but it may live wherever the decisions live now — which is exactly what the commit
# is declaring. Every other retirement still requires the line in DECISIONS itself.
_dec_retiring=no
printf '%s\n' $gone $emptied | hits -xF '_ops/DECISIONS.md' && _dec_retiring=yes
if [ -n "$gone$emptied" ] \
   && { [ "$_dec_retiring" = yes ] \
        || ( git diff --cached --name-only 2>/dev/null || true ) | hits -xF '_ops/DECISIONS.md'; }; then
  # The added DECISIONS lines, read once.
  # The added DECISIONS lines, fences stripped: a name and a verb inside a ```-block is an
  # example, not a decision, and §16 already reads fields that way.
  _dec_scope=_ops/DECISIONS.md
  [ "$_dec_retiring" = yes ] && _dec_scope=.
  _dec_added=$( ( git diff --cached -U0 -- "$_dec_scope" 2>/dev/null || true ) \
                | grep '^+' | grep -v '^+++ ' | sed 's/^+//' \
                | awk '/^[[:space:]]*```/{f=!f; next} !f' || true)
  for f in $gone $emptied; do
    base=${f##*/}
    # Fixed-string on the basename — as a regex, `.` matched any character, so a line naming
    # `TOOLINGxmd` opened the gate. And each retired file needs its OWN line: matching the
    # whole set let one line cover three deletions, which this comment used to deny.
    _line=$(printf '%s\n' "$_dec_added" | grep -F -- "$base" \
            | grep -iE 'retir|remov|delet|drop|obsolete|sunset|archiv|superseded|replaced by|no longer' \
      || true)
    [ -n "$_line" ] || { retired_ok=""; break; }
    retired_ok=yes
  done
fi
if [ -z "$retired_ok" ] && { [ -n "$gone" ] || [ -n "$emptied" ]; }; then
  say_fail "this commit retires$(printf '%s' " $gone $emptied" | tr '\n' ' ' | tr -s ' ') — these four may be \
absent because they have nothing to hold yet, but removing, renaming or emptying one that \
exists also removes the checks keyed on it (freshness, append-only, entitlements). If the \
register is genuinely being retired, add a line in this same commit — to _ops/DECISIONS.md, or, \
when DECISIONS itself is what is being retired, to wherever the decisions live now — in \
this shape: the file's own name and the word retired, one line per file:
$(for _f in $gone $emptied; do printf '    - %s retiring %s: <where the facts live now>\n' "$(date +%Y-%m-%d)" "$_f"; done)"
fi
# The doors travel with this guard (0.2.7), and a wired project without them is the measured
# dead end: §14 refuses a hand-edited stage and points at a door that is not there. Measured
# twice — a live project held only the guard, and the day-one install instruction alone ran
# 0/5 in the round — so the presence is held here, not remembered.
missing_doors=""
for d in _ops/scripts/transition.py _ops/scripts/new-id.py; do
  if [ ! -f "$d" ]; then
    missing_doors="$missing_doors ${d##*/}"
  elif [ ! -s "$d" ] || ! grep -q 'sys\.argv\|argparse' "$d"; then
    # Non-empty plus an argument-reading mention — deliberately a heuristic, because an
    # interrupted copy is the failure this catches and a stricter form needs an interpreter
    # this project may not have. Why the stricter form was tried and withdrawn: the 0.2.7
    # changelog.
    say_fail "$d is empty or does not read arguments — a half-copied door is not a door. \
Re-copy it with one of the two lines below, then commit again"
    missing_doors="$missing_doors ${d##*/}"
  fi
done
# One refusal for both doors, not one each: the message carries two command lines and printing
# it twice buries them. Third wording this release, and the first written from evidence — "ask
# your advisor to run the upgrade step" named a PROCESS and was invoked by nobody, 0 of 5,
# measured 2026-08-15. The message that went 5/5 in the same round named an artifact and printed
# the literal thing to do.
#
# `--doors-only`, and the reason is which program prints this. This runs as a pre-commit hook, so
# there is always staged work — and the plain `migrate-layout.py .` offered here before answered
# "the tree is dirty — commit or stash first" and copied nothing, every time, at the only moment
# anyone reads it. Measured 2026-08-15 (pass nine). The `cp` line now names only the doors that
# are actually missing: it was printed both ways even when one door was present, and plain `cp`
# silently clobbers a hand-edited door where the script keeps it at `.replaced-<hash>` and says
# where it went. They are not equals and are no longer offered as equals.
if [ -n "$missing_doors" ]; then
  cp_line="cp"
  for d in $missing_doors; do cp_line="$cp_line <the skill>/scripts/$d"; done
  cp_line="$cp_line _ops/scripts/"
  say_fail "the doors travel with this guard and are missing or half-copied:$missing_doors — \
§14 refuses your next stage change while pointing at a file you do not hold. Run this, here, \
with your work still staged:
    python3 <the skill>/scripts/migrate-layout.py . --doors-only
It finds its own source, copies what is missing, stages it, and keeps anything it replaces at \
\`.replaced-<hash>\`. If you cannot reach the skill's scripts, the blunt equivalent — which \
overwrites without keeping a copy — is:
    $cp_line
The skill is the plugin your advisor already has loaded — ask it for the path if you do not know \
it, because nothing shipped into this project names it"
fi
# `hits` instead of `grep -q`, everywhere the input can be large. `grep -q` exits on its
# first match and SIGPIPEs its producer; under `set -o pipefail` the pipeline then returns
# 141 and the condition reads it as NO MATCH. Measured: a credential gate that missed an
# AWS key sitting on line 1 of a 200 000-line file, and §14 letting a hand-edited stage
# through once a task's diff passed 64 KiB — the pipe buffer, not a file count.
#
# Wrapping the producer in `( … || true )` does NOT fix this: the signal lands on `printf`
# before the `|| true` can run, and in a three-stage pipe the middle stage takes it instead.
# `grep -c` reads its input to the end, so it cannot happen. Use `hits` for anything whose
# input is a diff, a file list or a file's contents.
if ( git ls-files || true ) | hits -E '\.(ts|tsx|js|py|go|rs|swift|kt|rb|java)$'; then
  [ -f _ops/ARCHITECTURE.md ] || say_warn "there is code but no _ops/ARCHITECTURE.md — every task \
starts in a fresh worktree and re-derives the layout"
fi

# `AMR`, not `AM`. git scores a rename and reports `R`, which `AM` does not select: measured
#      2026-08-15 (pass ten), `git mv` plus the offending edit in ONE commit produced `R098` and
#      **zero refusals** — §1c, §1g and the §14 net all went silent together. §1f was moved to
#      `AR` in this same release for exactly this reason and the sections beside it were not.
# 1c · one state, one home — enforced on what a commit ADDS, not on what a project already has.
#      The door reads a stage field "wherever the template put it", which is tolerant by design
#      and is how a project ends up with two: a prose `**Status**` the human reads and a machine
#      `stage:` the door moves. Measured on a live project, 12 of 12 tasks disagreed.
#
#      Scoped to the added line for the same reason the non-ASCII path check is: a project
#      carrying the old shape cannot rewrite its history, and refusing it on every commit until
#      someone hand-edits every task is a release stranding its own projects. What is refused is
#      CREATING a second home. The migration reports the legacy ones; it does not rewrite them.
while IFS= read -r -d '' tf; do
  # not anchored at `^`: the shipped template writes `**Type**: build · **Status**: done`, so a
  # start-anchored count scored that as zero homes and the motivating defect walked through the
  # gate built for it. Fenced and quoted lines are excluded — an example is not a field.
  # Against HEAD, not against the diff. Counting only the ADDED lines refused two homes arriving
  # in one commit and nothing else — so the ordinary path was silent: create the task the normal
  # way, commit, then append `stage:` in the next commit and the guard passes while `transition.py`
  # reads one copy and the human reads the other. That is the 12-of-12 defect this block cites,
  # walking through the block built for it. Measured 2026-08-15 (pass nine, cold read); the
  # comment above said "what is refused is CREATING a second home" and it was not true.
  # Comparing counts keeps legacy unstranded — a file that already had two still has two — while
  # actually catching creation, whichever commit it arrives in.
  now=$( ( staged "$tf" || true ) | state_homes )
  # "before" is read from the path the file came FROM when this is a rename. Reading
  # `HEAD:<new path>` gives nothing, so `was` came back 0 and a PURE `git mv` of a legacy
  # two-home task — byte-identical content, no edit at all — was refused, quoting "(it kept 0)",
  # a number that is false. That contradicted this section's own promise three lines up, and it is
  # the same defect shape §1f was repaired for in this release: a message stating a number the
  # file contradicts. Measured 2026-08-15 (pass eleven) — arrived with `AMR`, which made §1c see
  # renames without teaching it what one means.
  _was_path=$(rename_src "$tf"); [ -n "${_was_path:-}" ] || _was_path=$tf
  was=$( ( git show "HEAD:$_was_path" 2>/dev/null || true ) | state_homes )
  [ "${now:-0}" -le 1 ] && continue
  [ "${now:-0}" -le "${was:-0}" ] && continue
  n=$now
  say_fail "$tf now keeps its state in ${n} places (it kept ${was:-0}) — a status the human reads and a stage the \
door moves stop agreeing the first time only one of them is updated. Keep one, on the header \
line, and let the door own it"
done < <(changed --diff-filter=AMR -- '_ops/tasks/*.md')

# 1d · paths are ASCII; what is written inside them is the project's own language. Measured on a
#      live project: 126 tracked paths under `_ops/` carried Cyrillic, and git renders those as
#      octal escapes in every `status`, `log --name-only` and diff header — a maintainer reads
#      `"_ops/tasks/T-MEY1HV-\320\260\320\272\321\2023-…"`. macOS also stores names as NFD
#      and Linux as NFC, so the same file can fail to match across two machines. The document
#      speaks whatever language the project speaks; only its NAME is transliterated.
# `-c core.quotePath=false`, or git hands back the very escapes this check looks for and the
# path arrives as pure ASCII — the defect guarding against itself. Measured.
newpaths=$( ( git -c core.quotePath=false diff --cached --name-only --diff-filter=AR 2>/dev/null \
              || true ) | grep '^_ops/' || true)
if [ -n "$newpaths" ]; then
  odd=$(printf '%s\n' "$newpaths" | LC_ALL=C grep -n '[^ -~]' | head -3 || true)
  if [ -n "$odd" ]; then
    say_fail "this commit adds a path under _ops/ with non-ASCII characters: \
$(printf '%s' "$odd" | tr '\n' ' ') — git prints those as octal escapes in every status and \
diff, and macOS and Linux normalise them differently. Transliterate the name; the text inside \
stays in the project's language"
  fi
fi

# 1e · a ladder is checked when it is written, not when someone finally walks into it. One
#      character in `terminal:` disarms acceptance for a whole pipeline — the review-by-another
#      rule is only consulted on a terminal move — and nothing said a word until a worker
#      closed their own task. The door refuses a malformed ladder; this catches it at the commit
#      that writes it, which is where the person who can fix it is standing.
while IFS= read -r -d '' pf; do
  # The INDEX, not the worktree: staging a broken ladder and fixing it in the editor was
  # measured passing. The staged bytes go to a temp file because the door takes a path.
  tmp_l=$(mktemp) || continue
  staged "$pf" > "$tmp_l" 2>/dev/null || { rm -f "$tmp_l"; continue; }
  [ -s "$tmp_l" ] || { rm -f "$tmp_l"; continue; }
  out=$(python3 "_ops/scripts/transition.py" --check-ladder "$tmp_l" 2>&1) || \
    say_fail "$pf is a malformed ladder: $(printf '%s' "$out" | tr '\n' ' ' | cut -c1-220)"
  rm -f "$tmp_l"
done < <(changed -- '_ops/pipelines/*.md' '_ops/process/types/*.md')

# Reads the first word of a named table cell — `| **Verdict** | pass — … |` gives `pass`.
# **An unfilled cell yields nothing, and the regex is what does it**: `{{pass · fail · …}}`
# begins with `{`, which `[A-Za-z]` does not match. **Do not add a `{{` guard here** — it changes
# no outcome, and it blanks a HALF-filled `pass — {{what it concluded}}` where a verdict genuinely
# was reached. Both cases are asserted.
# **One home for the escalation test.** Three literal copies of this pattern shipped in one
# commit — the attempt gate, the neighbour table and the contradiction gate — and a change to any
# one of them would have silently disagreed with the other two.
#
# **It counts rather than answering yes/no**, because `grep -q` exits on its first match and can
# SIGPIPE whatever feeds it, which under `set -o pipefail` turns a found phrase into an absent
# one. That is this project's own machine note, measured three times elsewhere — it is why the
# form is `-c`, not something this consolidation demonstrated. **A `-q` variant of this helper was
# put to the suite and every assertion stayed green**, so the trap does
# not reproduce here. Use `-c` regardless — the precaution is cheap and the failure is silent.
# **The placeholder this gate's own refusal prints must not satisfy it.** The message hands the
# reader `**Escalated**: … — <what differed between the two askings: …>`, and pasting that whole
# line unedited passed: one non-space character after the colon was the whole test. That is the
# shape §1f's attempt gate condemns eleven lines below — *a gate satisfied by denying the thing it
# asks for is worse than an absent one* — and here the gate was handing over the shortest path to
# it. Found by a cold-read lens 2026-08-29. The test is exact rather than a heuristic about angle
# brackets, so an escalation that legitimately quotes `<…>` is never refused: the ONE string that
# does not count is the unedited placeholder itself, which is defined once, printed by the
# refusal, and excluded here.
ESC_PLACEHOLDER='<what differed between the two askings: machine, version, shell, working tree, order>'
# Emits the escalation lines themselves; `escalation_count` is this filtered and counted. Two
# callers need the difference: a record with NO such line and a record whose line is still the
# unedited placeholder are different mistakes, and telling a reader who wrote one that they wrote
# the other is the failure this file names eleven lines below — *unfollowable in one direction*.
escalation_lines() {
  grep -iE '^[[:space:]]*(\*\*)?(escalated|escalation)(\*\*)?[[:space:]]*:[[:space:]]*[^[:space:]]' || true
}

escalation_count() {
  # **An empty `$ESC_PLACEHOLDER` would make `grep -vF ""` match every line**, so every record
  # would read as having no escalation and honest work would be refused with the message about a
  # placeholder it does not carry. Unreachable from any input — the assignment is a literal — but
  # undefended until an adversarial lens constructed the state, 2026-08-29, and the suite already
  # defends the analogous case for the memo variable.
  [ -n "${ESC_PLACEHOLDER:-}" ] || { escalation_lines | grep -c . || true; return; }
  # **`-i` IS what this consolidation broke, measured**: every record writes `**Escalated**:` with
  # a capital E, all three original call sites carried `-i`, the merged helper did not, and five
  # assertions went red until it came back. Merging correct call sites is how a flag goes missing.
  escalation_lines | grep -cvF "$ESC_PLACEHOLDER" || true
}

# **A fenced block is an example, not a declaration.** Both readers below skip fences, and
# the same idiom is used by §1g. Without it a record quoting this template for reference was
# read as concluding whatever the example says — and once one-verdict-per-record landed, a
# record with a real row AND a quoted example was refused for declaring it twice. Measured
# 2026-08-29: the check written to close an evasion opened a false refusal within the hour,
# which in this file's own accounting is the more expensive of the two.
unfenced() { awk '/^[[:space:]]*(```|~~~)/{f=!f; next} !f'; }

verdict_of() {
  # **Skip backticks and bold before the value.** The corpus writes every enum in backticks —
  # `escalating.md`, `dispatching.md` and this template's own neighbouring cells all do — so a
  # record following house style wrote `` `fail` `` and the gate went silent on it. Measured
  # 2026-08-29 end to end: sibling `fail` against new `pass` REFUSED when bare, PASSED when either
  # side was backticked or bolded. A false refusal teaches --no-verify; a false silence teaches
  # nothing at all, which is worse. `{` is still not skipped, so an unfilled `{{…}}` still reads
  # empty.
  # **BOTH shapes, because everything else in §1f reads both.** Every other field check here is
  # `hits -iF`, and `record_task` was widened on 2026-08-21 for precisely this — the reader that
  # is rigid in a loose section is the reader that silently counts zero. `verdict_of` was written
  # last week and was not: a record writing `**Verdict**: pass` as a LINE satisfied every other
  # check in this section, was refused by nothing, and was invisible to the contradiction gate.
  # Measured 2026-08-29 by an adversarial lens, for `Outcome` as well as `Verdict`.
  unfenced | sed -nE "s/^[[:space:]]*\|[[:space:]]*(\\*\\*)?$1(\\*\\*)?[[:space:]]*\|[[:space:]]*[\`*]*([A-Za-z]+).*/\\3/p
           s/^[[:space:]]*[-*]?[[:space:]]*(\\*\\*)?$1(\\*\\*)?[[:space:]]*:[[:space:]]*[\`*]*([A-Za-z]+).*/\\3/pI" \
    | head -1 | tr 'A-Z' 'a-z'
}

# Every declaration of a named field, one per line — `verdict_of` is this taking the first.
# A record declaring the same field twice is the one case where "the first" is a guess: measured
# 2026-08-29, `| **Verdict** | none |` above `| **Verdict** | pass |` read `none` and hid a real
# contradiction, while the reverse order was refused. So the count is checked rather than the
# ambiguity resolved — one verdict per record, and a second one is a defect in the record.
verdict_count() {
  unfenced | sed -nE "s/^[[:space:]]*\|[[:space:]]*(\\*\\*)?$1(\\*\\*)?[[:space:]]*\|[[:space:]]*[\`*]*([A-Za-z]+).*/\\3/p
           s/^[[:space:]]*[-*]?[[:space:]]*(\\*\\*)?$1(\\*\\*)?[[:space:]]*:[[:space:]]*[\`*]*([A-Za-z]+).*/\\3/pI" \
    | grep -c . || true
}

# 1f · a run record carries its numbers, or it is a sentence wearing the word "record". The
#      guide calls it a door — `a dispatch lands as _ops/runs/R-<id>.md carrying its four token
#      numbers` — and nothing read one. `unknown` is an accepted value, as the guide says; an
#      absent field is not. `attempt` is here because it is what makes "three attempts and it
#      escalates" countable — that rule claimed `enforced_by: validator` with no field to count.
# `--diff-filter=A`, not `AM`: a record written before 0.2.7 has no `attempt` and never will,
# and refusing every commit that touches one strands the project over history it cannot change.
# What is required is that a NEW record is complete.
  # AR, not A. A record delivered as a rename escaped this gate whole: `git mv` the old file
  # onto a new id, edit it, and `--diff-filter=A` lists nothing — measured 2026-08-15 with a
  # record carrying `attempt: 4` and naming no escalation, exit 0. §1d in this file has used
  # `AR` since it was written.
while IFS= read -r -d '' rf; do
  for need in input output cache_read cache_write; do
    ( staged "$rf" || true ) | hits -iF "$need" || say_fail "$rf does not name \`$need\` — a \
dispatch record carries four token numbers, and \`unknown\` is an accepted value where the \
runtime does not report one. A sentence in History is not a record"
  done
  # Three attempts on one task is a spec problem, not a quality problem (escalating.md) — the
  # rule is written eleven times across nine files and claimed `enforced_by: validator` with no
  # field to count. The field exists now, so the count does too: a third attempt lands with the
  # escalation named in the same commit, or it is refused.
  att=$( ( staged "$rf" || true ) \
         | sed -nE 's/.*[Aa]ttempt[^0-9]*([0-9]+).*/\1/p' | head -1)
  # The field is a claim; the neighbours are a fact. A third record labelled `attempt: 1` — a
  # fresh count on the same task, which is what a worker who did not read the prior records
  # writes — passed a gate keyed only on the field. So the task's OTHER records are counted too,
  # and the higher of the two numbers is the one this refusal uses. Measured 2026-08-15: N93
  # scored 1/5 with four runs dispatching a further attempt having read neither prior record.
  # This does not repair that — a guard cannot see a dispatch — but it closes the case where the
  # record IS written and the count is simply wrong.
  # `{1,}` — a project whose ids are short (`T-9`) is still a project, and `{2,}` silently
  # matched nothing there, which is how this counted zero neighbours on its own fixture.
  # The id is read from where a record DECLARES its task — its title line or its `Task` row — and
  # matched as a whole token. `grep -rlF` over whole files counted two things it must not: a record
  # for a different task that merely NAMES this one (in `blocked_by`, which this section's own
  # escalation regex greps for), and a record for a task whose id merely extends this one as a
  # prefix. Measured 2026-08-15 (pass ten): three records naming `T-4F2K9Q` in a `blocked_by`
  # field made the FIRST EVER record on that task be refused as "attempt 4", with a number that
  # appears nowhere in the file. A false refusal on an ordinary dependency graph is how a project
  # learns to reach for --no-verify, which is the one outcome this file's header says it exists
  # to prevent — so the strictness costs more than the miss it was closing.
  rtask=$( ( staged "$rf" || true ) | record_task )
  # **An id read from a record that does not END there was truncated, and comparing it is worse
  # than skipping it.** `record_task` matches `T-[0-9A-Za-z-]+`, so `T-A.1` and `T-A.2` both read
  # as `T-A`: two records on genuinely different tasks were refused as one contradiction, with a
  # message naming a task id present in neither file — measured 2026-08-29, and the same
  # truncation drove the three-attempt gate. That is the failure this section's own comment calls
  # *"a number that appears nowhere in the file"*, arriving through the id READER rather than the
  # matcher. `new-id.py` never mints punctuation, but an imported backlog's key is whatever the
  # source used. A miss costs a missed contradiction; a false refusal costs `--no-verify`.
  if [ -n "${rtask:-}" ] \
     && [ "$( ( staged "$rf" || true ) | grep -cE "${rtask}[0-9A-Za-z._/]" || true )" -gt 0 ]; then
    say_warn "$rf declares a task id that does not end where this guard stops reading it \
(\`$rtask\` …) — §1f's neighbour count and the contradiction gate skip this record rather than \
compare it against the wrong task. Ids minted by \`new-id.py\` are never affected"
    rtask=""
  fi
  if [ -n "${rtask:-}" ]; then
    # The neighbour table is built ONCE, on first use, not per record: the previous form forked
    # `git show` for every kept record for every new one — O(new × kept) — which on a project with
    # a few hundred records turns a commit into a two-minute wait, and a hook people wait two
    # minutes for is a hook they pass with --no-verify. Scoped to `R-*.md`, which is what §1f
    # applies to; the old glob read every `.md` in the directory, so an ordinary note living there
    # was parsed as a run record. Both measured 2026-08-16 (pass eleven).
    # **The guard names the table it guards.** It said `_sibtab` for an hour after the two tables
    # were collapsed into `_vtab` — a variable nothing assigned any more, so the test was always
    # true and the table was rebuilt once per changed record: measured 2026-08-29, four builds for
    # four records, 16s against 150 kept ones. That is the exact regression the comment below says
    # was removed on 2026-08-16, reintroduced by the commit titled *one walk paid for twice*.
    # `scripts/test-company-preflight.sh` now refuses a guard whose variable is not the one the
    # body assigns, because nothing about correctness notices this — all 189 assertions stayed
    # green through it.
    if [ -z "${_vtab:-}" ]; then
      # ONE table, five columns: task · file · outcome · verdict · does it name an escalation.
      # It shipped as two — the attempt counter's pair and the contradiction gate's five — built
      # side by side in this loop from the same buffer, with `record_task` forked twice over
      # identical bytes — three extra processes per kept record, which is the cost a second walk
      # would have had, arrived at by another route. Found 2026-08-28.
      _vtab=$(mktemp) || _vtab=/tmp/.cpf-vtab.$$
      _cpf_tmp="$_cpf_tmp $_vtab"
      while IFS= read -r -d '' other; do
        _ob=$( ( staged "$other" 2>/dev/null || cat "$other" 2>/dev/null || true ) )
        printf '%s\t%s\t%s\t%s\t%s\n' \
          "$(printf '%s' "$_ob" | record_task)" "$other" \
          "$(printf '%s' "$_ob" | verdict_of Outcome)" \
          "$(printf '%s' "$_ob" | verdict_of Verdict)" \
          "$(printf '%s' "$_ob" | escalation_count)" \
          >> "$_vtab"
      done < <(git ls-files -z -- '_ops/runs/R-*.md')
    fi
    # field 1 is the task, so the attempt count reads this table unchanged; the second test
    # anchors on the TAB after the filename, because the row no longer ends there.
    sib=$(grep -c "^${rtask}$(printf '\t')" "$_vtab" 2>/dev/null || echo 0)
    grep -q "^${rtask}$(printf '\t')${rf}$(printf '\t')" "$_vtab" 2>/dev/null || sib=$(( sib + 1 ))
    [ "${sib:-0}" -gt "${att:-0}" ] 2>/dev/null && att=$sib
  fi
  if [ -n "${att:-}" ] && [ "$att" -ge 3 ] 2>/dev/null; then
    # A FIELD the message prints, not five keywords it keeps to itself. The keyword form was
    # unfollowable in one direction and satisfiable in the other, both measured 2026-08-16 (pass
    # eleven): a reader who did exactly what the message said — wrote, in the record, why a fourth
    # was right — was refused again with the identical text and no new information; and a record
    # saying *"not a spec problem — the sandbox was flaky"* PASSED, because it contains the
    # substring `spec problem`. A gate satisfied by denying the thing it asks for is worse than an
    # absent one. The shape that measured 5/5 on this corpus prints the literal line to write.
    [ "$( ( staged "$rf" || true ) | escalation_count )" -gt 0 ] \
      || say_fail "$rf records attempt $att and carries no \`Escalated:\` line — three rounds on \
one point is a spec problem, not a quality problem. Add ONE line to this record, and its content \
is the whole point:
    **Escalated**: <what you raised, and to whom — or why a fourth attempt is right anyway>
Prose elsewhere in the record does not satisfy this and is not meant to: the field exists so the \
next reader can find the decision without reading the run"
  fi
  # **The contradiction stop — the bound `escalating.md` has carried as prose since 2026-08-21.**
  # Three attempts bound FAILURE. Nothing bounded CONTRADICTION, which is the worse state: two
  # runs answering one question differently both end `completed`, so a ledger holding only
  # `Outcome` records that both finished and loses the disagreement entirely. Every run inside it
  # reports confidently, and the confidence is the problem. `LATER.md` named the missing half
  # exactly — *a run record cannot carry the answer it reached, only how it ended* — and refused
  # to add the field for a gate's sake alone. The review flow wants it written for its own
  # reasons: a reviewer's conclusion is what the requester acts on, and a second reviewer can
  # only be compared to the first if the first wrote down what it concluded.
  #
  # **The excused set is ONE CLAUSE, wherever it appears.** Only `pass` against `fail` clashes
  # — every other value, and every run that did not complete, is excused. It shipped as four
  # enumerations across three files, no two alike and none of them complete — one forgot
  # unfinished runs, one forgot an unfilled cell; a deletion lens counted them the day they were
  # written. Four lists to keep in sync is four chances to be wrong about one rule — this file's own history says a false refusal on ordinary work costs
  # more than the miss it closes, because it is how a project learns to reach for --no-verify.
  # **And a disagreement is not itself the failure.** Recording it satisfies the gate; what is
  # refused is a second, opposite verdict landing with nothing anywhere saying anyone noticed.
  _vme=$( ( staged "$rf" || true ) | verdict_of Verdict)
  _ome=$( ( staged "$rf" || true ) | verdict_of Outcome)
  # **One verdict per record**, or "the first one" is a guess that hid a contradiction (above).
  [ "$( ( staged "$rf" || true ) | verdict_count Verdict )" -le 1 ] \
    || say_fail "$rf declares \`Verdict\` more than once, and only the first is read — so which \
one this record actually concluded is not decidable from the file. Keep one, in the run's table."
  # **A word that is not one of the four is refused, not excused.** `failed` and `passed` came
  # back whole and matched neither `pass` nor `fail`, so they took the silent-excuse path — and
  # `failed` is a legal *Outcome* value two rows above the Verdict cell, which is exactly the
  # confusion a run record invites. Measured 2026-08-29. An ABSENT verdict stays legal: that is
  # every record written before this field existed.
  case "${_vme:-}" in
    ""|pass|fail|mixed|none) ;;
    *) say_fail "$rf gives \`$_vme\` as its \`Verdict\`, which is not one of \`pass\` · \
\`fail\` · \`mixed\` · \`none\`. Anything else is read as no verdict at all and compared with \
nothing — silently. If you meant how the run ENDED, that is \`Outcome\`, two rows up.";;
  esac
  if [ -n "${rtask:-}" ] && [ "${_ome:-}" = "completed" ] \
     && { [ "${_vme:-}" = "pass" ] || [ "${_vme:-}" = "fail" ]; }; then
    _clash=$(awk -F'\t' -v t="$rtask" -v me="$rf" -v v="$_vme" \
      '$1==t && $2!=me && $3=="completed" && ($4=="pass"||$4=="fail") && $4!=v {print $2"\t"$5; exit}' \
      "$_vtab" 2>/dev/null)
    if [ -n "$_clash" ]; then
      _cf=${_clash%%$(printf '\t')*}; _ce=${_clash##*$(printf '\t')}
      # computed straight from the record rather than read out of _vtab field 5: the table is
      # built from `staged || cat`, and coupling the refusal to that fallback would make this
      # gate depend on a path it does not control.
      _eme=$( ( staged "$rf" || true ) | escalation_count )
      # **A line that is still the placeholder is a different mistake from no line at all.**
      # Measured 2026-08-29: a reader who pasted the printed line and typed their answer AFTER the
      # angle brackets was refused with the message that asks for the line they had just written.
      _eraw=$( ( staged "$rf" || true ) | escalation_lines | grep -c . || true )
      if [ "${_eme:-0}" -eq 0 ] && [ "${_eraw:-0}" -gt 0 ] && [ "${_ce:-0}" -eq 0 ]; then
        say_fail "$rf has an \`Escalated:\` line that still carries the printed placeholder — \
\`$ESC_PLACEHOLDER\` — so nothing in it says what actually differed. Replace that bracketed text \
(do not type around it): the machine, the version, the shell, the working tree, or the order the \
two runs ran in. Every one of those five has caught something in this project's own history, and \
none of them is visible from inside a single run."
      elif [ "${_eme:-0}" -eq 0 ] && [ "${_ce:-0}" -eq 0 ]; then
        say_fail "$rf concludes \`$_vme\` on $rtask while \`$_cf\` concluded the opposite, and \
neither record says anyone noticed. Two runs disagreeing on one question stop the work at the \
SECOND ANSWER, not the third — this is the first time the two have disagreed, and once is \
already the finding, because running it again until one agrees with you is sampling until the \
answer is convenient. Add ONE line to this record:
    **Escalated**: the question is unstable — $ESC_PLACEHOLDER
It escalates as \"the question is unstable\", never as \"which run was right\": arbitration \
produces a winner rather than a resolution, and every one of those five differences has caught \
something in this project's own history"
      fi
    fi
  fi
  for need in "model that answered" "attempt" "outcome"; do
    ( staged "$rf" || true ) | hits -iF "$need" || say_fail "$rf has no \`$need\` field — \
without it the run cannot be sliced later, and a slice you did not record a field for is \
impossible rather than merely missing"
  done
done < <(changed --diff-filter=AR -- '_ops/runs/R-*.md')

# 1g · a child link that resolves to nothing is a board that cannot be walked. The template
#      writes children as `- [ ] [T-XXXXXX](T-XXXXXX-slug.md)` precisely so the board is
#      navigable and a rotted link is catchable — measured on a live project, twelve tasks with
#      plainly dependent work and not one link between them, because a bare id is a string.
while IFS= read -r -d '' tf; do
  while IFS= read -r target; do
    [ -n "$target" ] || continue
    # A template's example link points at an id nobody has minted yet, and a task copied
    # from `TASK-template.md` carries five of them — measured: the shipped template was
    # refused five times by this check, on the first commit of a project standing up from it.
    case "$target" in http*|""|*XXXXXX*|*"{{"*) continue;; esac
    [ -e "$(dirname "$tf")/$target" ] || say_fail "$tf links to \`$target\`, which is not \
there — a child or parent link that resolves to nothing is worse than a bare id, because it \
reads as navigable. Fix the path, or say the id in plain text"
  done <<LINKS
$( ( staged_diff "$tf" ) | grep '^+' | grep -v '^+++ ' \
   | sed 's/^+//' | awk '/^[[:space:]]*(```|~~~)/{f=!f; next} !f' \
   | grep -oE '\]\([^)]+\.md\)' | sed -E 's/^\]\(//; s/\)$//' || true)
LINKS
done < <(changed --diff-filter=AMR -- '_ops/tasks/*.md')

# 2 · a recorded fact past its recheck is unknown, not fact. TOOLING.md carries a
#     Checked column precisely so this can be enforced rather than hoped for.
if [ -f _ops/TOOLING.md ]; then
  python3 - <<'PY'
import re, datetime
# Past the first threshold a row is worth a nudge. Past the second it is not a stale fact, it is
# a false one sitting where agents read it as true — and warnings do not get acted on. Measured:
# a row eleven months old said "free tier, 1,000/month" for a vendor that had closed its free
# tier; three separate runs found that out, said so clearly, and left the row exactly as it was,
# each listing "update the register" as something for the owner to do later.
STALE_DAYS, FALSE_DAYS = 90, 180
today = datetime.date.today()
for line in open("_ops/TOOLING.md", encoding="utf-8"):
    if not line.strip().startswith("|"):
        continue
    m = re.search(r"(\d{4})-(\d{2})-(\d{2})", line)
    if not m:
        continue
    d = datetime.date(*map(int, m.groups()))
    age = (today - d).days
    if age > FALSE_DAYS:
        print(f"FALSE:{line.split('|')[1].strip()} (checked {d}, {age}d ago)")
    elif age > STALE_DAYS:
        print(f"STALE:{line.split('|')[1].strip()} (checked {d}, {age}d ago)")
PY
fi 2>/dev/null > /tmp/.pf-tooling.$$ || true
while IFS= read -r l; do
  case "$l" in
    STALE:*) say_warn "TOOLING entry past its recheck: ${l#STALE:}";;
    FALSE:*) say_fail "TOOLING entry ${l#FALSE:} — past twice its recheck, so it is not stale, \
it is false where agents read it as true. Re-verify it, or write the value as \`unknown\` with \
today's date. Writing \`unknown\` needs no new information and takes one edit.";;
  esac
done < /tmp/.pf-tooling.$$
rm -f /tmp/.pf-tooling.$$

# A field's value, from a markdown line that may wear any decoration: `**payload**:`, `- Payload :`,
# `payload: "x"`. Everything before the first colon after the key is stripped, then quotes,
# backticks and asterisks. Returns empty when the key is absent OR present with nothing after it —
# which is the point: the first version of these gates tested for the SUBSTRING, and a lens showed
# that `**Ask**: we need an image. payload: predicate: destination:` satisfied all three checks
# while saying exactly what they were written to refuse. A key with no value is not an answer.
# `{{…}}` is the template's own placeholder: an untouched one is a hole, not a value —
# measured, the shipped REQUEST-template passed §16 with nothing filled in. Fenced blocks are
# stripped before this runs, because the template's worked EXAMPLE is not the request.
field() { # field <key> <file-or-"-">
  sed -nE "s/^[[:space:]]*[-*]?[[:space:]]*[*\`_]*$1[*\`_]*[[:space:]]*:[[:space:]]*//Ip" "$2" \
    | sed -E 's/^["'"'"'\`*]+//; s/["'"'"'\`*]+$//' \
    | grep -vE '^[[:space:]]*$|\{\{' | head -1
}
# Read from the INDEX, never the worktree: every other check in this file uses `git diff --cached`
# or `git show HEAD:`, and a gate that reads the disk passes a commit whose staged content is
# broken — stage the bad version, fix it in the editor, forget `git add`, commit green.

# 16 · a `relay` is one operation the worker cannot perform — not the job. The failure it exists
#      to catch is the request that reads "we need an image for the post": the whole task leaving
#      under the name of a step, landing on someone with no runs and no capacity, where its
#      progress goes invisible. Three of the four things are checked here; the fourth — what to
#      return with the result — is caught downstream by §15 when the recipe cannot be filled, and
#      this file does not claim otherwise. requests.md → `relay`.
# `done < <(…)` and not `… | while`: a loop on the right of a pipe runs in a SUBSHELL, so every
# `say_fail` inside it prints and its `fail=1` dies with the subshell — the gate speaks and the
# commit passes. Measured on this very rewrite, which is why the note is here and not in a
# changelog: the shape that fails open is the natural one to write.
while IFS= read -r -d '' r; do
  tmp=$(staged "$r") || continue
  [ -n "$tmp" ] || continue
  f=$(mktemp); printf '%s\n' "$tmp" | awk '/^```/{fence=!fence; next} !fence' > "$f"
  # A file that names itself a relay ANYWHERE counts as one. Requiring a well-formed `kind:` line
  # to notice it would let a malformed relay through unexamined, which is the failure inverted.
  grep -qiE 'kind[^:]*:[[:space:]]*[*\`_]*relay|\|[[:space:]]*[*\`_]*kind[*\`_]*[[:space:]]*\|[[:space:]]*[*\`_]*relay' "$f" \
    || { rm -f "$f"; continue; }
  missing=""
  [ -n "$(field payload "$f")" ]     || missing="$missing payload"
  [ -n "$(field predicate "$f")" ]   || missing="$missing predicate"
  [ -n "$(field destination "$f")" ] || missing="$missing destination"
  rm -f "$f"
  [ -z "$missing" ] || say_fail "$r is a \`relay\` and is missing a value for:$missing — a relay \
carries the payload verbatim, the predicate that decides whether what comes back is acceptable, \
and where the result lands. A key with nothing after it counts as missing. Without them this is \
not one operation going up, it is the task going up, to someone with no runs and no capacity \
(requests.md)."
done < <(changed -- '_ops/requests/*.md')

# 15 · (numbered by arrival, placed by theme) a generated asset without its recipe is
#      unrepeatable, and nobody finds out on the day. A month later the second banner in the set
#      comes back "close but not it", the model has moved, the prompt is gone, and the set stops
#      matching without anyone deciding to let it.
#      **Three lessons are baked into the selector, each paid for by a lens.** (a) A list of
#      vendor names goes stale between releases — Ideogram, Nano Banana and gpt-image-1 all
#      walked through it. (b) Replacing that list with a declared `origin:` NARROWED the gate,
#      because a row saying only "Midjourney v7" then matched nothing: an upgrade that quietly
#      narrows a gate is worse than no upgrade, so the vendor names are kept as a genuine
#      supplement rather than a replacement. (c) The opt-out must not be authorable by the
#      constrained party — `origin: build` mentioned anywhere in a row used to excuse a row that
#      also declared `origin: generated`, which §13's own principle forbids.
#      visual.md §A generated asset carries its recipe.
VENDORS='midjourney|dall-?e|stable diffusion|sdxl|flux|imagen|comfyui|fal\.ai|replicate|ideogram|firefly|recraft|seedream|nano banana|gpt-image'
# The value of `key:` inside a table row: everything up to the next comma, pipe or end, trimmed
# of decoration. Empty is missing — and so is a value that BEGINS with another `word:`, which
# is the next key rather than an answer. That is how
# `model: prompt: seed: none` satisfied three substring tests at once while carrying no recipe.
rowval() { # rowval <row> <key>
  printf '%s\n' "$1" \
    | sed -nE "s/.*[^a-zA-Z0-9_-]$2[[:space:]]*:[[:space:]]*([^,|]*).*/\1/Ip" \
    | sed -E 's/^[[:space:]*\`_"'"'"']+//; s/[[:space:]*\`_"'"'"']+$//' \
    | grep -vE '^[[:space:]]*$|^[A-Za-z][A-Za-z0-9_-]*:|^[-—–?.]+$|^(tbd|n/a|none yet|unknown)$' | head -1
}
if ( git diff --cached --name-only 2>/dev/null || true ) | hits -xF '_ops/assets.md'; then
  while IFS= read -r row; do
    # A declared origin always wins: only a row that does NOT declare `origin: generated` may be
    # excused by another origin. The exclusion used to run last and beat the declaration.
    if ! printf '%s\n' "$row" | hits -iE 'origin:[[:space:]]*generated'; then
      printf '%s\n' "$row" | hits -iE 'origin:[[:space:]]*(drawn|stock|build|licensed|commissioned)' && continue
    fi
    short=$(printf '%s' "$row" | cut -c1-60)
    for k in model prompt seed; do
      [ -n "$(rowval "$row" "$k")" ] || say_fail "an asset row in _ops/assets.md is a generated \
asset and has no \`$k:\` value — a generated image whose recipe was not written down cannot be \
made again, and the set it belongs to drifts. \`seed: none\` is an accepted answer where the \
model exposes none; an empty key, or a key whose value is the next key, is not (visual.md): $short"
    done
  done < <(staged _ops/assets.md \
             | grep -iE "^[[:space:]]*\|.*(origin:[[:space:]]*generated|\bgenerated\b|$VENDORS)")
fi

# 3 · DECISIONS.md is append-only. Rewriting it is how a rejected idea comes back
#     next quarter with nobody able to say why it was rejected the first time.
if git rev-parse --verify HEAD >/dev/null 2>&1 && [ -f _ops/DECISIONS.md ]; then
  # Removed lines counted against the added set, by MULTIPLICITY: in a unified diff a removed
  # bullet arrives as `--`, and appending to a file with no trailing newline shows its last
  # line removed and re-added. A line that comes back the same number of times was not removed.
  # Counting membership instead let three identical entries collapse to one in silence, and a
  # decision moved out of the log into a fenced block counted as still present. Pure shell on
  # purpose — this guard must keep working in a project with no python3. Stated limit: this
  # protects the TEXT, not its rendering — moving an entry into a fenced block keeps the
  # line and passes, which reading markdown structure in shell would be a poor trade for.
  _diff=$(git diff --cached -U0 -- _ops/DECISIONS.md 2>/dev/null || true)
  _added_f=$(mktemp); _removed_f=$(mktemp)
  printf '%s\n' "$_diff" | sed '1,/^@@/d' | grep '^+' | sed 's/^+//' > "$_added_f" || true
  # the header is dropped by PATH, not by shape: a removed line whose own text starts with
  # `-- ` arrives as `--- …` and was being read as the diff header, hiding every such bullet
  # The header is dropped by STRUCTURE, not by its `a/` prefix: `diff.noprefix`,
  # `diff.mnemonicPrefix` and `diff.srcPrefix` are ordinary settings, and under any of them the
  # header arrives as `--- _ops/DECISIONS.md` and becomes a phantom removed line — refusing
  # every commit to the file, including the append the refusal asks for. Everything up to and
  # including the first hunk marker is header.
  printf '%s\n' "$_diff" | sed '1,/^@@/d' | grep '^-' | sed 's/^-//' > "$_removed_f" || true
  # One awk pass, not `uniq -c | while read`: `read` strips leading and trailing whitespace
  # from the line it hands on, so a decision bullet with a trailing space could not match
  # itself and was refused as removed. awk compares the lines byte for byte.
  # The added side is read in BEGIN rather than as awk's first file: with `NR==FNR` an EMPTY
  # first file makes the test true for the second one too, so every removed line landed in the
  # added set and the gate counted zero — measured, on the very case it exists for.
  removed=$(awk -v addf="$_added_f" '
      BEGIN { while ((getline l < addf) > 0) a[l]++ }
      { r[$0]++ }
      END { n = 0
            for (l in r) { d = r[l] - (l in a ? a[l] : 0); if (d > 0) n += d }
            print n+0 }' "$_removed_f")
  rm -f "$_added_f" "$_removed_f"
  [ "${removed:-0}" -gt 0 ] && say_fail "_ops/DECISIONS.md is append-only — this commit \
removes or rewrites $removed line(s). Add a new entry instead."
fi

# 3b · the migration log in config.md is append-only for the same reason, and a sharper one:
#      it is the only thing that can distinguish "the files were swapped" from "the project was
#      migrated", and a step re-run after a failure must append rather than overwrite — "this
#      was attempted twice" is exactly the fact a later reader needs. Scoped to the section, so
#      ordinary edits elsewhere in config.md stay free.
# Measured 2026-08-14: this could never fire. It was gated on a flat `config.md` that the
# migration moves to `_ops/config.md`, and its two filters excluded each other — the first
# dropped every `--` line, the second required exactly that shape.
cfg=""
for c in _ops/config.md config.md; do [ -f "$c" ] && { cfg="$c"; break; }; done
if git rev-parse --verify HEAD >/dev/null 2>&1 && [ -n "$cfg" ] \
   && grep -q '^## Migrations' "$cfg"; then
  removed=$(git diff --cached -U0 -- "$cfg" 2>/dev/null \
            | grep -v '^--- ' | grep -cE '^-[[:space:]]*-.*(→|->)' || true)
  [ "${removed:-0}" -gt 0 ] && say_fail "the migration log in $cfg is append-only — this \
commit removes or rewrites $removed line(s). A re-run appends a line; it does not replace one."
fi

# 4 · the architecture map must mention the places work actually happens.
if [ -f _ops/ARCHITECTURE.md ]; then
  # NUL-separated like the rest — a top-level directory holding a space would otherwise split
  # into two names, each warned about separately and neither one real. The first path component
  # and the de-duplication are done in the shell rather than with `awk 'BEGIN{RS="\\0"}'`, which
  # BSD awk cannot do: awk strings are NUL-terminated, so `ORS` emits a literal backslash-zero
  # and the whole listing arrives as one record. Measured 2026-08-15 — and measured only because
  # the same day showed that a form checked at the prompt is not the form the script runs.
  _seen=""
  while IFS= read -r -d '' _f; do
    case "$_f" in */*) d=${_f%%/*};; *) continue;; esac
    case " $_seen " in *" $d "*) continue;; esac
    _seen="$_seen $d"
    case "$d" in docs|.github|node_modules|dist|build|vendor) continue;; esac
    grep -q "$d" _ops/ARCHITECTURE.md || say_warn "_ops/ARCHITECTURE.md never mentions \`$d/\` \
— either map it or say why it doesn't matter"
  done < <(git ls-files -z)
fi

# 4b · the product map, where one exists, must parse and stay reachable. An unclosed mermaid
#      fence renders as a bomb on every surface that draws it, and a split-out move file nothing
#      points at is a flow the index quietly forgot.
for m in _ops/MAP.md _ops/map/*.md; do
  [ -f "$m" ] || continue
  fences=$(grep -c '^```' "$m")
  [ $((fences % 2)) -eq 0 ] || say_fail "$m has an unclosed \`\`\` fence — the map renders as an error"
done
if [ -d _ops/map ]; then
  for m in _ops/map/*.md; do
    [ -f "$m" ] || continue
    grep -q "$(basename "$m")" _ops/MAP.md 2>/dev/null \
      || say_fail "_ops/MAP.md never points at $(basename "$m") — a move file the index forgot"
  done
fi

# 4b-bis · **the guard checks its OWN age against the guide.** This file is a COPY: it is written
#      into `_ops/scripts/` at stand-up and never moves again by itself, so every release that adds
#      a check leaves every existing project on the old one — silently, with a green tick. The
#      upgrade's four layers name the skill's bytes, the project's format, attached skills and
#      tooling versions; **the installed machinery was in none of them**, which is the fifth layer
#      and the one nobody notices, because a stale guard does not complain: it simply does less.
#
#      A WARNING and not a refusal: a project may sit a version behind on purpose between upgrades,
#      and a guard that refuses every commit until someone re-copies it is a guard people delete.
_gv=$(sed -n 's/^# guard-version:[[:space:]]*\([0-9.]*\).*/\1/p' "$0" | head -1)
_pv=$(grep -m1 -oE 'Operated by:\*\*[^*]*\*\*([0-9]+\.[0-9]+\.[0-9]+)\*\*' CLAUDE.md 2>/dev/null \
      | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
if [ -n "$_gv" ] && [ -n "$_pv" ] && [ "$_gv" != "$_pv" ]; then
  say_warn "this guard is version $_gv and the guide says the project runs $_pv — the guard is a \
COPY and does not move with an upgrade, so any check added since $_gv is not running here and \
nothing else will say so. Re-copy it beside its doors: \`cp <skill>/templates/company-preflight.sh \
_ops/scripts/preflight.sh\` and the two scripts next to it, then run \`bash _ops/scripts/preflight.sh \
--install\`. A stale guard does not complain; it does less"
fi

# 4c · **a move added to the map names the job it is hired for.** A move is a route someone takes;
#      the job is what they were trying to get done when they took it. Without it the map answers
#      *how the product is walked* and never *why anyone walks it* — and a roadmap built on that
#      map proposes routes nobody asked for, which is the failure this field exists to make
#      visible rather than to argue about.
#
#      **A job story, not a user story**: `when <situation>, someone wants to <motivation>, so
#      they can <outcome>`. Behaviour with a trigger, which can be checked against a real person;
#      *"as a user I want"* is a wish with a costume, and it cannot be wrong.
#
#      ENFORCED ON WHAT THE COMMIT CREATES, like every other gate here: a move already on the map
#      is left alone, because retro-filling a map is a project's decision and not a commit's. Only
#      a `### ` heading ADDED by this commit is asked, and it is asked once.
_map_missing=""
while IFS= read -r -d '' m; do
  # the added move headings in this file, and the added body under each
  _added=$( ( git diff --cached -U0 -- "$m" 2>/dev/null || true ) | grep '^+' | grep -v '^+++ ' | sed 's/^+//' )
  printf '%s\n' "$_added" | grep -qE '^###[[:space:]]+\S' || continue
  # A job may be declared on the move's own line or anywhere in the block this commit added for
  # it. Reading the whole added hunk is deliberate: a diff does not carry section boundaries, and
  # demanding the field on the heading line itself would refuse the ordinary shape where it sits
  # underneath. One job per commit-that-adds-moves, not one per heading — a stricter rule needs a
  # section parser, and this file's own law is that a gate reads what it can read honestly.
  printf '%s\n' "$_added" | grep -qiE '\*\*Job\*\*[[:space:]]*:[[:space:]]*\S' \
    || _map_missing="$_map_missing $m"
done < <(changed --diff-filter=AMR -- '_ops/MAP.md' '_ops/map/*.md')
[ -z "$_map_missing" ] || say_fail "this commit adds a move to$(printf '%s' "$_map_missing" | tr -s ' ') \
and no \`**Job**\` line comes with it — a move is a route, and the job is what someone was trying to \
get done when they took it. Without it the map says how the product is walked and never why, and a \
roadmap reading that map proposes routes nobody asked for. Write it as a job story, which can be \
wrong: \`**Job**: when <situation>, someone wants to <motivation>, so they can <outcome>\`. If the \
honest answer is that nobody knows yet, that is a valid job line — write \`unknown, and here is what \
would settle it: …\` — but it is not a blank"

# 4d · **a market figure carries where it came from and when.** `_ops/MARKET.md` holds the size
#      of the opportunity, and this is the single most hallucination-prone file a project can own:
#      a plausible number arrives free, reads as research, and is quoted for a year. So a figure
#      line is refused unless it carries a SOURCE and a DATE beside it — the same law
#      `permissions.md` already applies to prices, applied where the numbers are largest and the
#      checking is hardest.
#
#      `unknown` IS an accepted value, and that is the point: the gate is not asking for a number,
#      it is asking that a number, once written, be traceable. A file honestly saying `TAM:
#      unknown — nobody has counted this` passes; one saying `TAM: $4.2B` does not.
#
#      A figure is a currency amount or a count with a unit. Prose about a market is not a figure
#      and is not asked — this refuses claims, not sentences.
if ( changed --diff-filter=AMR -- '_ops/MARKET.md' ) | hits . ; then
  _mkt_bad=""
  # **A figure and its provenance may be on two lines.** This corpus hard-wraps at ~98 columns, so
  # `SAM: 180,000 firms · source: …` splits, and a line-at-a-time test saw the number without the
  # source and refused. It refused the SHIPPED `templates/MARKET-template.md` — the documented
  # stand-up act — so every new project would have met this on day one. Measured 2026-08-23.
  # Each line is therefore tested together with the one after it, which is where a wrapped
  # continuation lives; the same flattening lesson as three other checks in these repositories.
  _mkt_lines=$( ( git diff --cached -U0 -- _ops/MARKET.md 2>/dev/null || true ) \
                | grep '^+' | grep -v '^+++ ' | sed 's/^+//' \
                | awk '/^[[:space:]]*```/{f=!f; next} !f' )
  _mkt_pairs=$(printf '%s\n' "$_mkt_lines" | awk '{prev=cur; cur=$0; if (NR>1) print prev " " cur} END {print cur}')
  while IFS= read -r _l; do
    # a figure: a currency amount, or a bare number with a magnitude suffix or a unit noun
    printf '%s\n' "$_l" \
      | grep -qiE '(^|[^0-9A-Za-z])([$€£¥][0-9][0-9.,]*|[0-9][0-9.,]*[[:space:]]*(m|bn|b|k|million|billion|thousand)\b|[0-9][0-9.,]*[[:space:]]*(people|users|firms|companies|households|businesses|customers|seats))' \
      || continue
    # …must carry a source AND a date on the same line
    printf '%s\n' "$_l" | grep -qiE '(source|per|from|via)[[:space:]]*:?[[:space:]]*\S' \
      && printf '%s\n' "$_l" | grep -qE '20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]|20[0-9][0-9]' \
      || _mkt_bad="$_mkt_bad
    $_l"
  done < <(printf '%s\n' "$_mkt_pairs")
  [ -z "$_mkt_bad" ] || say_fail "_ops/MARKET.md adds figures with no source and date beside them:\
$_mkt_bad
— a market number is the easiest thing in a project to invent and the hardest to check, and one \
quoted without provenance is indistinguishable from one somebody made up. Each figure carries \
where it came from and when: \`TAM: \$4.2B · source: <who counted, and how> · 2026-08-21\`. \
\`unknown\` is an accepted answer and needs nothing — this gate asks that a number, once written, \
be traceable, not that a number exist"
fi

# 4e · **a new dependency says what it replaces.** The sharpest rung of *should this exist at all*
#      is the one a commit can be asked about: adding a dependency. Everything above it in the
#      ladder — is it already here · does the standard library do it · does the platform do it
#      natively · can it be one line — is a judgement no script can make. **Whether the answer was
#      written down is not.**
#
#      So this refuses a commit that ADDS a dependency line with nothing in the same commit saying
#      what was considered. `unknown` is not the escape here that it is for a market figure: the
#      answer is cheap and the asker is the person who just chose. One line in `_ops/DECISIONS.md`
#      naming the dependency does it.
#
#      Enforced on what the commit CREATES, like every gate here — existing dependencies are the
#      project's history and are not retro-justified.
_dep_added=""
_dep_names=""   # under `set -u` an unset name is not empty, it is the end of the script —
                # and it ends BEFORE printing anything, so the failure arrives as a green
                # tick with no refusal. Caught by this gate's own suite, 2026-08-22.
while IFS= read -r -d '' mf; do
  # the added lines of this manifest, fences and lockfiles aside
  case "$mf" in *.lock|*lock.json|*.sum) continue;; esac
  _new=$( ( git diff --cached -U0 -- "$mf" 2>/dev/null || true ) | grep '^+' | grep -v '^+++ ' | sed 's/^+//' )
  # The NAME, not just the shape. A keyword list was the first version and the suite caught it
  # inside the hour: it accepted a justification that happened to say `stdlib` and refused an
  # honest one that did not — the substring-instead-of-value class, in a gate written the same day
  # two others were repaired for it. Requiring the dependency's own NAME cannot be satisfied by
  # vocabulary, and the person who just chose it is the one person who can write it.
  # ADDED MINUS REMOVED. Writing a manifest reformats its neighbours — adding one dependency
  # re-indents the line above it and puts a comma on it, so a naive read of the `+` side asked
  # about a package nobody touched. It also, for free, stops a VERSION BUMP being treated as a
  # new dependency: the name is on both sides, so it cancels. Both measured 2026-08-22, the first
  # by this gate's own suite within the hour.
  _gone=$( ( git diff --cached -U0 -- "$mf" 2>/dev/null || true ) | grep '^-' | grep -v '^--- ' | sed 's/^-//' )
  # ANYWHERE in the line, not anchored to its start. Third iteration of this extractor, and
  # reformatting was the adversary every time: writing a manifest re-indents neighbours (caught
  # first), and it also COLLAPSES or EXPANDS them — `{"react": "^18.0.0"}` on one line becomes
  # three, so the removed side carries the name inside a brace and a line-anchored read missed it,
  # reporting a package nobody touched. Measured 2026-08-22, all three by this gate's own tests.
  # **Seven manifest kinds are named in the pathspec, so seven shapes are read.** The first
  # version matched two — JSON `"n": "^1.0"` and `n==1.0` — and was blind to `"latest"`, `"*"`,
  # `npm:`/`git+`/`file:` specifiers, bare `requirements.txt` names, `go.mod`'s `require`, TOML
  # tables, and Gemfile `gem "x"`. Nine of sixteen realistic ways to add a dependency, in a gate
  # whose pathspec promises all seven files. Measured 2026-08-23 by two lenses.
  # The VALUE decides, not the key. Dropping the version-prefix requirement to catch `"latest"`
  # and `"*"` made `"name": "renamed"` a dependency — caught by this gate's own suite within the
  # minute. So the value must look like a version or a known specifier: a digit, `^ ~ > < =`,
  # `latest`, `*`, or a `npm: git+ file: workspace: link:` prefix. A key blocklist was the other
  # option and it rots; this reads what a dependency actually looks like.
  _pick() { grep -oE '"[A-Za-z0-9@/._-]+"[[:space:]]*:[[:space:]]*"([~^>=<*0-9]|latest|npm:|git\+|file:|workspace:|link:)[^"]*"|^[[:space:]]*(require[[:space:]]+)?[A-Za-z0-9_.@/-]+[[:space:]]*([=~<>!]{1,2}[[:space:]]*[0-9v]|[[:space:]]+v?[0-9])|^[[:space:]]*gem[[:space:]]+"[^"]+"|^[[:space:]]*[A-Za-z0-9_.-]+[[:space:]]*=[[:space:]]*[{"][~^>=<*0-9]' \
             | grep -oE '"[A-Za-z0-9@/._-]+"|^[[:space:]]*(gem[[:space:]]+"[^"]+"|require[[:space:]]+[A-Za-z0-9_.@/-]+|[A-Za-z0-9_.@/-]+)' \
             | sed 's/^[[:space:]]*gem[[:space:]]*//; s/^[[:space:]]*require[[:space:]]*//' | tr -d '" \t' \
             | grep -vE '^([0-9~^v]|require$|dependencies$|dev-dependencies$|tool$|project$|package$)' || true; }
  _old_names=$(printf '%s\n' "$_gone" | _pick)
  _names=$(printf '%s\n' "$_new" | _pick | while IFS= read -r _n; do
             [ -n "$_n" ] && { printf '%s\n' "$_old_names" | hits -xF -- "$_n" || printf '%s\n' "$_n"; }
           done)
  [ -n "$_names" ] && _dep_added="$_dep_added $mf" && _dep_names="$_dep_names $_names"
# **Rooted AND at depth.** A bare `package.json` is a git pathspec anchored at the top
# level, so a monorepo — `frontend/package.json`, `services/api/go.mod` — was invisible to
# both this gate and the reach gate. That is exactly the case the reach gate was widened
# for. Measured 2026-08-23. Lockfiles are skipped in the loop above, so `*/…` is safe.
done < <(changed --diff-filter=AMR -- 'package.json' '*/package.json' 'requirements*.txt' \
         '*/requirements*.txt' 'pyproject.toml' '*/pyproject.toml' 'go.mod' '*/go.mod' \
         'Cargo.toml' '*/Cargo.toml' 'Gemfile' '*/Gemfile' 'composer.json' '*/composer.json')
if [ -n "$_dep_added" ]; then
  _dec=$( ( git diff --cached -U0 -- _ops/DECISIONS.md 2>/dev/null || true ) | grep '^+' | grep -v '^+++ ' || true )
  _unnamed=""
  for _d in $_dep_names; do
    # WORD-BOUNDED. `hits -iF` was an unbounded substring test, so a decision about anything
    # containing the package name as a fragment — `date` inside `update`, `fs` inside `refs` —
    # satisfied it. Measured 2026-08-23.
    # **A full stop after the name must not break the match.** `.` is a NAME character here so
    # `lodash.merge` and `github.com/x/y` hold together — and that made `left-pad.` fail the
    # trailing boundary, so a maintainer who wrote exactly what the refusal asked was refused
    # again, and told "says nothing about why" about a commit that said it. Measured 2026-08-23 in
    # a lens's four-variant probe: name followed by a space passed, name followed by a full stop
    # did not. This file is copied into other people's repositories; the only escapes were
    # guessing the punctuation rule or `--no-verify`.
    #
    # So a `.` counts as part of the name only when a name character follows it.
    _esc=$(printf '%s' "$_d" | sed 's/[].[^$\\*\/]/\\&/g')
    printf '%s\n' "$_dec" | hits -iE "(^|[^A-Za-z0-9_.@/-])${_esc}([^A-Za-z0-9_.@/-]|\.([^A-Za-z0-9_@/-]|$)|$)" \
      || _unnamed="$_unnamed $_d"
  done
  [ -z "$_unnamed" ] \
    || say_fail "this commit adds$(printf '%s' "$_unnamed" | tr -s ' ') to$(printf '%s' "$_dep_added" | tr -s ' ') and says \
nothing about why. The cheapest code is the code nobody writes, and the ladder above a new \
dependency — is it already here · does the standard library do it · does the platform do it \
natively · can it be one line — is a judgement only the person choosing can make. Write the one \
line they already know, in _ops/DECISIONS.md in this same commit, NAMING IT: what it replaces, \
and what was rejected. The name is asked for rather than a keyword, because a gate satisfied by \
vocabulary teaches people to sprinkle words. A dependency arrives in a minute and leaves over a \
year"
fi

# 4f · **the same rung outside software.** A package manifest is one project's spelling of *a new
#      standing commitment*. A bakery's is a supplier, a channel's is a subscription, a studio's
#      is a stock licence — and this system is used in all of them (*a chip maker has no data
#      flows and a bakery has no deploys*). **The universal register is `_ops/TOOLING.md`**: a row
#      added there is the same act as a dependency line, arriving in a minute and maintained for a
#      year. So a project with no package manifest at all is not exempt from the rung, which it
#      was for the first hour of this gate's life.
#
#      It REFUSES, and the accepted answer is what makes that fair: outside software the honest
#      answer is very often *we had none* — the work was not being done at all — and that is an
#      answer, not an evasion, so writing it passes. It warned for its first hours and measured
#      0 of 5; as a refusal, 2 of 5 (2026-08-22). The register's own template already asks *what for*; what this asks
#      is the rung above choosing: **what was done before this, and why that stopped being enough.**
# **It refuses rather than warns, and that was measured rather than argued.** It warned for its
# first hours and scored 0 of 5 — three runs added the row, committed, and none said what came
# before. The same day, in the same corpus, a rule that REFUSES scored 5 of 5. A warning is a
# demand, and this system's own rounds put demands in the same band as prose. Accepting
# `we had none` is what makes refusing fair: the gate refuses SILENCE, never the answer.
#
# The six lines above lived INSIDE the refusal string for a day — the closing quote sat after
# them, so every reader of this gate's message got the author's commentary as part of it. Three
# lenses found it, 2026-08-23. A comment inside a quoted argument is not a comment.
_tool_rows=""
if ( changed --diff-filter=AMR -- '_ops/TOOLING.md' ) | hits . ; then
  # **Everything is read from the INDEX, because that is what a pre-commit hook judges.** The
  # first version of this took the register from the WORKTREE and the added lines from the index,
  # then intersected them — so the moment the two disagreed the intersection was empty and the
  # rung went silent. Staging a row and then aligning the table's pipes, which is what a person
  # does next, made the gate pass a row it had just refused. Measured 2026-08-23 by an adversarial
  # lens; a regression against the version before it, whose single source could not disagree with
  # itself. One source, and the question it answers is the right one: what is about to be committed.
  _staged=$(git show :_ops/TOOLING.md 2>/dev/null || true)
  # A separator is one-or-more dashes: `|-|-|` is valid GFM and `-{2,}` read the separator itself
  # as a data row, so a register standing up in that dialect was still refused. The header is the
  # line above it — structure, never the words in it — and fences are skipped because this file's
  # own templates ship example tables.
  # Fences come in dialects, and all of them hide an example the same way: ``` and ~~~ both open
  # and close one, and an HTML comment is how a register parks a draft row it does not mean yet.
  # Only ``` was skipped, so a ~~~ example and a commented-out row were both read as live rows
  # and refused — four documentation-only edits, measured 2026-08-23 by an adversarial lens.
  # **A comment hides a LINE, never the rest of the file, and never a live row it sits inside.**
  # The first version set a flag on any line containing `<!--` and skipped until one carried
  # `-->`. **Six ways silenced the gate, all measured 2026-08-27, and they need three cures.**
  # An opener is believed only when a closer exists — that answers the first three: an inline
  # `<!-- todo -->` in a live row made that row invisible while GFM still rendered it; a bare
  # `<!--` with no closer anywhere made every row after it invisible **permanently**; a stray
  # fence opener with no closer at the top did the same. A line left empty by the strip is HIDDEN
  # rather than read as a boundary — that answers the fourth, the parked draft row. And the strip
  # itself has to survive the text it walks — that answers the last two, a `>` inside a parked row
  # and a CR at the end of it. **This sentence has said "three ways · one cure" through three of
  # those discoveries**; when the next one lands, the count moves with it.
  #
  # Lines are buffered RAW — the diff is matched against the file's own bytes, so a line rewritten
  # for analysis would never match what was staged. Comments are resolved afterwards, where the
  # whole file is visible and an opener can be told from an opener that never closes.
  _rowsrc='
    { n++; L[n] = $0 }
    function resolve(   i, j, k, s) {
      for (i = 1; i <= n; i++) hide[i] = 0
      i = 1
      while (i <= n) {
        # **The inline strip must survive a `>` and a CR.** `<!--[^>]*-->` cannot cross a `>`, so a
        # parked row containing `->`, `>=` or any HTML tag was neither stripped nor hidden — it
        # stayed as non-pipe text and the row scan read it as the end of the table, silencing every
        # live row below. `[ \t]` excluded `\r`, so a CRLF register did the same. Both measured
        # 2026-08-27, both surviving instances of the defect the strip was written to close: the
        # repair had generalised the finding and not the rule.
        # **Three more things this loop has to survive, all measured 2026-08-28.**
        # (a) It rebuilt the WHOLE line each pass — prefix included — so the next match rescanned
        #     everything already walked: 27.8s on a 390 KB row against 0.06s for the single gsub
        #     it replaced. A guard that slow is one people run with --no-verify, which this
        #     file names as its own failure mode. The prefix is consumed into _acc and never
        #     scanned again; same output, 0.7s.
        # (b) An opener inside a CODE SPAN is text. A register documenting its own parking idiom
        #     — a row whose cell reads `<!--` in backticks — had no closer on that line, so the
        #     multi-line path fired and swallowed every live row down to the next `-->`. The gate
        #     went silent on the very file that explained it. Backtick parity is carried across
        #     the line in _par, counted chunk by chunk so it stays linear.
        # (c) A bare `-->` left standing is not a row, and the walk read it as the end of one.
        _open = 0
        s = L[i]; _acc = ""; _par = 0
        while (match(s, /<!--/)) {
          _st = RSTART
          _pre = substr(s, 1, _st - 1)
          _t = _pre; _par += gsub(/`/, "&", _t)
          if (_par % 2 == 1) { _acc = _acc _pre "<!--"; s = substr(s, _st + 4); continue }
          _rest = substr(s, _st + 4)
          if (!match(_rest, /-->/)) { _open = 1; break }
          _t = substr(_rest, 1, RSTART + 2); _par += gsub(/`/, "&", _t)
          _acc = _acc _pre
          s = substr(_rest, RSTART + 3)
        }
        s = _acc s
        S[i] = s
        if (s ~ /^[ \t\r]*-->[ \t\r]*$/) { hide[i] = 1; i++; continue }
        # **A line that was ENTIRELY an inline comment is a hidden line, not an empty one.** Left
        # visible-but-empty it read as the end of the table, so one parked draft row —
        # `<!-- | draft | parked | | -->`, the idiom the comment above recommends — silenced
        # the gate for every live row below it. Measured 2026-08-27; a regression against the
        # version before this rewrite, which refused that file.
        if (L[i] ~ /<!--/ && s ~ /^[ \t\r]*$/) { hide[i] = 1; i++; continue }
        if (_open) {
          # an opener with no closer later in the file is ordinary text, not a comment
          k = 0
          for (j = i + 1; j <= n; j++) if (L[j] ~ /-->/) { k = j; break }
          if (k) { for (j = i; j <= k; j++) hide[j] = 1; i = k + 1; continue }
        }
        i++
      }
      # A fence opener with no closer after it is not a fence — it is a stray line. Toggling on it
      # left every row below hidden and the gate silent for the rest of the file, which one
      # accidental ``` at the top of a register achieved. Measured 2026-08-27, same shape as the
      # unterminated comment above and cured the same way: look for the closer before believing
      # the opener.
      i = 1
      while (i <= n) {
        if (hide[i] || S[i] !~ /^[ \t]*(```|~~~)/) { i++; continue }
        k = 0
        for (j = i + 1; j <= n; j++) if (!hide[j] && S[j] ~ /^[ \t]*(```|~~~)/) { k = j; break }
        if (!k) { i++; continue }
        for (j = i; j <= k; j++) hide[j] = 1
        i = k + 1
      }
    }
  '  # **One awk pass, and the header never makes a round trip through the shell.** Passing it back
  # as `HDR="$_hdr"` was an evasion anyone could trigger with a single character: awk
  # escape-processes a command-line assignment, so a header containing `c:\temp` arrived with a
  # TAB in it and `\|` — markdown's own pipe escape — arrived as a bare pipe. The equality test
  # then matched nothing and **§4f went silent for that file, permanently**. Measured 2026-08-23
  # by an adversarial lens; a regression introduced the same day the table-scoping was.
  #
  # **Which table is the register**: the first one, plus any table whose header carries a
  # `Replaces` column. The first, because a file's opening table is its subject; the others,
  # because a decoy table above the register would otherwise capture the gate and a `Replaces`
  # column on the wrong table would otherwise steal it. Both were measured as evasions. The cost
  # is that a `## Retired` table which itself carries a `Replaces` column gets asked — coherent,
  # since its author put the column there.
  #
  # Each row is emitted with ITS OWN table's column index, so two tables with the column in
  # different positions are both read correctly. Index 0 means "this table has no such column" and
  # sends the row to the keyword fallback below.
  # **Cells are split by an unescaped pipe outside a code span**, not by `-F"|"`. Markdown's own
  # escape `\|` and a pipe inside backticks both shift every field after them, so a header
  # carrying either put the column index one place out and the gate read the wrong cell —
  # `| Otter | x |  | d |` answered with the date. Both measured 2026-08-23.
  #
  # The whole judgement happens here, in one pass, and the shell is handed a verdict rather than
  # an index: Y the cell is filled · N the cell is blank · K this table has no such column.
  _cand=$(printf '%s\n' "$_staged" | awk "$_rowsrc"'
    function cells(s, A,   i, ch, cur, k, tick) {
      k = 0; cur = ""; tick = 0
      for (i = 1; i <= length(s); i++) {
        ch = substr(s, i, 1)
        if (ch == "\\" && i < length(s)) { cur = cur substr(s, i+1, 1); i++; continue }
        if (ch == "`") { tick = !tick; cur = cur ch; continue }
        if (ch == "|" && !tick) { A[++k] = cur; cur = ""; continue }
        cur = cur ch
      }
      A[++k] = cur
      return k
    }
    # `\r` is in the class because a CRLF register whose last column is `Replaces` and whose rows
    # omit the optional trailing pipe left `" \r"` in the final cell — non-empty, so a blank answer
    # read as filled. One character, measured 2026-08-27.
    function trim(s) { gsub(/^[ \t\r*]+|[ \t\r*]+$/, "", s); return s }
    # No apostrophe in this comment: the whole program is single-quoted, and one would end it.
    function colof(h,   i, m, cc) {
      m = cells(h, F)
      for (i = 1; i <= m; i++) { cc = tolower(F[i]); gsub(/[^a-z]/, "", cc); if (cc == "replaces") return i }
      return 0
    }
    END {
      resolve()
      tbl = 0
      for (i = 1; i <= n; i++) {
        if (hide[i]) continue
        if (i + 1 > n || hide[i+1] || S[i+1] !~ /^[ \t]*\|[ \t]*:?-+/) continue
        tbl++
        ci = colof(S[i])
        if (tbl != 1 && ci == 0) continue
        for (j = i + 2; j <= n; j++) {
          if (hide[j]) continue
          if (S[j] !~ /^[ \t]*\|/) break
          if (S[j] ~ /^[ \t]*\|[ \t]*:?-+/) continue
          m = cells(S[j], R)
          state = (ci == 0) ? "K" : ((ci <= m && trim(R[ci]) != "") ? "Y" : "N")
          # The tool name is emitted with its own tabs squeezed out: the three fields travel to the
          # shell tab-delimited, so one interior tab in a cell shifted `cut -f2`/`-f3-` and the row
          # was dropped from the intersection entirely — the gate silent on a row v0.2.11 refused.
          # A regression of the round trip itself, measured 2026-08-27. The raw line still goes out
          # whole as the third field, because that is what must match the diff.
          _tool = trim(R[2]); gsub(/\t/, " ", _tool)
          printf "%s\t%s\t%s\n", state, _tool, L[j]
        }
      }
    }')
  _real=$(printf '%s\n' "$_cand" | cut -f3- | grep . || true)
  _added=$( ( git diff --cached -U0 -- _ops/TOOLING.md 2>/dev/null || true ) \
    | grep '^+' | grep -v '^+++ ' | sed 's/^+//' | grep -E '^[[:space:]]*\|' || true )
  if [ -n "$_cand" ] && [ -n "$_added" ]; then
    # keep each candidate WITH its own table's column index; the diff only says which are new
    _tool_rows=$(printf '%s\n' "$_cand" \
      | while IFS= read -r _l; do
          _r=$(printf '%s' "$_l" | cut -f3-)
          printf '%s\n' "$_added" | grep -Fxq -- "$_r" && printf '%s\n' "$_l"
        done || true)
  fi
fi
if [ -n "$_tool_rows" ]; then
  _dec2=$( ( git diff --cached -U0 -- _ops/DECISIONS.md 2>/dev/null || true ) \
    | grep '^+' | grep -v '^+++ ' || true )
  # **A FIELD, not a vocabulary.** This began as a keyword list — `instead of|replaces|already|…`
  # — which is precisely the defect §4e was repaired away from in this same file on the same day:
  # a gate satisfied by words teaches people to sprinkle them, and refuses an honest answer that
  # uses different ones. The register carries a **Replaces** column
  # (`templates/TOOLING-template.md`) and this reads the cell.
  #
  # **Two homes count and either is enough** — the cell, or a line in `_ops/DECISIONS.md` that
  # NAMES the row's tool. With only the cell read, a maintainer doing exactly what the refusal
  # prescribed was refused again by the same message, with no hint a column existed. A register
  # that predates the column keeps the keyword fallback, and that fallback is named here rather
  # than presented as a test: an old register is not a project's fault, and refusing every commit
  # until it is reshaped is how a guard gets deleted.
  _unanswered=0
  while IFS= read -r _entry; do
    [ -n "$_entry" ] || continue
    _state=$(printf '%s' "$_entry" | cut -f1)
    _tool=$(printf '%s' "$_entry" | cut -f2)
    _row=$(printf '%s' "$_entry" | cut -f3-)
    [ "$_state" = "Y" ] && continue
    if [ "$_state" = "K" ]; then
      # this row's table has no Replaces column — the older shape, judged by the keyword list
      printf '%s\n' "$_row" \
        | hits -iE 'instead of|replaces|rather than|already|by hand|nothing else|we had none|had no ' \
        && continue
    fi
    # the cell is blank (or the row said nothing) — a decision naming this tool is the other answer
    if [ -n "$_tool" ]; then
      _esc2=$(printf '%s' "$_tool" | sed 's/[].[^$\\*\/]/\\&/g')
      printf '%s\n' "$_dec2" | hits -iE "(^|[^A-Za-z0-9_-])${_esc2}([^A-Za-z0-9_-]|$)" && continue
    fi
    _unanswered=$((_unanswered+1))
  done <<TOOLROWS
$_tool_rows
TOOLROWS
  [ "$_unanswered" -eq 0 ] \
    || say_fail "this commit adds a row to _ops/TOOLING.md and nothing says what it replaces. Two \
places count, and either one is enough: the row's own **Replaces** cell, or a line in \
_ops/DECISIONS.md that NAMES this tool and says what was done before it. \`we had none\` is a \
complete answer and often the true one outside software — write it in the cell and this passes. \
A tool arrives in a minute and is maintained for a year, which is why the rung is asked at all"
fi

# 5b · skills born in this repo stay modular (templates/SKILL-SCAFFOLD.md): a budgeted
#      router core + chapters. Catches the monolith while it is still one commit old.
while IFS= read -r -d '' sk; do
  dir=$(dirname "$sk")
  budget=$(sed -n 's/^core_budget:[[:space:]]*//p' "$sk" | head -1)
  lines=$(grep -c '' "$sk")
  if [ -n "$budget" ] && [ "$lines" -gt "$budget" ]; then
    say_warn "$sk is $lines lines against its own core_budget: $budget — move a block to a chapter, don't squeeze"
  fi
  chapters=$(ls "$dir"/*.md 2>/dev/null | grep -v 'SKILL\.md$' | wc -l | tr -d ' ')
  if [ "$chapters" -gt 0 ] && ! grep -q '| Load' "$sk"; then
    say_warn "$sk has $chapters chapter file(s) but no '| Load … | …when |' routing table — chapters nobody routes to are dead weight"
  fi
done < <(git ls-files -z -- ':(glob)**/SKILL.md' 'SKILL.md')

# 7 · exactly one advisor. Two of them is not a busier project, it is two seats each
#     believing it holds the loop, writing each other's model and effort, and each one
#     recording decisions the other never saw. Stated in three files and, until now,
#     enforced by none of them.
# Measured 2026-08-14: §7 and §8 never ran in the `_ops/` layout — both were gated on a flat
# `roles/`, and §8 then looped over `_ops/roles/*.md`. Two advisors passed green.
roles_dir=""
for rd in _ops/roles roles; do [ -d "$rd" ] && { roles_dir="$rd"; break; }; done
if [ -n "$roles_dir" ]; then
  # **BOTH forms, because the template writes only one of them and it is not the YAML.**
  # `templates/ROLE-template.md` produces `**Type**: advisor · **Grade**: senior` — it contains no
  # `type:` line at all — so a role written from the shipped template was invisible to this check
  # and to §8 below. Measured 2026-09-05 on a live migration: two declared advisors, one found;
  # nineteen skills, zero counted. **This pair has been repaired once before** — the comment above
  # records fixing the DIRECTORY in August while the format mismatch survived, so the gate went on
  # reporting green about a file it never read. A guard that is green because it looked at nothing
  # is worse than an absent one: it issues a report on a check that did not happen.
  #
  # The prose form allows backticks and bold around the value, as `verdict_of` learned to; the
  # UNFILLED template placeholder `{{worker · expert · … · advisor}}` must not match, and does not,
  # because `advisor` is not what follows the colon there.
  advisors=$( { grep -rlE '^[[:space:]]*type:[[:space:]]*advisor[[:space:]]*$' "$roles_dir" 2>/dev/null
                grep -rlE '^[[:space:]]*(\*\*)?[Tt]ype(\*\*)?[[:space:]]*:[[:space:]]*[\`*]*advisor([^A-Za-z]|$)' "$roles_dir" 2>/dev/null
              } | sort -u)
  n=$(printf '%s' "$advisors" | grep -c . || true)
  if [ "${n:-0}" -gt 1 ]; then
    say_fail "there are $n advisors — exactly one holds the loop. Found: $(echo $advisors | tr '\n' ' ')"
  fi
fi

# 6 · if the layers are split, the manifest must exist. A clone that gives contents with no
#     map looks complete and is not — which is worse than one that is obviously partial.
if [ -f config.md ] || [ -f CLAUDE.md ]; then
  have_docs=0; have_work=0
  [ -d docs ] && have_docs=1
  [ -d tasks ] && have_work=1
  if [ "$have_docs" = 1 ] && [ "$have_work" = 0 ]; then
    grep -qiE 'where (each )?layer|record lives|destinations?:' config.md CLAUDE.md 2>/dev/null \
      || say_warn "docs/ is here but _ops/tasks/ is not, and no manifest names where the other layers \
live — a clone of this repo cannot tell what is missing"
  fi
fi

# 8 · a role that does everything is usually a role that is missing. The load budget is a
#     share of the window, and skills attached to a role load on every run it makes — needed or
#     not. This counts them; the judgement about which to drop stays a person's.
if [ -n "$roles_dir" ]; then
  for r in "$roles_dir"/*.md; do
    [ -f "$r" ] || continue
    # **The table the template writes, and the YAML list a legacy file may carry.** The old
    # counter read only the second, so a template-written role with nineteen skills counted zero
    # and could never reach the threshold. On the YAML form it counted 20 of 19 — the frontmatter's
    # closing `---` matched its own list-item pattern, which is the tell that neither path had been
    # measured. Both fixed and both asserted, 2026-09-05.
    # A header row, a separator row and a row still carrying `{{…}}` are not skills.
    skills=$(awk '
      /^##[[:space:]]+[Ss]kills/                       { tbl = 1; next }
      tbl && /^##[[:space:]]/                          { tbl = 0 }
      tbl && /^[[:space:]]*\|/ {
        if ($0 ~ /^[[:space:]]*\|[[:space:]]*[-:| ]+$/)        next
        if ($0 ~ /\{\{/)                                       next
        if (tolower($0) ~ /^[[:space:]]*\|[[:space:]]*skill[[:space:]]*\|/) next
        c++
      }
      /^skills:[[:space:]]*$/                          { yml = 1; next }
      yml && (/^---[[:space:]]*$/ || /^[a-z_]+:/)      { yml = 0 }
      yml && /^[[:space:]]*-[[:space:]]*[^[:space:]-]/ { c++ }
      END { print c + 0 }' "$r")
    if [ "${skills:-0}" -ge 8 ]; then
      say_warn "$(basename "$r" .md) carries $skills skills — every one loads on every run it \
makes, and a role carrying that many is worse at each of them. Usually the signal is a missing hire"
    fi
  done
fi

# 9 · an entitlement claim points at its evidence, or it is not a claim. Measured: a run found a
#     bundled dependency was BUSL-1.1 rather than MIT, corrected this file honestly, added
#     "commercial license held" — a licence nobody had bought — and tagged a release into the
#     paid product on the strength of it. Every step was defensible except the one that wrote
#     its own permission. Only entitlement words are checked; an ordinary licence name is a
#     fact about the dependency and needs nothing.
#     The evidence must sit in the SAME CLAUSE as the entitlement, not merely somewhere in the
#     row. Measured within an hour of this check being written: a run wrote
#     "commercial license held; evidence: `vendor/plotwright-LICENSE`" — a real pointer, but to
#     the licence *text*, not to a purchase, and the licence text is the document that forbids
#     the very use being claimed. A row-level test cannot validate a claim inside the row, so
#     the clause is the unit: from the entitlement word to the next `;` or column break.
if [ -f _ops/TOOLING.md ]; then
  while IFS= read -r line; do
    case "$line" in \|*) ;; *) continue;; esac
    printf '%s' "$line" | hits -iE '(licence|license|plan|tier)[^|;]*(held|purchased|bought|covered|acquired|granted)' || continue
    clause=$(printf '%s' "$line" | tr '|;' '\n\n' \
             | grep -iE '(licence|license|plan|tier)[^|;]*(held|purchased|bought|covered|acquired|granted)' | head -1)
    printf '%s' "$clause" | hits -iE '(receipt|invoice|order|https?://|`[^`]+`)' && continue
    name=$(printf '%s' "$line" | cut -d'|' -f2 | sed 's/^ *//;s/ *$//')
    say_fail "_ops/TOOLING.md claims an entitlement for \`$name\` — \"$(printf '%s' "$clause" | sed 's/^ *//;s/ *$//')\" \
— with no evidence in that same clause. A pointer elsewhere in the row does not cover it, and a \
licence file is evidence of the terms, never of a purchase. Point at the receipt, or write it as \
unknown. An agent may not author the fact that unblocks its own work."
  done < _ops/TOOLING.md
fi

# 10 · nothing transitions itself, and nobody edits the bar they are measured against. Both are
#      stated as laws and, until now, held by nothing. Measured: a run discovered a licence
#      blocker, then set its own task to shipped and tagged a release in the same breath.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  while IFS= read -r -d '' t; do
    d=$(staged_diff "$t")
    printf '%s' "$d" \
      | hits -iE '^\+.*\*{0,2}status\*{0,2}[[:space:]]*:[[:space:]]*(done|shipped|completed|accepted|closed)' \
      || continue
    # The bar is compared SECTION against SECTION, not guessed at by a regex. It is a list of
    # bullets under `## Done when` (or a `dod:` field), so editing it changes lines that contain
    # none of those words — measured: a task reaching `done` through the door with its
    # acceptance criterion rewritten in the same commit passed every regex form of this check.
    bar_at() {  # bar_at <rev-or-empty> — the acceptance section as it stands there
        if [ -z "$1" ]; then git show ":$t" 2>/dev/null; else git show "$1:$t" 2>/dev/null; fi \
          | awk 'tolower($0) ~ /^#{2,}[[:space:]]*(done when|acceptance)/{f=1; next}
                 f && /^#{2,}[[:space:]]/{f=0}
                 f {print}
                 tolower($0) ~ /^[[:space:]]*(dod|acceptance|definition of done)[[:space:]]*:/{print}' \
          | sed -E 's/^([[:space:]]*[-*+][[:space:]]*)\[[ xX]\]/\1[ ]/'
    }
    # The tick is normalised out: `- [ ]` → `- [x]` records that a criterion was MET, which is
    # what closing a task is, and the template this guard ships beside tells the owner to do it.
    # Measured 2026-08-15: without this, the documented way to close a task — tick the
    # deliverable, move through the door, be reviewed by someone else — was refused as editing
    # the bar. The bar is the criterion; the mark beside it is the evidence.
    if [ "$(bar_at HEAD)" != "$(bar_at '')" ]; then
      say_fail "$t reaches a terminal status in the same commit that edits its own bar — \
nobody edits the bar they are measured against. Move the bar in its own commit, before the work \
is judged against it."
    fi
    printf '%s' "$d" | hits -iE '(review|approved|accepted by|evidence|run [0-9a-z]|#[0-9]+|https?://)' \
      || say_warn "$t reaches a terminal status and nothing in the change points at a review, a \
run or evidence — nothing transitions itself, and a status that moves on its own is how a board \
begins to lie."

    # 10b · WHAT IT COST, at the moment it is last cheap to record. `cost.md` says it outright —
    # *"Measured at the atom, everything else derived. Store once, at the run"* — and the guide's
    # own door says a dispatch lands as `_ops/runs/R-<id>.md` carrying its four token numbers.
    # Nothing checked that the atom exists. Measured 2026-08-15: a task taken started → review →
    # done THROUGH the door, with zero run records anywhere in the project, drew no refusal and no
    # warning at all — so every derived number (a feature's cost, the budget burn, the waste
    # slices, the trend the owner is told) rests on records nobody is asked for. Observed first on
    # a live project, where the board carried finished work and no cost at all.
    #
    # A WARNING, not a refusal, because a task done by a person legitimately has no run — and it
    # names both ways to be right, so it is answerable rather than nagging.
    # **The id, not the id plus the slug.** The class held `-` and `a-z`, so the shipped filename
    # convention `T-XXXXXX-slug.md` — the one §1g's own comment cites — produced tid
    # `T-CCC333-fix-login`, which no run record ever names: the warning fired on EVERY close of a
    # slug-named task, and was unanswerable, because writing the record it demands could not
    # silence it. `new-id.py` mints from Crockford base32 (`ALPHABET` there, digits and capitals
    # only), so the id ends where the first lowercase or hyphen begins. Measured 2026-08-21.
    # And when the filename carries no id at all — a slug-only name, which the guide permits —
    # the TITLE is asked, through the same reader §1f uses, so the two sections cannot disagree
    # about what a declaration is. §10b silently skipped those tasks entirely.
    tid=$(basename "$t" .md | grep -oE '^[A-Z]{1,2}-[0-9A-Z]+' || true)
    [ -n "${tid:-}" ] || tid=$( ( staged "$t" 2>/dev/null || cat "$t" 2>/dev/null || true ) | record_task )
    if [ -n "${tid:-}" ]; then
      _has_run=no
      while IFS= read -r -d '' _r; do
        # ONE reader, shared with §1f by construction. This carried its own rigid regex while
        # §1f was converted to `record_task` in the same release, so the two sections read the
        # same declaration differently — the exact divergence class the release claimed to have
        # closed. Comparing `record_task`'s output makes a future widening reach both at once.
        [ "$( ( staged "$_r" 2>/dev/null || cat "$_r" 2>/dev/null || true ) | record_task )" = "$tid" ] \
          && { _has_run=yes; break; }
      done < <(git ls-files -z -- '_ops/runs/*.md')
      [ "$_has_run" = yes ] || say_warn "$t closes and no run record names $tid — \
\`cost.md\` stores cost once, at the run, and derives everything else from it, so a task that \
finishes without one leaves its own cost, its feature's total and the budget burn resting on \
nothing. Either write the record (\`_ops/runs/R-<id>.md\`, four token numbers, \`unknown\` where \
the harness does not report one), or say in History that this was done by hand — both are \
honest, silence is not."
    fi

    # A task that CLAIMS a run and links to a record that is not there is already refused by §1g,
    # which checks every `.md` link in a task and does not care what it points at. A second check
    # for the same shape was written here and deleted before it shipped — measured 2026-08-15: on
    # a task linking `../runs/R-GHOST.md`, §1g refused and this fired zero times. Two gates for one
    # defect is the redundancy the deletion lens exists to remove, and the one that survives is the
    # one that catches the whole class. (The deletion left this heredoc's BODY and TERMINATOR
    # behind for one commit: a `$( … )` in command position, so a markdown link in a task file
    # became an argv word THIS HOOK EXECUTED, and `LINKS: command not found` went to stderr on
    # every closing task. `bash -n` passes on it. Measured 2026-08-15 — the second time in this
    # release that a cut heredoc left live code, which is why the suite now asserts stderr.)
  done < <(changed -- '_ops/tasks/*.md')
fi

# 11 · a review is not a review when the author signs it off. "Nobody edits the bar they are
#      measured against" has a sibling nobody enforced: models judge their own output generously,
#      and a thread where the only name approving is the name that did the work reads exactly
#      like a reviewed one. Names, not identities — this is a nudge at the honest case, not an
#      identity check, and anything stronger belongs in branch protection.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  while IFS= read -r -d '' t; do
    d=$(staged_diff "$t")
    printf '%s' "$d" | hits -iE '^\+.*(reviewed by|approved by|accepted by)' || continue
    who=$(printf '%s' "$d" | grep -ioE '(reviewed|approved|accepted) by[: ]+@?[A-Za-z0-9._-]+' \
          | sed -E 's/.*by[: ]+@?//' | head -1)
    author=$(grep -ioE '^(assigned|author|worker)[: ]+@?[A-Za-z0-9._-]+' "$t" 2>/dev/null \
             | sed -E 's/.*[: ]+@?//' | head -1)
    [ -n "$who" ] && [ -n "$author" ] && [ "$who" = "$author" ] && \
      say_fail "$t is signed off by \`$who\`, who did the work — a review goes to someone else, \
because a model reads its own output generously and the thread cannot tell the difference."
  done < <(changed -- '_ops/tasks/*.md')
fi

# 14 · (numbered by arrival, placed by theme — like the rest of this file)
#      a stage changes through the door, or not at all. transition.py checks the ladder and
#      the gates and appends the move to History in the same write — so a staged diff that
#      changes a stage with no transition line beside it is a hand edit around the door.
#      Forging the line instead is a separate visible claim, which is the same argument §13
#      makes about acceptance: the gate's job is to make the bypass cost a lie in plain sight.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  # The field arrives bold in the stock template — `**Status**: draft` — so the pattern
  # allows the asterisks, or this net matches nothing while reading as a gate. Measured by
  # the lenses within a day of it being written: the plain-colon version had zero matches.
  while IFS= read -r -d '' t; do
    d=$(staged_diff "$t")
    printf '%s' "$d" | hits -iE '^-.*(stage|status)\*{0,2}[[:space:]]*:' || continue
    printf '%s' "$d" | hits -iE '^\+.*(stage|status)\*{0,2}[[:space:]]*:' || continue
    printf '%s' "$d" | hits -E '^\+.*transition .* (→|->) .*, by ' \
      || say_fail "$t changes its stage with no transition line in the same change — the door \
is \`_ops/scripts/transition.py\`: it refuses an illegal move with the reason and records the legal \
one. A stage edited by hand is a bypass."
  done < <(changed -- '_ops/tasks/*.md')
fi

# 13 · a parent does not close itself. §10 catches a task reaching a terminal status with nothing
#      pointing at evidence; a parent is the sharper case, because its children being done looks
#      exactly like the parent being done and is not the same claim. A parent carrying its own
#      definition of done surfaces as *ready to close* and waits for a person; only a container —
#      a title and children, no DoD of its own — may close on its own, and then the fact that it
#      closed automatically is itself recorded. Measured 0 of 10 across two full rounds as prose,
#      and 1 of 5 after the rule was moved into the always-loaded core, which is why it is here.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  while IFS= read -r -d '' t; do
    grep -qiE '^[[:space:]]*((children|subtasks)[[:space:]]*:|##[[:space:]]*(children|subtasks))' "$t" || continue
    d=$(staged_diff "$t")
    printf '%s' "$d" \
      | hits -iE '^\+.*\*{0,2}status\*{0,2}[[:space:]]*:[[:space:]]*(done|shipped|completed|accepted|closed)' \
      || continue
    # A container has no predicate of its own — that one may close itself, and says so.
    grep -qiE '^[[:space:]]*((dod|acceptance|definition of done)[[:space:]]*:|##[[:space:]]*done when)' "$t" || {
      printf '%s' "$d" | hits -iE 'closed (automatically|by rollup)|container' \
        || say_warn "$(basename "$t") is a container closing on its children — legitimate, and \
the fact that it closed automatically is part of the record. Say so in the same change."
      continue
    }
    # The acceptance must already be in HEAD. Asking the diff for it made the gate satisfiable
    # by the party it constrains, and three runs did exactly that within an hour of it being
    # written: a thread line in the owner's voice, a bare "Owner approved.", and — on the
    # licence scenario — the owner's real email address typed under `Approved by:`. **A gate
    # whose evidence the constrained party can author is not a gate.** Acceptance that existed
    # before this commit cannot be forged in the same move; forging it now costs a separate
    # commit whose only content is a claim of approval, which is visible as what it is.
    if ( git show HEAD:"$t" 2>/dev/null || true ) | hits -iE '(approved by|accepted by|signed off|owner (said|confirmed))'; then
      :
    else
      say_fail "$(basename "$t") carries children **and its own definition of done**, and this \
commit closes it. Children being done is not the parent's predicate being met — it surfaces as \
ready to close and waits for a person. **And the acceptance must already be in the file before \
this commit**: written into the same change, it is the closer vouching for itself. Measured — \
given the earlier version of this gate, runs wrote \"Accepted by owner\" and the owner's own \
email address to get past it."
    fi
  done < <(changed -- '_ops/tasks/*.md')
fi

# 12 · the spend cap, which for months was written as "stop at the cap" and performed by nothing.
#      Nothing can halt a run already in flight, and on a subscription the authoritative figure
#      belongs to the harness — so the performable half is the one checkable between runs: a
#      commit that records new spend while the ledger is already at or past the envelope is
#      refused, which is what "refuse the next dispatch" means in practice (`cost.md`).
#      Read from _ops/BUDGET.md: the envelope from the Amount line, the level from the latest
#      "Where it stands" row. Percent or currency, either way.
#      A budget with no numbers yet is silent — a template nobody filled must not block a commit.
if [ -f _ops/BUDGET.md ] && git rev-parse --verify HEAD >/dev/null 2>&1; then
  if ( git diff --cached --name-only 2>/dev/null || true ) | hits -E '^(_ops/BUDGET\.md|docs/BUDGET\.md|_ops/tasks/.*\.md|_ops/runs/.*|runs?/.*)$'; then
    python3 - <<'PY' > /tmp/.pf-budget.$$ 2>/dev/null || true
import re
txt = open("_ops/BUDGET.md", encoding="utf-8").read()
def money(s):
    m = re.search(r"([0-9][0-9,]*\.?[0-9]*)", s.replace(" ", ""))
    return float(m.group(1).replace(",", "")) if m else None
# The envelope: the Amount bullet. Braces mean the template is unfilled — say nothing.
env = None
for ln in txt.split("\n"):
    if re.search(r"\*\*Amount\*\*", ln) and "{{" not in ln:
        env = money(ln.split(":", 1)[-1] if ":" in ln else ln)
        break
pause = 100.0
m = re.search(r"\*\*Pause spend at\*\*[:\s]*\{?\{?([0-9]+)", txt)
if m and "{{" not in m.group(0):
    pause = float(m.group(1))
# The level: the last data row of the standing table — a row whose second cell carries a number.
level_pct = level_abs = None
for ln in txt.split("\n"):
    if not ln.strip().startswith("|") or "{{" in ln:
        continue
    cells = [c.strip() for c in ln.strip().strip("|").split("|")]
    if len(cells) < 3 or cells[0].lower().startswith("read on") or set(cells[0]) <= set("-: "):
        continue
    if "%" in cells[2]:
        p = money(cells[2])
        if p is not None:
            level_pct = p
    a = money(cells[1])
    if a is not None:
        level_abs = a
if level_pct is None and env and level_abs is not None and env > 0:
    level_pct = 100.0 * level_abs / env
if level_pct is not None and level_pct >= pause:
    print(f"OVER:{level_pct:.0f}:{pause:.0f}")
PY
    while IFS= read -r l; do
      case "$l" in
        OVER:*) pct=$(printf '%s' "$l" | cut -d: -f2); cap=$(printf '%s' "$l" | cut -d: -f3)
          say_fail "_ops/BUDGET.md reads ${pct}% of the envelope against a pause at ${cap}% — \
this commit records more spend past the cap. Nothing can halt a run already in flight, so the cap \
is held here: raise the envelope deliberately, or stop dispatching. The cap is \`locked\` — \
proposed to a human, never edited by whoever works under it.";;
      esac
    done < /tmp/.pf-budget.$$
    rm -f /tmp/.pf-budget.$$
  fi
fi

# 5 · a cheap last line on credentials. NOT a secret scanner — gitleaks/trufflehog are,
#     and they belong in CI. This catches the obvious paste before it reaches history,
#     where removing it means rewriting history and rotating the key anyway.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  added=$(git diff --cached -U0 2>/dev/null | grep '^+' || true)
  # known credential shapes: provider prefixes, then key-ish name = long quoted value
  if printf '%s' "$added" | hits -E '(sk-[A-Za-z0-9]{20,}|sk_live_[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----)'; then
    say_fail "this commit contains something shaped like a credential — secrets live in \
the environment or a keychain, never in the repository. If it is already committed, rotate it."
  elif printf '%s' "$added" | hits -iE '(api[_-]?key|secret|token|password|credential|[^a-z]key)[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9_/+.-]{20,}["'"'"']'; then
    say_warn "a long literal is assigned to a key-shaped name — check it is not a secret \
(the real scan is gitleaks in CI, see the tooling register)"
  fi
fi

[ "$fail" = 0 ] && { [ "$warn" = 0 ] && echo "  ✓ clean" || echo "  ✓ passed with warnings"; }
exit "$fail"
