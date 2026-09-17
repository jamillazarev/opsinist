#!/usr/bin/env bash
# `graph-check.py` — does this project's graph actually work — on throwaway vaults holding every
# shape that decides the answer: a link that resolves both ways, one that resolves only relative to
# its own file, one that resolves only from the vault root, a phantom, an unencoded space, an
# absolute path, a link climbing out of the repository, a fenced example, an attachment, and a
# project of notes with no lines between them at all.
#
# **The measured case it was written against** (2026-09-18, a live project): 19 notes, **0 edges**,
# 19 orphans — and this script's own first run called that *"the graph is whole"*, which is true
# about links and false about everything a graph is for. That sentence is now a finding, and the
# mutant below is the version that says it again.
#
# **Four code mutants**: the scatter verdict removed · resolution tried one way only · fenced
# examples counted as phantoms · a `## History` line counted as a missing edge — that last one in
# `link-ids.py`, because **the missing-edge count is the door's own answer** rather than a second
# derivation of it, and a mutant has to land where the rule lives.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
said() { [ "$(printf '%s' "$OUT" | grep -cF -- "$1")" -gt 0 ]; }
gc() { OUT=$(python3 "${MUT:-$HERE/graph-check.py}" "$T/p" "$@" 2>&1); RC=$?; }

fixture() {
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/tasks" "$T/p/_ops/roles" "$T/p/_ops/scripts"
  cd "$T/p" || exit 1
  git init -q . && git config user.email t@f.t && git config user.name T
  printf '# Roadmap\n\nFirst the alpha.\n' > _ops/ROADMAP.md
  printf '# Web Engineer\n\n**Type**: worker\n' > _ops/roles/web_engineer.md
  printf 'x = 1\n' > _ops/scripts/thing.py
  git add -A >/dev/null 2>&1
}

task() {   # $1 id · $2.. body lines
  local id="$1"; shift
  { printf '# %s — a thing\n\n**Type**: feature · **Status**: review\n' "$id"
    for l in "$@"; do printf '%s\n' "$l"; done
    printf '\n## History\n\n- 2026-09-18 — started\n'
  } > "_ops/tasks/$id-thing.md"
  git add -A >/dev/null 2>&1
}

# ── a linked project: edges counted, nothing broken, the relative form recognised ──────────────
fixture
task T-AAAAAA '**Assignee**: [Web Engineer](../roles/web_engineer.md)' \
              'Waits for [T-BBBBBB](T-BBBBBB-thing.md).'
task T-BBBBBB '**Assignee**: [Web Engineer](../roles/web_engineer.md)'
gc
[ "$RC" = 0 ] && said 'the graph is whole' && ok || bad "a properly linked project was not called whole: $OUT"
said '3 note-to-note edges' && ok || bad "the edges were miscounted: $OUT"
said 'only relative to their own file' && said 'the relative form throughout' && ok \
  || bad "the file-relative form was not recognised as the prescribed one: $OUT"

# ── a project of notes with no lines is the finding, not a clean bill ──────────────────────────
fixture
task T-CCCCCC '**Assignee**: nobody'
task T-DDDDDD '**Assignee**: nobody'
gc
[ "$RC" = 1 ] && said 'no edges at all' && ok \
  || bad "a project with notes and no edges was reported as whole: $OUT"

# ── a mention that would be an edge is counted, and the door is named ─────────────────────────
fixture
task T-EEEEEE '**Assignee**: Web Engineer' 'Waits for T-FFFFFF.'
task T-FFFFFF '**Assignee**: nobody'
gc
[ "$RC" = 1 ] && said '2 ids or names already name' && said 'link-ids.py --write' && ok \
  || bad "mentions that could be edges were not counted: $OUT"

# ── a phantom, and what the graph does with it ─────────────────────────────────────────────────
fixture
task T-GGGGGG 'See [the missing one](T-ZZZZZZ-gone.md).'
gc
[ "$RC" = 1 ] && said 'resolves to no file' && said 'Existing files only' && ok \
  || bad "a phantom target was not reported as one: $OUT"

# ── an unencoded space, an absolute path, and a climb out of the repository ────────────────────
fixture
task T-HHHHHH 'See [it](my file.md).'
gc; [ "$RC" = 1 ] && said 'unencoded space' && ok || bad "an unencoded space was not caught: $OUT"

fixture
task T-IIIIII 'See [it](/Users/somebody/_ops/ROADMAP.md).'
gc; [ "$RC" = 1 ] && said 'outside the vault' && ok || bad "an absolute path was not caught: $OUT"

fixture
task T-JJJJJJ 'See [it](../../../outside.md).'
gc; [ "$RC" = 1 ] && said 'outside the vault' && ok || bad "a climb out of the repository was not caught: $OUT"

# ── a destination that resolves only from the vault root is called out ─────────────────────────
fixture
task T-KKKKKK 'See [the roadmap](_ops/ROADMAP.md).'
gc
said 'only from the vault root' && said 'breaks in this repository and on the git host' && ok \
  || bad "a vault-absolute-only link was not called out: $OUT"

# ── a fenced example is not an edge and not a defect ───────────────────────────────────────────
fixture
task T-LLLLLL '**Assignee**: [Web Engineer](../roles/web_engineer.md)' '' '```' \
              'See [an example](T-NOWHERE-at-all.md).' '```'
gc
[ "$RC" = 0 ] && ! said 'resolves to no file' && ok \
  || bad "a link inside a fence was counted as a phantom: $OUT"

