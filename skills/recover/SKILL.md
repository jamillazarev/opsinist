---
description: Read state back from the record and continue an interrupted run.
---

Load the **opsinist** skill ([SKILL.md](../advisor/SKILL.md)) and run this flow — the procedure is in [`recovering.md`](../../recovering.md).

Recovery reads committed state, not a session that no longer exists: what was running, what it had produced, and where it stopped.

Args: $ARGUMENTS
