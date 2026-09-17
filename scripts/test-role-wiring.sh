#!/usr/bin/env bash
# §28 of the project guard — **a role the runtime cannot see is a document, not a worker** — on a
# throwaway project in the state a live one was measured in: three role files in `_ops/roles/` and
# **no `.claude/` directory at all**, so every instruction, skill and bar those roles carried was
# read by nobody and the advisor did the work instead. That failure does not error; it just looks
# like a project where one agent does everything.
#
# **Five code mutants**: the agent wiring unchecked · the runtime's name spelling compared
# literally (`web_engineer.md` must answer to `web-engineer.md`) · the other-runtime escape removed,
# which would refuse every project not run in Claude Code · and the two ways an adversarial lens
# got a MENTION read as a declaration, a fenced example and an HTML comment. **That escape has had
# three shapes and four reproduced holes**, which is why its cases here are a loop over the shapes
# rather than one example: the rule is *naming a setting is not reading one*.
# **The skills half is §26's**, tested in `test-skills-attached.sh` — one reader per table, one
# suite per reader; the escape itself is one reader (`_wiring_elsewhere`) that both stand down on.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
said() { [ "$(printf '%s' "$OUT" | grep -cF -- "$1")" -gt 0 ]; }
run() { git add -A; OUT=$(bash _ops/scripts/preflight.sh 2>&1); RC=$?; }
commit() { git add -A; git commit -qm "$1" --no-verify; }

role() {   # $1 file stem · $2.. skill rows
  local f="_ops/roles/$1.md"; shift
  { printf '# A role\n\n**Type**: worker · **Grade**: mid\n\n## Skills attached\n\n'
    printf '| Skill | Why this role needs it |\n|---|---|\n'
    for s in "$@"; do printf '| %s | because |\n' "$s"; done
  } > "$f"
}
agent() {   # $1 name — the runtime file a role owes
  mkdir -p .claude/agents
  printf -- '---\nname: %s\ndescription: does the thing\n---\n\nThe instructions.\n' "$1" \
    > ".claude/agents/$1.md"
}

fixture() {
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/roles" "$T/p/_ops/tasks" "$T/p/_ops/scripts" "$T/p/src"
  cd "$T/p" || exit 1
  git init -q . && git config user.email t@f.t && git config user.name T
  for f in ROADMAP TEAM TOOLING DECISIONS ARCHITECTURE; do printf '# %s\n' "$f" > "_ops/$f.md"; done
  printf '# Guide\n\n**Operated by** Opsinist **0.2.19**\n' > CLAUDE.md
  printf '# Project configuration\n\nschema_version: 1\n' > _ops/config.md
  printf 'one\n' > src/app.js
  cp "${MUT:-$HERE/../templates/company-preflight.sh}" _ops/scripts/preflight.sh
  cp "$HERE/transition.py" "$HERE/new-id.py" _ops/scripts/ 2>/dev/null || true
  commit "chore: opsinist init"
}

# ── the measured case: a role with nothing in .claude/agents/ ──────────────────────────────────
fixture
role web_engineer
run
[ "$RC" = 1 ] && said 'the runtime cannot see' && said '.claude/agents/web-engineer.md' && ok \
  || bad "a role with no runtime wiring was accepted: $OUT"

# ── the wiring is one file, and the slug is compared, not the spelling ─────────────────────────
agent web-engineer
run; [ "$RC" = 0 ] && ok || bad "a role wired as `web-engineer.md` was still refused: $OUT"
commit "a wired role"

# ── the skills half moved to §26, which owns the table ────────────────────────────────────────
# A deletion lens found §26 and §28 reading one table in one file, and §26 already had the row
# open — so the pool-skill-not-wired case lives in `test-skills-attached.sh` now.

# ── a project run in another runtime DECLARES it, once, and this stands down ───────────────────
fixture
printf '# Project configuration\n\n| Setting | Value | Notes |\n|---|---|---|\n| `runtime_wiring` | `.codex/agents/` | Codex here |\n' \
  > _ops/config.md
role web_engineer
run; [ "$RC" = 0 ] && ok || bad "a project declaring another runtime's wiring path was still refused: $OUT"

