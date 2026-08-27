# Field notes

**Friction, recorded the moment it happens.** One line each, newest last, **append-only** — a
correction is a new entry, never an edit to an old one. **The one exception is the `Closed` cell**,
and it is narrow on purpose: closing only ever moves that cell from empty to a version, and a
`Closed` cell that already holds one is never changed. Nothing a reader relied on is rewritten, so
the guarantee append-only exists for still holds.

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
| {{2026-08-04}} | {{review}} | {{two reviewers disagreed and both were recorded as done}} | {{the two records}} | {{a stop at the second disagreement}} |  |

**`Closed` holds the version that shipped the fix; leave it empty while the note is still open.**
The sweep at a status check is what fills it (`checking.md`) — the person closing the loop, not the
person who wrote the note. **Nothing validates this table's shape**, so an existing file with five
columns keeps working; add the column when you next close something, or never.

## Sweeps

**A sweep that found nothing says so, with what it looked at** — an empty log is otherwise
unreadable.

- {{2026-08-01 · swept the release and dispatch flows · nothing}}
