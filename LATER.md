# Later — deferred, each with a moment that reopens it

**This project's own deferred list**, kept by the rule it gives everyone else: **a revisit trigger
that is a moment, not a date**. A deferral with no trigger is an abandonment wearing better
clothes, and this file exists so the ones here can be told apart from the ones nobody wrote down.

**What belongs here:** something real, understood, and consciously not done now. Not a wish, not
an idea — those go to the backlog or nowhere. **What does not belong here:** anything that stops
work now, which is a task with a blocker instead.

---


## ~~`diagrams.md` is at its budget~~ — answered 2026-09-06: beside the rule, not in a gallery

**Measured 2026-08-15**: the file stood at **499 lines of a 500-line chapter budget** before this
release added one, and `self-maintenance.md` §What-a-capability-owes requires a diagram for every
new mechanic. Those two rules meet at the next mechanic, not at some point in the future.

This release resolved its own case by putting the diagram in `cost.md`, the chapter it illustrates
— which is arguably where it always belonged, and `consulting.md` already carried its own. So the
question is not "where does this one go" but **whether `diagrams.md` is a chapter or an index**: a
gallery that must hold every diagram will keep hitting 500, while a chapter that holds the ones
which cross several rules can stay small if the rest live beside their rules.

**Answered 2026-09-06, and by use rather than argument** — the revisit trigger asked for the next
mechanic that owed a diagram, and two releases running had already answered it. Both put their
diagrams beside the rules they draw — the contradiction stop's in `escalating.md`, the cost one in
`cost.md` — and twice in one session a repair to an existing mechanic owed none at all and said so
instead of manufacturing one. **The gallery reading was the collision course, not the budget**: a
file holding every diagram meets 500 at each new mechanic, a file holding only what crosses several
rules does not. `self-maintenance.md` §4 now says so. The file sits at 500 of 500 today, and stays
there — which is the whole point of dropping the gallery reading.

## ~~Measure what the day-one cut actually bought~~ — run 2026-08-01, partly falsified

**Closed by measurement, and the verdict is split.** The **ordering** claim confirmed: the first
task is now written second, before every document, where it used to arrive after the scaffolding.
The **volume** and **time** claims **falsified** against the criteria written below before the
run: still ten to thirteen files, and turn two still at four hundred seconds against a stated
threshold of three hundred. `evals/RUNS.md` carries the table.

**What it taught, and the next thing to try:** the gate could see *order* and enforced it; it
cannot see *emptiness*, so once the task exists every document passes. **The corpus says day one
is four things and the hook enforces something narrower — the gap between them is the thirteen
files.** The predicate that would close it is *refuse a document whose body is a heading and a
template's braces*: checkable, a commission, and the shape that has worked twice. **Not
attempted**, because the criterion comes first — **and that half is open work under a struck
heading**, which the 2026-09-06 audit read past. Its form question is the last entry in this file,
on whether anything measures a document rather than a rule.

**The original entry, kept because the criteria are what made the verdict possible:**

## ~~Measure what the day-one cut actually bought~~ — the pre-registered criteria, kept

*This is the entry above as it stood BEFORE the run, kept whole because criteria written after a
result are not criteria. It is not open work.*

**Deferred because** the account stood at **92% of its seven-day allowance** on `2026-08-01`, and
an honest measurement of this change is three runs on the tier an owner actually uses — the tier
where the problem was found and the only one where the answer means anything.

**What to run:** `S2` on the strong tier, three runs, three turns, `defaults` answered — the exact
shape of the diagnostic that produced the numbers being compared against. **The baseline is
recorded**: `11–13 minutes` of advisor time across three turns, `10–13` files before any work
existed, the first task arriving in turn two of one run and turn three of the other
(`evals/RUNS.md`).

**What would falsify the fix:** the first task still arriving after the scaffolding, or the second
turn still running past five minutes. **What would confirm it:** a task in turn one or two, and
four files where there were thirteen.

**Revisit when** the seven-day allowance resets, or sooner if the owner who reported the
forty minutes comes back — **their session is worth more than a synthetic one**, and the fix was
made for them.

---

## ~~A wave's failure policy~~ — carried in 2026-08-06, with its second occasion

**The bar was met, then the shelf was cleared**: Dify's iteration modes were the first
occasion, the conveyor case named at carry-in (a batch where one corrupt source must not hold
thirty) the second, and the owner took it into the release — `on_child_failure` on the
parent's wave plan, default `escalate` unchanged (`decomposing.md`).

