# Upgrading — getting current

**Load when:** a new version of this system exists, a project is on an old format, or something
needs to move onto newer bytes.

**Two words, and they are not the same.** **Update** = new bytes arrive on the machine.
**Upgrade** = the project moves onto them. Confusing them is why people install something and
wonder why nothing changed.

---

## Four layers

| Layer | What moves |
|---|---|
| **this system's bytes** | the skill files on the machine — **by a route that differs per install**, below |
| **the project's format** | `schema_version` and the codemods that move a repo from one to the next |
| **attached skills** | third-party skills, re-screened |
| **tooling versions** | the things in the register, checked against their release feeds |

**Discovery precedes updating: run `bash scripts/find-installs.sh` and read the list it prints.**
It names every install, its version and its route, and flags the two states nothing else reports:
a symlink into a directory that does not exist, and a copy silently on an old version. Measured
`2026-07-31`: a machine remembered as holding three installs held **fourteen**, nine symlinked
into a directory that had never existed — wired into nine harnesses, loading in none. **"Updated
everywhere" is a claim about a generated list, never about memory**, and the list is re-run
afterwards so every row is seen to have moved.

**The routes that move the bytes live in `INSTALL.md`**, one per harness with its trap — the file
that decided how it was installed decides how it updates. **Verify by reading the installed copy,
never the command's output**: every one of those routes has reported success at least once for a
version it had not moved to.

**Preview first, always** — what changes, what it touches, what it needs; apply; verify. **The changelog is the migration map**: read the entries between the project's
version and the current one, and act on what they say rather than on the diff.

**And the map is read from the new version, not recalled.** Both ends are on disk: the project's
version in its guide's *Operated by* line and its `config.md`, the target's in the **installed
copy's own `CHANGELOG.md`**. Read the entries **there** — a migration performed from memory runs
against the release you last read about and fails silently, leaving a shape nothing describes.

**Then it is an audit and a delta, never a rebuild — and the delta reads both ways.** Re-running
the interview overwrites conventions the owner chose on purpose; the takeover discipline holds
(`entering.md`): read first, then **one list** — what this release adds that the project lacks,
**and the project rules the new corpus now contradicts** — each a finding with two named sides:
**the owner decides which wins, recorded so the next upgrade does not re-ask.**

**This is not the other audit, and saying which one you are running is its first line.** A
**takeover audit** measures a repository you have not operated **against the invariants**; a
**migration audit** measures one you already operate **against a version**. **The yardstick is
the difference**, and handing an owner who asked to upgrade a list of everything wrong with their
project is how an upgrade becomes an argument. `GLOSSARY.md` carries the pair.

**And the owner is not held while it runs** — the same three-part shape as reading a repository
(`entering.md`): **the arrival is inline**, seconds, naming both versions and where each was read
from; **the audit is background work**, a tier down, being extraction rather than reasoning the
advisor could not do itself → `dispatching.md`; **only the questions block**, once, in one batch.

**Say all three out loud at the start**: what arrived, that the audit is running and roughly how
long, and that the session stays usable. **An owner made to sit through a scrolling audit pays
for a wait that had no reason to hold the session**; one given no notice reads silence as a crash.

**The shape of it, because "be transparent" is an instruction nobody can follow:**

> *"You are on 0.1.2, the skill here is 0.1.5 — both read from disk, yours from the guide, mine
> from the installed copy's changelog. Nothing says a migration ran, so I am checking what those
> three releases mean for **this** project: what applies on its own, what needs a decision from
> you, what needs nothing. Background, a couple of minutes — keep going, ask me anything, and I
> come back with **one list**, not a stream of questions."*

Then the list, in the three piles, **and the questions in one batch with the recommendation
already filled in** — where the runtime offers a native way to ask a small set of named options,
it is used, recommended first, each carrying its trade-off, with a free answer beating the
buckets (`arriving.md`, `PATTERNS.md` §26). **Nothing in that message is a status report about
the tool**: every line says what it means for their project.

**And the end is said as plainly as the start** — applied, declined, waiting on a moment, and
where all three are written. **Where the runtime has no delegation, say that instead of
pretending** (`runtimes.md`): the audit runs inline, kept short, and the owner is told it will
take a moment. **A promise of a non-blocking upgrade that blocks is worse than an honest wait.**

**The list splits on one question — does this need you? — and that is the whole point of it.**
An upgrade that hands the owner a mixed list has made them read every line to find the two that
concern them.

