#!/usr/bin/env bash
# The 0.2.0 layout migrator exercised on a flat 0.1.x fixture: history-preserving
# moves, the hook and .gitignore following their files, the craft's docs/ left
# alone, a dirty tree refused, a second run finding nothing, a collision named.
set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d /tmp/opsinist-migrate-test.XXXXXX)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/repo"; cd "$T/repo"
git init -q -b main . && git config user.email t@f.t && git config user.name T

mkdir -p docs/tooling tasks cohorts scripts src .index
printf 'adapter: claude\n' > config.md
printf '# Company\n' > docs/COMPANY.md
printf '# Decisions\n' > docs/DECISIONS.md
printf '# Ops guide\n' > docs/tooling/deploy.md
printf 'the craft own notes\n' > docs/handbook.md
printf '**Status**: started\n' > tasks/T-1.md
printf '# Beta readers\n' > cohorts/beta.md
printf 'echo net\n' > scripts/preflight.sh
printf 'code\n' > src/app.py
printf '.index/\n.opsinist-checkout\n' > .gitignore
printf 'w-1\n' > .opsinist-checkout
printf '{}\n' > .index/cache.json
printf '#!/bin/sh\nbash scripts/preflight.sh || exit 1\n' > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
git add -A && git commit -qm flat

pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }

# another system's tree is refused whole — the shared door read before any move
printf '# Guide\n\n**Operated by:** otherops 9.9.9\n' > CLAUDE.md
git add -A && git commit -qm operator
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1 && bad "sibling-operated tree was migrated" || ok
grep -q 'another system' "$T/out.txt" && [ -f tasks/T-1.md ] && ok || bad "refusal unnamed or something moved"
git rm -q CLAUDE.md && git commit -qm rm-operator

# a dirty tree is refused, and nothing moves
printf 'x\n' >> src/app.py
python3 "$HERE/migrate-layout.py" . >/dev/null 2>&1 && bad "dirty tree was not refused" || ok
[ -f tasks/T-1.md ] && ok || bad "refusal still moved something"
git checkout -q src/app.py

# the migration: git-mv moves, renames applied, followers rewritten
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1 || bad "migration exited nonzero: $(cat "$T/out.txt")"
[ -f _ops/config.md ] && [ -f _ops/ABOUT.md ] && [ -f _ops/tasks/T-1.md ] \
  && [ -f _ops/panels/beta.md ] && [ -f _ops/runbooks/deploy.md ] \
  && [ -f _ops/scripts/preflight.sh ] && [ -f _ops/.checkout ] \
  && ok || bad "a recognised path did not land under _ops/"
# `|| true` before the pipe: this file sets pipefail, so a failing left side returns through a
# MATCHING grep and the assertion reads a found phrase as absent. Benign here today — `git
# diff` without `--exit-code` returns 0 — but it is the shape that lied once already.
( git diff --cached --name-status || true ) | grep -q '^R.*tasks/T-1.md' && ok || bad "moves are not history-preserving renames"
grep -q '_ops/scripts/preflight.sh' .git/hooks/pre-commit && ok || bad "the hook did not follow the preflight"
grep -q '_ops/.index/' .gitignore && ok || bad ".gitignore did not follow .index"
[ -f docs/handbook.md ] && grep -q 'handbook.md' "$T/out.txt" && ok || bad "the craft's docs/ was not left alone and named"

# a second run finds nothing
git commit -qm migrate
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1
grep -q 'nothing to migrate' "$T/out.txt" && ok || bad "second run was not a no-op"

# a collision is a named CONFLICT and a nonzero exit, never an overwrite
mkdir -p tasks && printf 'stray\n' > tasks/T-9.md
git add -A && git commit -qm stray
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1 && bad "collision exited zero" || ok
grep -q 'CONFLICT' "$T/out.txt" && [ -f tasks/T-9.md ] && ok || bad "collision was moved or unnamed"

# the doors ride the migration. Until 2026-08-14 this was prose in `project-layout.md` while
# the script copied only the guard — so an existing project taking 0.2.7's guard was refused on
# every commit by a message telling it to copy files "from the skill", a path a project cannot
# resolve. Both cases below are the ones that actually occur: a project already on `_ops/`
# (every upgrade), and a flat project whose guard only lands under `_ops/` mid-run.
[ -f _ops/scripts/transition.py ] && [ -f _ops/scripts/new-id.py ] \
  && ok || bad "the flat migration did not bring the doors with the guard"
grep -q 'sys.argv\|argparse' _ops/scripts/transition.py \
  && ok || bad "the door that landed is not the door — the guard tests that it reads arguments"

rm -f _ops/scripts/transition.py _ops/scripts/new-id.py
git add -A && git commit -qm "doors lost"
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1
[ -f _ops/scripts/transition.py ] && [ -f _ops/scripts/new-id.py ] \
  && ok || bad "an already-_ops project did not get its doors back"
grep -q 'doors re-copied' "$T/out.txt" && ok || bad "the re-copy happened silently"
( git diff --cached --name-only || true ) | grep -q '_ops/scripts/transition.py' \
  && ok || bad "the re-copied door was left unstaged, so the migration commit would not carry it"

