# Patterns — the shapes this system reuses

Twenty-seven recurring forms, each named once. A rule that instantiates a pattern **cites it and
stops**; it does not restate the reasoning. That is the whole point: a pattern named once and
cited nine times is a form, and nine paraphrases are prose.

**Why this file earns its place.** The corpus arrived at the same shape repeatedly under
different words — the resolution cascade appeared in nine places, "store the atom" in seven,
"provenance is mandatory" in seven. Every paraphrase is a copy that can drift, and a rule
living in two files goes stale in one of them.

**The meta-rule above all of these:** **form beats prose, and this was measured, not argued.**
A regression gate on the system this one grew from found prose the mid tier ignored until it was re-formed into
structure. So when a rule does not hold, the repair is a **form** — a list, a required field, a
gate — never a stronger sentence.

**Adding a pattern:** it enters when the same shape appears in **three** places under different
names. Two is a coincidence; three is a form. Same evidence bar as making a skill.

---

## Resolution and inheritance

**1 · Resolution cascade.** Settings resolve **project → team → role → task**, most specific
wins, **each setting declares which rungs it has**, and the resolved value is **recorded on the
run** so "why did it cost that" is answerable afterwards.
*Applies to:* model · effort · fast · run strategy · pipeline · project guide · description
depth (`spec_mode`) · attention preset · skills · resources · terseness.
*Why the "declares its rungs" clause:* a pipeline has no role rung — it belongs to the work, not
the worker — and description depth carries a **per-type default on the project rung**, because
depth belongs to the kind of work. Stating these as declarations rather than exceptions keeps
the pattern whole.

**2 · One-way tightening, and loosening only by grant.** A lower level may only **raise** the
bar. Loosening is not a setting but a **grant** — `{right, grantee, scope, duration}` — that
expires by itself and is visible while it lives.
*Why:* a setting rots quietly; a grant announces its own death. The only value a gate has is
that it is believed.
*Applies to:* attention presets · the project guide · one-time passage of a destructive gate.

**3 · Own → group → project.** Effective sets resolve in that order and are recorded on the run.
Inheritance is **additive by default**; removal is an explicit, named subtraction, never a
silent replacement — because a replacement loses whatever the group adds next month, and nobody
notices.
*Applies to:* skills · resources · guide rules.

## Truth and derivation

**4 · Store the atom, derive the rest.** Measure once, at the smallest event; **never store
rollups** — they drift the moment anything is edited.
*Applies to:* progress · cost · team membership · the inverse side of a relation · the board ·
the roster · the usage cache.
*Corollary:* a derived cache is not a record. It may live outside markdown and outside git,
because deleting it loses nothing.

**5 · One side stored, the other generated.** "I am blocked by X" is a property of me, so it
lives in my file; X shows it in a generated block.
*Why:* storing both sides guarantees drift the first time someone edits one and forgets the
other.
*Applies to:* relations · team membership · `cited-by` in the source register.

**6 · Generated surfaces are views, never sources.** Markdown between markers, rewritten only by
its generator, carrying a generated-file header. **No rule lives only in a generated surface** —
including a diagram, because agents read the prose and only humans read the picture.
*Applies to:* board · roster · progress · children lists · changelog · analytics · diagrams.

**7 · Generate the index, don't maintain it.** A frozen list ages faster than anything around
it; generate it or search for it.
*Applies to:* `awesome-{topic}` instead of a frozen catalogue · a code graph instead of a
hand-kept map · the board · the roster.

## Time and change

**8 · Ages like a request.** Anything pending carries its age and surfaces past a threshold,
because **a wait nobody chased and a wait everybody forgot look identical from outside**.
*Applies to:* requests · `waiting_on` · escalations · grants · an owner-assigned task ·
favourites.

**9 · Nothing transitions itself** (the law is in `SKILL.md`). All children done
does not close the parent; a slipped task does not move a date. Each **surfaces as ready and
waits**.
*Why:* automatic transitions are how boards begin to lie.
*The one honest exception:* a parent with **no DoD of its own** is a folder, and closing an empty
folder asserts nothing — it may close itself, and the fact that it did is recorded.

**10 · Effect at the next boundary, never mid-flight.** A change to the machinery applies to the
**next** dispatch; work in flight finishes on the bytes it started with.
*Applies to:* settings · guide edits · skill versions · autonomy presets.

**11 · Check-date, not a tick.** Every recorded fact that can change carries **when it was
verified**; past its recheck it is **unknown, not fine**.
*Applies to:* the tooling register · catalogue rows · sources · facts quoted inside tasks.

**12 · Distil at rotation.** Compression happens **inside** the rotation step, so "we'll compress
it someday" is not expressible.
*Applies to:* threads · archives · DM attachments.

## Evidence and honesty

**13 · Provenance is mandatory.** Origin · when · who · what version. Without it an upgrade
cannot tell what it is updating and an audit cannot tell what is old.
*Applies to:* skills · resources · sources · persona consent · external pointers · catalogue
rows · imported templates.

**14 · Every thing carries its why.** A resource without it is a bookmark; a declared field
without it is filled inconsistently within a month; a batch line without it is ceremony.
*Applies to:* resources · declared custom fields · pipelines · mentions · batch operations.

