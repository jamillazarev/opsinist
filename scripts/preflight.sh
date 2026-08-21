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
# The block is the heading plus the LIST under it. Extracted in python because the rule needs
# one line of lookahead: a blank line ends the block unless the next non-blank line is still a
# list item or an indented continuation. The awk version that preceded it was measured failing
# both ways on 2026-08-14 — a list using `*` markers reported "has no block" while the heading
# sat there unchanged, and a gutted guide passed by putting the four paths on an indented line
# two blank lines below a one-item list, because blank lines never terminated and any indented
# line was accepted as part of the block.
doors_block=$(python3 - "$ROOT/templates/GUIDE-template.md" <<'BLOCK'
import re, sys
raw = open(sys.argv[1], encoding="utf-8-sig").read()
raw = re.sub(r"<!--.*?-->", "", raw, flags=re.S).replace("\r", "")
lines = raw.split("\n")
heads = [i for i, l in enumerate(lines) if l.startswith("**The doors — run these")]
if not heads:
    sys.exit(0)
if len(heads) > 1:
    # A second copy of the heading is a decoy: an illustrative complete block early hid a
    # gutted real section, and the mirror — the real block second — was falsely refused.
    print("!!DUPLICATE-HEADING")
    sys.exit(0)
start = heads[0]
ITEM = re.compile(r"^[ \t]*([-*+]|[0-9]+[.)])[ \t]")
CONT = re.compile(r"^[ \t]+\S")
# The first NON-BLANK line after the heading must be a list ITEM: an indented sentence alone,
# with no list at all, was being accepted as the block. Blanks are skipped first — requiring the
# item immediately refused the ordinary markdown form (a blank line between a lead-in and its
# list, which is what markdownlint MD032 and prettier both produce) and misdiagnosed it as a
# missing heading, which is the class the ast door-check was withdrawn for.
j = start + 1
while j < len(lines) and not lines[j].strip():
    j += 1
if j >= len(lines) or not ITEM.match(lines[j]):
    sys.exit(0)
out, i = [], j
while i < len(lines):
    l = lines[i]
    if ITEM.match(l) or CONT.match(l):
        out.append(l); i += 1; continue
    if not l.strip():
        # a blank line ends it unless the list resumes immediately after
        j = i + 1
        while j < len(lines) and not lines[j].strip():
            j += 1
        # only a LIST ITEM resumes the block. An indented line after a blank is a new
        # paragraph or a code block in markdown, never a continuation — and accepting it was
        # exactly how a gutted guide passed with the four paths two blank lines below.
        if j < len(lines) and ITEM.match(lines[j]):
            i = j; continue
    break
print("\n".join(out))
BLOCK
)
if [ "$doors_block" = "!!DUPLICATE-HEADING" ]; then
  say_fail "templates/GUIDE-template.md has the doors heading more than once — one of them is \
a decoy or an example, and the check cannot tell which is the section workers read. Keep one"
elif [ -z "$doors_block" ]; then
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
# Measured 2026-08-14: deleting the row and appending "if company-preflight.sh, transition.py
# or new-id.py is ever missing, ask your advisor" satisfied the three greps. The row is a table
# row that installs the three INTO `_ops/scripts/`, so that is what is required.
# No `grep -q` anywhere in this chain: under `set -o pipefail` an early-exiting `grep -q`
# SIGPIPEs its upstream and the pipeline returns that failure even when the phrase MATCHED —
# this repo's own machine note, and measured to fire deterministically once the input passes a
# few hundred matching lines. The result is captured instead, so nothing exits early.
dayone_row=$(perl -0pe 's/<!--.*?-->//gs; s/\r//g' "$ROOT/starting.md" \
  | grep '^[[:space:]]*|' | grep -F 'transition.py' | grep -F 'new-id.py' \
  | grep -F 'company-preflight.sh' | grep -F '_ops/scripts/' || true)