## ~~A `pack` mode for the inventory script~~ — deleted 2026-08-06, by the owner's call

**Removed unrequested rather than reopened**: no dispatch had hit a context ceiling, and the
owner chose deletion over shelf-keeping. **The idea survives in this paragraph and nowhere else**:
`scripts/inventory.py` has no mode dispatch and no `pack`, so if a real ceiling ever shows up the
mode is written from scratch. An earlier version of this line claimed the CLI was already shaped to accept one, which
was not true when written — checked 2026-09-06.

## ~~A nested layout — the machinery under one root directory~~ — carried in 0.2.0, by the owner's call

**The deferral said** flat `tasks/`-shaped paths were load-bearing across every validator,
hook, fixture and chapter, so nesting was a whole-stack format migration paid twice — once by
us, once by each owner. **The owner re-counted and overrode it**: the real path-logic surface
was ~10 points in three scripts, the rest plain text substitution — and the residue the entry
itself had named honest, the **name collision** with a project's own `tasks/` or `docs/`, was
the argument *for* moving. So it landed exactly as the entry priced it: a major-version
migration with its own map (`scripts/migrate-layout.py`), the machinery under `_ops/` — named
to sort first and to collide with nothing — and a flat-root fallback in the door so an
unmigrated project fails toward the notice, not a stack.

## A generated Opportunity-Solution-Tree view over the specs

**Deferred because** the data half landed on 2026-08-06 — the spec's `Opportunity` field names
the need and cites its insight, so every new spec feeds the tree — and only the generator
remains: mermaid between markers (`PATTERNS.md` §6, same shape as `touched by:`), a day of
work with no requester yet. A view nobody reads is furniture; the field is not, because a
solution with no opportunity above it now fails a read even without the picture.

**Revisit when** the first project running product discovery asks to *see* the tree, or a
review finds a solution shipped with no opportunity above it.

## `starts: webhook` — an external trigger the automation can declare

**Reopened as a live candidate 2026-08-06 — the listener now exists somewhere real.** OpenClaw
was measured on this machine: a resident WebSocket gateway, `cron`, agent hooks — the first
runtime that could actually *hold* a declared trigger, where every earlier survey found only
serverless sessions. The shape stays settled: `webhook:<name>` beside `schedule:<cron>`,
executed by the host that has a listener, under the schedule's own law — *one that silently
did not run is worse than one that says it was late*.

**Revisit when** the first automation actually needs an external event — and the first step
then is verifying OpenClaw's trigger surface (its cron/gateway API), not building one.

## ~~Project-local skills must survive an upgrade that ships a same-named stock skill~~ — reopened 2026-08-05, taken into the release

**Its own trigger fired the day it was written**: the owner read the entry and took it into the
spec-format release (batch 6, beside the screener work). The rule it called for is the one being
added: **local wins, upgrade never overwrites it, and the collision is surfaced rather than
silent.** Kept here because the check that produced it is evidence: `upgrading.md` protects the
owner's *conventions*, and nothing protected their *files of the same name* until this.

---

## A tripwire for work bypassing the machinery wholesale

**The evidence:** a live project split into two eras at one commit — before it, six honest run
records and twelve tasks with done-definitions; after it, **0 of 33 commits touched `_ops`** while
the site shipped, decisions changed unrecorded (domain, language count, act format), and the
board froze at "created". The guard fired on every commit and had nothing to say, because no
check reads *work advancing while the record stands still*. The shape of the form: the project
preflight warns — never fails — when the last N commits carry zero `_ops/` paths in a repo whose
guide declares an operator. **Warn, not fail, and once**: site work is legitimate; the record
going dark is the smell. **Revisit when:** the next takeover audit or field report shows a second
project with a dark era — twice is the threshold everywhere here.

## A channel that reaches the owner who is away

**Requests age in files, and nothing tells an owner who is not at the terminal.** Evaluated
2026-08-14: Agent-Reach (71k★, MIT) — declined; despite the name it is **inbound only** (agents
reading platforms via cookie scrapers, ToS-gray, churn-prone), it contains no notification
surface at all. The honest candidates remain the harness's own push notifications and a
Telegram-bot shelf row (one token, owner-controlled, off-terminal). **Revisit when:** a request
ages past its threshold unseen in a real project — that is the moment the need names the row.