| Pile | What is in it | What the owner does |
|---|---|---|
| **needs no answer** | mechanical and decided: a rule that tightened, a check that got stricter | **reads it afterwards.** Applied on approval of the batch, reported as done, never as a question |
| **needs your answer** | a setting with no honest default *for this project*, a choice the release opened, anything touching the four gated kinds | **answers, once, in one batch** — never one question per message, the same rule and the same reason as the debt list |
| **needs nothing at all** | additions whose absence already reads as the old behaviour | **nothing.** Named so the list is complete, and so the silence is visible rather than assumed |

**Nothing is applied before the owner has seen the list**, and it is applied in batches they
approve.

**The guide's `Operated by` line is the first mechanical item, always** — necessary to finish,
never sufficient to prove anything (the next section says why). Measured next door at N=3: **not
one run bumped it**, two then wrote their log line, and a written log is what silences the
session-start check. **Bump it in the same breath as writing the log.**

**A document the release adds arrives when it has something to hold, exactly as on day one.** An
upgrade is the other place this goes wrong, and for the same reason: the release names a file, so
the migration creates it, and the owner gains an empty `TEAM.md` from a version they installed
rather than from a team they hired. **The delta names it as available, not as missing** — and it
is written at the first decision, the first deferral, the first role, whichever the file is for
(`starting.md`). **A migration that leaves a project with more empty documents than it had is a
migration that made the project worse**, however faithfully it followed the changelog.

**Only the advisor runs a migration; a worker that notices one escalates.** It edits many
artefacts at once — the owner's call by definition — and a worker holding one task has neither
the view nor the standing. **It says so and stops**: a request with an age (`requests.md`), its
own task continuing if the pending step does not touch it. **A migration run by whoever noticed
it first is how a project gets migrated twice.**

**The middle pile is the one that must not be guessed**: a default chosen on the owner's behalf
during an upgrade is the same failure as one chosen during the interview, arriving later and
harder to notice.

**Most additions are silent by design, and saying so is part of the list.** A new setting whose
absence reads as its old default costs an existing project nothing: no codemod, no
`schema_version` move, no action. **An upgrade that reports "three additions, none of which
require anything from you" is a good upgrade**, and it is the one an owner can trust the next
time it says something *is* required.

### What is already written is part of the delta, not just what is missing

**The easy half of an upgrade is the files that do not exist yet. The half that gets skipped is
the work already written under the old shape**, and it is the half the owner actually feels.

**A setting that decides the form of an artifact makes every existing artifact a candidate.**
When `spec_mode` was inherited rather than asked, tasks were written at the floor by nobody's
decision — so a project that now answers *"we work from specs"* is not only missing a setting,
**it is holding tasks that lack what the answer requires**: the document to point at, the
reference into it, the closing step that updates it. **Naming the setting and leaving the tasks
is a half-migration**, and it looks finished.

So the audit reads the artifacts, not only the tree: **how many are affected, what specifically
is missing from them, and what bringing them into shape costs.** That count is a line in the
pile that needs an answer, because rewriting someone's tasks is their call.

**Three honest endings, and the upgrade offers all three:** bring them into shape now, in batches;
bring them **forward only** — new work takes the new form, existing tasks stay, recorded as a
deliberate split rather than left as drift; or decline, with a revisit trigger that is a moment.
**What is never acceptable is silence** — a setting saying one thing and the tasks another, with
nothing saying why. **The same test applies to any setting that shapes an artifact**: if the
answer would have changed how something was written, everything already written is in scope.

**What the release left behind is in the delta too, and it is the half nobody looks for.** A
migration adds; it also **strands**. A file a superseded step created, a document the new version
no longer reads, the debris of a run that died halfway — none of it announces itself, and all of
it looks deliberate to the next reader. **So the audit names orphans as their own line**: what it
is, which version put it there, and what reads it now — *nothing* being the answer that makes it one.

**And naming is where it stops.** Deleting is one of the four kinds that route to the owner, so
an orphan is **reported, never removed** — and *"leave it"* is a legitimate, complete answer that
gets recorded as one rather than re-raised next release. **An upgrade that tidies is an upgrade
that deletes something load-bearing**, eventually, and the owner will not know which release did
it. When removal is agreed, it enumerates its destinations first (`storing.md`).

**Tasks are not one pile, and the state a task is in decides what may be done to it.** Treating
them alike is how a migration either disrupts live work or falsifies finished work.