[ -n "$dayone_row" ] || say_fail \
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
    # Sequence comparison, not set membership: `in`-tests made reordering the whole entry
    # invisible, and deleting one of N identical lines too — measured 2026-08-14, reversing all
    # 157 lines of the 0.1.0 body passed. The one permitted change is a contiguous run of
    # blockquote lines added anywhere, so those are stripped from the new side before comparing.
    # Terminators dropped: the file's own trailing newline flips the last entry's final
    # element and refused an otherwise byte-identical entry.
    a = [l.rstrip("\n") for l in a]
    b = [l.rstrip("\n") for l in b]
    # Blockquote lines absent from the tagged text are the permitted correction and are
    # ignored here. This comparison cannot see a correction that was ADDED after the tag and
    # later deleted — HEAD-against-tag makes that indistinguishable from one never written.
    # That case is held by the staged-diff check below instead.
    stripped = [l for l in b if not (l.startswith(">") and l not in a)]
    while stripped and not stripped[-1].strip():
        stripped.pop()
    a_trim = list(a)
    while a_trim and not a_trim[-1].strip():
        a_trim.pop()
    if [l for l in stripped if l.strip()] != [l for l in a_trim if l.strip()]:
        bad.append(tag)
for tag in bad:
    print("  \033[31m✗\033[0m the " + tag + " entry no longer matches what " + tag +
          " shipped — reordered, rewritten or lost. A released entry is frozen; the only "
          "permitted change is a marked correction added as a blockquote")
if not tags:
    # A green tick over zero tags is the vacuous pass this check exists to avoid elsewhere.
    # Measured: a shallow or tag-stripped checkout — which is what `actions/checkout` gives by
    # default — verified nothing and said so in the affirmative.
    print("  \033[33m!\033[0m no tags in this checkout, so no released entry was verified — "
          "fetch tags (CI: `fetch-depth: 0`) or this check is decoration")
elif not bad:
    print("  \033[32m✓\033[0m " + str(len(tags)) + " released entries match their tags")
sys.exit(1 if bad else 0)
FREEZE

# 1a-ter · a released entry's date must be the date it SHIPPED, not the date it was written.
#          Measured 2026-08-22: 0.2.8 and 0.4.7 both said 2026-08-16 while their tags were cut on
#          2026-08-20 — four days, and a reader takes the heading for the shipping date. The gap
#          is structural rather than careless: this repository's own law is that the tag waits for
#          the owner's word, so writing-date and shipping-date differ by however long that takes.
#          The repair is that the date is set AT THE TAG (AGENTS.md → the release ritual), and this
#          is the form that notices when it was not.
#          FROM THE CUTOFF FORWARD, like every other dated rule here: older entries carry ±1-day
#          gaps that are midnight-and-timezone artifacts (v0.1.16 tagged 22:54, v0.1.19 at 00:56),
#          and retro-editing frozen entries to satisfy a new check is exactly what the frozen rule
#          forbids. A marked correction blockquote naming the tag date satisfies this check too.
python3 - <<'DATEPY' || FAIL=1
import re, subprocess, sys, pathlib
CUTOFF = "2026-08-22"
text = pathlib.Path("CHANGELOG.md").read_text(encoding="utf-8")
heads = {}
for m in re.finditer(r"^## (\d+\.\d+\.\d+) — (\d{4}-\d\d-\d\d)\s*$", text, re.M):
    heads[m.group(1)] = m.group(2)
raw = subprocess.run(["git", "for-each-ref", "--format=%(refname:short) %(creatordate:short)",
                      "refs/tags/v*"], capture_output=True, text=True).stdout
bad = []
for line in raw.split("\n"):
    if not line.strip():
        continue
    tag, tdate = line.split()
    if tdate < CUTOFF:
        continue
    ver = tag[1:]
    entry = heads.get(ver)
    if entry is None or entry == tdate:
        continue
    # a marked correction naming the tag's date is the permitted answer
    sec = re.search(r"^## " + re.escape(ver) + r" — .*?(?=^## )", text, re.S | re.M)
    if sec and re.search(r"^>.*" + re.escape(tdate), sec.group(0), re.M):
        continue
    bad.append(f"{ver}: entry says {entry}, tag cut {tdate}")
