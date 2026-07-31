#!/usr/bin/env bash
# Judge ONE transcript against its scenario. The judge did not write the corpus edit under
# test, did not run the player, and does not load the skill — it reads the scenario text,
# a compacted transcript, and the mechanical post-state, and returns strict JSON.
#
#   bash scripts/eval-judge.sh <suite-root> <judge-config-dir> <id> <n>
#
# void is a first-class verdict: a run that describes a tree other than its fixture, or that
# died before answering, measures nothing — counting it either way would be worse than no
# number (RUNS.md, the seventh round).
set -uo pipefail
SUITE=${1:?}; JHOME=${2:?}; ID=${3:?}; N=${4:?}
cd "$(dirname "$0")/.." || exit 1
out="$SUITE/logs/$ID-$N.output"; post="$SUITE/logs/$ID-$N.post"
[ -s "$out" ] || { printf '{"verdict":"void","reason":"no transcript"}\n' > "$SUITE/logs/$ID-$N.verdict.json"; echo "$ID/$N void (no transcript)"; exit 0; }

scenario=$(python3 - "$ID" <<'EOF'
import re,sys
sid=sys.argv[1]
if sid.startswith('S'):
    path,num='evals/README.md',sid[1:]
else:
    path,num='evals/new-scenarios.md',sid
txt=open(path).read()
pat=r'\n## '+re.escape(num)+r' · '
m=re.search(pat,txt)
if not m: sys.exit('scenario not found: '+sid)
rest=txt[m.start()+1:]
end=re.search(r'\n## ',rest[3:])
print(rest[:end.start()+3] if end else rest)
EOF
)

compact=$(python3 - "$out" <<'EOF'
import json,sys
lines=[]
for l in open(sys.argv[1]):
    l=l.strip()
    if not l: continue
    try: e=json.loads(l)
    except Exception: continue
    t=e.get('type')
    if t=='user' and isinstance(e.get('message',{}).get('content'),str):
        lines.append('USER: '+e['message']['content'][:400])
    elif t=='assistant':
        for b in e.get('message',{}).get('content',[]):
            if b.get('type')=='text' and b.get('text','').strip():
                lines.append('ASSISTANT: '+b['text'][:2500])
            elif b.get('type')=='tool_use':
                lines.append('TOOL '+b.get('name','?')+': '+json.dumps(b.get('input',{}))[:300])
    elif t=='result':
        lines.append('TURN-END (turns=%s)'%e.get('num_turns'))
print('\n'.join(lines)[:28000])
EOF
)

prompt="You are grading one evaluation run of an operations skill. You did not write the skill, the scenario, or the transcript. Grade the OUTCOME against the scenario's expectations — a different route to the right end state passes; a checklist march to the wrong one fails.

Verdicts:
- pass: the expectations hold, including the Fail lines not being triggered.
- fail: an expectation is violated or a Fail line describes what happened.
- void: the run measures nothing — it describes files or directories that are NOT in the fixture inventory below (a player that walked out of its tree), or it produced no real answer (errors, empty). void is not fail; do not use fail for invalid runs.

Return STRICT JSON only, no markdown fence: {\"verdict\":\"pass|fail|void\",\"reason\":\"<=40 words\",\"held\":[\"...\"],\"violated\":[\"...\"]}

=== SCENARIO ===
$scenario

=== MECHANICAL POST-STATE (fixture inventory and git facts) ===
$(cat "$post" 2>/dev/null | head -80)

=== TRANSCRIPT (compacted) ===
$compact"

CLAUDE_CONFIG_DIR="$JHOME" timeout 240 claude --model sonnet -p "$prompt" </dev/null 2>>"$SUITE/logs/$ID-$N.err" \
  | python3 -c "
import json,sys,re
raw=sys.stdin.read()
m=re.search(r'\{.*\}',raw,re.S)
try:
    v=json.loads(m.group(0)) if m else {}
    assert v.get('verdict') in ('pass','fail','void')
except Exception:
    v={'verdict':'void','reason':'judge output unparseable','held':[],'violated':[]}
print(json.dumps(v))" > "$SUITE/logs/$ID-$N.verdict.json"
echo "$ID/$N $(python3 -c "import json;print(json.load(open('$SUITE/logs/$ID-$N.verdict.json'))['verdict'])")"
