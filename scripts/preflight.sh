#!/usr/bin/env bash
# Preflight — the structural gate. Runs locally before a commit and in CI on every push.
#
# It checks shape and existence. It cannot check that a paragraph is still true — that is
# what the four lenses and the eval pass are for (AGENTS.md). Keep it small: a checker that
# cries wolf gets bypassed, and then none of it is enforced.
set -uo pipefail
cd "$(dirname "$0")/.."          # the repository root: skills/advisor/SKILL.md, its chapters and the
ROOT="$(pwd)"                    # manifests all live here, so corpus and root are one place

FAIL=0
say_fail() { printf '  \033[31m✗\033[0m %s\n' "$1"; FAIL=1; }
say_warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
say_ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }

echo "preflight"

# 1 · version agreement
sv=$(grep -m1 '^version:' skills/advisor/SKILL.md | awk '{print $2}')
pv=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["version"])' "$ROOT/.claude-plugin/plugin.json")
[ "$sv" = "$pv" ] && say_ok "version $sv" \
  || say_fail "version mismatch: skills/advisor/SKILL.md=$sv plugin.json=$pv"

# 1a · the guide template names the doors. The 2026-08-10 field report measured the cost of
#      this hole: a high-tier run hand-edited stages, recorded a 223k-token dispatch as a History
#      sentence, and created no pipeline files — because the one file every worker loads named
#      none of them. The repair form is the corpus's own measured one (a list of paths placed
#      before the alternative), and this check keeps the list from silently eroding.
# Anchored to the BLOCK, not the substring: a lens defeated the first version by leaving the
# four paths in an HTML comment while deleting the block itself — the guide stopped telling
# workers the doors and the check stayed green. Comments are stripped first, then the paths
# must sit inside the block that starts at the doors heading.
# Three further holes — CRLF disabling the range, a blank line ending the block early, and the
# starting.md half still being a bare substring — were measured on 2026-08-14 and are each a
# named mutant in `scripts/test-corpus-preflight.sh`, which is where the reasoning lives: a
# mutation test is the executable form of the claim, and saying it twice is how one copy rots.
doors_block=$(perl -0pe 's/<!--.*?-->//gs; s/\r//g' "$ROOT/templates/GUIDE-template.md" \
  | awk '/\*\*The doors — run these/{f=1; print; next} f && /^[[:space:]]*(\*\*|#)/{exit} f{print}')
if [ -z "$doors_block" ]; then
  say_fail "templates/GUIDE-template.md has no block starting with the line \
'**The doors — run these' — the measured repair for the operational-scripts hole \
(2026-08-10 report) is gone, or its heading was reworded"
else
  # only when the block was found: an empty block already failed above, and running the loop
  # over it would bury that one true refusal under four false ones.
  for door in "_ops/scripts/transition.py" "_ops/runs/" "_ops/pipelines/" "_ops/scripts/new-id.py"; do
    printf '%s' "$doors_block" | grep -qF "$door" || say_fail \
      "the doors block in templates/GUIDE-template.md no longer names $door — a guide that stops \
naming a door recreates the hole. The block is read as the heading plus the list under it, \
ending at the next line that is neither a list item nor indented, so a paragraph opened \
mid-list truncates it: check that the door is above that line, not only in the file"
  done
fi
# The day-one row installs all three into _ops/scripts/ in one move, so the anchor is one line
# naming all three. A path loose in a comment, a changelog quotation or a later sentence no
# longer satisfies it — which is precisely how the previous form was defeated.
perl -0pe 's/<!--.*?-->//gs; s/\r//g' "$ROOT/starting.md" \
  | grep -F 'transition.py' | grep -F 'new-id.py' | grep -qF 'company-preflight.sh' || say_fail \
  "starting.md has no ONE LINE naming transition.py, new-id.py and company-preflight.sh together \
— that is the day-one row installing the doors beside the guard, and splitting it across two \
lines reads here as deleting it. The guard's §14 points at _ops/scripts/transition.py, and \
installing the refusal without the door strands the next commit"

# 1a-bis · a released entry is frozen. The changelog is this repo's migration map, and its
#          0.1.0 section had been edited upward release after release — the counts, and a
#          vocabulary sweep that turned "eighteen verbs" into "eighteen doors" — so an entry
#          describing one version was quietly asserting the current corpus. Restoring it was a
#          sentence ("A historical entry is frozen"); this is the form, and the form is what
#          found the second drift. One change is permitted: a MARKED correction added as a
#          blockquote, because that is how a corpus admits an error without rewriting history
#          into something that never shipped.
python3 - <<'FREEZE' || FAIL=1
import re, subprocess, sys, pathlib
def entry(text, v):
    out, f = [], False
    for line in text.splitlines(True):
        m = re.match(r'^## (\S+)', line)
        if m:
            if m.group(1) == v:
                f = True; out.append(line); continue
            if f: break
        if f: out.append(line)
    return out
