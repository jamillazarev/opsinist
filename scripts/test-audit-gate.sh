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

echo "pass $pass · fail $fail"
[ "$fail" = 0 ]