# and a third run is a true no-op: identical bytes are not a re-copy
git commit -qm "doors back"
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1
grep -q 'doors re-copied' "$T/out.txt" && bad "re-copied identical doors and called it work" || ok

# Three shapes measured 2026-08-14: a customised door overwritten in silence against this file's
# own "never a silent overwrite"; `git add`'s result discarded, so an ignored path leaves the door
# in the worktree and out of the commit; and the already-_ops exit staging work it never mentioned,
# so the NEXT run hit the dirty-tree refusal against a docstring promising a no-op.
# the collision fixture above leaves tasks/T-9.md at the root, which keeps the migrator off its
# already-`_ops/` exit — clear it so this block exercises the path it is about
rm -rf tasks
printf 'custom door, do not clobber\n' > _ops/scripts/transition.py
git add -A && git commit -qm "customised door"
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1
grep -q 'differed from the shipped door and was replaced' "$T/out.txt" \
  && ok || bad "a customised door was replaced in silence"
ls _ops/scripts/transition.py.replaced-* >/dev/null 2>&1 && ok || bad "the replaced door was not kept"
# a second replacement must not clobber the first keep — the prescribed flow runs twice
printf 'a different custom door\n' > _ops/scripts/transition.py
git add -A && git commit -qm "customised again"
python3 "$HERE/migrate-layout.py" . >/dev/null 2>&1
[ "$(ls _ops/scripts/transition.py.replaced-* 2>/dev/null | wc -l | tr -d ' ')" -ge 2 ] \
  && ok || bad "the second replacement overwrote the first keep, losing the project's own edits"
grep -q 'Commit them before running this again' "$T/out.txt" \
  && ok || bad "work was staged and the operator was not told to commit it"
rm -f _ops/scripts/transition.py.replaced-*; git add -A; git commit -qm "doors restored"

# an ignore only bites an UNTRACKED path, so the door has to leave the index first — which is
# exactly the shape that produced the measured case: a project that never tracked its doors
git rm -q --cached _ops/scripts/new-id.py
printf '_ops/scripts/*.py\n' >> .gitignore
git add -A && git commit -qm "ignore the doors"
printf 'clobber me\n' > _ops/scripts/new-id.py
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1
grep -q 'written but NOT staged' "$T/out.txt" \
  && ok || bad "an ignored door was reported as re-copied while the commit would not carry it"
git checkout -q .gitignore 2>/dev/null || true

# The upgrade path a real 0.2.6 project takes. 0.2.7 refuses a commit that ADDS a second state
# home, not the existence of one — so a legacy project is not stranded and needs no rewriting.
# The migration NAMES what disagrees and writes nothing: an earlier version rewrote these files
# and a lens pass found seven distinct ways it destroyed content in a project this script does
# not own. These cases hold the property that replaced it — that it does not write.
mkdir -p _ops/tasks
cat > _ops/tasks/T-A.md <<'TASKA'
# T-A

**Type**: build · **Status**: started
stage: review

## Notes

```yaml
stage: draft
```

    stage: indented-example
TASKA
printf '# T-B\n\n**Status**: review\nstage: review\n' > _ops/tasks/T-B.md
printf '# T-C\n\n**Status**: done\n' > _ops/tasks/T-C.md
git add -A && git commit -qm "0.2.6 task shapes"
before_a=$(md5 -q _ops/tasks/T-A.md); before_b=$(md5 -q _ops/tasks/T-B.md)
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1

[ "$(md5 -q _ops/tasks/T-A.md)" = "$before_a" ] && ok || bad "the migration rewrote a task file — it does not own them"
[ "$(md5 -q _ops/tasks/T-B.md)" = "$before_b" ] && ok || bad "the migration rewrote a second task file"
grep -q 'carry state in two places' "$T/out.txt" && ok || bad "the two-home tasks were not named"
# the shape that went 5/5 in the refusal round: the literal edit, per item, not an instruction.
# The general form — "keep it in **Status**, delete the machine line, by hand" — produced a
# report and a request for permission in five runs of five and was applied by none.
grep -q 'delete line [0-9]' "$T/out.txt" \
  && ok || bad "the report does not name the line to delete"
# **The `<prose|mach>` shape this used to assert was unfollowable, and the assertion pinned it.**
# The door refuses BOTH values it offered: `prose` is where the task already is and a no-op is
# refused, `mach` is refused whenever it is more than one rung away. So a reader obeying the
# report was refused either way. Measured 2026-08-21 (pass twelve); the suite asserted the defect
# because it asserted a SHAPE rather than a followable instruction. Now: one command, the machine
# value, and the linear-ladder note that tells the reader what to do when it is refused as a jump.
grep -qE 'transition\.py [^ ]+ review --by' "$T/out.txt" \
  && ok || bad "the report does not name the door with the one value that is ever a move"
grep -q 'walk it one rung at a time' "$T/out.txt" \
  && ok || bad "the report does not say what to do when the door refuses the move as a jump"
grep -qE 'transition\.py .*<[a-z]+\|[a-z]+>' "$T/out.txt" \
  && bad "the report still offers a pseudo-choice the door refuses on both branches" || ok
