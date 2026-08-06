#!/usr/bin/env bash
# SessionStart with matcher "compact" — the documented channel whose stdout DOES reach the
# context (cited 2026-08-06). Runs right after a compaction: the summary is now the only
# transcript, so the first act is reconciling it against the canon it was allowed to drop.
cat <<'EOF'
This session was just compacted. The summary is a lossy view; the repository is the canon.
Before continuing: if the summary names decisions, thread tails or applied work that you do
not find written in the tree, write them now — and where the summary carries only pointers
(ids, paths), read the pointed-at files rather than trusting the précis of them.
EOF
exit 0
