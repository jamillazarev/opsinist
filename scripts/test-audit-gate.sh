#!/usr/bin/env bash
# Mutation tests for hooks/audit-gate.py — the same discipline as preflight §13: every rule
# is shown denying the mutant AND passing the honest twin, or the gate is a sentence.
#   bash scripts/test-audit-gate.sh
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
GATE=hooks/audit-gate.py
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT

# a mess-shaped repo: tracked files, no guide, no list
R="$T/repo"; mkdir -p "$R/src" "$R/docs"
printf 'x=1\n' > "$R/src/util.py"; printf 'notes\n' > "$R/notes.txt"
git -C "$R" init -q && git -C "$R" add -A && \
  git -C "$R" -c user.email=t@t -c user.name=t commit -qm wip

# transcripts: one that engaged the skill, one that never did
TE="$T/engaged.jsonl";  printf '{"type":"assistant","x":{"skill":"opsinist:advisor"}}\n' > "$TE"
TN="$T/cold.jsonl";     printf '{"type":"assistant","text":"hello"}\n' > "$TN"

pass=0; fail=0
check() { # name expected_rc payload
  local name=$1 want=$2 payload=$3 rc
  printf '%s' "$payload" | python3 "$GATE" >/dev/null 2>&1; rc=$?
  if [ "$rc" = "$want" ]; then pass=$((pass+1));
  else fail=$((fail+1)); echo "FAIL: $name (want $want, got $rc)"; fi
}
pl() { # tool file_path-or-command transcript
  case $1 in
    Bash) printf '{"tool_name":"Bash","tool_input":{"command":%s},"cwd":"%s","transcript_path":"%s"}' \
            "$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$2")" "$R" "$3";;
    *)    printf '{"tool_name":"%s","tool_input":{"file_path":"%s"},"cwd":"%s","transcript_path":"%s"}' \
            "$1" "$2" "$R" "$3";;
  esac
}

check "tracked write, no list, engaged → deny"        2 "$(pl Write "$R/src/util.py" "$TE")"
check "tracked edit, no list, engaged → deny"         2 "$(pl Edit "$R/notes.txt" "$TE")"
check "new untracked file (the list itself) → allow"  0 "$(pl Write "$R/LATER.md" "$TE")"
check "session never opened the skill → allow"        0 "$(pl Write "$R/src/util.py" "$TN")"
check "bash rm in phase → deny"                       2 "$(pl Bash "rm notes.txt notes-final-v2.txt" "$TE")"
check "bash git add+commit in phase → deny"           2 "$(pl Bash "git add -A && git commit -m x" "$TE")"
check "bash sed -i in phase → deny"                   2 "$(pl Bash "sed -i '' s/a/b/ src/util.py" "$TE")"
check "bash read-only → allow"                        0 "$(pl Bash "ls -la && git log --oneline && cat notes.txt" "$TE")"
check "bash grep 'rm' as substring → allow"           0 "$(pl Bash "grep -rn format src/" "$TE")"

printf '# the honest twin: the list exists\n' > "$R/LATER.md"
check "tracked write AFTER the list, engaged → allow" 0 "$(pl Write "$R/src/util.py" "$TE")"
check "bash rm AFTER the list, engaged → allow"       0 "$(pl Bash "rm notes.txt" "$TE")"
rm "$R/LATER.md"

printf '**Operated by:** Opsinist 0.0.0\n' > "$R/CLAUDE.md"
mkdir -p "$R/_ops/tasks"
check "operated repo (guide names Opsinist) → allow"  0 "$(pl Write "$R/_ops/tasks/T-9.md" "$TE")"
rm "$R/CLAUDE.md"