grep -q 'both copies said' "$T/out.txt" \
  && ok || bad "a task whose two copies agree was not distinguished from one whose copies differ"
grep -q 'T-C.md' "$T/out.txt" && bad "a one-home task was named as a problem" || ok
# the examples are not fields: a value from a fence or an indented block must never be reported
grep -q 'draft\|indented-example' "$T/out.txt" && bad "a value out of an example was read as state" || ok

# ── the report's number must be RIGHT, not merely present ──────────────────────────────────
# The assertion above checks that a number printed. It cannot fail when the number is wrong, and
# it was: `lines.index(l)` returned the first line EQUAL to the machine line, so a task carrying
# a fenced example byte-identical to its real field named the FENCED line as the one to delete —
# a reader following the report destroys the example and keeps the duplicate. Measured 2026-08-15
# (pass nine). These assert the exact line, the value alone, and the refusal to instruct.
mkdir -p "$T/rep/_ops/tasks" && ( cd "$T/rep" && git init -q . )
printf '# A\n\n**Status**: doing\n\n```\nstage: doing\n```\n\nstage: doing\n' > "$T/rep/_ops/tasks/T-fence.md"
printf '# B\n\n**Status**: doing - **Owner**: me\n\nstage: review\n'          > "$T/rep/_ops/tasks/T-hyphen.md"
printf '# C\n\n**Status**: doing\n\nstage: doing is what we mean when we say it\n' > "$T/rep/_ops/tasks/T-prose.md"
# committed, or the dirty-tree refusal answers instead of the report
( cd "$T/rep" && git add -A >/dev/null && git -c user.email=t@f.t -c user.name=T commit -qm f )
python3 "$HERE/migrate-layout.py" "$T/rep" > "$T/rep.txt" 2>&1
# line 9 is the real field; line 6 is inside the fence
grep -A1 'T-fence.md' "$T/rep.txt" | grep -q 'delete line 9' \
  && ok || bad "the report names the wrong line for a task whose fenced example matches its field"
grep -A1 'T-fence.md' "$T/rep.txt" | grep -q 'delete line 6' \
  && bad "the report points at a line inside a fence" || ok
# the value alone, not the neighbouring field a `-` separator glued to it
grep -A3 'T-hyphen.md' "$T/rep.txt" | grep -q 'the header already says `doing`' \
  && ok || bad "the report swallowed a neighbouring field into the value it shows"
grep -A2 'T-hyphen.md' "$T/rep.txt" | grep -q 'Owner' \
  && bad "the report offered to overwrite a neighbouring field" || ok
# a stage that is a sentence gets no instruction at all
grep -A2 'T-prose.md' "$T/rep.txt" | grep -q 'is not a stage name' \
  && ok || bad "a prose sentence was printed as the value to set"
grep -A2 'T-prose.md' "$T/rep.txt" | grep -q 'set  *\*\*Status\*\*: doing is what' \
  && bad "the report instructed the reader to write a sentence into a stage field" || ok

# ── the report's instruction must have a path through the guard ────────────────────────────
# Printed as one act — "delete the machine line and set **Status**" — it walked into §14: a stage
# edited by hand is the bypass the guard refuses, and reaching for the door instead was refused
# too because the door still read the machine copy. For the tasks whose copies DISAGREE, which
# are the only tasks the report exists for, there was no path but `--no-verify`. Measured
# 2026-08-15 (pass nine, cold read). This walks step 1 for real, against the shipped guard.
mkdir -p "$T/seq/_ops/scripts" "$T/seq/_ops/tasks" && ( cd "$T/seq" && git init -q . )
cp "$HERE/../templates/company-preflight.sh" "$T/seq/_ops/scripts/preflight.sh"
cp "$HERE/transition.py" "$HERE/new-id.py" "$T/seq/_ops/scripts/"
for d in ROADMAP TEAM TOOLING DECISIONS; do printf '# %s\n' "$d" > "$T/seq/_ops/$d.md"; done
printf '# T-63 — the reminders email\n\n**Type**: build · **Status**: started\n**Assignee**: ui\n\n<!-- machine-readable -->\nstage: review\n\n## History\n' > "$T/seq/_ops/tasks/T-63.md"
( cd "$T/seq" && git add -A >/dev/null && git -c user.email=t@f.t -c user.name=T commit -qm f )
( cd "$T/seq" && python3 "$HERE/migrate-layout.py" . ) > "$T/seq.txt" 2>&1
grep -q 'commit THAT ALONE' "$T/seq.txt" \
  && ok || bad "the report does not say the two edits are two commits"
grep -q 'transition.py' "$T/seq.txt" \
  && ok || bad "the report never names the door for step 2"
grep -qE 'set +\*\*Status\*\*:' "$T/seq.txt" \
  && bad "the report still tells the reader to set **Status** by hand, which §14 refuses" || ok
# and step 1, performed exactly as printed, must commit
python3 -c "
import pathlib
p = pathlib.Path('$T/seq/_ops/tasks/T-63.md')
p.write_text('\n'.join(l for l in p.read_text().split('\n') if not l.startswith('stage:')))"
( cd "$T/seq" && git add -A && bash _ops/scripts/preflight.sh >/dev/null 2>&1 ) \
  && ok || bad "step 1 of the report's own instruction is refused by the guard it ships beside"