## A market-recon distillate template for `research/`

**The folder exists with no named shape** (`project-layout.md` — "studies and their
distillates"), and a live project's recon produced clean per-study documents with nowhere agreed
to converge. The substance worth keeping from the 2026-08-14 gap analysis: analogs land in the
competitor register (now with stage/outcome) · what-to-borrow and risks-and-failures as
distillate sections citing register rows · the delta is the positioning brief, homed in
`BRAND-template.md` §Positioning. **Revisit when:** the next real market-recon study is
commissioned — a template written before its second use is a guess.

## The advisor-side half of the doors: nothing forces wiring at stand-up

**Measured 2026-08-14, N89 at 0/3** (2 of its 5 runs voided): every graded day-one run stood the project up ad hoc — no
guard wired, no doors, no type file — so the guard's new doors check (the wired-project form,
landed the same day) never gets its chance. The prose instruction alone does not survive
contact, which is this corpus's oldest measurement. The candidate form: the plugin's own
SessionStart hook already delivers the migration fact in operated projects — the same mechanism
can say, once, *"this operated project has no wired guard and no doors"*.

**Revisit when:** a round re-measures N89 with the wired-project form in the field — if ad-hoc
stand-ups persist, the hook line is built, and a second round with no passes is the threshold. (This said
*"the next full round after 0.2.7"*; eight releases later N89 has been measured once, so the
version was never the condition — the second measurement is.)

## The council has a field but no gate, and a document has no seam to hold one

> [!NOTE]
> **This is a debt against the capability bar, not work consciously deferred** — the distinction
> this file's own contract draws. It stays because the missing half IS deferrable and its trigger
> is real; what belongs beside the bar, and not in a list of things not yet built, is the
> admission that the bar was not met.

**Named 2026-08-14, at the release that shipped it.** The capability bar has four clauses and
says *no exceptions for small ones*; the council shipped with the showcase trio and a declared
field (`angles · voices · provider`), and **without the other two — no form where it can fail,
no mutation test, and therefore no dated measurement of the field ever appearing**. This is
written here rather than implied met.

**Why no form today.** A council is a consultation: zero standing footprint, so its synthesis is
an answer in a conversation, and there is no artifact for a gate to read. Every enforceable rule
in this corpus keys on a file — a staged commit, a row, a request. The declaration is real
guidance and unenforced guidance, which is the class this corpus keeps measuring at ~0/5.

**Revisit when** either becomes true: a council's synthesis is written to a file (the owner asks
to keep it, or a research flow persists one) — that file is the seam, and the gate is a
missing-declaration refusal with its mutant · **or** the next full round measures whether a
council fires with its price and its declaration at all, which would give the claim its date. If
a round shows the field is simply not written, the honest repair is to delete the sentence rather
than repeat it louder.

## The repair exemption is judgement, and the test that would replace it has not paid its price

**Named 2026-09-07, the day it was written and taken back out.** `self-maintenance.md` §4 says a
repair owes only the fact, not the diagram and not the situation. **Nothing decides what a repair
is.** Clauses 1–3 of the bar name artifacts a script can find; this one is answered by a sentence
in the changelog entry, written by the person who wants the answer — and it was claimed twice in
one session before anything checked it.

**The test that would close it**, drafted so it is not re-derived: *a change shipping a **new form**
— a gate, a field, a refusal — is a new mechanic and owes the trio; a change that only alters what
an existing form reads is a repair.* Read off the diff, not off the author's account.

**Why it did not ship the day it was written.** `self-maintenance.md`'s own ladder puts a rule at
rung 3, and rung 3 costs **a week between the first dated line and the promotion, and it still
reproduces**. This was conceived and written into a standing chapter in one sitting, on one
occasion — the dotted branch of that section's own diagram, *promoted the same day* → *a rule that
was true once, on one machine, about one version*. The exception is a defect with a live blast
radius; a test telling authors how to classify their own changes is a lesson, and lessons climb.
**A lens caught it in the same release that wrote it**, which is the ladder working at the only
moment it can.

**What a form would read**, when it has earned the rung: `preflight.sh` §1b-bis already resolves
the last tag (`last_tag=$(git describe --tags --abbrev=0 …)`) and already names `${last_tag}..HEAD`
as the range the lenses run over, and §11 already reads the entry being shipped. A check would grep
that range's diff for a **new section header in `templates/company-preflight.sh`** — the shape that
file actually writes is `# N · `, **never `§`**, whose 44 occurrences there are all prose
cross-references — or a **new required field in a template**, which is what `+| **Verdict** |`
was. Then it asks the entry the question the signal raises.

