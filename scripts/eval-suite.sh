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

# Sharded on purpose. The first full suite ran one pool of five and took two hours of wall clock
# for 370 runs — and the round is bound by waiting on an API, not by this machine, so the fix is
# concurrency rather than a faster loop. SHARDS × POOL is the real parallelism; keep the product
# under about 30, since past that the provider starts shedding requests and a shed request looks
# exactly like a slow one.
SHARDS=${SHARDS:-6}; POOL=${POOL:-5}
echo "dispatching $total player runs · $SHARDS shards × $POOL = $((SHARDS*POOL)) concurrent…"
pids=()
for i in $(seq 0 $((SHARDS-1))); do
  bash scripts/eval-shard.sh "$SUITE" "$CORPUS" "$PHOME" "$i" "$SHARDS" "$POOL" \
    > "$SUITE/logs/shard-$i.log" 2>&1 &
  pids+=($!)
done
for p in "${pids[@]}"; do wait "$p"; done

# A run the provider cut short is not a result. Requeue whatever the limit ate, once the reset
# has passed — the alternative is a rate table where the account's ceiling is scored as the
# corpus's behaviour.
if [ -s "$SUITE/logs/POISONED" ]; then
  n=$(wc -l < "$SUITE/logs/POISONED" | tr -d ' ')
  echo
  echo "$n run(s) hit the session limit and were not graded:"
  sort -u "$SUITE/logs/POISONED" | head -3 | sed 's/^/  /'
  echo "  requeue them with:  SHARDS=$SHARDS POOL=$POOL bash scripts/eval-requeue.sh $SUITE $CORPUS $PHOME $JHOME"
fi

echo "judging…"
JPOOL=${JPOOL:-10}
awk '{print}' "$jobs" | xargs -P"$JPOOL" -n2 bash scripts/eval-judge.sh "$SUITE" "$JHOME"

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