# ── a task the report cannot read is named, not dropped ────────────────────────────────────
# A task with a real two-home disagreement and one invalid UTF-8 byte was omitted while the
# header went on counting the rest — a report whose whole job is naming what disagrees quietly
# shrank. Measured 2026-08-15 (pass nine).
printf '# D\n\n**Status**: doing\n\nstage: review\n\377\n' > "$T/rep/_ops/tasks/T-bad.md"
( cd "$T/rep" && git add -A >/dev/null && git -c user.email=t@f.t -c user.name=T commit -qm b )
python3 "$HERE/migrate-layout.py" "$T/rep" > "$T/rep2.txt" 2>&1
grep -q 'could not be read as UTF-8' "$T/rep2.txt" \
  && ok || bad "an undecodable task was dropped from the report without a word"
grep -q 'T-bad.md' "$T/rep2.txt" \
  && ok || bad "the undecodable task was not named"

# ── new-id.py must not mint an id §1d refuses ──────────────────────────────────────────────
# `str.isalpha()` is Unicode-aware, so `--prefix ЖД` minted `ЖД-6ZW5EA` and the guard's ASCII-path
# check then refuses that filename — a door handing the project an id its own guard rejects.
python3 "$HERE/new-id.py" --prefix "ЖД" >/dev/null 2>&1 \
  && bad "new-id.py minted a non-ASCII prefix the guard refuses as a path" || ok
python3 "$HERE/new-id.py" --prefix "RQ" >/dev/null 2>&1 \
  && ok || bad "new-id.py refuses a two-letter ASCII prefix it is supposed to mint"

# ── the doors remedy must run where it is printed ──────────────────────────────────────────
# The guard's doors refusal is emitted by a pre-commit hook, so there is always staged work. It
# offered a plain `migrate-layout.py .`, which refuses a dirty tree — the first remedy could not
# work at the only moment it is read. Measured 2026-08-15 (pass nine). This asserts the whole
# loop: staged work present · a door missing · run the printed command · it lands and stages.
mkdir -p "$T/doors/_ops/scripts" "$T/doors/_ops/tasks" && ( cd "$T/doors" && git init -q . )
cp "$HERE/../templates/company-preflight.sh" "$T/doors/_ops/scripts/preflight.sh"
cp "$HERE/transition.py" "$T/doors/_ops/scripts/"            # only ONE door
printf '# T\n\n**Status**: started\n\n## History\n' > "$T/doors/_ops/tasks/T-1.md"
( cd "$T/doors" && git add -A >/dev/null && git -c user.email=t@f.t -c user.name=T commit -qm f )
printf -- '- a change\n' >> "$T/doors/_ops/tasks/T-1.md"
( cd "$T/doors" && git add -A )                               # the hook's actual state: dirty
( cd "$T/doors" && bash _ops/scripts/preflight.sh 2>&1 || true ) > "$T/doors.txt"
grep -q -- '--doors-only' "$T/doors.txt" \
  && ok || bad "the doors refusal does not print a command that runs with work staged"
grep -q 'cp .*transition.py' "$T/doors.txt" \
  && bad "the refusal offered to overwrite a door that is present" || ok
# The harness's own shape: `wired;` copies GUIDE-template.md to CLAUDE.md with placeholders
# unfilled, and its line 13 reads `**Operated by:** {{skill display_name}}` — "operated by" and
# not "opsinist" — which tripped the sibling-tree refusal BEFORE the doors branch. Measured
# 2026-08-15 (pass ten): the remedy the guard prints as THE fix was refused whole, exit 2, no
# door copied, inside the harness built to measure whether anyone runs it. Real projects hit it
# between day one and the first generation of the guide.
# ...and a SIBLING-operated tree must still be refused. `{{` anywhere in the line was too wide a
# skip: a sibling methodology's guide names itself and leaves a placeholder VERSION beside it, so
# the skip disarmed the shared door for exactly the tree it protects — measured 2026-08-15 (pass
# eleven), the migration ran and moved files. The rule is that the OPERATOR position must be
# unfilled, not that the line contains a placeholder somewhere.
printf '# Guide\n\n**Operated by otherops {{x.y.z}}.** Workspace: `{{workspace}}` elsewhere.\n' \
  > "$T/doors/CLAUDE.md"
( cd "$T/doors" && python3 "$HERE/migrate-layout.py" . --doors-only >/dev/null 2>&1 ) \
  && bad "a sibling-operated workspace was migrated because its version was a placeholder" || ok
cp "$HERE/../templates/GUIDE-template.md" "$T/doors/CLAUDE.md"
( cd "$T/doors" && python3 "$HERE/migrate-layout.py" . --doors-only ) > "$T/doors2.txt" 2>&1
[ -s "$T/doors/_ops/scripts/new-id.py" ] \
  && ok || bad "the printed command did not place the missing door"
( cd "$T/doors" && git diff --cached --name-only | grep -q 'new-id.py' ) \
  && ok || bad "the door was written but not staged"
( cd "$T/doors" && bash _ops/scripts/preflight.sh >/dev/null 2>&1 ) \
  && ok || bad "the commit is still refused after following the refusal's own instruction"