**The mutant and the twin, and the first draft of this pair did not discriminate**: it accepted
*the word `repair`* as a valid answer, which is exactly what the mutant says, so the mutant passed.
The pair only works if the check refuses a **form signal answered by an unbacked claim**. **The
mutant is a release whose diff adds a section header and whose entry says *repair* with no trio;
the twin is one whose diff adds no form and whose entry says *repair*** — the twin passes, the
mutant is denied, and neither is decided by the author's word.

**Revisit when** the exemption is claimed in a release at least a week after 2026-09-07 and still
reads right — the ladder's own price, a second occasion recorded separately. **Do not count the
citations inside the release that wrote it**: 0.2.16 applied the idea three times in one commit,
which is one occasion, and reading those three as three is the mistake `checking.md` calls *a
second occurrence recorded nowhere is a first occurrence again*.

## The two capability bars have diverged, and neither repository says so

**Named 2026-09-07** by a lens asked to compare them. `self-maintenance.md`'s bar and the sibling's
`AGENTS.md` bar agree on clauses 1 and 2 — a form where the rule can fail, a mutation test — and
are disjoint on 3 and 4: this repository asks for **the claim dated with its measurement** and
**the showcase trio**, the sibling for **a scenario and the fixture it needs** and **a door**. Each
file says *four things* as though its own partition were the finding.

**It is mostly one set cut two ways, and that is the part worth fixing.** The sibling's *door* is
this repository's rule too — `AGENTS.md` carries *every capability has a door* outside the bar. The
sibling's *scenario and fixture* is enforced here in code and omitted from the stated bar:
`preflight.sh` warns when a version bumps and `evals/runsheet.tsv` is unchanged. The trio lives in
the sibling as a session-loop step with a narrower fact rule; the dated claim is folded into its
clause 1.

**Why not now.** Reconciling two bars is a change to both repositories' always-loaded contracts, and
the honest first step was the smaller one already taken: §4 no longer claims *both siblings' ledgers
carry the receipts* for clauses the sibling does not hold. Merging the partitions is a bigger move
than one release, and doing it while the divergence is one day old repeats the mistake the entry
above records.

**Revisit when** a third repository takes this bar, or when a capability ships in one repository and
is ported to the other — the first time the two lists have to agree on one object, which is when a
difference stops being a wording question.

## The promotion ladder's week has no form, only a citation a form could read

**Named 2026-08-21, at the release that shipped it.** `self-maintenance.md` now says a lesson
waits a week between its dated field-note line and its promotion to a rule — a filter against a
corpus that fills with laws written the afternoon something broke. **Two of its three parts are
already machine-readable** and one is not: field notes carry a `Date` column, and a promotion is
told to cite the line it came from, but **nothing reads the citation against the note's own date**,
and nothing notices a rule that cites nothing at all.

**Why no form today.** The seam exists — a promotion touches a rule file and a field-notes line in
the same commit — but the gate would have to tell a *promotion* from any other edit to a rule
file, and there is no field declaring one. Inventing a field for the gate's convenience is the
shape this corpus refuses: the form should read something the work already writes.

> [!NOTE]
> **The precondition landed 2026-08-27, and the gate deliberately did not.** Read the trigger
> below before concluding otherwise: the column existing is not the trigger, a closure written by
> real work is. The closure this entry waits on
> (`checking.md`) was prose with no cell to hold it; it is a column now. **Building the gate in the
> same hour would be the law written the afternoon something broke, which is the exact thing this
> ladder exists to filter.**

**Revisit when** a `Closed` cell is filled **by a sweep closing real work** in a project running
this skill, and that closure reaches here as a field report — not by the person who added the
column, and not by a note written to demonstrate it.

> [!NOTE]
> **This trigger could not fire for a fortnight and nobody noticed.** It said *"this repository's
> own field notes"*, and this repository has none — `_ops/FIELD-NOTES.md` lives in a **project's**
> tree by `self-maintenance.md`'s own split, where friction in the work is noted, while friction
> in the system operating it comes here. A deferral whose condition is unreachable is an
> abandonment wearing this file's better clothes, which is the sentence at the top of this page.
> Corrected 2026-09-06 by reading every trigger against reality.

