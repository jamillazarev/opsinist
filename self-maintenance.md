# Self-maintenance — changing the machinery

**Load when:** the change is to the project's own apparatus rather than to its product — a script,
a process file, a gate, a role, a skill, the guide, this system itself.

**Anything that changes the machinery is a task, regardless of size.** Not because small changes
deserve ceremony, but because **a machinery change with no record is silent drift in the worst
possible place**. This is a rule about **category, not size** — it does not contradict *small stays
small*, which is about product work someone asked for casually.

---

## The system stream

One field, one generated view. No new entity.

**`stream: product | system`.** A field rather than a label, because it **changes behaviour** —
board membership and whether history is mandatory — and a label only filters.

**What lands in `system`:** scripts and helpers · process — ladders, gates, settings that change
behaviour · **the project's own documentation** (product documentation is product work) · the
shape of the team · skills · project-scope resources.

**One new type, not six: `tooling`.** Its definition of done is honestly different: **name the
routine it replaces** · it is discoverable · it is documented · **someone other than the author
used it once**. Everything else system-shaped is an ordinary chore in this stream until its DoD
proves it needs its own type — **a type is earned by a diverging definition of done, not by
feeling like different work**.

**A short ladder, not an exemption: `doing → done`.** If a one-line script change had to cross four
stages, people would route around it, and then none of this holds.

**Intake reuses `triage`.** An audit finding, a field note, a proposal — all land there with the
four dispositions. This is what fixes the oldest hole in the audit: **its output was a report, and
a report lives until the end of the scroll.** Through triage a finding gets an age and a place in
the attention view.

**Review is a gate on `done`, not a stage.** A request routed to a non-author *is* the review gate,
so no column is needed and the non-author rule still holds. For machinery it matters more than for
product work: **an unnoticed change to a gate is a quietly weakened gate.**

**And it is never self-merged.** The project's own definition is **append-only**: proposed to a
human, never merged by whoever proposed it. That is the same line as *nobody edits the bar they are
measured against*, applied to the bar itself.

---

## What the history is made of

The task is not a new record — it is **the anchor that makes four existing ones findable
together**:

| Record | Answers |
|---|---|
| the task file | what, when, who filed it, what done means |
| the run history | who did it, with what, how many attempts, what it cost |
| git | the diff, the author, human or agent |
| the decisions log | why, for anything that changes behaviour |

Without the task these all exist and none of them is findable from the others.

---

## Effect at the next boundary

**A change to the machinery takes effect at the next boundary, never mid-flight.** Work in progress
finishes on the version it started with → `upgrading.md`.

This is one rule covering three things that used to be three: a settings change, an edit to the
guide, and a new version of a skill. **One version per unit of work**, and the advisor **reports
which version it is now running** — an agent on the old version that proposed the new one runs its
*next* task on the new one, which is normal, but a single unit of work does not change under itself.

---

## Field notes — friction recorded where it happens

**Working inside a system surfaces stumbles the guide never predicted**, and they are worth more
than anything a planning session produces: **recorded friction from real use finds what nobody
thought of, and it is cheaper and better than combinatorics.**

**One line, the moment it happens:** date · flow · symptom · evidence · fix candidate.
**Append-only — a correction is a new entry, never an edit to an old one.**

**Swept at natural checkpoints** — end of session, a status check, before a release cut — into the
backlog, deduplicated so a re-sweep is idempotent, and **an entry that ships gets closed with the
version**. **A sweep that found nothing writes that it found nothing** — with its date and **what it looked
at**. An empty log is otherwise unreadable: *"a quiet week"* and *"nobody looked"* leave the
identical trace, and the second is the one worth knowing about. Naming the scope is what makes the
empty entry evidence rather than a shrug — *"swept the release flow, nothing"* can be wrong later
and be seen to be wrong, which *"nothing to report"* never can. That makes **caught → logged → backlog → done → released** one visible chain rather than
four disconnected places.

**Field note or blocking task? One question: does this stop me now?**

- **No** → a field note, and carry on. It becomes a task if it recurs — **twice**.
- **Yes** → say so where you are, agree what is needed, and the original takes a `blocked_by` on a
  `tooling` task.

**Proactive is right here.** Naming the friction while the decision is still cheap beats naming it
after the work has been built around the workaround. The bound on it is the same as everywhere:
earned, not reflexive — and **twice**, not once.

---

## Packaging a problem upstream

When the friction is in **this system** rather than in the project, the owner needs something they
can send. There is no channel for that by default, which for a public tool means people hit
something, complain aloud, and say nothing outward.

**Assemble:** version · the flow · the symptom · **the evidence** — the exchange, the run record
with model, effort, attempt and outcome, the state of the files involved — and the environment
fingerprint where it smells relevant.

**Screenshots are the owner's attachments, not ours.** Dropped into the conversation they are
already task resources, so the package **references** them rather than creating anything.

**De-identify with the same discipline as releasing a skill:** project names, internal paths,
ticket keys and **above all anything secret** — and **a human reads the diff before it goes
anywhere**. A bug report is by nature full of paths and fragments.

**One artifact, where the owner says.** Same rule as a consultation: nothing written silently.

**We do not send it.** Publishing is outward, from their account. We produce the text; they post
it.

---

## Running this system on itself

There is no separate ritual for it. **This project's own repository is a project, and its
machinery is this skill**, so everything above applies unchanged — that is the whole reason the
stream is a field rather than a special mode.

Two things it adds, both of which apply to any project:

**Fence before staff.** Branch protection exists **before** anyone can push. A human merges;
agents propose. Self-adoption happens **after** a merge, never instead of one.

**Guards green before adoption.** A new version applies to the team only when the checks pass in a
clean checkout at the merge commit — **and red guards mean not adopted, and it says so**. Rollback
is the previous commit; git is the restore point, so no separate backup exists or is needed.