# **A door already at HEAD, deleted and restored to identical bytes, is staged — and the check
# used to say it was not.** `git diff --cached --name-only` lists paths whose index entry differs
# from the COMMIT, so a byte-identical restore appears nowhere in it. The script then printed
# "written but NOT staged" and pointed at ignored paths and symlinks, on the one path where the
# message does most harm: someone running the remedy the guard just printed. The assertion above
# passes only because that fixture's door is NEW; this one covers the case it cannot see.
# Measured 2026-08-23.
( cd "$T/doors" && git add -A && git -c user.email=t@t -c user.name=t commit -qm "doors in" ) >/dev/null 2>&1
rm -f "$T/doors/_ops/scripts/new-id.py"
( cd "$T/doors" && python3 "$HERE/migrate-layout.py" . --doors-only ) > "$T/doors3.txt" 2>&1
grep -q 'NOT staged' "$T/doors3.txt" \
  && bad "a door restored to the bytes it already has at HEAD was reported as not staged" || ok
[ -s "$T/doors/_ops/scripts/new-id.py" ] \
  && ok || bad "the restored door is not on disk"
# The silence has to be the RIGHT silence, and asking `--error-unmatch` could not establish that:
# the path is committed two lines above and `rm -f` touches only the worktree, so the index entry
# survives no matter what the command under test does — an assertion that cannot fail. It also
# asked the wrong question. The defect was that the index already held the CONTENT; presence was
# never in doubt. Compare the index blob to the file's own hash, which is what the fix does.
_ix=$( cd "$T/doors" && git ls-files -s -- _ops/scripts/new-id.py | awk '{print $2}' )
_wt=$( cd "$T/doors" && git hash-object -- _ops/scripts/new-id.py )
[ -n "$_ix" ] && [ "$_ix" = "$_wt" ] \
  && ok || bad "the index does not hold the restored door's bytes — the silence was the wrong silence"
# **A door on disk with the right bytes and removed from the index** — the third case the refusal
# string names as measured, and the one the remedy could not reach: the identical-bytes
# short-circuit returned before `git add`, printed "already in place and current", and the guard
# reads the worktree so it saw the file too. Nothing anywhere said the commit was about to go out
# without the door. Found 2026-08-23 by an adversarial lens.
( cd "$T/doors" && git rm -q --cached _ops/scripts/new-id.py ) >/dev/null 2>&1
( cd "$T/doors" && python3 "$HERE/migrate-layout.py" . --doors-only ) > "$T/doors4.txt" 2>&1
grep -q 'already in place and current' "$T/doors4.txt" \
  && bad "a door missing from the index was reported as already in place and current" || ok
( cd "$T/doors" && git ls-files --error-unmatch _ops/scripts/new-id.py >/dev/null 2>&1 ) \
  && ok || bad "the remedy did not put the door back in the index"

# **`_ops/scripts` as a symlink out of the repository** — the case the refusal string named as
# measured and no test had ever built. git refuses to stage through it, so the doors land on disk
# and the commit cannot carry them. Two things must be true: the message picks ONE remedy from
# git's own reason rather than offering a menu, and the summary line does not print "re-copied"
# over a door that was not carried. Both were wrong until 2026-08-23; the second is the shape
# `git pull` uses to hide its failures — `Aborting` and `Updating <old>..<new>` on adjacent lines.
SL="$T/sym"; mkdir -p "$SL/outside/scripts" "$SL/r/_ops"
cp "$HERE/../templates/company-preflight.sh" "$SL/outside/scripts/preflight.sh"
ln -s "$SL/outside/scripts" "$SL/r/_ops/scripts"
printf '# P\n\n**Operated by:** Opsinist **%s**\n' \
  "$(sed -n 's/^version: //p' "$HERE/../skills/advisor/SKILL.md" | head -1)" > "$SL/r/CLAUDE.md"
( cd "$SL/r" && git init -q && git add -A >/dev/null 2>&1
  git -c user.email=t@t -c user.name=t commit -qm init ) >/dev/null 2>&1
( cd "$SL/r" && python3 "$HERE/migrate-layout.py" . --doors-only ) > "$T/sym.txt" 2>&1
# A `_ops/scripts` that links out of the tree is now refused BEFORE the write, so the write
# path's symlink wording is no longer what fires here — the earlier, stronger refusal is. The
# assertion moved with the behaviour rather than the behaviour being kept for the assertion.
grep -qE 'OUTSIDE this repository — refusing|is a symlink to .* OUT of this repository' "$T/sym.txt" \
  && ok || bad "the symlink case did not name why the door cannot be placed"