# A repository somebody ELSE operates is not an unoperated one. Measured 2026-08-02: with a
# sibling operations skill installed alongside this one, a bare "what's next?" in a workspace
# that skill manages routed here, and the takeover flow ran against a project that had an owner.
printf '# Tonic\n\nOperated by **another-ops 0.2.0**. Workspace: `x`.\n' > "$R/CLAUDE.md"
check "guide declares ANOTHER operator → allow"      0 "$(pl Write "$R/src/util.py" "$TE")"
rm "$R/CLAUDE.md"
printf '# Upgrades\n\n- 2026-07-24 · another-ops 0.2.0 · applied\n' > "$R/UPGRADES.md"
check "another system's migration log alone → allow" 0 "$(pl Write "$R/src/util.py" "$TE")"
rm "$R/UPGRADES.md"
printf '# Notes\n\nNothing here declares an operator.\n' > "$R/CLAUDE.md"
check "a guide declaring no operator still gates"    2 "$(pl Write "$R/src/util.py" "$TE")"
rm "$R/CLAUDE.md"

# A guest owes no debt list (entering.md), so the collaboration furniture stands the gate down.
# Each signal is shown alone, because any one of them is enough and a bug in one would hide
# behind the others.
printf '# Contributing\n' > "$R/CONTRIBUTING.md"
check "guest signal: CONTRIBUTING → allow"            0 "$(pl Write "$R/src/util.py" "$TE")"
rm "$R/CONTRIBUTING.md"
mkdir -p "$R/.github"; printf '* @acme/maintainers\n' > "$R/.github/CODEOWNERS"
check "guest signal: CODEOWNERS → allow"              0 "$(pl Write "$R/src/util.py" "$TE")"
rm "$R/.github/CODEOWNERS"
printf '## What changed\n' > "$R/.github/pull_request_template.md"
check "guest signal: PR template → allow"             0 "$(pl Write "$R/src/util.py" "$TE")"
rm -rf "$R/.github"
check "furniture removed → deny again"                2 "$(pl Write "$R/src/util.py" "$TE")"

