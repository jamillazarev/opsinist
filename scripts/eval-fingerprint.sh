#!/usr/bin/env bash
# Fingerprint the corpus a player can load, so a suite can prove it was scored against one text.
#
#   bash scripts/eval-fingerprint.sh            # print the fingerprint
#   bash scripts/eval-fingerprint.sh <saved>    # compare against one taken earlier; non-zero if it moved
#
# A suite was once run while its own corpus was being edited. Six of eighteen players read a file
# that changed under them, and only two noticed — which is luck, not method. A pass-rate over a
# tree that moved describes nothing, and nothing in the transcript says so afterwards.
#
# Only what a run can route to counts: the top-level companions and SKILL.md. The cleaner, this
# directory and the evals are developer material no player loads, so editing them mid-run is fine
# and must not raise a false alarm.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fingerprint() {
  # Sorted so the order of `ls` can never change the answer; content-hashed, not mtime.
  #
  # The core moved to skills/advisor/SKILL.md in the restructure and this stayed at maxdepth 1,
  # so for a while it hashed 51 companions and **not the file every run starts from** — the one
  # text whose edit would invalidate a suite hardest. It reported "corpus unchanged" either way,
  # which is the failure mode a checker must never have. The verb doors are routable too, so
  # they count for the same reason the companions do.
  { find . -maxdepth 1 -name '*.md' -type f -print0
    find skills -name 'SKILL.md' -type f -print0
  } | sort -z \
    | xargs -0 shasum -a 256 2>/dev/null \
    | shasum -a 256 \
    | cut -d' ' -f1
}

now=$(fingerprint)
[ -n "$now" ] || { echo "could not fingerprint the corpus"; exit 2; }

if [ $# -eq 0 ]; then
  echo "$now"
  exit 0
fi

if [ "$1" = "$now" ]; then
  echo "corpus unchanged — the run was scored against one text"
  exit 0
fi

echo "CORPUS MOVED DURING THE RUN"
echo "  at dispatch: $1"
echo "  now:         $now"
echo "These results are observations, not measurements. Re-run against a frozen tree."
exit 1
