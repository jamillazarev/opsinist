#!/usr/bin/env bash
# §27 of the project guard — **a mention of something inside this project is a link** — and every
# link resolves and is of a shape a vault can follow. Shown on a throwaway project in the state a
# live one was measured in: one link in the whole of `_ops/` against twenty-two bare ids, and nine
# tasks naming an assignee with no way to reach the role.
#
# **Four code mutants**: the id left unlinked (the bare-id half switched off), the person field
# ignored (the edge between the roster and the work — the one the measured project was missing),
# a dead link accepted, and a declaration judged as a mention (a `task:` line and a `**Task**` cell
# are what the guard's own readers parse — linked, they hand a slug back).
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
said() { [ "$(printf '%s' "$OUT" | grep -cF -- "$1")" -gt 0 ]; }
run() { git add -A; OUT=$(bash _ops/scripts/preflight.sh 2>&1); RC=$?; }
commit() { git add -A; git commit -qm "$1" --no-verify; }

task() {   # $1 id · $2 assignee · $3.. extra body lines
  local id="$1" who="$2"; shift 2
  { printf '# %s — a thing\n\n**Type**: feature · **Status**: review\n**Assignee**: %s\n\n' "$id" "$who"
    printf '## Ready when\n\nThe thing is not there.\n\n## Done when\n\n- [ ] it is\n\n'
    for l in "$@"; do printf '%s\n' "$l"; done
    printf '\n## History\n\n- 2026-09-18 — started\n'
  } > "_ops/tasks/$id-thing.md"
}

fixture() {
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/tasks" "$T/p/_ops/roles" "$T/p/_ops/scripts" "$T/p/src"
  cd "$T/p" || exit 1
  git init -q . && git config user.email t@f.t && git config user.name T
  for f in ROADMAP TEAM TOOLING DECISIONS ARCHITECTURE; do printf '# %s\n' "$f" > "_ops/$f.md"; done
  printf '# Guide\n\n**Operated by** Opsinist **0.2.19**\n' > CLAUDE.md
  printf '# Web Engineer\n\n**Type**: worker · **Grade**: mid\n' > _ops/roles/web_engineer.md
  printf 'one\n' > src/app.js
  cp "${MUT:-$HERE/../templates/company-preflight.sh}" _ops/scripts/preflight.sh
  cp "$HERE/transition.py" "$HERE/new-id.py" _ops/scripts/ 2>/dev/null || true
  commit "chore: opsinist init"
}

# ── the measured case: a name that resolves, written as text ────────────────────────────────────
fixture
task T-AAAAAA "Web Engineer"
run
[ "$RC" = 1 ] && said 'does not link' && said 'link-ids.py --write' && ok \
  || bad "an assignee naming a role file was accepted unlinked: $OUT"

# ── the door fixes exactly what the gate refuses ────────────────────────────────────────────────
python3 "$HERE/link-ids.py" . --write > /dev/null 2>&1
run; [ "$RC" = 0 ] && ok || bad "the door's own output did not satisfy the gate: $OUT"
commit "linked"

# ── an id mentioned in prose is the same rule ──────────────────────────────────────────────────
task T-BBBBBB '[Web Engineer](../roles/web_engineer.md)' 'This waits for T-AAAAAA.'
run; [ "$RC" = 1 ] && said 'T-AAAAAA' && ok || bad "a bare id in prose was accepted: $OUT"
python3 "$HERE/link-ids.py" . --write > /dev/null 2>&1
run; [ "$RC" = 0 ] && ok || bad "the linked id still failed: $OUT"
commit "second task"

# ── what must stay as written: History, a declaration, a heading, a fence ──────────────────────
fixture
task T-CCCCCC '[Web Engineer](../roles/web_engineer.md)'
commit "one task"
mkdir -p _ops/runs
{ printf '# R-CCCCCC\n\n| | |\n|---|---|\n| **Task** | T-CCCCCC · a thing |\n'
  printf '| **Outcome** | completed |\n| **Attempt** | 1 |\n| **Model that answered** | m |\n\n'
  printf '| `input` | `output` | `cache_read` | `cache_write` |\n|---|---|---|---|\n| 1 | 1 | 0 | 0 |\n'
} > _ops/runs/R-CCCCCC.md
printf -- '- 2026-09-18 — reviewed by qa, see T-CCCCCC\n' >> _ops/tasks/T-CCCCCC-thing.md
run; [ "$RC" = 0 ] && ok \
  || bad "a run's Task declaration or a History line was judged — both must stay as written: $OUT"