# --- the two measured forms: outward and rule-home, scoped to operated trees ------------
printf '**Operated by:** Opsinist 0.0.0\n' > "$R/CLAUDE.md"
printf '# later\n' > "$R/LATER.md"
check "outward: git push in operated tree → deny"     2 "$(pl Bash "git push origin main" "$TE")"
check "outward: the retry does not pass → deny again" 2 "$(pl Bash "git push origin main" "$TE")"
check "outward: gh release create → deny"             2 "$(pl Bash "gh release create v1 --notes hi" "$TE")"
check "outward: deploy → deny"                        2 "$(pl Bash "npm run build && flyctl deploy" "$TE")"
check "outward: --dry-run is a read → allow"          0 "$(pl Bash "git push --dry-run origin main" "$TE")"
check "outward: local commit untouched → allow"       0 "$(pl Bash "git add -A && git commit -m x" "$TE")"
outward_off() { printf '%s' "$(pl Bash "git push origin main" "$TE")" | OPSINIST_OUTWARD_GATE=off python3 "$GATE" >/dev/null 2>&1; echo $?; }
[ "$(outward_off)" = 0 ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: outward off-switch"; }
MEM="$T/home/.claude/projects/x-proj/memory"; mkdir -p "$MEM"
check "rule-home: agent-memory write in operated tree → deny" 2 "$(pl Write "$MEM/rule.md" "$TE")"
check "rule-home: the guide is a home → allow"        0 "$(pl Write "$R/CLAUDE.md" "$TE")"
rulehome_off() { printf '%s' "$(pl Write "$MEM/rule.md" "$TE")" | OPSINIST_RULE_HOME=off python3 "$GATE" >/dev/null 2>&1; echo $?; }
[ "$(rulehome_off)" = 0 ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: rule-home off-switch"; }
rm "$R/CLAUDE.md" "$R/LATER.md"
check "rule-home: unoperated tree → allow"            0 "$(pl Write "$MEM/rule.md" "$TN")"

# many hands is checked last: it rewrites the repo's history and every later case would
# inherit a tree that has already stood the gate down.

check "outside any git repo → allow"                  0 "$(printf '{"tool_name":"Write","tool_input":{"file_path":"%s"},"cwd":"%s","transcript_path":"%s"}' "$T/loose.txt" "$T" "$TE")"

# --- Stop: the deferrable half said and not written ---------------------------------------
# A transcript whose closing message presents a classified list, and one that does not.
TD="$T/deferred.jsonl"
{ printf '{"type":"assistant","x":{"skill":"opsinist:join"}}\n'
  printf '{"type":"assistant","message":{"content":[{"type":"text","text":"BLOCKING: secrets. DEFERRABLE: the stray notes files."}]}}\n'; } > "$TD"
TS="$T/silent.jsonl"
{ printf '{"type":"assistant","x":{"skill":"opsinist:join"}}\n'
  printf '{"type":"assistant","message":{"content":[{"type":"text","text":"Fixed the import."}]}}\n'; } > "$TS"
stop() { printf '{"hook_event_name":"Stop","cwd":"%s","transcript_path":"%s"%s}' "$R" "$1" "${2:-}"; }

check "stop: deferrables presented, no LATER.md → block"  2 "$(stop "$TD")"
# The harness passes the closing message directly; the transcript walk is only the fallback.
check "stop: reads last_assistant_message when given"     2 "$(stop "$TS" ',"last_assistant_message":"one deferrable finding"')"
check "stop: that field silent → allow"                   0 "$(stop "$TS" ',"last_assistant_message":"all fixed"')"
check "stop: no deferrables mentioned → allow"            0 "$(stop "$TS")"
check "stop: already blocked once → allow (no loop)"      0 "$(stop "$TD" ',"stop_hook_active":true')"
# stop_hook_active alone is not enough — measured: two refusals arrived with it never set. The
# transcript's own count of past refusals is the guard that actually held.
TT="$T/twice.jsonl"; cp "$TD" "$TT"
for _ in 1 2; do printf '{"type":"user","message":{"content":"Opsinist audit gate (entering.md): you presented deferrable findings and there is no LATER.md."}}\n' >> "$TT"; done
check "stop: two past refusals in transcript → allow"     0 "$(stop "$TT")"
TO="$T/once.jsonl"; cp "$TD" "$TO"
printf '{"type":"user","message":{"content":"Opsinist audit gate (entering.md): you presented deferrable findings and there is no LATER.md."}}\n' >> "$TO"
check "stop: one past refusal → still blocks"             2 "$(stop "$TO")"
printf '# later\n' > "$R/LATER.md"
check "stop: LATER.md written → allow"                    0 "$(stop "$TD")"
rm "$R/LATER.md"
printf '**Operated by:** Opsinist 0.0.0\n' > "$R/CLAUDE.md"
check "stop: our own repo → allow"                        0 "$(stop "$TD")"
rm "$R/CLAUDE.md"
printf 'not json' | python3 "$GATE" >/dev/null 2>&1 && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: broken stdin must fail open"; }

# Last, because it rewrites history: three distinct authors is a project someone else has run.
for a in b c; do printf '%s\n' "$a" >> "$R/notes.txt"; git -C "$R" add -A >/dev/null; \
  git -C "$R" -c user.email="$a@x" -c user.name="$a" commit -qm "$a" >/dev/null; done
check "guest signal: three authors → allow"           0 "$(pl Write "$R/src/util.py" "$TE")"
check "stop: three authors stands it down too"        0 "$(stop "$TD")"


# --- SessionStart: the migration state, delivered as a fact -------------------------------
ss() { printf '{"hook_event_name":"SessionStart","source":"startup","cwd":"%s","transcript_path":"%s"}' "$1" "$TE"; }
say() { # name expect-substring-or-EMPTY cwd
  local name=$1 want=$2 dir=$3 got
  got=$(printf '%s' "$(ss "$dir")" | python3 "$GATE" 2>/dev/null)
  if { [ "$want" = "EMPTY" ] && [ -z "$got" ]; } || { [ "$want" != "EMPTY" ] && printf '%s' "$got" | grep -q "$want"; }; then
    pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $name (got: ${got:-<empty>})"; fi
}
V=$(grep -m1 '^version:' skills/advisor/SKILL.md | awk '{print $2}')

say "session: no guide, no config — not ours → silent" "EMPTY" "$R"
printf '**Operated by:** Opsinist 0.1.0\n' > "$R/CLAUDE.md"
say "session: our guide, no config.md → speaks"  "no \`config.md\`" "$R"
printf '# Project configuration\n\n## Migrations\n\n- 0.1.3 → 0.1.4 · 2026-07-31 · applied · t@t\n' > "$R/config.md"
say "session: log misses this version → speaks"  "does not name version" "$R"
printf -- "- 0.1.4 → %s · 2026-08-01 · nothing-required · t@t\n" "$V" >> "$R/config.md"
printf -- "**Operated by:** Opsinist %s\n" "$V" > "$R/CLAUDE.md"
say "session: log names this version → silent"   "EMPTY" "$R"

# The guide's version line. Measured in the sibling project at N=3: the log line got written
# and this line did not, 0 of 3 — and a written log is exactly what silences the check above,
# so the disagreement would never be raised again. Each rule refuses the stale guide and stays
# quiet on the honest twin.
printf 'Opsinist operates this repository.\n**Operated by:** Opsinist **0.0.1**\n' > "$R/CLAUDE.md"
say "session: log current, guide stale → speaks"  "the guide is the" "$R"
printf 'Opsinist operates this repository.\n**Operated by:** Opsinist **%s**\n' "$V" > "$R/CLAUDE.md"
say "session: log current, guide agrees → silent" "EMPTY" "$R"
printf 'Opsinist operates this repository.\nWe ran 0.0.1 once and it broke.\n' > "$R/CLAUDE.md"
say "session: a version in prose is not a claim"  "EMPTY" "$R"
printf 'Opsinist operates this repository.\n**Operated by:** Opsinist **0.0.1**\n' > "$R/CLAUDE.md"
rm "$R/config.md"
say "session: both stale → the no-config message" "no \`config.md\`" "$R"
printf '# Project configuration\n\n## Migrations\n\n- 0.1.4 → %s · 2026-08-01 · nothing-required · t@t\n' "$V" > "$R/config.md"
printf '**Operated by:** Opsinist %s\n' "$V" > "$R/CLAUDE.md"

printf '# Project configuration\n\n## Migrations\n\n- 0.1.4 → %s · 2026-08-02 · t@t\n  impact: guide version line only.\n  Outcome: applied.\n' "$V" > "$R/config.md"
say "session: a wrapped entry counts as a line"  "EMPTY" "$R"
printf '# Project configuration\n\n## Migrations\n\n- 0.1.4 → %s · 2026-08-02 · t@t\n  impact: none recorded yet.\n' "$V" > "$R/config.md"
say "session: wrapped but no outcome → speaks"   "does not name version" "$R"

# The shared _ops/ door: a bare config.md is the sibling's shape too, so presence alone is
# no longer an ownership claim — and another system's operator line means their workspace.
printf '# Project configuration\n\n## Migrations\n\n- — → 0.4.0 · 2026-08-08 · applied · t@t\n' > "$R/config.md"
printf '# Guide\n\n**Operated by:** otherops 9.9.9\n' > "$R/CLAUDE.md"
say "session: sibling-operated tree → silence"     "EMPTY"  "$R"
printf '# Guide\n\nA project. It mentions opsinist in passing.\n' > "$R/CLAUDE.md"
say "session: config.md alone, no operator line → silence" "EMPTY" "$R"
printf '**Operated by:** Opsinist %s\n' "$V" > "$R/CLAUDE.md"
printf '# Project configuration\n\n## Migrations\n\n- 0.1.4 → %s · 2026-08-01 · nothing-required · t@t\n' "$V" > "$R/config.md"

printf '# Contributing\n' > "$R/CONTRIBUTING.md"
say "session: guest tree → silent"               "EMPTY" "$R"
rm "$R/CONTRIBUTING.md" "$R/CLAUDE.md" "$R/config.md"
# A REPO that is not ours — the fixture used to be `$T`, the suite's own non-repo temp root,
# which asserted the right thing for the wrong reason: it passed because nothing fired there
# at all, not because ownership was tested. The no-repo line found that by breaking it.
say "session: outside a project we operate → silent" "EMPTY" "$R"

# --- Stop: a project stood up without spec_mode -------------------------------------------
printf '# Project configuration\n\n## Settings\n\nnothing here yet\n' > "$R/config.md"
TSP="$T/spec.jsonl"
{ printf '{"type":"assistant","x":{"skill":"opsinist:init"}}\n'
  printf '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Write","input":{"file_path":"%s/config.md"}}]}}\n' "$R"
  printf '{"type":"assistant","message":{"content":[{"type":"text","text":"Project is set up."}]}}\n'; } > "$TSP"
check "stop: project stood up, no spec_mode → block" 2 "$(stop "$TSP")"
printf '| `spec_mode` | outcome |\n' >> "$R/config.md"
check "stop: spec_mode answered → allow"             0 "$(stop "$TSP")"

# A session that only READ an existing config.md must not be hijacked — measured: the first
# version of this predicate matched the filename anywhere in the transcript and made three
# scenarios worse by demanding a decision from owners who had asked something else.
TRD="$T/readonly.jsonl"
{ printf '{"type":"assistant","x":{"skill":"opsinist:advisor"}}\n'
  printf '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","input":{"file_path":"%s/config.md"}}]}}\n' "$R"
  printf '{"type":"assistant","message":{"content":[{"type":"text","text":"Here is what is next."}]}}\n'; } > "$TRD"
printf '# Project configuration\n\nno settings yet\n' > "$R/config.md"
check "stop: config.md only read, not written → allow" 0 "$(stop "$TRD")"
rm "$R/config.md"
check "stop: no config.md written this session → allow" 0 "$(stop "$TD")"

# --- PreToolUse: obligations restated as refusals -----------------------------------------
# Measured: a fact delivered at SessionStart and a demand at Stop each bought nothing, while
# the one scenario that merely forbids held 5/5. These fire where the missing answer is used.
P="$T/proj"; mkdir -p "$P/tasks" "$P/roles"
# a task exists here on purpose: the first-task gate is exercised in its own block below, and
# without one it would answer first and every migration case would pass for the wrong reason.
printf '# T-0\nStatus: open\n' > "$P/tasks/T-0.md"
git -C "$P" init -q 2>/dev/null || { mkdir -p "$P"; git -C "$P" init -q; }
printf 'Opsinist operates this repository.\n' > "$P/CLAUDE.md"
git -C "$P" add -A >/dev/null 2>&1; git -C "$P" -c user.email=t@t -c user.name=t commit -qm init >/dev/null 2>&1
ppl() { printf '{"tool_name":"Write","tool_input":{"file_path":"%s"},"cwd":"%s","transcript_path":"%s"}' "$1" "$P" "$TE"; }

# Each gate is exercised alone: the other one is satisfied first, or a pass could be a
# refusal from the wrong rule wearing the right verdict.
# The two forgeable refusals were removed by measurement; what remains is asserted NOT to fire.
check "task write, no config.md at all → allow now"   0 "$(ppl "$P/tasks/T-1.md")"
printf '# Project configuration\n\n## Migrations\n\n' > "$P/config.md"
printf -- "- — → %s · 2026-08-01 · applied · t@t\n" "$V" >> "$P/config.md"
check "task write, no spec_mode → no longer refused"  0 "$(ppl "$P/tasks/T-1.md")"
check "a doc is not a task → allow"                   0 "$(ppl "$P/docs/NOTE.md")"
printf '| `spec_mode` | outcome |\n' >> "$P/config.md"
check "task write, both answered → allow"             0 "$(ppl "$P/tasks/T-1.md")"

# now break only the migration half
printf '# Project configuration\n\n| `spec_mode` | outcome |\n\n## Migrations\n\n- 0.1.3 → 0.1.4 · 2026-07-31 · applied · t@t\n' > "$P/config.md"
check "role write, log misses version → no longer refused" 0 "$(ppl "$P/roles/writer.md")"
check "config.md itself is never blocked → allow"     0 "$(ppl "$P/config.md")"
check "LATER.md is never blocked → allow"             0 "$(ppl "$P/LATER.md")"
printf -- "- 0.1.4 → %s · 2026-08-01 · nothing-required · t@t\n" "$V" >> "$P/config.md"
check "role write once the log names it → allow"      0 "$(ppl "$P/roles/writer.md")"

# on-touch conversion: with a spec format declared, a task written without its reference is
# refused at the moment of the touch — the only shape in which a lazy migration finishes.
ppc() { printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s},"cwd":"%s","transcript_path":"%s"}' \
          "$1" "$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$2")" "$P" "$TE"; }
printf '# Project configuration\n\n| `spec_mode` | spec |\n\n## Migrations\n\n' > "$P/config.md"
printf -- "- — → %s · 2026-08-01 · applied-base · pending-on-touch · t@t\n" "$V" >> "$P/config.md"
check "on-touch: task without a spec reference → deny" 2 "$(ppc "$P/tasks/T-9.md" "# T-9 — the thing
Status: open
DoD: it works.")"
check "on-touch: task carrying Spec: → allow"          0 "$(ppc "$P/tasks/T-9.md" "# T-9 — the thing
Spec: docs/specs/thing.md
Status: open")"
printf '# Project configuration\n\n| `spec_mode` | outcome |\n\n## Migrations\n\n' > "$P/config.md"
printf -- "- — → %s · 2026-08-01 · applied · t@t\n" "$V" >> "$P/config.md"
check "outcome mode: no spec reference wanted → allow" 0 "$(ppc "$P/tasks/T-9.md" "# T-9
Status: open")"

# `example` mode wants the same structural proof as a spec format: the task points at the
# artefact rather than restating it.
printf '# Project configuration\n\n| `spec_mode` | example |\n\n## Migrations\n\n' > "$P/config.md"
printf -- "- — → %s · 2026-08-01 · applied · t@t\n" "$V" >> "$P/config.md"
check "example mode: task without its artefact → deny" 2 "$(ppc "$P/tasks/T-11.md" "# T-11
Status: open")"
check "example mode: task pointing at one → allow"     0 "$(ppc "$P/tasks/T-11.md" "# T-11
Spec: tests/golden/parse_delimiters.py
Status: open")"

# The store's own record: created by the flow, two files, no guide — the exact shape this gate
# read as a takeover until the skill hit it and filed a report about itself.
ST="$T/.opsinist/projects/thing"; mkdir -p "$ST"
git -C "$ST" init -q; printf '# record\n' > "$ST/record.md"; printf '# runs\n' > "$ST/runs.md"
git -C "$ST" add -A >/dev/null 2>&1
stp() { printf '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"},"cwd":"%s","transcript_path":"%s"}' "$1" "$TE"; }
check "store record: first commit → allow (path)"     0 "$(stp "$ST")"
SR="$T/elsewhere"; mkdir -p "$SR"; git -C "$SR" init -q
printf '# record\n' > "$SR/record.md"; printf 'x\n' > "$SR/other.txt"
git -C "$SR" add -A >/dev/null 2>&1; git -C "$SR" -c user.email=t@t -c user.name=t commit -qm init
check "a repo carrying record.md → allow (shape)"     0 "$(stp "$SR")"

# The first task before the machinery — measured: 10-13 files built before any work existed.
FT="$T/fresh"; mkdir -p "$FT/tasks"; git -C "$FT" init -q
printf 'Opsinist operates this repository.\n' > "$FT/CLAUDE.md"
printf '# Project configuration\n\n| `spec_mode` | outcome |\n\n## Migrations\n\n' > "$FT/config.md"
printf -- "- — → %s · 2026-08-01 · applied · t@t\n" "$V" >> "$FT/config.md"
git -C "$FT" add -A >/dev/null 2>&1; git -C "$FT" -c user.email=t@t -c user.name=t commit -qm init >/dev/null 2>&1
fpl() { printf '{"tool_name":"Write","tool_input":{"file_path":"%s"},"cwd":"%s","transcript_path":"%s"}' "$1" "$FT" "$TE"; }
check "no task yet: docs/TEAM.md → deny"            2 "$(fpl "$FT/docs/TEAM.md")"
check "no task yet: roles/writer.md → deny"         2 "$(fpl "$FT/roles/writer.md")"
check "no task yet: process/labels.md → deny"       2 "$(fpl "$FT/process/labels.md")"
check "no task yet: the guide itself → allow"       0 "$(fpl "$FT/CLAUDE.md")"
check "no task yet: config.md → allow"              0 "$(fpl "$FT/config.md")"
check "no task yet: a task file → allow"            0 "$(fpl "$FT/tasks/T-1.md")"
check "reading a repo: docs/ARCHITECTURE.md → allow" 0 "$(fpl "$FT/docs/ARCHITECTURE.md")"
check "reading a repo: docs/DEBTS.md → allow"        0 "$(fpl "$FT/docs/DEBTS.md")"
printf '# T-1\nStatus: open\n' > "$FT/tasks/T-1.md"
check "task exists: docs/TEAM.md → allow"            0 "$(fpl "$FT/docs/TEAM.md")"

# 2c · the role gate: product surface in an operated project refuses once, system never.
G="$T/prod"; mkdir -p "$G/site" "$G/tasks" "$G/docs"
printf '# Guide\n\n**Operated by:** Opsinist 0.0.1\n' > "$G/CLAUDE.md"
printf '<h1>hi</h1>\n' > "$G/site/index.html"
git -C "$G" init -q && git -C "$G" add -A && \
  git -C "$G" -c user.email=t@t -c user.name=t commit -qm wip
gpl() { printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"},"cwd":"%s","transcript_path":"%s","session_id":"prodgate-test-%s"}' "$1" "$G" "$TE" "$2"; }
rm -f /tmp/opsinist-prodgate-*
check "product edit, operated → stopped once"        2 "$(gpl "$G/site/index.html" A)"
check "identical retry → passes"                     0 "$(gpl "$G/site/index.html" A)"
check "system record (tasks/) → never trips"         0 "$(gpl "$G/tasks/T-9.md" B)"
check "the guide itself → never trips"               0 "$(gpl "$G/CLAUDE.md" C)"
# and the refusal's door has to RESOLVE from the project it is read in. The exit code cannot
# see this: 0.2.7 corrected `scripts/transition.py` → `_ops/scripts/transition.py` here and
# nothing asserted it, so the next edit would have put the wrong path back in silence — the
# same reasoning the SessionStart block below states for its own assertions.
rm -f /tmp/opsinist-prodgate-*
prodmsg=$(gpl "$G/site/index.html" D | python3 "$GATE" 2>&1)
case "$prodmsg" in
  *"_ops/scripts/transition.py --brief"*) pass=$((pass+1));;
  *) fail=$((fail+1)); echo "FAIL: the role gate's door is not a path the project can resolve";;