| State | What happens | Why |
|---|---|---|
| **closed** | **never converted.** Counted and reported, and that is all | a closed task is a **record of what happened**, written and done under the shape that was in force. Rewriting it produces a spec that never guided the work and a history that describes a process nobody followed — the same reason `docs/DECISIONS.md` is append-only |
| **a run in flight** | **never touched, and not even offered** | the offer itself would have to interrupt. It converts at its next transition, which is a seam that already exists and already writes to the thread |
| **started, no live run** | **the owner chooses**, and the recommendation is *convert at its next transition* | it costs nothing and rides a seam that is coming anyway. Converting now is legitimate where the new form would change how the work gets done — but that is a decision, not a default |
| **open, not started** | **converted with the batch** — this is the safe pile | nobody is holding it, nothing is invalidated, and leaving it is how a project ends up with two forms in its queue |

**On a large project there is a fourth ending, and it is usually the right one: the base now, the
rest on touch.** Converting nine hundred tasks in a batch is a diff nobody reads; *forward-only*
gives up on the nine hundred. **On-touch splits it honestly** — settings, the files the version
needs and the log line land now, bounded; **every other artefact converts the next time work
opens it**, when someone is already reading it and can judge the result.

**And it is only real if "converted" is machine-checkable.** A lazy migration whose predicate
lives in prose is not lazy, it is abandoned — nothing can tell a converted artefact from an
untouched one, so nothing can refuse, report or finish. **The migration declares the predicate
when it chooses this mode**: for a spec format, *a task carries its spec reference*; for a
renamed field, *the new key is present*. One line, checkable by a script.

### Absent, and the three reasons — only two of them are findings

**"You do not have X" is not one fact, it is three, and telling them apart is what keeps an
upgrade from re-opening settled questions.**

| Why it is absent | What it is | What the audit does |
|---|---|---|
| **the release just added it** | a genuine delta item | goes in the list, in whichever pile it belongs |
| **it was never used, and the release now makes it load-bearing** | **an adoption, not a migration** | offered with its cost, **declinable**, and the answer recorded |
| **the owner turned it off or declined it before** | **already decided** | **not raised at all.** `config.md` says which modules are on; `docs/DECISIONS.md` says what was declined and what would reopen it |

**Adoption is the one people get wrong, and the case a long-lived project meets most.** A release
can turn something optional into something a newer mechanism assumes — and a project that never
used it is not behind, it **worked differently on purpose**. So it is put as a choice with its
price, never as a defect: *"pipelines were optional and this release's gate reads them; adopting
costs about this much, and here is what happens if you do not."*
**"We do not work that way" is a complete answer**, recorded with a revisit trigger that is a
moment, and **not offered again until that moment.**

**The audit reads the module state before it reports anything missing.** A disabled module
reported as a gap is the fastest way to teach an owner that the list is noise — and the second
fastest is offering, every release, the thing they already said no to.

**The conversion is enforced where the touch happens, not remembered.** Writing to an artefact
that is still in the pending scope is **refused, with what is missing and how to supply it** —
the same shape as every gate here, and the reason this mode works at all. Measured across three
rounds: a rule that asks a run to convert something buys nothing; a rule that refuses the write
until it is converted is the one that holds.

**Pending is a state with a count, a trigger and an ending.** The log line says
`applied-base · pending-on-touch`, the scope is recorded with its predicate and its size, **the
status check reports how many remain**, and a **revisit trigger that is a moment** — before the
next release, at the first new maintainer — stops *lazy* becoming *never*. **At zero the log gets
its closing line**, because a migration that never says it finished is one nobody can prove.

**The audit is bounded the same way.** On a project this size, reading every artefact to produce
the delta costs more than the migration: **count and sample instead**, say the sample size, and
name the number as an estimate rather than dressing it as a census.

**The counts are in the list, not just the total.** *"Forty-two tasks: thirty closed and
untouched, eight open and convertible, three started, one in flight"* is a sentence an owner can
decide on. *"Forty-two affected"* is not, and it makes the safe pile look like the risky one.

**A closed task is still allowed to be pointed at.** If the new form wants a document, that
document may reference what was already built — what it must not do is **claim to have specified
it**.

**And whenever an artifact does change form, its thread says so** — what changed, why, and which
version asked for it. A task whose shape changed with nothing in its history explaining it is
indistinguishable from a task somebody quietly rewrote.

