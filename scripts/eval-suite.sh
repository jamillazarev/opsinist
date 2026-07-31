#!/usr/bin/env bash
# The whole suite: every runsheet row, N instances each, then the judge, the boundary
# tripwire and the rate table. Re-runnable — build → dispatch → judge → clean, not
# archaeology through a conversation about what was run.
#
#   bash scripts/eval-suite.sh <suite-root> <corpus-copy> <player-home> <judge-home> <N> [ids...]
#
# The fingerprint is taken at dispatch and checked at the end INSIDE this script, because a
# freeze that lives in someone's memory has already failed twice; here it is a mechanism.
set -uo pipefail
SUITE=${1:?}; CORPUS=${2:?}; PHOME=${3:?}; JHOME=${4:?}; NRUNS=${5:?}; shift 5
ONLY_N=$#; ONLY="$*"
cd "$(dirname "$0")/.." || exit 1
mkdir -p "$SUITE/logs"

fp_start=$(bash scripts/eval-fingerprint.sh)
echo "$fp_start" > "$SUITE/fingerprint.at-dispatch"
echo "corpus fingerprint at dispatch: $fp_start"

jobs="$SUITE/jobs.txt"; : > "$jobs"
grep -v '^#' evals/runsheet.tsv | cut -f1 | while read -r id; do
  [ -n "$id" ] || continue
  if [ "$ONLY_N" -gt 0 ]; then
    keep=0; for o in $ONLY; do [ "$o" = "$id" ] && keep=1; done
    [ $keep = 1 ] || continue
  fi
  for n in $(seq 1 "$NRUNS"); do echo "$id $n" >> "$jobs"; done
done
total=$(wc -l < "$jobs" | tr -d ' ')
echo "dispatching $total player runs, 5 at a time…"
xargs -P5 -n2 bash scripts/eval-dispatch.sh "$SUITE" "$CORPUS" "$PHOME" < "$jobs"

echo "judging…"
xargs -P6 -n2 bash scripts/eval-judge.sh "$SUITE" "$JHOME" < "$jobs"

echo; echo "== boundary tripwire"
bash scripts/eval-boundary.sh "$SUITE/runs" "$SUITE/logs" || true

echo; echo "== corpus freeze"
bash scripts/eval-fingerprint.sh "$fp_start" || echo "RESULTS ARE OBSERVATIONS, NOT MEASUREMENTS"

echo; echo "== rates (pass/fail/void per scenario)"
python3 - "$SUITE" <<'EOF'
import json,os,sys,collections
suite=sys.argv[1]
rows=collections.defaultdict(lambda: collections.Counter())
for f in sorted(os.listdir(suite+'/logs')):
    if f.endswith('.verdict.json'):
        sid=f.rsplit('-',1)[0]
        try: v=json.load(open(suite+'/logs/'+f))['verdict']
        except Exception: v='void'
        rows[sid][v]+=1
def key(s):
    return (0,int(s[1:])) if s[0]=='S' else (1,int(s[1:]))
worst=[]
for sid in sorted(rows,key=key):
    c=rows[sid]; n=sum(c.values()); valid=c['pass']+c['fail']
    rate=('%d/%d'%(c['pass'],valid)) if valid else 'all void'
    print(f"{sid:5s} pass {c['pass']} fail {c['fail']} void {c['void']}  rate {rate}")
    if valid and c['fail']>=c['pass']: worst.append(sid)
print()
print("failing or split scenarios:", ' '.join(worst) if worst else "none")
EOF
echo; echo "clean up with: bash scripts/eval-clean.sh $SUITE/runs --yes   (per-run roots inside)"