esac
case "$prodmsg" in
  *" scripts/transition.py"*) fail=$((fail+1)); echo "FAIL: the bare skill-relative path came back";;
  *) pass=$((pass+1));;
esac
rm -f /tmp/opsinist-prodgate-*

# PostToolUse · the spiral note: twelve read-only calls speak once, a write resets, retired after.
spl() { printf '{"tool_name":"%s","tool_input":{"command":"ls -la"},"cwd":"%s","transcript_path":"%s","hook_event_name":"PostToolUse","session_id":"spiral-%s"}' "$1" "$G" "$TE" "$2"; }
sgot() { printf '%s' "$(spl "$1" "$2")" | python3 "$GATE" 2>/dev/null; }
find "$(cd /tmp && pwd -P)" -maxdepth 1 -name 'opsinist-spiral-*' -delete
for i in $(seq 1 10); do sgot Bash S >/dev/null; done
[ -z "$(sgot Read S)" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: spiral spoke before threshold"; }
[ -n "$(sgot Read S)" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: spiral silent at threshold"; }
[ -z "$(sgot Read S)" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: spiral nagged twice"; }
find "$(cd /tmp && pwd -P)" -maxdepth 1 -name 'opsinist-spiral-*' -delete
for i in $(seq 1 11); do sgot Bash R >/dev/null; done
sgot Write R >/dev/null
[ -z "$(sgot Read R)" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: a write did not reset the spiral"; }
find "$(cd /tmp && pwd -P)" -maxdepth 1 -name 'opsinist-spiral-*' -delete

# SessionStart · the no-repo fact. The exit code is 0 either way, so the assertion has to be
# about what it SAYS — and the load-bearing half is the silence: a line in every directory
# somebody happens to open is the fastest way to teach them to ignore this hook.
NRC=$(mktemp -d); NRD=$(mktemp -d)
ss() { printf '{"hook_event_name":"SessionStart","cwd":"%s"}' "$1" \
       | CLAUDE_CONFIG_DIR="$NRC" python3 "$GATE" 2>/dev/null; }
[ -n "$(ss "$NRD")" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: silent in a non-repo directory"; }
case "$(ss "$NRD"; ss "$NRD")" in "") pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: repeated the no-repo line for the same directory";; esac
NRD2=$(mktemp -d)
[ -n "$(ss "$NRD2")" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: a second, different directory was never told"; }
[ -z "$(ss "$R")" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: spoke inside a real repository"; }
[ -z "$(ss "$HOME")" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: nagged in the home directory"; }
# the message has to carry the two routes and the reassurance, or it is a fact with no exit
msg=$(ss "$(mktemp -d)")
case "$msg" in *"git init"*) pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: no route offered";; esac
case "$msg" in *"moves and changes nothing"*) pass=$((pass+1));; *) fail=$((fail+1)); echo "FAIL: the join case (a folder with files) is not reassured";; esac
rm -rf "$NRC" "$NRD" "$NRD2"

# ── the reach gate: a run may not end leaving `_ops/` uncommitted ──────────────────────────
# New in 0.2.10. Measured 2026-08-22 over ten runs of one scenario: the player edited the
# machinery 8 times and committed 0 times, so every `enforced_by: validator` gate — which fires
# at the commit and nowhere else — went unreached. This forbids the ending rather than asking for
# a commit, because this hook's own three-round measurement says a demand at Stop bought 1/5
# while a prohibition held 5/5.
RG="$T/reach"; mkdir -p "$RG/_ops"
printf '# Map\n' > "$RG/_ops/MAP.md"; printf '# Guide\n' > "$RG/CLAUDE.md"
git -C "$RG" init -q && git -C "$RG" add -A && \
  git -C "$RG" -c user.email=t@t -c user.name=t commit -qm init
rstop() { printf '{"hook_event_name":"Stop","cwd":"%s"%s}' "$RG" "${1:-}"; }

check "reach: a clean tree ends freely" 0 "$(rstop)"
printf '\n### express-checkout\n' >> "$RG/_ops/MAP.md"
check "reach: uncommitted machinery refuses the ending" 2 "$(rstop)"
# said ONCE — a transcript already carrying the refusal must not block a second time, or the
# owner cannot deliberately leave work
RT="$T/reach.jsonl"; printf 'machinery edited in this session is still uncommitted\n' > "$RT"
check "reach: refused once, not twice" 0 "$(rstop ",\"transcript_path\":\"$RT\"")"
# and committing the same work clears it
git -C "$RG" add -A && git -C "$RG" -c user.email=t@t -c user.name=t commit -qm move
check "reach: committing the work clears the gate" 0 "$(rstop)"
# the product's own files are not the machinery and are not held
printf 'print(1)\n' > "$RG/app.py"
check "reach: product files are the craft's business, not this gate's" 0 "$(rstop)"
# the deliberate escape
printf '\n### another\n' >> "$RG/_ops/MAP.md"
printf '%s' "$(rstop)" | OPSINIST_UNCOMMITTED_GATE=off python3 "$GATE" >/dev/null 2>&1 \
  && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: reach: OPSINIST_UNCOMMITTED_GATE=off"; }
rm -rf "$RG"

echo "pass $pass · fail $fail"
[ "$fail" = 0 ]