### Did the migration ever run? The version line cannot answer that

**Swapping the files is not migrating the project, and the two are indistinguishable from
outside.** Every install route moves a plugin, an extension or a directory; none touches the
owner's repository. So a project can carry the newest version number, have received none of what
that version asked for, and **look exactly like one that migrated cleanly** — the state every
project upgraded before this section existed is in, by construction.

**So it is recorded in the repository, where every other entity lives** — a migration only a
conversation remembers is one the next session cannot see. Three places, each already existing:

| What | Where | Why there |
|---|---|---|
| **which steps ran** | the **migration log** — a `## Migrations` section in `config.md`, one line per step: `from → to · date · outcome · who` | it sits beside `schema_version`, which is the *state*; the log is the *history* that state alone cannot carry |
| **what the owner chose** — and especially what they **declined** | `docs/DECISIONS.md`, in the shape it already has: considered · chose · rejected · because · revisit-if | a decline is a decision, and re-asking it every session is how an owner learns to ignore the question |
| **what was deferred** | `LATER.md`, with a revisit trigger that is a moment | the same place every other deferral lives |

**The outcome is one of five words, and the list is closed.** A log read by a comparison cannot
afford prose: *"mostly done"* is unreadable to a check, and a vocabulary that grows per release
is a vocabulary nothing can rely on.

| Outcome | What it means | What the next session does |
|---|---|---|
| `applied` | the step ran and the project carries it | nothing |
| `nothing-required` | checked against this project, no work followed | nothing — **and this line is why later messages are free** |
| `declined` | the owner said no, and the reason is in `docs/DECISIONS.md` with its revisit-if | **does not re-ask**; the trigger reopens it |
| `deferred` | agreed, not now (`LATER.md`, with a moment for a trigger) — **and the same word for a delta that stopped to ask**: waiting silently leaves the trace of never having looked, and the owner meets the identical list next session | **does not re-ask**; the moment, or the answer, reopens it — and the line is **replaced, not duplicated** |
| `failed` | it was attempted and did not complete, with what broke | **retries**, and appends a second line rather than editing the first |

**A version is covered when its newest line is any of the five.** `failed` covers it too — the
attempt is recorded, the retry is the next line, and a step that fails forever is visible as a
column of `failed` rather than as silence.

**It is a log, not a field, and the difference is load-bearing.** Migrations accumulate, and a
single *"last migration"* value answers **which version** while losing **what happened on the
way** — which step was declined, deferred, or re-run after a failure. **Append-only, one line per
step, never edited in place**, the same discipline as `docs/DECISIONS.md`: a re-run **appends**,
because *"this was attempted twice"* is exactly the fact a later reader needs.

**And it is what makes a multi-version jump answerable afterwards.** *"We came from 0.1.1, four
steps ran, one was declined, one is deferred until we take on a second maintainer"* is a sentence
the log can produce and a version number cannot.

**A declined step is not an incomplete migration.** It is a completed one with a recorded no, and
the log says so — otherwise every future session reads the gap as work outstanding and asks
again. **The revisit trigger is what reopens it**, not the next upgrade.

**When the log is absent entirely, no migration has run** — which for a project created before
the log existed is a fact about this system, not a fault of theirs. The resolution is cheap and
identical either way: **run the audit**; against a conformant project it finds nothing and says so.

**A guest repository has none of this and gets none of it.** No log, no check, no line written —
a contributor passing through owes the maintainers no record of our versions, and `entering.md`
is absolute about nothing of ours landing in their tree. **The record for guest work is kept with
you, elsewhere** (`storing.md`), and that is where its version belongs. The same silence covers a
quick job and a question with nothing to build: **no project, no log, nothing to check.**

**Each line records who ran the step**, because a project has more than one pair of hands and
*"who migrated this and when"* is the first question asked when two clones disagree. The
identity is the one git already knows — no new notion of a user, and nothing to keep in sync.

**Two clones, two appends, one conflict — and the resolution is always both lines.** An
append-only log conflicts exactly where two people wrote at the end, and **keeping both entries
in date order is correct every time**: two people checked, both facts are true, and the log is a
history rather than a state. Nothing is ever resolved by deleting the other person's line.

**An older skill meeting a newer project is real** — a rollback, or a teammate who has not
updated. **It must not break and must not lie**: a log line stays readable to a version that has
never heard of it — a date, two versions, an outcome word, an author. A log naming a version
*ahead* of the one running is **reported, not migrated backwards**, and **nothing here ever
rewrites a line another version wrote.**