The template can hold the closure now; what the gate waits on is one
written for its own reasons, because a gate built on a shape nobody has used yet is a gate built
on a guess. The gate then reads: a rule added to an always-loaded file in the same commit as a
closure whose dated origin is under seven days old is refused, naming both dates. **The mutant is
a same-day promotion; the twin is one dated eight days back.** Until then the week is judgement,
and it is written here rather than believed.

## ~~The contradiction stop has no form~~ — shipped in 0.2.14

**Closed.** The entry asked for *a run record that can carry the answer it reached, not only how
it ended*, and refused to add the field for the gate's sake alone — *"it waits for a flow that
wants the verdict written for its own reasons."* That flow arrived: a reviewer's conclusion is
what the requester acts on, and a second reviewer can only be compared to the first if the first
wrote down what it concluded. The field is `Verdict` on `RUN-template.md`; the gate is in §1f;
the mutant and twin are the pair this entry specified, and both behave as it predicted.

## Convergence between independent reviewers is not read as a signal

**Named 2026-08-28**, from `qa-swarm` — surveyed in the 0.2.14 entry, whose `catalogue.md` row
0.2.16 removed. The four lenses already run independently
and each reports even when empty, which is half of what that harness does. The half we do not do
is the cheap one: when two of them land on **the same file and the same line**, that agreement is
evidence, and this project currently treats it as a duplicate to be merged away. A finding two
blind readers reached separately is not the same object as a finding one reader reached twice.

**Why no form today.** Lens output is prose in a task notification, not a record with a file and a
line — so there is nothing to compare. The same objection `LATER.md` raised about the contradiction
stop applies, and the same answer resolves it: **wait for a flow that wants the finding written
structurally for its own reasons** rather than adding the shape for a counter's sake. The review
request is the candidate — a review that lands as findings with locations is useful to the
requester whether or not anything counts convergence.

**Revisit when** a review answer carries findings as rows. The gate then reads: a finding two
independent reviewers reached is promoted, and the promotion is recorded, so a later reader can
tell an agreed finding from a repeated one. **The mutant is two findings from ONE reviewer merged
and promoted; the twin is the same pair from two.**

## The inventory is silent when a mount's CONFIG goes and its directory stays

**Named 2026-09-05, doing the ritual.** `find-installs.sh` gained a hermes row because a mount is
an install even though no file lands anywhere, and its comment covers one direction: *"it outlives
the directory it points at, which is how a cleanup elsewhere silently unplugs it."* The other
direction happened this release. `~/.hermes/` was removed between two runs; the row simply stopped
appearing, and `~/.agents/skills/opsinist/skills` still holds 21 files that hermes had been
mounting. The inventory's output is the canon by this project's own rule, so a canon that shrinks
without saying why is a canon that has to be re-derived by hand — which is what it exists to stop.

**Why no form today.** The honest check is not "did a row vanish" — rows vanish legitimately all
the time, and a diff against a remembered count is the shape this corpus refuses. What it wants is
a directory that *looks* mounted with no config naming it, and "looks mounted" has no test yet
beyond "a runtime we happen to know about used to point here". Guessing at that would be a check
that cries wolf, which is worse than this silence.

**Revisit when** a runtime's mount is recorded somewhere the inventory can read back — a stamp the
install itself carries, rather than a config only the runtime owns. The gate then reads: a
directory carrying our manifest, inside a runtime root, that no config mounts is reported as
orphaned. **The mutant is a live mount reported as orphaned; the twin is this exact case — config
gone, directory full — reported once and by name.**

## A "should this exist at all" ladder, and whether it changes anything

**Named 2026-08-22**, from a third-party plugin the owner asked about
(`github.com/DietrichGebert/ponytail`, MIT, 107,575 stars and 5,946 forks read from the API on
2026-08-22, created 2026-06-12). Its content is one ladder an agent walks **before writing code**:
does this need to exist · is it already in the codebase · standard library · a native platform
feature · an installed dependency · can it be one line · only then a minimum implementation.

**Why it is a real gap and not a duplicate.** `choosing-tools.md` holds a ladder for *which
vendor* — free → open source → self-hostable → embeddable → agent-drivable. Nothing in the
shipped corpus asks *should this code exist at all*. The nearest thing, **native-first**, lives in
`AGENTS.md`, which governs work on this repository and never reaches a project.