for b in bad:
    print("  \033[31m✗\033[0m " + b + " — a changelog date is read as the date the version "
          "SHIPPED. Set it when the tag is cut, or add a marked correction naming the tag's date")
sys.exit(1 if bad else 0)
DATEPY


# 1a-ter · a generated file that nobody regenerates is a stale file with a confident header.
#          `evals/COVERAGE.md` says "edit the tree, not this file" and had drifted two suites
#          behind its own generator — in the document whose subject is how well the corpus is
#          covered. Nothing ran the generator, so nothing noticed.
# `--check` and not a regeneration: the first version of this ran the generator in place, so a
# checker mutated the tree it was checking — a failed preflight would leave uncommitted changes
# behind, and a read-only checkout could not run it at all.
if [ -f scripts/coverage-map.py ] && [ -f evals/COVERAGE.md ]; then
  if python3 scripts/coverage-map.py --check >/dev/null 2>&1; then
    say_ok "coverage map matches its generator"
  else
    say_fail "evals/COVERAGE.md is stale — run \`python3 scripts/coverage-map.py\` and stage the \
result. A file headed 'edit the tree, not this file' is only true if something runs the generator"
  fi
fi

# 1a-quater · a correction, once committed, is not deleted. The freeze above compares HEAD
#             against each tag, so a blockquote added after the tag and removed later looks
#             exactly like one never written — and a correction is where this repository
#             admits an error, which is the last thing that should be quietly removable.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  gone_q=$( ( git diff --cached -U0 -- CHANGELOG.md 2>/dev/null || true ) \
            | grep '^-' | grep -v '^--- ' | sed 's/^-//' | grep -c '^>' || true)
  back_q=$( ( git diff --cached -U0 -- CHANGELOG.md 2>/dev/null || true ) \
            | grep '^+' | grep -v '^+++ ' | sed 's/^+//' | grep -c '^>' || true)
  if [ "${gone_q:-0}" -gt "${back_q:-0}" ]; then
    say_fail "this commit removes $((gone_q - back_q)) correction line(s) from CHANGELOG.md — \
a blockquote note under a released entry is how this repository admits an error, and it is not \
deletable. Add a further correction instead"
  fi
fi

# 1b · and everywhere a human wrote it. Two files agreeing proves nothing about the third: a
# release badge sat hardcoded at a version while the frontmatter moved, and the newest changelog
# heading is the other place a release quietly disagrees with itself.
cl=$(grep -m1 '^## [0-9]' "$ROOT/CHANGELOG.md" | sed 's/^## \([0-9.]*\).*/\1/')
[ "$cl" = "$sv" ] || say_fail "newest CHANGELOG heading is $cl, declared version is $sv"

# 1b-bis · a version ahead of its last tag is a release being prepared, and this repository's own
#          law is that lenses read anything of consequence. That law lived in `CLAUDE.md` as
#          prose while the SIBLING project's preflight asked for it out loud — and this release
#          took nine lens passes without its own checker mentioning one. Prose where a form was
#          already written next door.
last_tag=$(git describe --tags --abbrev=0 2>/dev/null || true)
if [ -n "$last_tag" ]; then
  tag_ver=$(git show "${last_tag}:skills/advisor/SKILL.md" 2>/dev/null \
            | grep -m1 '^version:' | tr -dc '0-9.')
  if [ -n "$tag_ver" ] && [ "$tag_ver" != "$sv" ]; then
    say_warn "releasing $sv: run the four review lenses over ${last_tag}..HEAD before tagging, \
and record the eval state in the entry (AGENTS.md → the release ritual). Neither is checkable \
from here — this line exists so the question is asked out loud rather than remembered"
    ( git diff --quiet "$last_tag" -- evals/runsheet.tsv 2>/dev/null ) \
      && say_warn "version bumped $tag_ver → $sv and evals/runsheet.tsv is unchanged — a release \
that adds behaviour and no scenario measures the new behaviour with the old questions"
  fi
