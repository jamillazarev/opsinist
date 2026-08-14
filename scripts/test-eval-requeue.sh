#!/usr/bin/env bash
# The void sweep in eval-requeue.sh, exercised against the shapes that produced it.
#
# Every case here is one the 2026-08-14 round met: N72's five runs left no transcript, the judge
# honestly wrote `void: no transcript` over each, and the requeue printed "every run in the table
# is a run that finished" across them — because it reads only logs/POISONED, and a run that
# vanished for any reason other than a session limit is in no list it reads.
#
# WHAT THIS DOES NOT COVER: the sweep after a real requeue. Reaching that path dispatches live
# agents, so these cases drive the no-poisoned-runs entry instead. Both entries call the same
# sweep_voids; the dispatch between them is untested here and the round record says so.
set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d /tmp/opsinist-requeue-test.XXXXXX)
trap 'rm -rf "$T"' EXIT
S="$T/suite"; mkdir -p "$S/logs"

pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }

# a table of three finished runs: every one has a transcript and a real verdict
build_clean() {
  : > "$S/jobs.txt"; rm -f "$S"/logs/*
  for n in 1 2 3; do
    printf 'N1 %s\n' "$n" >> "$S/jobs.txt"
    printf 'a transcript\n' > "$S/logs/N1-$n.output"
    printf '{"verdict":"pass","reason":"held"}\n' > "$S/logs/N1-$n.verdict.json"
  done
  : > "$S/logs/POISONED"
}
run() { bash "$HERE/eval-requeue.sh" "$S" /nonexistent /nonexistent /nonexistent 2>&1; }

# the twin — nothing poisoned and nothing void: the script says so and exits 0
build_clean
out=$(run); rc=$?
[ "$rc" -eq 0 ] && ok || bad "a clean table was refused (exit $rc)"
printf '%s' "$out" | grep -q "no requeue needed" && ok || bad "the clean table lost its message"

# mutant A · the N72 shape: a void verdict with no transcript beneath it
build_clean
printf '{"verdict":"void","reason":"no transcript"}\n' > "$S/logs/N1-2.verdict.json"
rm -f "$S/logs/N1-2.output"
out=$(run); rc=$?
[ "$rc" -ne 0 ] && ok || bad "a void run passed the sweep — the defect this file exists for"
printf '%s' "$out" | grep -q "N1/2" && ok || bad "the refusal did not name the run"
printf '%s' "$out" | grep -q "every run in the table is a run that finished" \
  && bad "the completion claim was printed over a void" || ok

# mutant B · a verdict with no transcript beneath it: a judge that scored nothing must not count
build_clean
rm -f "$S/logs/N1-3.output"
run >/dev/null 2>&1 && bad "a verdict with no transcript passed" || ok

# mutant C · an empty transcript is not a transcript
build_clean
: > "$S/logs/N1-1.output"
run >/dev/null 2>&1 && bad "an empty transcript passed" || ok

# and a run whose verdict is an honest fail is a finished run, not a void — the sweep must not
# quietly widen into "re-run anything that did not pass", which would make every round green
build_clean
printf '{"verdict":"fail","reason":"skipped the door"}\n' > "$S/logs/N1-2.verdict.json"
run >/dev/null 2>&1 && ok || bad "a failing run was swept as if it had not finished"

# THE TWIN THAT MATTERS, and the one the first version of this suite did not have: a **content
# void** — a judge that read a real transcript and ruled it measures nothing. That is a verdict,
# not a loss. Measured on the 2026-08-14 round: 91 of its 96 voids are this, against 5 real ones,
# so a sweep that counts them refuses a healthy round and asks for 91 pointless re-dispatches.
build_clean
printf '{"verdict":"void","reason":"the run describes files outside its fixture"}\n' > "$S/logs/N1-2.verdict.json"
run >/dev/null 2>&1 && ok || bad "a content void was swept as a lost run — 91 of 96 on the real round"

# and an unreadable table is not an empty one: the claim must not be printed over a table that
# was never opened, which is the same over-claim one level up from the one this file exists for
build_clean
rm -f "$S/jobs.txt"
out=$(run); rc=$?
[ "$rc" -ne 0 ] && ok || bad "a missing jobs table was reported as a finished round"
printf '%s' "$out" | grep -q "nothing was swept" && ok || bad "the missing table was not named"

# Four shapes the sweep called finished, every one measured 2026-08-14.
build_clean
printf 'N1 1\nN1 2\nN1 3' > "$S/jobs.txt"        # no trailing newline: `read` drops the last row
: > "$S/logs/N1-3.output"
run >/dev/null 2>&1 && bad "an unterminated last row was never read — where a truncated write lands" || ok

build_clean
python3 -c "
import pathlib,sys
p=pathlib.Path(sys.argv[1]); p.write_text(p.read_text().replace('\n','\r\n'))" "$S/jobs.txt"
run >/dev/null 2>&1 && ok || bad "a CRLF jobs table reported a healthy round as entirely lost"

build_clean
rm -f "$S/logs/N1-2.verdict.json"                  # a transcript nobody judged is not a finished run
run >/dev/null 2>&1 && bad "a run with no verdict at all counted as finished" || ok

build_clean
printf '{"verdict": "vo' > "$S/logs/N1-2.verdict.json"   # truncated write
run >/dev/null 2>&1 && bad "an unparseable verdict counted as finished" || ok

echo "eval-requeue: $pass passed, $fail failed"
exit "$fail"