tags = subprocess.run(["git", "tag", "-l", "v*"], capture_output=True, text=True).stdout.split()
head = pathlib.Path("CHANGELOG.md").read_text(encoding="utf-8")
bad = []
for tag in tags:
    v = tag[1:]
    old = subprocess.run(["git", "show", tag + ":CHANGELOG.md"],
                         capture_output=True, text=True).stdout
    a, b = entry(old, v), entry(head, v)
    if not a or a == b:
        continue
    lost = [l for l in a if l not in b]
    added = [l for l in b if l not in a]
    if lost or not all(l.startswith(">") or not l.strip() for l in added):
        bad.append((tag, len(lost)))
for tag, n in bad:
    print("  \033[31m✗\033[0m the " + tag + " entry no longer matches what " + tag +
          " shipped (" + str(n) + " line(s) changed or lost) — a released entry is frozen; "
          "the only permitted addition is a marked correction as a blockquote")
if not bad:
    print("  \033[32m✓\033[0m " + str(len(tags)) + " released entries match their tags")
sys.exit(1 if bad else 0)
FREEZE

# 1a-ter · a generated file that nobody regenerates is a stale file with a confident header.
#          `evals/COVERAGE.md` says "edit the tree, not this file" and had drifted two suites
#          behind its own generator — in the document whose subject is how well the corpus is
#          covered. Nothing ran the generator, so nothing noticed.
if [ -f scripts/coverage-map.py ] && [ -f evals/COVERAGE.md ]; then
  before=$(md5 -q evals/COVERAGE.md 2>/dev/null || md5sum evals/COVERAGE.md | cut -d' ' -f1)
  python3 scripts/coverage-map.py >/dev/null 2>&1
  after=$(md5 -q evals/COVERAGE.md 2>/dev/null || md5sum evals/COVERAGE.md | cut -d' ' -f1)
  if [ "$before" != "$after" ]; then
    say_fail "evals/COVERAGE.md was stale — it has just been regenerated in place, so review \
and stage the diff. A file headed 'edit the tree, not this file' is only true if something runs \
the generator"
  else
    say_ok "coverage map matches its generator"
  fi
fi

# 1b · and everywhere a human wrote it. Two files agreeing proves nothing about the third: a
# release badge sat hardcoded at a version while the frontmatter moved, and the newest changelog
# heading is the other place a release quietly disagrees with itself.
cl=$(grep -m1 '^## [0-9]' "$ROOT/CHANGELOG.md" | sed 's/^## \([0-9.]*\).*/\1/')
[ "$cl" = "$sv" ] || say_fail "newest CHANGELOG heading is $cl, declared version is $sv"
for stray in $(grep -oE '\b[0-9]+\.[0-9]+\.[0-9]+\b' "$ROOT/README.md" | sort -u); do
  [ "$stray" = "$sv" ] || say_fail "README.md states version $stray — declared version is $sv"
done
# The runsheet too: N65's setup writes "you are on the current version" into a fixture guide, and
# a number a scenario depends on being *current* rots the moment a release moves without it. The
# other rows name older versions on purpose, so only the ones claiming to be current are checked.
for stray in $(grep -oE 'Operated by:\*\* Opsinist \*\*[0-9]+\.[0-9]+\.[0-9]+' "$ROOT/evals/runsheet.tsv" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -u); do
  [ "$stray" = "$sv" ] || say_fail "evals/runsheet.tsv sets a fixture to version $stray as though current — declared version is $sv"
done

# 2 · the core stays inside the budget it declares
budget=$(grep -m1 '^core_budget:' skills/advisor/SKILL.md | awk '{print $2}')
lines=$(wc -l < skills/advisor/SKILL.md | tr -d ' ')
if [ -z "$budget" ]; then
  say_fail "skills/advisor/SKILL.md declares no core_budget"
elif [ "$lines" -gt "$budget" ]; then
  say_fail "skills/advisor/SKILL.md is $lines lines, over its declared budget of $budget — move detail to a chapter"
else
  pct=$(( lines * 100 / budget ))
  say_ok "core $lines/$budget lines (${pct}%)"
  [ "$pct" -gt 90 ] && say_warn "core is at ${pct}% of its budget — moving beats squeezing"
fi

# 3 · the three files everything cites must exist
for f in GLOSSARY.md PATTERNS.md lenses.md; do
  [ -f "$f" ] || say_fail "$f is missing — the corpus cites it throughout"
done