fi
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
# **Scope is the repository, not the directory.** This walked the filesystem, so ANY file under
# the root tripped it — including ignored caches written by tools the author does not control.
# Measured 2026-08-21: a third-party plugin cached a path to a neighbouring checkout in an
# ignored `.impeccable/` file and turned preflight red, with no edit to this repository's own
# work that could clear it. The rule is about what this repository SAYS, so the scope is what
# git considers its work: tracked plus untracked-not-ignored, which keeps a brand-new file that
# has not been `git add`ed still in range while putting ignored litter out of it.
# `git grep` and not a file list: a `$(git ls-files -z)` first attempt looked right and matched
# NOTHING — command substitution **discards NUL bytes**, so the whole -z stream collapsed into
# one impossible filename and the gate passed everything. Caught by its own mutant, which is the
# only reason it is not shipping blind. `--untracked` keeps a not-yet-added file in range while
# `--exclude-standard` (its default) keeps ignored litter out, and git's own matcher is the same
# on every machine — unlike `grep`, which is ugrep at this prompt and BSD inside a script.
hits=$(git -C "$ROOT" grep -lI --untracked -i -e "$pat" \
        -- '*.md' '*.py' '*.sh' '*.json' '*.yml' 2>/dev/null | grep -v CHANGELOG.md || true)
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
# A dated round must name the CONFIG its rate is a claim about. The runsheet's own header says it
# — "The rate a row produces is a claim about its tier" — and five of five dated entries named no
# player anywhere in their bodies, including the 103×5 round whose 26.3% is quoted across the
# corpus. Borrowed from `smevals`, which makes the config a first-class object beside the eval, the
# task and the grader; here it is one line, because the gap was never the model of the thing, it
# was that nobody wrote it down. `unknown` is an accepted value, as everywhere else.
# **The checker's own failure is a failure.** This block redirected with `2>/dev/null`, never read
# the exit code, and treated an empty output as "no violations" — so any crash inside it (a typo, a
# regex error, a future edit) silently disarmed the gate while preflight printed nothing at all.
# The class this corpus keeps meeting: a gate that cannot fail loudly is a gate that has stopped.
# Measured 2026-08-21 (pass twelve).
if [ -f evals/RUNS.md ]; then
  _cfg=$(mktemp); _cfge=$(mktemp)
  python3 - > "$_cfg" 2> "$_cfge" <<'RUNSPY'
import re, sys
t = open("evals/RUNS.md", encoding="utf-8").read()
bad = []
# FROM THE DAY THE RULE ARRIVED, not backwards. 27 entries predate it, their artifacts are gone,
# and demanding `unknown` in each would be 27 retro-edits to records nobody can verify — a rule
# that asks for that is a rule someone deletes. Same law this repository applies to its own guard:
# enforce what a commit CREATES, not what the project already holds.
CUTOFF = "2026-08-16"
for p in re.split(r"\n(?=## 20\d\d-)", t):
    m = re.match(r"## (20\d\d-\d\d-\d\d)", p)
    if not m or m.group(1) < CUTOFF:
        continue
    head = p.split("\n")[0]
    # A NON-SPACE VALUE, not the bare label. `**Config**:` with nothing after it satisfied the
    # substring test — the substring-not-value class this same release names as repaired twice
    # elsewhere. `unknown` still passes, by design: it is an answer.
    if not re.search(r"\*\*Config\*\*:[ \t]*\S", p):
        bad.append(head[:70])