**Why it is not being taken today.** Two reasons, and the second is the corpus's own rule.
· Its headline rates — *"~54% less code (up to 94%) · ~20% cheaper · ~27% faster · 100% safe"* —
carry no denominator, no corpus, no date, and *100% safe* is not falsifiable. The ladder can be
taken; those numbers cannot be quoted here without breaking the rung rule.
· **A finding does not become a rule the day it is found** (`self-maintenance.md`). Two capabilities
shipped in 0.2.9 whose prose measures 1 in 10 and whose gates the round could not reach. Adding a
third before the first two are measured is the exact shape that section exists to refuse.

**What the round did buy, and it narrows the question rather than answering it.** N97/N98 ran.
The prose arm measured **1 of 10** — over ten dispatches the player added the move eight times and
wrote the declared line once, committing ZERO times. **N102 is N97 with *"then commit it"* in the
turn, the only difference, and it converted 3 of 3, every one refused first.** **The two rates do
not share a denominator and this entry will not pretend they do**: 1-of-10 is over every dispatch,
3-of-3 is over the three of five that reached the gate — the other two were void. That is the
comparison `evals/RUNS.md` itself draws and defends as outside the noise band; it is quoted here
with its shape rather than as a headline, because the paragraph above refuses a third party's rates
for carrying no denominator and this entry does not get an exemption from its own rule.

So a ladder of this kind **shipped as prose** lands in the band this corpus already measures near
zero; whether one shipped as a **form** changes anything is untouched, and that is the half worth a
release. If this ever arrives, it arrives as a form.

**Revisit when N97/N98 are re-run** against a decision this round left open — whether a scenario
meaning to reach a gate must say *commit it* in the turn, or whether not-committing is itself the
behaviour under test. `evals/RUNS.md` names that choice as owed and says the re-run waits on it.
The old trigger said *"when N97/N98 have measured the gates in the wild"*, and they ran without
measuring them: a `validator` reaches only a worker that commits, ten runs committed nothing, and
the round closes with **"0.2.9 has no gate measurement"**. **A first draft of this correction said
*revisit when a run reaches the gate*, which N102 had already done six lines above** — the same
failure, in the sentence repairing it.

**Do not install that plugin alongside this skill** — two plugins instructing one agent about how
to write code is the shadowing trap `evals/RUNS.md` measured. That is a fact about coexistence
rather than a deferral, and it stays in this entry because there is no shelf row holding it.

> [!NOTE]
> **This entry was closed on 2026-09-06 and reopened the same day, by three lenses reading it
> separately.** The closure called the prose arm *"a declared gate, in the field"* and cited a page
> whose own closing line says the gates were never reached — while this entry's paragraph above,
> untouched, already said *whose gates the round could not reach*. **An audit that reads triggers
> against reality has to read the evidence file, not the trigger's summary of what would satisfy
> it**; the reading was the failure, not the trigger.

## Nothing here measures whether a DOCUMENT works, only whether a rule holds

**What it is.** Every scenario in `evals/` puts a run in a situation and counts whether the rule
survived. None of them asks the other question: given this document and a task, what comes back —
how many tries to a clean result, how many violations of what it teaches, how big the output, how
far each iteration moved, what the reading cost. A rule can hold inside a document nobody can use,
and a document can produce good work while the rule inside it is never reached. The corpus has
sixty-odd documents and no measurement of any of them as a document.

**Why not now.** It is a second harness, not a scenario: several runs against one task, an
artefact compared across them, and counts that are not pass/fail. The existing rig measures a
verdict; this measures a distribution. Building it while the scenario rig still owes RUNS — N97 and N98
have never measured the gates they were written for — would leave two half-harnesses instead of
one whole one. (An earlier draft of this line said those scenarios owed *fixtures*; all four named
are bound in `evals/runsheet.tsv`, and two of the ids were written without their `N`.)

**What reopens it.** A document is rewritten for readability and nobody can say whether it got
better — the argument that has already happened twice about the always-loaded core and once about
`diagrams.md`. That is the moment: the first time a rewrite is proposed and defended with taste
alone.

**Where the method came from.** Sanity Labs measured their own design system this way and
published the findings, the method and the runner (`catalogue.md`, *Does the design system survive an
agent?*). Their counts are the borrowable half; their tool is theirs.