**15 · Evidence, not verdicts.** A tool that pattern-matches produces **findings**, and a clean
report is not approval while a flag is not a rejection. Who decides what a finding means is
named separately.
*Applies to:* import scanners · skill-quality signals · synthetic reactions · cost slices.

**16 · Honest `enforced_by`.** Every gate declares what actually holds it: `request` ·
`validator` · `git-host` · `harness` · `prose-only` — and the rules that are deliberately
**not** gates are listed by name.
*Why:* a gate believed in but not enforced is worse than a stated rule, because it buys false
confidence. The four lenses are the compensating control for everything `prose-only`.

**17 · Three-way compare on drift.** Theirs changed · ours changed · both — **surfaced with
options**, never silently merged.
*Applies to:* external resources · tracker checkout · generated-block hashes · migration · a
template against its upstream.
*Corollary:* hashes are over **content**, never over modification time.

## Interaction

**18 · The bridge.** A conversation with an open outcome. Most exchanges end in an answer and
leave no footprint; the ones that cross the bridge ("let's build it") **seed work and leave the
conversation as it was**. No mode to switch, no third container.
*Applies to:* DM → task · task thread → subtask · consultation → project · audit finding →
task.

**19 · Address the group, never the guessed person.** The caller states **what and why**; the
group's routing rule decides **who**. Several may answer a question; exactly one may hold an
assignment.
*Why:* the caller should not need to know the roster, which is what lets the roster change
without rewriting every mention.

**20 · Push, don't wait.** A thing that has just arrived is **offered to whoever it plausibly
serves, at that moment**, instead of sitting on a shelf until someone thinks to look.
*Applies to:* new resources · advice one step ahead · a dependency update · a ripe deferred item.

**21 · Earned, never reflexive.** State notices its own consequences and says so **while it is
still cheap** — but only when it follows from the state, at most two options, one concrete
sentence, one nudge each, never nagging.
*Why:* the value of a suggestion is inversely proportional to how often one appears.
*Applies to:* the next action · settings noticing their own friction · deferred items ripening ·
leading indicators.

## Growth

**22 · Twice is the evidence bar.** Once is a task, twice is a pattern, and "we might need it" is
neither. Naming both occasions is part of the proposal.
*Applies to:* making a skill · adding a project-specific guard · raising a tooling need to a
task · adding a pattern to this file.

**23 · Promote what outgrew itself; don't nest deeper.** When a part needs parts of its own, it
stops being a part. Seen mid-flight, the promotion is **offered by name** — the destination and
what carries over — never reported as status → `checking.md`.
*Applies to:* milestone → release · subtask → task · chapter → skill · task resource → project
resource.

**24 · Budget declared at birth, expressed as a share.** The cost is stated when the thing is
created, as a **fraction of the window** rather than a fixed number, because windows differ and
the real question is how much room is left for the work.
*Applies to:* a skill's `core_budget` · a role's always-loaded weight · the project envelope.
*Corollary:* raising a budget is a decision with a stated cost, never a reflex; the first moves
are **move, don't squeeze**.

**25 · One position on a ladder, not a row of switches.** Where a set of things is ordered by a
single property, the choice is **where to cut it** — one value to state, resolve and change —
rather than one boolean each. The ordering carries the reasoning, so the setting does not have to.
*Applies to:* which layers land in the repository · the tool selection ladder · evidence rungs ·
the escalation ladder.
*Corollary:* the cut implies a **fan-out** — every whole-project operation resolves the
destinations first, then acts on each, and **one it cannot reach stops the operation** instead of
being skipped. Deletion, audit, handover, search and release are all this same shape.

**26 · The shape of a choice is decided before the choice is put.** Three shapes, and picking the
wrong one is its own defect independent of getting the substance right. **Readable from the
ground → read it, never ask** (is there a repo, is it theirs, is it empty). **A default is
defensible → state it as a filled-in form** with the recommendation already chosen, needing a
nod, not an answer. **No default is defensible → a real choice**, at most two options, each with
its consequence named.
*Applies to:* where the record lands · where the code lives · the two hard gates · a fix with
alternatives · a tool decision.
*Why:* measured — an eval found the same run over-asking (three open questions where the
defaults were already written in the prose beside them) and under-offering (one plan presented
where two were called for). Substance was right in both; only the shape was wrong.

**27 · Radical transparency: the record says how, not only what.** Anything that produced a
result is named on the result — the model, the effort, the strategy with its source, the tools
driven, the subprocesses spawned and their tiers, the rung of every claim, and what actually
enforces a rule. **Where something is
unknown or unenforced, that is stated rather than omitted**, because an omission reads as a
negative and a stated gap reads as a fact.
*Applies to:* the run record · a thread entry · a decision · a review verdict · `enforced_by` ·
the runtime profile · a persona's output · the prose-only list.
*Why:* every one of these was added after the same failure — a result that could not be priced,
repeated or argued with, because how it was reached had not been written down. **The cost of the
field is one line; the cost of not having it is that the answer becomes unfalsifiable.**