print("\n".join(bad))
RUNSPY
  _cfg_rc=$?
  [ "$_cfg_rc" -eq 0 ] || say_fail "the **Config** checker itself exited $_cfg_rc — its silence \
means nothing until it runs: $(head -c 200 "$_cfge" | tr '\n' ' ')"
  while IFS= read -r _e; do
    [ -n "$_e" ] && say_fail "the round \"$_e\" names no **Config** value — a rate is a claim about \
a corpus AND a model, and this entry does not say which model. Add one line: \`**Config**: player \
<model> · judge <model> · N=<n>\`, with \`unknown\` where it cannot be recovered"
  done < "$_cfg"
  rm -f "$_cfg" "$_cfge"
fi

# No shell script in this repository may put text in command position. This is the form for the
# defect that shipped on 2026-08-16: a deleted check left its heredoc body behind, the body was a
# `$( … )` at line start, and the pre-commit hook EXECUTED a file named by a link inside a task.
# `bash -n` passes on that shape — measured — so the syntax check cannot stand in for this one.
# A lens found it; this is so the next one is found by a run.
# **Not behind `CORPUS_PF_TEST`.** It was, and that flag is set by the one suite in this repository
# that runs preflight inside a clone — so the only place able to observe whether this gate GOES RED
# was the one place guaranteed to skip it. That is how `fail=1` survived: no test could reach the
# block. The flag exists to stop the suite battery recursing, not to skip checks; this check spawns
# no suite, so it runs always. Found by the completeness critic, 2026-08-21 (pass twelve).
_se=$(python3 scripts/check-shell-exec.py templates/*.sh scripts/*.sh 2>&1); _se_rc=$?
if [ "$_se_rc" -eq 0 ]; then
  say_ok "$(printf '%s' "$_se" | sed 's/^  //')"
else
  # TWO breaks lived in these four lines, and the gate exited 0 through both — measured
  # 2026-08-21 by two lenses independently. (1) `fail=1` set a variable this file does not
  # read: the flag is `FAIL`, so the belt was fastened to nothing. (2) the `say_fail` calls
  # sat on the RIGHT of a pipe, where a subshell owns them, so even the correct name would
  # have died with it. A gate that prints its findings in red and then says `preflight
  # passed` is worse than no gate: it manufactures the evidence that it held.
  while IFS= read -r _l; do
    say_fail "$_l"
  done < <(printf '%s\n' "$_se" | grep '✗' | sed 's/^  ✗ //')
  FAIL=1
fi

# Every suite in scripts/ must be run by something, and the exclusion list is DECLARED here so it
# can be checked rather than hidden in a `grep -v` further down. The previous form promised this
# and did not do it: its body fired only for the literal string `test-audit-gate.sh` and fell
# through silently for everything else, so a second exclusion could be added to the battery's own
# `grep -v` with nothing objecting — the roll-call had not gone away, it had moved from the
# inclusion list to the exclusion list where nothing guarded it. Measured 2026-08-15 (pass ten).
BATTERY_EXCLUDES="test-audit-gate.sh"
for _s in scripts/test-*.sh; do
  [ -f "$_s" ] || continue
  _b=${_s##*/}
  case " $BATTERY_EXCLUDES " in
    *" $_b "*)
      # excluded from the battery, so something else must run it — say which, or refuse
      grep -q "$_b" .github/workflows/*.yml 2>/dev/null \
        || say_fail "$_b is excluded from the suite battery and named in no workflow — nothing runs it" ;;
  esac
done

# exercise the doors check — the clone's preflight skips the suite battery, or the suite that
# calls preflight would call itself through every clone, forever.
if [ -z "${CORPUS_PF_TEST:-}" ]; then
: > /tmp/.pf-suites.$$
# DISCOVERED, not listed. A hardcoded roll-call is the rot surface §1 warns about wearing a
# script's clothes: a suite added and not added HERE never runs, and the green tick says
# otherwise. Measured next door 2026-08-15 — `test-preflight-checks.sh`, the suite whose whole
# job is mutation-testing the guard's own checks, had been absent from that repo's CI list since
# it was written. The exclusions come from `BATTERY_EXCLUDES` above, which the loop up there
# checks — a second `grep -v` here would be a silent exclusion again.
#
# A GLOB, not `$(ls …)`: the unquoted command substitution word-splits, so a suite whose filename
# holds a space was never run and never mentioned while preflight reported green — verbatim the
# failure the comment above says this form fixed, in the commit that wrote it. Measured 2026-08-15
# (pass ten), and it is the same shape the sibling guard spent this whole range converting away
# from in ten places.
for t in scripts/test-*.sh; do
  [ -f "$t" ] || continue
  case " $BATTERY_EXCLUDES " in *" ${t##*/} "*) continue;; esac
  out=$(bash "$t" 2>&1 | tail -1)
  printf '%s %s\n' "${t##*/}" "$(printf '%s' "$out" | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+')" \
    >> /tmp/.pf-suites.$$
  case "$out" in
    *" 0 failed") say_ok "${t##*/}: ${out}" ;;
    *) say_fail "${t##*/}: ${out:-did not run}" ;;
  esac
