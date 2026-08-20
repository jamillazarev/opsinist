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

The dispatch sheet may adapt the scenario's canonical query to the fixture's own vocabulary (a settings screen becomes a services page, a YouTube channel becomes a tile workshop). The USER turns in the transcript are authoritative for what was asked — grade the expectations against that ask, and never fail a run for serving the adapted subject instead of the canonical one.

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

# `--output-format json`, so the judge's own usage is CAPTURED rather than re-measured later.
# Without it no usage block is emitted at all and the verdict file stores only the verdict — which
# is why "judge usage is unmeasured" sat open in RUNS.md. Measured 2026-08-15 by replaying three
# real transcripts: in=2 out=43-50 cache_read=28,375 (a CONSTANT — the harness prefix, paid per
# verdict) cache_write=13-15k (the prompt, written to cache and never read back, because every
# judge call is a fresh session). ~$0.095 a verdict; the 515-verdict round cost ≈$49 of judging.
# The compaction is not the cost — 189,634 raw bytes reduce to 3,936 — the per-session prefix is.
# `timeout` is not part of macOS — it arrives with Homebrew's coreutils. Measured 2026-08-20 in
# the sibling tree: a suite that wrapped its calls in `timeout` was green on this machine and
# failed every assertion with 127 on a runner without it. Here the timeout does real work — it is
# what stops a hung run from holding a round forever — so it is not silently skipped. It is used
# when present, and its absence is SAID once, because an unbounded run that looks bounded is the
# worse of the two failures. Resolved at TOP LEVEL: the first version of this sat inside the turn
# loop, where it would have re-resolved and re-warned once per turn, up to 55 times a run.
_TMO=$(command -v timeout || command -v gtimeout || true)
[ -n "$_TMO" ] || echo "  ! no \`timeout\` on this machine (it is Homebrew's, not macOS's) — runs are UNBOUNDED" >&2

raw=$(CLAUDE_CONFIG_DIR="$JHOME" ${_TMO:+$_TMO 240} claude --model sonnet -p "$prompt" --output-format json </dev/null 2>>"$SUITE/logs/$ID-$N.err")

# The judge has the same failure mode as the player and had no detection for it: a limited
# judge returns the harness's banner, which parses as nothing and was written down as
# `void: judge output unparseable` — a verdict about the account wearing a verdict about the
# run. Measured 2026-07-31: 317 of 370 judgments in one round, every transcript intact.
# Nothing is written when this fires, so a requeue re-judges exactly these.
if printf '%s' "$raw" | grep -q "hit your session limit"; then
  echo "$ID $N judge-limit $(printf '%s' "$raw" | grep -o 'resets [^\"]*' | head -1)" >> "$SUITE/logs/POISONED-JUDGE"
  echo "$ID/$N JUDGE LIMIT — not graded"
  exit 4
fi

# The ENVELOPE is unwrapped first, then the verdict is found inside its `result` text. Without
# this step the greedy `\{.*\}` matches the envelope itself, `verdict` comes back None, and EVERY
# judgment becomes `void: judge output unparseable` — the whole round silently voided by a flag
# added to measure its cost. The old text form is still accepted, so a re-judge of an existing
# raw log is unaffected.
printf '%s' "$raw" | python3 -c "
import json,sys,re
raw=sys.stdin.read()
usage={}
try:
    env=json.loads(raw)
    if isinstance(env,dict) and 'result' in env:
        usage=env.get('usage') or {}
        if env.get('total_cost_usd') is not None:
            usage['total_cost_usd']=env['total_cost_usd']
        raw=env['result'] if isinstance(env['result'],str) else json.dumps(env['result'])
except Exception:
    pass
m=re.search(r'\{.*\}',raw,re.S)
try:
    v=json.loads(m.group(0)) if m else {}
    assert v.get('verdict') in ('pass','fail','void')
except Exception:
    v={'verdict':'void','reason':'judge output unparseable','held':[],'violated':[]}
if usage: v['judge_usage']=usage
print(json.dumps(v))" > "$SUITE/logs/$ID-$N.verdict.json"
echo "$ID/$N $(python3 -c "import json;print(json.load(open('$SUITE/logs/$ID-$N.verdict.json'))['verdict'])")"