# ── a symlinked ancestor pointing INSIDE the repository is refused too ──────────────────────
# **Both earlier guards missed this one.** Containment asks only whether the target leaves the
# tree; the second-name check looks at the door itself, and behind `_ops/scripts -> scripts_real`
# the door is an ordinary file with a single name. Measured 2026-08-28: a tracked 45-byte file
# replaced by 19 KB of door at exit 0, while the printed diagnosis said the link led *out* of the
# repository and told the reader to move it *in* — where it already was. What makes it refusable
# is not the direction: git cannot stage a path behind a symlink either way, so no commit here
# could carry the door, and the bytes overwritten sit at a path nobody pointed this command at.
IN="$T/inlink"; mkdir -p "$IN/_ops/scripts_real" "$IN/docs"
printf 'MY OWN FILE, TRACKED
' > "$IN/_ops/scripts_real/transition.py"
_kept=$(wc -c < "$IN/_ops/scripts_real/transition.py")
printf '#!/bin/sh\necho guard\n' > "$IN/_ops/scripts_real/preflight.sh"
ln -s scripts_real "$IN/_ops/scripts"
printf 'adapter: claude\nversion: %s\n' \
  "$(sed -n 's/^version: //p' "$HERE/../skills/advisor/SKILL.md" | head -1)" > "$IN/CLAUDE.md"
( cd "$IN" && git init -q && git add -A >/dev/null 2>&1
  git -c user.email=t@t -c user.name=t commit -qm init ) >/dev/null 2>&1
( cd "$IN" && python3 "$HERE/migrate-layout.py" . --doors-only ) > "$T/inlink.txt" 2>&1
[ "$(wc -c < "$IN/_ops/scripts_real/transition.py")" = "$_kept" ] \
  && ok || bad "a tracked file was overwritten through a symlinked ancestor pointing INSIDE the repository"
grep -q 'inside this repository' "$T/inlink.txt" \
  && ok || bad "the refusal names the wrong direction — it said the link led out of a repository it points into, and prescribed a move that was already done"
grep -q 'beyond a symbolic link' "$T/inlink.txt" \
  && ok || bad "the refusal does not say why direction is irrelevant: git cannot stage behind a symlink either way"
grep -q 'Read the reason above and pick accordingly' "$T/sym.txt" \
  && bad "the message still offers a menu instead of a remedy" || ok
grep -q 'NOT carried by this commit' "$T/sym.txt" \
  && ok || bad "doors that could not be staged were not named as uncarried"
grep -q 'doors re-copied beside the guard' "$T/sym.txt" \
  && bad "a door that was never staged was reported as re-copied" || ok

# **The identical-bytes short-circuit is the other half, and it was not covered.** Doors on disk
# with the shipped bytes, gitignored and never in the index: two hard refusals, then `doors
# re-copied beside the guard`, then exit 0. `_failed` was appended on the write path only.
# Measured 2026-08-23 by an adversarial lens.
IG="$T/ig"; mkdir -p "$IG/_ops/scripts"
cp "$HERE/../templates/company-preflight.sh" "$IG/_ops/scripts/preflight.sh"
cp "$HERE/transition.py" "$HERE/new-id.py" "$IG/_ops/scripts/"
printf '_ops/scripts/*.py\n' > "$IG/.gitignore"
printf '# P\n\n**Operated by:** Opsinist **%s**\n' \
  "$(sed -n 's/^version: //p' "$HERE/../skills/advisor/SKILL.md" | head -1)" > "$IG/CLAUDE.md"
( cd "$IG" && git init -q && git add -A >/dev/null 2>&1
  git -c user.email=t@t -c user.name=t commit -qm init ) >/dev/null 2>&1
( cd "$IG" && python3 "$HERE/migrate-layout.py" . --doors-only ) > "$T/ig.txt" 2>&1
grep -q 'doors re-copied beside the guard' "$T/ig.txt" \
  && bad "doors that were never staged were reported as re-copied on the identical-bytes path" || ok
grep -q 'NOT carried by this commit' "$T/ig.txt" \
  && ok || bad "the identical-bytes path did not name the doors it could not stage"
grep -q 'Read the reason above and pick accordingly' "$T/ig.txt" \
  && bad "the identical-bytes path still prints the menu the write path was cured of" || ok

# ── a write that leaves the repository is refused, and the file outside survives ─────────────
# **This overwrote somebody else's file.** `write_bytes` follows a symlink, so a door path
# pointing out of the tree meant a 35-byte personal file was silently replaced by 19 KB of door,
# with the only notice being "the previous file is at …" — naming a backup written INSIDE the
# repo whose original was not. Measured 2026-08-23 by an adversarial lens. The test is the
# RESOLVED destination, so `_ops/scripts` being a link is caught the same as the door being one.
OUT="$T/outside"; mkdir -p "$OUT"
printf '# MY OWN PRECIOUS FILE, not a door\n' > "$OUT/mine.py"
_before=$(wc -c < "$OUT/mine.py")
LK="$T/lk"; mkdir -p "$LK/_ops/scripts"
cp "$HERE/../templates/company-preflight.sh" "$LK/_ops/scripts/preflight.sh"
ln -s "$OUT/mine.py" "$LK/_ops/scripts/transition.py"
printf '# P\n\n**Operated by:** Opsinist **%s**\n' \
  "$(sed -n 's/^version: //p' "$HERE/../skills/advisor/SKILL.md" | head -1)" > "$LK/CLAUDE.md"
( cd "$LK" && git init -q && git add -A >/dev/null 2>&1
  git -c user.email=t@t -c user.name=t commit -qm init ) >/dev/null 2>&1