done

# A suite size quoted in prose has now rotted four times in one release — 5/5 for a 7-case
# suite, 21/21 for 23, 23/23 for 26, 8/8 for 15. Prose does not hold numbers, so the numbers
# are checked. Only the UNRELEASED changelog entry and the newest RUNS entry are read: older
# entries correctly describe the suite as it was, and the frozen-entry check above holds them.
python3 - "$sv" /tmp/.pf-suites.$$ <<'SUITES' || FAIL=1
import re, sys, pathlib
version, sizes_file = sys.argv[1], sys.argv[2]
actual = {}
for line in open(sizes_file):
    parts = line.split()
    if len(parts) == 2 and parts[1].isdigit():
        actual[parts[0]] = int(parts[1])
# Both homes, because the comment above always said both and the code read one. And any
# `N/M` beside a suite name, not only `N/N` — a "12/12 → 18/18" pair rotted invisibly under
# a backreference that required the halves to match.
regions = []
text = pathlib.Path("CHANGELOG.md").read_text(encoding="utf-8")
m = re.search(r"^## " + re.escape(version) + r"\b.*?(?=^## |\Z)", text, re.S | re.M)
if m:
    regions.append(("the " + version + " changelog entry", m.group(0)))
runs = pathlib.Path("evals/RUNS.md")
if runs.exists():
    rt = runs.read_text(encoding="utf-8")
    # The newest DATED entry, not the last heading: RUNS.md also carries undated prose
    # sections at the bottom, and taking the last heading pointed the check at one of those —
    # silently, since it prints nothing on success. One more appended section would have
    # disabled this half permanently.
    dated = re.findall(r"^## \d{4}-\d{2}-\d{2}.*?(?=^## |\Z)", rt, re.S | re.M)
    if dated:
        regions.append(("the newest evals/RUNS.md entry", dated[-1]))
    else:
        print("  \033[33m!\033[0m evals/RUNS.md has no dated entry — its counts went unchecked")
bad = []
for where, body in regions:
    for suite, a, b in re.findall(r"(test-[a-z-]+\.sh)[^\n]{0,40}?(\d+)/(\d+)", body):
        n = actual.get(suite)
        if n is None or a != b:      # a mutant score like 6/15 is a different claim
            continue
        if int(a) != n:
            bad.append((where, suite, a, n))
for where, suite, quoted, n in bad:
    print(f"  \033[31m✗\033[0m {where} says {suite} is {quoted}/{quoted}; "
          f"it is {n}. A count in prose is a claim like any other")
sys.exit(1 if bad else 0)
SUITES
rm -f /tmp/.pf-suites.$$
fi

echo
[ "$FAIL" = 0 ] && { printf '\033[32mpreflight passed\033[0m\n'; exit 0; }
printf '\033[31mpreflight failed\033[0m\n'; exit 1