# ── and a MENTION is not a declaration ─────────────────────────────────────────────────────────
# An adversarial lens found the escape firing on any prose naming a non-`.claude` agents path — so
# a sentence about a *rejected* alternative silenced both wiring checks on a correctly wired
# project (2026-09-18). An escape any footnote can trip is not an escape, and this is the second
# time this one was widened too far: the answer was to make it a declared setting.
fixture
printf '# Project configuration\n\nschema_version: 1\n\nWe evaluated `.gemini/agents/` and stayed on `.claude/agents/`.\n' \
  > _ops/config.md
role web_engineer
run; [ "$RC" = 1 ] && said 'the runtime cannot see' && ok \
  || bad "prose mentioning another runtime's path silenced the check: $OUT"

# ── naming the setting is not reading one: four shapes an adversarial lens broke ───────────────
# The third shape of this escape looked for its own key ANYWHERE in a line, and a lens broke it
# four ways in one sitting (2026-09-18): the key inside a fenced example · inside an HTML comment ·
# in another row's notes column · and, worst, in a sentence FORBIDDING it, which disabled §28
# entirely on an unwired role — exit 0, no output. The reader reads the settings table now.
for shape in fence comment incell notes negation stray; do
  fixture
  case "$shape" in
    fence)    printf '# Project configuration\n\nFor example:\n\n```\n| `runtime_wiring` | `.codex/agents/` |\n```\n' > _ops/config.md ;;
    comment)  printf '# Project configuration\n\n<!-- old value was `runtime_wiring` = `.codex/agents/` -->\n' > _ops/config.md ;;
    incell)   printf '# Project configuration\n\n| Setting | Value |\n|---|---|\n| `runtime_wiring` | <!-- `.codex/agents/` --> |\n' > _ops/config.md ;;
    notes)    printf '# Project configuration\n\n| Setting | Value | Notes |\n|---|---|---|\n| `spec_mode` | outcome | see `runtime_wiring` and `.codex/agents/` |\n' > _ops/config.md ;;
    negation) printf '# Project configuration\n\nDo not set `runtime_wiring` to `.codex/agents/` -- we use Claude Code here.\n' > _ops/config.md ;;
    stray)    printf '# Project configuration\n\n| Setting | Value |\n|---|---|\n| `runtime_wiring` | `.claude/agents/` |\n\nNever write `runtime_wiring` as `.codex/agents/`.\n' > _ops/config.md ;;
  esac
  role web_engineer
  run; [ "$RC" = 1 ] && said 'the runtime cannot see' && ok \
    || bad "the escape was taken from a $shape rather than a declaration: $OUT"
done

# ── and a value written as a markdown link declares its destination ────────────────────────────
# The same lens found the other side of it: a value cell holding a link read as no declaration at
# all, so a project that HAD declared another directory was refused. The href is the path.
fixture
mkdir -p .codex/agents && printf -- '---\nname: web-engineer\n---\n' > .codex/agents/web-engineer.md
printf '# Project configuration\n\n| Setting | Value |\n|---|---|\n| `runtime_wiring` | [the agents dir](../.codex/agents/) |\n' \
  > _ops/config.md
role web_engineer
run; [ "$RC" = 0 ] && ok || bad "a declared value written as a link was not read: $OUT"

# ── and a link-written `.claude/agents/` is still the directory we check ───────────────────────
# A link's href is FILE-relative, so the value arrives as `../.claude/agents/` — which a prefix
# test read as "somewhere else" and used to stand the check down on a correctly wired project.
# Compared by first real segment now.
fixture
printf '# Project configuration\n\n| Setting | Value |\n|---|---|\n| `runtime_wiring` | [ours](../.claude/agents/) |\n' \
  > _ops/config.md
mkdir -p .claude/agents && printf -- '---\nname: other\n---\n' > .claude/agents/other.md
role web_engineer
run; [ "$RC" = 1 ] && said 'the runtime cannot see' && ok \
  || bad "a link-written .claude/agents/ stood the check down: $OUT"

# ── an unfilled placeholder is not a declaration either ────────────────────────────────────────
# `CONFIG-template.md` ships the row with `{{absent}}` in its value cell, and a project that has
# not filled it in must be judged, not excused. The notes column names `.claude/` on purpose.
fixture
printf '# Project configuration\n\n| Setting | Value | Notes |\n|---|---|---|\n| `runtime_wiring` | {{absent}} | absent means `.claude/`, e.g. `_ops/agents/` would not |\n' \
  > _ops/config.md