( cd "$LK" && python3 "$HERE/migrate-layout.py" . --doors-only ) > "$T/lk.txt" 2>&1
[ "$(wc -c < "$OUT/mine.py")" = "$_before" ] \
  && ok || bad "a file OUTSIDE the repository was overwritten by --doors-only"
# A symlinked door is now caught by the second-name check BEFORE the containment check, and for
# a truer reason: it does not matter where the other name lives, only that there is one. Either
# refusal is correct; what must never happen is the write.
grep -qE 'OUTSIDE this repository — refusing|is a symlink to' "$T/lk.txt" \
  && ok || bad "the refusal did not name why the door cannot be placed"
grep -q 'NOT carried by this commit' "$T/lk.txt" \
  && ok || bad "the refused door was not named as uncarried"

# the other shape: the DIRECTORY is the link, and the doors must not land in the other tree
OD="$T/otherdir"; mkdir -p "$OD"
LD="$T/ld"; mkdir -p "$LD/_ops"
cp "$HERE/../templates/company-preflight.sh" "$OD/preflight.sh"
ln -s "$OD" "$LD/_ops/scripts"
printf '# P\n\n**Operated by:** Opsinist **%s**\n' \
  "$(sed -n 's/^version: //p' "$HERE/../skills/advisor/SKILL.md" | head -1)" > "$LD/CLAUDE.md"
( cd "$LD" && git init -q && git add -A >/dev/null 2>&1
  git -c user.email=t@t -c user.name=t commit -qm init ) >/dev/null 2>&1
( cd "$LD" && python3 "$HERE/migrate-layout.py" . --doors-only ) > "$T/ld.txt" 2>&1
[ ! -e "$OD/transition.py" ] && [ ! -e "$OD/new-id.py" ] \
  && ok || bad "the doors were written into a directory outside the repository"

# ── a HARD link is the other way out of the repository, and it had no test ──────────────────
# The symlink guard resolves the destination; a hard link has no target to resolve, so
# containment passed and the door was written straight through — measured 2026-08-27, a file
# outside replaced by 19 KB, reported as success at exit 0.
HL="$T/hl"; mkdir -p "$HL/_ops/scripts"
printf 'PRECIOUS ORIGINAL CONTENT\n' > "$T/victim.py"
_vbefore=$(wc -c < "$T/victim.py")
cp "$HERE/../templates/company-preflight.sh" "$HL/_ops/scripts/preflight.sh"
ln "$T/victim.py" "$HL/_ops/scripts/transition.py"
printf '# P\n\n**Operated by:** Opsinist **%s**\n' \
  "$(sed -n 's/^version: //p' "$HERE/../skills/advisor/SKILL.md" | head -1)" > "$HL/CLAUDE.md"
( cd "$HL" && git init -q && git add -A >/dev/null 2>&1
  git -c user.email=t@t -c user.name=t commit -qm init ) >/dev/null 2>&1
( cd "$HL" && python3 "$HERE/migrate-layout.py" . --doors-only ) > "$T/hl.txt" 2>&1
[ "$(wc -c < "$T/victim.py")" = "$_vbefore" ] \
  && ok || bad "a file outside the repository was overwritten through a HARD link"
grep -q 'hard link' "$T/hl.txt" \
  && ok || bad "the hard link was not named as the reason"
grep -q 'NOT carried by this commit' "$T/hl.txt" \
  && ok || bad "the refused door was not named as uncarried"
# a hard link INSIDE the repository is legitimate and must still be refused for the same reason —
# writing through it rewrites the other name, which is inside the tree but is still not this door
printf 'sibling\n' > "$HL/other.py"
rm -f "$HL/_ops/scripts/new-id.py"
ln "$HL/other.py" "$HL/_ops/scripts/new-id.py"
( cd "$HL" && python3 "$HERE/migrate-layout.py" . --doors-only ) > "$T/hl2.txt" 2>&1
[ "$(cat "$HL/other.py")" = "sibling" ] \
  && ok || bad "a hard link inside the repository was written through"

# A SYMLINK whose target is inside the repository is a second name too. The containment test only
# asks whether the target leaves the tree, and the link-count test skipped symlinks — so an
# in-repo target was written straight through, 28 bytes replaced by 19 KB, with a backup named
# that was not it. Measured 2026-08-27.
IN="$T/inrepo"; mkdir -p "$IN/_ops/scripts" "$IN/tools"
printf 'MY OWN FILE inside the repo\n' > "$IN/tools/mine.py"
_ibefore=$(wc -c < "$IN/tools/mine.py")
cp "$HERE/../templates/company-preflight.sh" "$IN/_ops/scripts/preflight.sh"
( cd "$IN/_ops/scripts" && ln -s ../../tools/mine.py transition.py )
printf '# P\n\n**Operated by:** Opsinist **%s**\n' \
  "$(sed -n 's/^version: //p' "$HERE/../skills/advisor/SKILL.md" | head -1)" > "$IN/CLAUDE.md"
( cd "$IN" && git init -q && git add -A >/dev/null 2>&1
  git -c user.email=t@t -c user.name=t commit -qm init ) >/dev/null 2>&1