# 4 · every chapter named in the routing table exists
python3 - <<'PY' || FAIL=1
import re, sys, pathlib
t = pathlib.Path("skills/advisor/SKILL.md").read_text(encoding="utf-8")
named = set(re.findall(r'`([a-z][a-z0-9-]*\.md)`', t))
# The core also names files that live in the *owner's* project, not in this repository, and
# they are lowercase like the chapters are. Uppercase project files (`LATER.md`,
# `docs/DECISIONS.md`) never collided; this one does. Kept as a short explicit list rather
# than a pattern, because every name added here is one the check stops guarding — if it grows
# past a couple of entries, the check is being weakened rather than corrected.
named -= {"config.md"}
missing = sorted(n for n in named if not pathlib.Path(n).exists())
if missing:
    for m in missing:
        print(f"  \033[31m✗\033[0m skills/advisor/SKILL.md routes to {m}, which does not exist")
    sys.exit(1)
print(f"  \033[32m✓\033[0m routing table: {len(named)} chapters, all present")
PY

# 5 · every command points at a chapter that exists, and declares a description
python3 - <<'PY' || FAIL=1
import re, sys, pathlib
bad = []
# The doors moved to skills/<verb>/SKILL.md in the plugin restructure and this kept globbing
# `commands/`, a directory that no longer exists — so it printed "0 commands, each a door to a
# file that exists" and passed, vacuously, for every release since. A check that cannot fail
# is the failure this file exists to catch; the count is now asserted so an empty glob is red.
cmds = sorted(p for p in pathlib.Path("skills").glob("*/SKILL.md") if p.parent.name != "advisor")
if not cmds:
    print("  \033[31m✗\033[0m no command doors found under skills/ — the glob is looking in the wrong place")
    sys.exit(1)
for p in cmds:
    t = p.read_text(encoding="utf-8")
    if not re.match(r'^---\ndescription: \S', t):
        bad.append(f"{p}: no description in frontmatter")
    for target in re.findall(r'\[`([a-z][a-z0-9-]*\.md)`\]', t):
        if not pathlib.Path(target).exists():
            bad.append(f"{p}: points at {target}, which does not exist")
for b in bad:
    print(f"  \033[31m✗\033[0m {b}")
if bad: sys.exit(1)
print(f"  \033[32m✓\033[0m {len(cmds)} commands, each a door to a file that exists")
PY

# 6 · nothing from the platform this grew out of
# Built from parts so this file does not itself contain the strings it forbids.
pat="mul""tica\\|\\bm""ops\\b"
hits=$(grep -ril "$pat" --include='*.md' --include='*.py' --include='*.sh' \
        --include='*.json' --include='*.yml' "$ROOT" 2>/dev/null | grep -v '\.git/' | grep -v CHANGELOG.md)
[ -z "$hits" ] && say_ok "no predecessor references" \
  || { echo "$hits" | while read -r f; do say_fail "$f still names the predecessor"; done; FAIL=1; }

# 7 · cross-references resolve, file *and* section
if python3 scripts/check-links.py >/tmp/pf-links 2>&1; then
  say_ok "$(tail -1 /tmp/pf-links)"
else
  grep 'FAIL:' /tmp/pf-links | while read -r l; do say_fail "$l"; done; FAIL=1
fi

# 8 · recorded facts are not past their recheck
python3 scripts/check-freshness.py >/tmp/pf-fresh 2>&1
if grep -q '^0 FAIL' /tmp/pf-fresh; then
  say_ok "$(tail -1 /tmp/pf-fresh)"
else
  grep 'FAIL:' /tmp/pf-fresh | while read -r l; do say_fail "$l"; done; FAIL=1
fi
warns=$(grep -c 'WARN:' /tmp/pf-fresh || true)
[ "${warns:-0}" -gt 0 ] && say_warn "$warns rows carry no check-date or are ageing — see check-freshness"

# 8b · no chapter outgrows the core. The core is capped because it is always loaded; a
# chapter pulled in by a trigger must not cost more than the thing that is always there, or the
# saving the cap exists for is spent on the first routing hop.
cbudget=$(grep -m1 '^chapter_budget:' skills/advisor/SKILL.md | awk '{print $2}')
if [ -z "$cbudget" ]; then
  say_fail "skills/advisor/SKILL.md declares no chapter_budget"
else
  over=0; big=""; top=0; topf=""
  for f in *.md; do
    case "$f" in README.md|CHANGELOG.md|AGENTS.md|TRADEMARKS.md|skills/advisor/SKILL.md) continue;; esac
    n=$(grep -c '' "$f")
    [ "$n" -gt "$top" ] && { top=$n; topf=$f; }
    [ "$n" -gt "$cbudget" ] && { over=$((over+1)); big="$big $f($n)"; }
  done
  if [ "$over" -gt 0 ]; then
    say_fail "$over chapter(s) over the $cbudget-line budget:$big"
  else
    say_ok "every chapter inside $cbudget lines (largest: $topf at $top)"
  fi
