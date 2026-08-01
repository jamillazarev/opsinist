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

printf 'Opsinist operates this repository.\n' > "$R/CLAUDE.md"
check "operated repo (guide names Opsinist) → allow"  0 "$(pl Write "$R/src/util.py" "$TE")"
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
printf 'Opsinist operates this repository.\n' > "$R/CLAUDE.md"
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
printf 'Opsinist operates this repository.\n' > "$R/CLAUDE.md"
say "session: our guide, no config.md → speaks"  "no \`config.md\`" "$R"
printf '# Project configuration\n\n## Migrations\n\n- 0.1.3 → 0.1.4 · 2026-07-31 · applied · t@t\n' > "$R/config.md"
say "session: log misses this version → speaks"  "does not name version" "$R"
printf -- "- 0.1.4 → %s · 2026-08-01 · nothing-required · t@t\n" "$V" >> "$R/config.md"
say "session: log names this version → silent"   "EMPTY" "$R"
printf '# Contributing\n' > "$R/CONTRIBUTING.md"
say "session: guest tree → silent"               "EMPTY" "$R"
rm "$R/CONTRIBUTING.md" "$R/CLAUDE.md" "$R/config.md"
say "session: outside a project we operate → silent" "EMPTY" "$T"

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

echo "pass $pass · fail $fail"
[ "$fail" = 0 ]