# ── a link that resolves to nothing, and one no vault can follow ───────────────────────────────
# **Written into `_ops/MAP.md` and not `DECISIONS.md`**: the decision log is append-only and §3
# refuses a rewrite of it, so a fixture that keeps overwriting it measures that rule instead of
# this one — a case that fails for the wrong reason is a case that proves nothing.
# **A backticked path is a warning, not a refusal**, and the asymmetry is deliberate: a shipped
# template's prose names project files on purpose and cannot carry a project-relative link without
# breaking the skill's own checker. An id and a person's name have no such double life.
fixture
printf '# Map\n\nSee `_ops/ROADMAP.md`.\n' > _ops/MAP.md
run; [ "$RC" = 0 ] && said '_ops/ROADMAP.md' && said 'where a link would be an edge' && ok \
  || bad "a backticked internal path was neither warned about nor let through: $OUT"

printf '# Map\n\nSee [the roadmap](ROADMAP.md) and [the gone one](GONE.md).\n' > _ops/MAP.md
run; [ "$RC" = 1 ] && said 'is not there' && ok || bad "a dead link outside a task was accepted: $OUT"

printf '# Map\n\nSee [the roadmap](/Users/somebody/_ops/ROADMAP.md).\n' > _ops/MAP.md
run; [ "$RC" = 1 ] && said 'no vault can follow' && said 'absolute path' && ok \
  || bad "an absolute path was accepted as a link: $OUT"

printf '# Map\n\nSee [the roadmap](my file.md).\n' > _ops/MAP.md
run; [ "$RC" = 1 ] && said 'unencoded space' && ok || bad "an unencoded space was accepted: $OUT"

printf '# Map\n\nSee [the roadmap](ROADMAP.md) — and https://example.com/a%%20b.md is not ours.\n' > _ops/MAP.md
run; [ "$RC" = 0 ] && ok || bad "a resolving link, or an outside URL, was refused: $OUT"

# ── history is not retro-linked ────────────────────────────────────────────────────────────────
fixture
printf '# Decisions\n\nOld prose naming `_ops/ROADMAP.md` from before the rule.\n' > _ops/DECISIONS.md
commit "legacy prose"
printf 'two\n' > src/app.js
run; [ "$RC" = 0 ] && ok || bad "a file this commit did not touch was judged: $OUT"

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
mutant "the bare id half switched off" 'if ident != own and ident in ents:' 'if False:' \
  && { fixture; task T-DDDDDD '[Web Engineer](../roles/web_engineer.md)'
       commit "one"; task T-EEEEEE '[Web Engineer](../roles/web_engineer.md)' 'Waits for T-DDDDDD.'
       run; [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: bare ids unchecked"; }

mutant "the person field ignored" 'if pm and norm(pm.group(1)) not in OPEN and norm(pm.group(1)) in people:' 'if False:' \
  && { fixture; task T-FFFFFF "Web Engineer"; run
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: the roster edge unchecked"; }

mutant "a dead link accepted" '                    dead.append(target)' '                    pass' \
  && { fixture; printf '# Map\n\nSee [the gone one](GONE.md).\n' > _ops/MAP.md; run
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: dead links accepted"; }

# **The declaration is judged in a file §27 actually reads** — `_ops/runs/` is skipped whole, so a
# fixture that puts it there measures the skip list and not the declaration rule.
mutant "a declaration judged as a mention" 'if fenced or st.startswith("#") or DECLARATION.search(line):' \
                                           'if fenced or st.startswith("#"):' \
  && { fixture; task T-GGGGGG '[Web Engineer](../roles/web_engineer.md)'; commit "one"
       printf '# Map\n\ntask: T-GGGGGG\n' > _ops/MAP.md
       run; [ "$RC" = 1 ] && ok \
       || bad "the suite did not catch the mutant: a declaration judged as a mention"; }
MUT=""

echo "links-hard: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