fi

# 9 · nothing built is tracked. A `git add -A` during a squash once swept a site build into
# this tree and shipped 928K of fonts and bundles inside a package that is markdown. The commit
# looked fine; only a file inventory showed it.
built=$(git -C "$ROOT" ls-files 2>/dev/null | grep -cE '(^|/)(dist|node_modules)/|\.(woff2?|ttf|eot|map)$|\.min\.(js|css)$' || true)
if [ "${built:-0}" -gt 0 ]; then
  say_fail "$built built files are tracked — a package of markdown ships no bundles"
  git -C "$ROOT" ls-files | grep -E '(^|/)(dist|node_modules)/|\.(woff2?|ttf|eot|map)$|\.min\.(js|css)$' | head -5 | sed 's/^/      /'
else
  say_ok "nothing built is tracked"
fi

# 10 · heuristic structure guards (never fatal)
if [ -f scripts/check-structure.py ]; then
  python3 scripts/check-structure.py 2>/dev/null | while read -r line; do
    case "$line" in FAIL:*) say_warn "structure: ${line#FAIL:}" ;; WARN:*) say_warn "structure: ${line#WARN:}" ;; esac
  done
fi

# 12 · every manifest this repo ships carries the same version — the sweep the ritual asks
#      for, held here rather than remembered (found by the lenses: a bump hit four of seven,
#      the four hid the three, and find-installs reads installs, not this tree).
ref=$(sed -n 's/^version: //p' skills/advisor/SKILL.md | head -1)
for mf in package.json gemini-extension.json .claude-plugin/plugin.json \
          .codex-plugin/plugin.json .cursor-plugin/plugin.json .kimi-plugin/plugin.json; do
  [ -f "$mf" ] || continue
  v=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$mf" | head -1)
  [ "$v" = "$ref" ] || say_fail "$mf declares $v while SKILL.md declares $ref — one bump, seven manifests"
done

# 11 · the shipped guards are exercised, not hoped: a validator whose test only runs when
#      somebody remembers is a hope with a filename (found by the lenses — both tests were
#      green and nothing ran them).
# the hook wiring: hooks.json must parse, and every command file it names must exist —
# a renamed hook script fails silently at runtime, which is the blind spot class the
# sibling paid for ("a guard must not share its sweep's blind spot")
python3 - <<'PY' || FAIL=1
import json, os, re, sys
try:
    h = json.load(open("hooks/hooks.json"))
except Exception as e:
    print(f"  \033[31m✗\033[0m hooks/hooks.json does not parse: {e}"); sys.exit(1)
bad = []
for event, rules in (h.get("hooks") or {}).items():
    for rule in rules:
        for hook in rule.get("hooks", []):
            cmd = hook.get("command", "")
            m = re.search(r"\$\{CLAUDE_PLUGIN_ROOT\}/(\S+)", cmd)
            if m and not os.path.exists(m.group(1)):
                bad.append(f"{event}: {m.group(1)} does not exist")
for b in bad: print(f"  \033[31m✗\033[0m hooks.json → {b}")
if bad: sys.exit(1)
print(f"  \033[32m✓\033[0m hook wiring: hooks.json parses, every named file exists")
PY

# a raw "(" inside a markdown URL breaks every downstream link reader — percent-encode it
raw=$(grep -rEln '\]\([^) ]*\(' --include='*.md' . 2>/dev/null | grep -v '^\./\.git' || true)
if [ -n "$raw" ]; then say_fail "raw ( in a markdown URL — percent-encode: $raw"; else say_ok "no raw parens inside markdown URLs"; fi

# CORPUS_PF_TEST is set by test-corpus-preflight.sh when it runs THIS script inside a clone to
# exercise the doors check — the clone's preflight skips the suite battery, or the suite that
# calls preflight would call itself through every clone, forever.
if [ -z "${CORPUS_PF_TEST:-}" ]; then
for t in scripts/test-transition.sh scripts/test-inventory.sh scripts/test-company-preflight.sh scripts/test-map-blocks.sh scripts/test-migrate-layout.sh scripts/test-corpus-preflight.sh scripts/test-eval-requeue.sh; do
  [ -f "$t" ] || continue
  out=$(bash "$t" 2>&1 | tail -1)
  case "$out" in
    *" 0 failed") say_ok "${t##*/}: ${out}" ;;
    *) say_fail "${t##*/}: ${out:-did not run}" ;;
  esac
done
fi

echo
[ "$FAIL" = 0 ] && { printf '\033[32mpreflight passed\033[0m\n'; exit 0; }
printf '\033[31mpreflight failed\033[0m\n'; exit 1