role web_engineer
run; [ "$RC" = 1 ] && said 'the runtime cannot see' && ok \
  || bad "an unfilled runtime_wiring row stood the check down: $OUT"

# ── wiring that is present but ignored by git ──────────────────────────────────────────────────
# An adversarial lens found `--exclude-standard` dropping an ignored `.claude/`, so a correctly
# wired role read as unwired and the refusal named a file sitting right there. Present-and-ignored
# is a different finding from absent, and it is a warning: the role loads here and arrives with no
# clone.
fixture
printf '.claude/\n' > .gitignore
agent web_engineer
role web_engineer
run
[ "$RC" = 0 ] && said 'on disk and NOT in git' && ok \
  || bad "an ignored-but-present wiring file was refused instead of warned about: $OUT"

# ── a README and an archived role are not workers ──────────────────────────────────────────────
# The same two false positives §7 was taught by an adversarial lens in 2026-08, inherited the
# moment this section read the same directory: a file explaining the form is not a role, and a
# parked one owes the runtime nothing precisely because nothing should be able to dispatch it.
fixture
printf '# How to write a role\n\nExample: **Type**: worker · **Grade**: mid\n' > _ops/roles/README.md
mkdir -p _ops/roles/archive
printf '# Old One\n\n**Type**: worker · **Grade**: mid\n' > _ops/roles/archive/old_one.md
run; [ "$RC" = 0 ] && ok \
  || bad "a README or an archived role was asked for runtime wiring: $OUT"

# ── history is not retro-wired ─────────────────────────────────────────────────────────────────
fixture
role old_role
commit "legacy role"                 # written before the guard was wired
printf 'two\n' > src/app.js
run; [ "$RC" = 0 ] && ok || bad "a role this commit did not touch was judged: $OUT"

# ── the mutants ────────────────────────────────────────────────────────────────────────────────
mutant() {   # $1 what it breaks · $2 from · $3 to
  cp "$HERE/../templates/company-preflight.sh" "$T/mut.sh"
  M_FROM="$2" M_TO="$3" python3 - "$T/mut.sh" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return 1; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  MUT="$T/mut.sh"
}
mutant "the agent wiring unchecked" \
  '    elif not wiring_elsewhere and norm(role) not in {norm(a) for a in agents}:' '    elif False:' \
  && { fixture; role web_engineer; run
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: wiring unchecked"; }

mutant "the runtime name compared literally" \
  'elif not wiring_elsewhere and norm(role) not in {norm(a) for a in agents}:' \
  'elif not wiring_elsewhere and role not in agents:' \
  && { fixture; role web_engineer; agent web-engineer; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: the slug compared literally"; }

# The escape is one reader now — `_wiring_elsewhere` — so both mutants land in it, and both
# sections stand or fall with it. That is the point of the shared helper: the alternative was two
# copies of a regex, which is how this escape came to have two different holes in two days.
mutant "the other-runtime escape removed" \
  '        print("1")' '        pass' \
  && { fixture
       printf '# Project configuration\n\n| Setting | Value | Notes |\n|---|---|---|\n| `runtime_wiring` | `.codex/agents/` | Codex here |\n' \
         > _ops/config.md
       role web_engineer; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: the escape removed"; }

# the two holes the lens found, each as its own mutant: an example and a comment are not
# declarations, and the lines that make them so are the ones to cut
mutant "a fenced example read as a declaration" \
  '    if fenced:                                             # an example is not a declaration' \
  '    if False:' \
  && { fixture
       printf '# Project configuration\n\nFor example:\n\n```\n| `runtime_wiring` | `.codex/agents/` |\n```\n' \
         > _ops/config.md
       role web_engineer; run
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: a fenced example silenced the check"; }

mutant "a commented-out value read as a declaration" \
  'cfg = re.sub(r"<!--.*?-->", " ", cfg, flags=re.S)          # a comment is not a declaration' \
  'pass' \
  && { fixture
       printf '# Project configuration\n\n| Setting | Value |\n|---|---|\n| `runtime_wiring` | <!-- `.codex/agents/` --> |\n' \
         > _ops/config.md
       role web_engineer; run
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: a commented-out value silenced the check"; }
MUT=""

echo "role-wiring: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
