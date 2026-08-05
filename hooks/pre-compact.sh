#!/usr/bin/env bash
# Fires before the runtime compacts the conversation. Compaction is a lossy summary of the
# transcript — safe for everything already written to the repository, and only for that.
# So the one instruction worth injecting is the order of operations: write first, shrink after.
cat <<'EOF'
Before this summary replaces the transcript: anything load-bearing that lives only in the
conversation must be written to the repository first — the tail of any thread in flight, any
decision reached in talk (docs/DECISIONS.md), any applied-but-uncommitted work named. What is
already in the tree needs nothing: the repository is the canon and the summary may drop it
freely. Preserve in the summary only: open questions awaiting the owner, and pointers (ids,
paths) to where everything else was written.
EOF
exit 0
