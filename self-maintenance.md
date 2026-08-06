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

**Scripts the project writes for itself — four rules before the first one lands.** **The stack
is what the project already runs**; where nothing runs yet, POSIX shell until the first
structure more complex than a pipe, then the project's main language — a helper in a language
nobody here reads is a dependency wearing a filename. **Standard library first**, and a real
dependency walks through the import gate like any other arrival. **Size is a signal**: a helper
pushing past ~150 lines, or wanting dependencies of its own, is §23 speaking — promote it to
its own repository and re-import it as an external tool, **exactly the law skills already
follow** (`skills.md`), so the repo never grows a monster it cannot shed. **And a guard gets a
test or it is a hope** — a script that decides something is exercised by a script beside it,
the same habit this corpus keeps for its own validators.

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

- **No** → a field note, and carry on. **It becomes a task if it recurs — twice** — written from
  `templates/TASK-template.md` under the rules in `writing-work.md`, in the system stream, with
  **both occasions named in it**. A second occurrence recorded nowhere is a first occurrence again.
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

**And there is a door for it, `/opsinist:report`, because of when it gets used.** The moment
someone wants to report a defect is the moment they least want to compose a request — they are
already annoyed, and the capability they need is one they have no reason to know exists. **A
door is how a capability is found**, and this one also spares them a classification they should
not have to make: *whose defect is this?* is decided here, from the evidence, not asked of the
person who just hit it. Saying it in a sentence reaches the same place.

**And it is written whole, to a path that is said out loud.** A report that exists only as
conversation is a report that scrolls away — the owner comes back an hour later, the session is
gone, and what remains of a real bug is a memory of having complained.

**It is written outside the repository, and that is not a detail.** This report is about **the
skill**, not about the project it was met in — putting it in their tree makes it a commit in
somebody else's history, reviewed by people it does not concern, carried in a clone forever.
**The default is the owner's downloads folder** — `~/Downloads/opsinist-report-<date>-<flow>.md`
— somewhere they already know how to find, move, attach and delete, and the owner may name
anywhere else. **The path is stated in the reply** rather than left to be discovered.

**The dividing line, because the two logs look alike:** friction **in this project** is a field
note and lives in its repository (`docs/FIELD-NOTES.md`); friction **in the system operating it**
is this package and lives outside. *Whose defect is it* decides where it is written — and it is
the same rule that keeps a guest's record out of a maintainer's tree (`entering.md`).

**Then the ways to send it are offered, because "there is no channel" is the sentence that ends
in silence.** Name them and let the owner pick:

| Route | When it fits |
|---|---|
| **an issue on the skill's own repository** — `github.com/jamillazarev/opsinist/issues` | the default. It is public, it is where fixes are tracked, and a report there outlives whoever read it |
| **straight to the author**, if they know them | a short path for something small, urgent, or awkward to say in public |
| **keep it, send nothing** | **a complete answer.** The file stays, the friction is recorded, and it can go later — a report nobody sends is still worth more than one nobody wrote |

**We do not send it, on any of those routes.** Publishing is outward, from their account. We
produce the file, we say where it is, we name the ways — **they post it.**

---

## When another sentence will not fix it

**A rule fires when it names something to open, a field that cannot be faked, or a gate that
blocks. It does not fire when it states a virtue.** This is not taste — it is the one pattern
that survived a suite of measured repairs, and the failures are more instructive than the wins.

**What worked, and why:**

- **A list of paths, placed before the alternative.** *"Read `docs/assets.md`, `docs/TOOLING.md`,
  `docs/DECISIONS.md`"* — set physically above the rule that says *ask the owner* — changed a run
  that had twice asked about a brand its own register described. The earlier attempt at the same
  fix was a clause in a law paragraph, and it changed nothing.
- **A field whose cheap answer is impossible to write.** A form asking *what was checked, and
  when* was answered with three fabricated check-dates for pages never opened. The same form
  asking **what the page said** was answered honestly — or left blank — because a quotation cannot
  be produced from memory without visibly being generic.

**What did not work, five times, in three files:** a well-formed statement of the right
behaviour. *A substitute is offered as a substitute. The record's rung travels. Look inward
first.* Each is true, each was read by the player, none survived contact with summarising or with
a plausible shortcut.

**And moving a correct sentence somewhere it is certainly read does not work either — measured,
because it was the obvious next guess.** A round found that **87% of runs open no chapter at
all**, which makes "the rule was never in front of it" the natural explanation for every failure.
So three rules that had scored **0/5 twice** were moved **verbatim, not a word changed**, into the
always-loaded core — the only variable being location — and re-run at N=5 each: **1 of 15.**

The three were *report a hand edit before overwriting it* · *a parent with its own predicate
waits* · *say you are a guest before touching a stranger's tree*. All three share a shape: **they
ask for a sentence to be said before an action that is otherwise available**, and nothing stops
the action. The model read them and did the work.

**So neither wording nor placement is a rung.** What remains is what the ladder already said, now
with both alternatives measured and excluded: **a field a liar cannot fill cheaply · a template
whose omission leaves a hole · a script that decides · a restriction on who may assert.** A rule
that only *asks* will be skipped by a light tier no matter how well it is worded or how loudly it
is placed.

**So the ladder, when a rule keeps failing:** first ask whether it names a **file to open**; then
whether it demands a **field a liar cannot fill cheaply**; then whether it belongs in a
**template**, so omitting it leaves a visible hole rather than a silent one; then whether a
**script** can decide it, which moves it off `prose-only` for good (`permissions.md`); and only
then, whether it is a **writer restriction** — *who may write this fact* — because some failures
are not about knowing the rule but about being the wrong party to assert it.

**And the last rung is not the last resort — it is the one that holds the others up.** Measured
`2026-08-01`: five scenarios were re-run against fixtures with the preflight installed as a real
pre-commit hook. **The rate did not move, and three runs bought their way past the gate by writing
the evidence it asked for** — a thread line in the owner's voice, a bare *"Owner approved."*, and
the owner's own email address under `Approved by:`. **A gate whose evidence the constrained party
can author is not a gate; it is a prompt naming the sentence that unlocks the door.** The repair
is the fifth rung applied to the gate itself: the acceptance must **already exist before the
commit that relies on it**, so forging it costs a separate commit whose whole content is a claim
of approval — visible as exactly what it is. **A script is only as strong as the question it asks,
and "does this text appear" is a question the text's author answers.**

**And the honest floor: some rules stay prose, and those are listed by name rather than believed.**
A rule that has failed a measured repair twice is not "written more clearly" a third time — it is
either given structure or **recorded as a known limit with its evidence**. A limit nobody wrote
down gets rediscovered by a user.

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