**The log is also the marker, and that is why no marker file exists.** Every command needs to know
whether this project was migrated to the version now running it, and **checking must cost nothing
after the first time** or every verb pays for it. So the check is a comparison, not an audit:
**does the log's newest step name the running version?** One line, from a file the session opens
anyway.

**Which means a check that finds nothing still writes a line.** `0.1.4 → 0.1.5 · nothing
required` is what makes the next hundred commands free, and it is also the honest record: *this
version was checked against this project on this date, and the answer was no work.* **A log of
changes only would leave "checked and clean" and "never checked" looking identical** — the exact
confusion this whole section exists to end.

**And the line is not gated on approval — only applying is.** Two different acts: the line
records that somebody *looked*, which needs nobody's permission; the changes need the owner's.
**Treating them as one is what loses the record** — measured next door, a run that built the
whole delta, asked its one real question and wrote nothing left a project indistinguishable from
one nobody had opened. Waiting is `deferred`, written when you decide to wait.

**A cache would have been the wrong shape.** `.index/` is gitignored and rebuildable, so a marker
there answers for one laptop — and the question is about the project. **The record already travels
with the repository.**

**A version whose migration never ran announces itself** — *"this project reports version X and
nothing records that its migration ran; I am checking what that means for you"* — and **runs the
audit itself**, on the shape above.

**And what waits is what the migration would change, not everything.** Blocking a whole session
is correctness nobody thanks you for; writing a task in a form the pending step is about to
change is worse, because it makes more to migrate. **Reading, answering, status and cost continue;
artefacts the pending step reshapes wait**, with the reason said in one line.

### When the project is already on the current version

**The common case, and the one an upgrade handles badly in both directions**: manufacturing work
to justify having been asked, or answering from the version string and calling it done.

**Say it, and say what it does and does not mean.** *"You are on the current version"* is a claim
about a number in a file, **not a claim that the project matches that version**: an upgrade
interrupted halfway, a hand edit, a setting nobody ever answered — each leaves a project whose
version line is current and whose tree is not. **A version comparison that short-circuits the
audit is a check that cannot fail**, and this file has paid for that lesson (`self-maintenance.md`).

**So the audit still runs — and it is cheap**, because there is no changelog span to walk: read
what the current version expects and check the tree carries it. Two endings, and both are short:

- **Nothing found.** One sentence — the version, where it was read from, and that the artefacts
  were checked too. **Nothing is created**: an upgrade that always leaves a file behind teaches
  the owner to ignore the files it leaves.
- **Something found.** The version line and the tree disagree, **and that disagreement is itself
  the first finding** — said plainly, with which is believed and why, then into the same split
  list as any other delta.

**Neither ending re-runs the interview**, and neither invents an optional improvement to have
something to show.

### A jump of several versions

**Entries are applied in order, and a later one may supersede an earlier one.** Reading them as a
pile invites doing work that a subsequent release undid — the map is a sequence, and it is walked.

**One list still, however many versions it spans.** The releases in between are how the list was
computed, not how it is presented: an owner upgrading across four versions wants *"here is what
this means for your project"*, not four changelogs. **The pile that needs an answer is the one
that grows** — and it is still asked in one batch.

**Superseded steps are named as skipped, not silently dropped.** *"0.1.2 asked you to move X;
0.1.4 removed X entirely, so that step is skipped"* costs one line and prevents the owner
discovering the contradiction themselves.

**And the questions are deduplicated across the span, then asked in their newest form.** A jump
is where the same setting is introduced by one release and widened by a later one — **that is one
question, not two**, and it is put as the newest release defines it. Asking the older form and
correcting it a message later is how an owner learns that a migration's questions are noise;
asking both is worse, because the two answers can disagree and nothing says which wins. **The
same holds for a question the owner already answered on the way** — if a step's setting is
present in `config.md`, the later release refines the value, it does not re-ask for it.

**The log gets one line per release that had something to say.** Releases that required nothing
fold into a single line naming the span — `0.1.1 → 0.1.4 · nothing-required` — because a column
of empty lines is not history, it is padding. **A release that was declined or deferred always
gets its own line**, whatever else happened around it: that is the one thing the next session
must not have to infer.