( cd "$IN" && python3 "$HERE/migrate-layout.py" . --doors-only ) > "$T/in.txt" 2>&1
[ "$(wc -c < "$IN/tools/mine.py")" = "$_ibefore" ] \
  && ok || bad "a file INSIDE the repository was overwritten through a symlinked door"
grep -q 'is a symlink to' "$T/in.txt" \
  && ok || bad "the symlink was not named as the reason"
# ...and a tree that really does declare another operator is still handed back untouched
printf '# Guide\n\n**Operated by:** otherops 9.9.9\n' > "$T/doors/CLAUDE.md"
rm -f "$T/doors/_ops/scripts/new-id.py"
( cd "$T/doors" && python3 "$HERE/migrate-layout.py" . --doors-only >/dev/null 2>&1 ) \
  && bad "a tree declaring another operator was migrated" || ok
[ -f "$T/doors/_ops/scripts/new-id.py" ] \
  && bad "a door was copied into another system's tree" || ok


# ── `skills/` at a project root is not always ours, and a dry run must not contradict itself ──
# Both reported 2026-09-05 from a live migration. `skills/` held one README pointing at an
# unrelated repository and was moved into `_ops/` silently, to be put back by hand — while the
# comment above `ENTITY_DIRS` already spells out this exact care for `scripts/`, and `docs/` takes
# only the names it knows. And `--dry-run` printed one file as both moved and left behind, because
# it read the directory from disk when nothing had moved yet — the preview lying in the one place
# a preview exists for.
FS="$T/foreign"; mkdir -p "$FS/skills" "$FS/docs"
printf '# see the other repository\n' > "$FS/skills/README.md"
printf '# arch\n' > "$FS/docs/ARCHITECTURE.md"
printf '# mine\n' > "$FS/docs/MINE.md"
printf 'adapter: claude\n' > "$FS/config.md"
( cd "$FS" && git init -q && git add -A >/dev/null 2>&1
  git -c user.email=t@t -c user.name=t commit -qm init ) >/dev/null 2>&1
( cd "$FS" && python3 "$HERE/migrate-layout.py" . --dry-run ) > "$T/fs.txt" 2>&1
grep -q 'left alone: skills/' "$T/fs.txt" \
  && ok || bad "a skills/ holding no SKILL.md was claimed as the machinery's pool — at a project root that name is not ours by right"
# **And the ACT, not only the message.** A mutant that put `skills` back in `ENTITY_DIRS` moved
# the foreign directory and still printed "left alone: skills/", and the assertion above passed —
# read alone it is a claim about the report. Measured by an adversarial lens 2026-09-05.
( cd "$FS" && python3 "$HERE/migrate-layout.py" . ) > "$T/fs-real.txt" 2>&1
[ -f "$FS/skills/README.md" ] && [ ! -e "$FS/_ops/skills" ] \
  && ok || bad "a real run MOVED the foreign skills/ while the preview said it was left alone — the assertion above tests the message, this one tests the act"
# **A symlinked subdirectory is not evidence of a pool** — `is_dir()` follows symlinks, so
# `skills/theirs -> /elsewhere` carrying a SKILL.md swept someone else's entity into `_ops/`:
# the exact failure this check exists to stop, one symlink away.
mkdir -p "$T/elsewhere/theirs" && printf '# s\n' > "$T/elsewhere/theirs/SKILL.md"
ln -s "$T/elsewhere/theirs" "$FS/skills/theirs" 2>/dev/null
( cd "$FS" && git add -A ) >/dev/null 2>&1
( cd "$FS" && python3 "$HERE/migrate-layout.py" . --dry-run ) > "$T/fs-sym.txt" 2>&1
grep -qE '^\s*skills\s+→' "$T/fs-sym.txt" \
  && bad "a SYMLINKED subdirectory carrying SKILL.md made the whole directory look like ours" || ok
rm -f "$FS/skills/theirs"
grep -qE '^\s*skills\s+→' "$T/fs.txt" \
  && bad "a foreign skills/ was still listed as a move" || ok
# the dry run does not print one file as both moved and staying
grep -q 'ARCHITECTURE.md  →' "$T/fs.txt" \
  && ok || bad "the dry run did not name the move it was previewing"
grep -E 'left in docs/' "$T/fs.txt" | grep -q 'ARCHITECTURE' \
  && bad "the dry run printed ARCHITECTURE.md as moved AND left behind — it read the directory from disk before anything moved" || ok
grep -E 'left in docs/' "$T/fs.txt" | grep -q 'MINE' \
  && ok || bad "the dry run stopped naming what genuinely stays behind"
# and a REAL pool is still claimed — the test above must not have bought its pass by refusing everything
mkdir -p "$FS/skills/advisor" && printf '# s\n' > "$FS/skills/advisor/SKILL.md"
( cd "$FS" && git add -A ) >/dev/null 2>&1
( cd "$FS" && python3 "$HERE/migrate-layout.py" . --dry-run ) > "$T/fs2.txt" 2>&1
grep -qE '^\s*skills\s+→' "$T/fs2.txt" \
  && ok || bad "a genuine skills pool — a subdirectory carrying SKILL.md — was left behind"

echo "migrate-layout: $pass passed, $fail failed"
exit "$fail"
