# Field notes

**Friction, recorded the moment it happens.** One line each, newest last, **append-only** — a
correction is a new entry, never an edit to an old one.

**What goes here:** anything that made the work harder than it needed to be and **did not stop
you**. If it stopped you, it is a blocking task instead, and the work it blocked takes a
`blocked_by` on it → `self-maintenance.md`.

**The bar for becoming a task is twice.** A second occurrence is written as its own line, and
then the two together earn a task with **both occasions named in it** — a recurrence recorded
nowhere is a first occurrence again.

**Swept at a status check** into the backlog, deduplicated, and an entry that ships is closed
with the version → `checking.md`.

**Friction in *this* project belongs here. Friction in the skill operating it does not** — that
is packaged for its authors and kept outside this repository, because it is not this project's
record → `self-maintenance.md`.

| Date | Flow | Symptom | Evidence | Fix candidate | Closed |
|---|---|---|---|---|---|
| {{2026-08-01}} | {{release}} | {{the version number lives in five files and I moved four}} | {{the commit that missed one}} | {{a check that reads them all}} | {{0.3.1}} |
| {{2026-08-04}} | {{review}} | {{two reviewers disagreed and both were recorded as done}} | {{the two records}} | {{a stop at the second disagreement}} | {{ }} |

**`Closed` holds the version that shipped the fix, and blank means still open.** Eleven lines
above, this file already told you an entry that ships is closed with the version — and until
2026-08-23 the table it told you that about had nowhere to write it. A rule stated in prose with
no cell to hold it is the shape this system measures at close to zero, and it was sitting in its
own template. The column is also what makes the promotion ladder checkable later: a rule promoted
from a note is supposed to cite the line it came from, and a citation is only checkable against a
date if the line has a closed state to check it in.

## Sweeps

**A sweep that found nothing says so, with what it looked at** — an empty log is otherwise
unreadable.

- {{2026-08-01 · swept the release and dispatch flows · nothing}}