**Past some distance this stops being an upgrade.** A project many versions behind, whose
conventions the corpus has since reorganised, is closer to a repository being met for the first
time — **read it as one** (`entering.md`), produce the debt list, and let the owner choose the
order. The threshold is judgement, not a number, and **the honest move is to say which of the two
you are doing and why** rather than performing a migration whose steps no longer describe the
tree in front of you.

**When the project does not say which version it is on**, that is the first finding, not an
obstacle: infer it from what is present — which files exist, which conventions the tree follows,
what the guide names — **say plainly that it is inferred and on what evidence**, and record the
result so the next upgrade starts from a stated version rather than inferring again. **An
inferred origin makes every step below it a judgement**, and the list says so.

**The delta interview is a delta, too.** Only what the new version introduced **and** the project
has not already answered — the same rule as entering a repository, for the same reason.

**Rollback is normal.** The previous commit is the restore point; there is nothing separate to
keep.

**Outside git there is no previous commit, and that is where a copy gets taken.** Uninstalling a
plugin, replacing an extension, moving a store: the safe move is to copy first — and **a copy
taken has exactly two endings, both of which include telling the owner.**

| Outcome | What happens to the copy |
|---|---|
| the step **succeeded** | **the copy is removed**, and the owner is told it existed and is gone |
| the step **failed or was abandoned** | **restore from it first**, verify the restore, **then** remove it — and say what failed, what was put back, and what state things are in now |

**A copy left behind is not caution, it is litter that looks like a backup.** Months later nobody
can tell a deliberate archive from an abandoned half-migration, and the one thing worse than no
backup is two states with no record of which is live. **Measured on this system's own release:**
a Gemini extension was copied before an uninstall, the reinstall succeeded, and the copy sat
there unmentioned until someone asked — the process had no ending written for the happy path,
only for the sad one.

**Finish by explaining it in plain language** — what changed, why it helps, what to do differently
now. That is onboarding a **person** into a release, and it is a different thing from onboarding
them into the system or into a project → `arriving.md`, `entering.md`.

---

## Format changes carry their own migration

This is the layer people skip, and it is the one that hurts.

**A change that alters the format does not ship without its codemod and a line about its risks.**
Not "here is what changed" — **here is what to run, what it will touch, and what could go wrong.**

**`schema_version` is what makes that possible.** A repo says which format it is on; an upgrade
knows which steps stand between that and now, and applies them in order.

**Moving a rule between files is a format change** for anyone who linked to it. That is not a
technicality: with the corpus split into companions, a reference that pointed at a section is a
reference that can break, and **only a link check across sections catches it** → `checking.md`.

**Anchors must be headings.** A reference to a bold line or a table row is invisible to tooling and
**dies silently the first time the table is reorganised**. If something is worth pointing at, it
gets a heading.

**An old-format project is a migration target, not a broken one** — and running an upgrade on one
is a scenario worth testing rather than assuming.

---

## Skills are re-screened, not assumed

**The version you vetted is not the version you are about to install.** Diff against the screened
one, scan it again, and **read the prose diff — a new paragraph is as much of a change as a new
script** → `security.md`.

Then record the newly-screened version, so the next upgrade has a baseline.

**Upgrading a skill that was never screened means screening it now, from scratch.**

---

## Tooling versions

For each entry in the register, check its release feed for a newer version **and for breaking
changes**.

**A tool that changed its interface breaks agents silently** — exactly like a stale pin, and with
the same symptom: work that used to succeed starts failing for reasons that look like the agent's
fault.

**Never upgrade unasked.** Summarise what changed and what it would touch — which roles carry it,
which rules mention it, which flows use it — and offer.

---

## When it applies

**At the next boundary, never mid-flight.** Work in progress finishes on the version it started
with; the next dispatch picks up the new one. **One version per unit of work.**

The advisor **reports which version it is now running**. A worker that proposed the new version
runs its *next* task on it — normal — but a single piece of work does not change under itself.

**Content applies on the next read.** Where a runtime registers commands or hooks at startup, those
need a restart; plain content does not.

**And where a team is running: wait for it to be idle.** Upgrading underneath live work is the
same failure as changing a setting mid-flight, with more moving parts.

---

## After a bad one

**Name what regressed** the way a recovery does → `recovering.md`.

**Restore the previous commit**, verify the regression is actually gone, and **write down what
broke, next to the entry**. The next attempt starts informed rather than repeating it.

**A rollback that nobody verified is a second change of unknown effect.**