# ── an elided path in prose is a placeholder, not a phantom ────────────────────────────────────
fixture
task T-PPPPPP '**Assignee**: [Web Engineer](../roles/web_engineer.md)' 'The shape is [the file](…).'
gc; [ "$RC" = 0 ] && ! said 'resolves to no file' && ok \
  || bad "an elided link target was reported as a phantom: $OUT"

# ── a link to a script is an attachment, not a note-to-note edge ───────────────────────────────
fixture
task T-MMMMMM '**Assignee**: [Web Engineer](../roles/web_engineer.md)' \
              'Run [the thing](../scripts/thing.py).'
gc
said '1 attachment link' && ok || bad "a link to a script was not counted as an attachment: $OUT"

# ── --json carries the same numbers, for a sweep ───────────────────────────────────────────────
gc --json
printf '%s' "$OUT" | python3 -c "
import json,sys
d = json.load(sys.stdin)
assert d['notes'] >= 1 and d['attachments'] == 1 and 'mentions_that_could_be_edges' in d, d
" 2>/dev/null && ok || bad "--json did not carry the counts: $OUT"

# ── a file that cannot be decoded makes the count a FLOOR, said out loud ──────────────────────
# The fold's first version swallowed every exception per file, so an undecodable file took its
# mentions with it and the report printed a plausible number that was simply wrong — three counted
# as two, silently, which is worse than the crash it replaced. Found by an adversarial lens,
# 2026-09-18.
fixture
task T-NNNNNN '**Assignee**: Web Engineer'
python3 -c "open('_ops/tasks/T-OOOOOO-bad.md','wb').write(b'# T-OOOOOO \xff\xfe\n\n**Assignee**: Web Engineer\n')"
git add -A >/dev/null 2>&1
gc; said 'could not be read' && said 'FLOOR' && ok \
  || bad "an undecodable file was dropped from the count with no word: $OUT"

# ── a directory with no markdown is refused rather than answered ───────────────────────────────
rm -rf "$T/p"; mkdir -p "$T/p"; ( cd "$T/p" && git init -q . )
gc; [ "$RC" = 2 ] && ok || bad "a tree with no notes did not exit 2: $OUT"

# ── the mutants ────────────────────────────────────────────────────────────────────────────────
# **The copy needs the door beside it**, because the missing-edge count IS the door's answer now:
# a lone `mut.py` cannot import `link-ids.py`, reports NOT MEASURED, and every assertion about the
# count would pass for the wrong reason. `$4` says which of the two files to mutate — the count's
# own line-walk lives in the door, so a mutant for it lands there.
mutant() {   # $1 what it breaks · $2 from · $3 to · $4 file to mutate (default the checker)
  cp "$HERE/graph-check.py" "$T/mut.py"; cp "$HERE/link-ids.py" "$T/link-ids.py"
  M_FROM="$2" M_TO="$3" python3 - "$T/${4:-mut.py}" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return 1; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  MUT="$T/mut.py"
}
mutant "the scatter verdict removed" 'scattered = len(notes) > 1 and not edges' 'scattered = False' \
  && { fixture; task T-CCCCCC '**Assignee**: nobody'; task T-DDDDDD '**Assignee**: nobody'; gc
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: a scatter called whole"; }

mutant "resolution tried one way only" '    rel_ok, abs_ok = as_rel in files, as_abs in files' \
                                        '    rel_ok, abs_ok = as_rel in files, False' \
  && { fixture; task T-KKKKKK 'See [the roadmap](_ops/ROADMAP.md).'; gc
       said 'resolves to no file' && ok \
       || bad "the suite did not catch the mutant: only one resolution tried"; }

mutant "fenced examples counted" '        if fenced:
            continue' '        if False:
            continue' \
  && { fixture
       task T-LLLLLL '**Assignee**: [Web Engineer](../roles/web_engineer.md)' '' '```' \
                     'See [an example](T-NOWHERE-at-all.md).' '```'
       gc; said 'resolves to no file' && ok \
       || bad "the suite did not catch the mutant: a fenced example read as a link"; }

mutant "a History line counted as a missing edge" \
  '        if fenced or history or DECLARATION.search(line):' \
  '        if fenced or DECLARATION.search(line):' link-ids.py \
  && { fixture
       task T-EEEEEE '**Assignee**: [Web Engineer](../roles/web_engineer.md)'
       python3 - <<'PY'
import io
p = "_ops/tasks/T-EEEEEE-thing.md"
s = open(p, encoding="utf-8").read()
open(p, "w", encoding="utf-8").write(s + "- 2026-09-18 — split out of T-FFFFFF\n")
PY
       task T-FFFFFF '**Assignee**: nobody'
       gc; said 'already name' && ok \
       || bad "the suite did not catch the mutant: a History mention counted"; }

# ── and with the door absent the count is NOT MEASURED, never zero ─────────────────
# The count is one number derived in one place now, so its failure mode is a missing door rather
# than a disagreeing copy — and a report printing `0` there would claim a measurement it never took
# (`PATTERNS.md` §16-bis: an honest empty state is a real answer).
# its own directory: `mutant()` leaves a copy of the door in `$T`, and `sys.path` here is the
# script's own parent — so a copy beside that one would import it and measure after all
mkdir -p "$T/alone"; cp "$HERE/graph-check.py" "$T/alone/graph-check.py"; MUT="$T/alone/graph-check.py"
fixture
task T-MMMMMM '**Assignee**: Web Engineer'
gc; said 'NOT MEASURED' && ok || bad "with no door beside it the count was not marked unmeasured: $OUT"
MUT=""

echo "graph-check: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
