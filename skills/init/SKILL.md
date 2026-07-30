---
description: Start or continue a project — empty folder or not is read, never asked; then the first task.
---

Load the **opsinist** skill ([SKILL.md](../advisor/SKILL.md)) and run this flow — the procedure is in [`arriving.md`](../../arriving.md).

Start or continue a project. Whether a repository is here, whether it is yours, and whether it is empty are **read from the ground, not asked** — that is what decides between standing one up, entering it as its operator, and entering it as a guest.

**Called bare — `/opsinist init` with nothing after it — this is a greeting**, and the front door
handles it: read what is here, say which entrance you would take and why in one line, and take it.
Anything after the name is treated as what you would have said in a sentence, so
`/opsinist init a podcast about interest rates` and *"set up a project for my podcast"* reach the
same place.

Args: $ARGUMENTS
