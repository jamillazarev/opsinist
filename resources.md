# Resources — places to look, and things attached

**Load when:** adding a reference, attaching a file, dropping a link into a conversation, or
asking where the project's knowledge lives.

**Three neighbouring things, deliberately distinct.** A **skill** is a procedure the agent loads
and follows. A **resource** is a place it goes to look. A **source** is the evidence behind a
claim it makes. **Blurring them is how bookmark piles form.**

---

## The fields

| Field | Note |
|---|---|
| `name` | short handle |
| `kind` | `url` · `file` (a path inside the repo) · `external` (a pointer with its own distillate) · **`repo`** (a dependency) |
| `target` | the URL or the path |
| **`why`** | **what it is for and when to consult it** |
| `scope` | project · team · role · **task** |
| `added_by` · `added_at` | provenance, which is mandatory (`PATTERNS.md` §13) |
| `last_checked` · `status` | ok · moved · broken — maintained by the link check |

**`why` is mandatory, and it is the whole difference between a resource and a bookmark**
(`PATTERNS.md` §14)**.** A link
with no stated purpose is consulted by nobody and removed by nobody, because removing it might
lose something and nobody knows what.

**Typing the purpose is optional and belongs to the project.** Reference, specification,
documentation, example — a project that wants board columns and filters over those declares a
`select` field and gets them. **A taxonomy baked into the core would be right for one domain and
wrong for the rest.**

---

## Scope, and the one that is not a rung

**Project · team · role** resolve by the usual cascade — **own → team → project** (`PATTERNS.md` §3), and the
effective set is **recorded on the run**, like skills, so what an agent actually had is never
reconstructed by guesswork afterwards.

**Task scope is a different axis, not a fourth rung.** A reference, a screenshot or a spec attached
to a task is about **this work**, not about who does it. It lives with the task and dies with it —
**unless someone promotes it** to project scope, which is the ordinary way a one-off reference
becomes shared knowledge.

**An attachment dropped into a task's thread becomes a task resource.** Registered, carrying a
`why`, link-checked, surviving the thread's rotation. Otherwise three reference images dropped
into a conversation live only in an archive nobody reads — which is exactly the *"a private place
became the only place a finding exists"* failure.

**An attachment in a direct conversation stays there and rotates with it**, unless promoted. Same
rule as distillation: at rotation, what matters is lifted and the rest goes.

---

## Arriving resources are pushed, not waited for (`PATTERNS.md` §20)

When something is added at project or team scope, **offer it at that moment to whoever it
plausibly serves** — *"added the brand book; it is relevant to design and content, attach it?"*

**And at dispatch:** a task's own attachments always travel in the brief, and a newly-added
project resource that matches the work's craft is **named in the brief too**.

The alternative — a growing shelf nobody consults — is the failure this entity exists to prevent.

**Who maintains them:** the owner adds them in conversation; any agent may **propose** additions
and removals, with a stated `why` for both. A role proposing something at **project** scope is
making a suggestion to the owner, not a self-service change.

---

## External things always keep a local file

Using an external tool does not remove the entity from the repository. A **pointer note** carries
`provider` · `url` · `version_seen` · `last_synced`, and **a distillate in the body**.

Three reasons, and the third is the one that matters: the graph stays complete · the distillate
survives the external tool · and **`project = f(repo)` holds** — cancel the subscription and
nothing load-bearing is lost.

**Same shape for binaries git cannot diff**: a note beside the file saying what it is, what
produced it, and what it is for. **This is also how a deliverable that cannot live in git is
held** — a render, a design file, a batch: the thing lives where it is made, the repository holds
the pointer → `storing.md`.

**`last_synced` is a check-date and ages like one** (`PATTERNS.md` §11)**.** A snapshot is a `cited` claim — *this is what
was there on that date* — and it is honest exactly as long as it is labelled and dated. The moment
it is read as current it becomes the cached fast-rotting fact the freshness law forbids.

**Writing to an external system is an outward operation**, therefore gated. And a two-way
relationship is declared once — with `version_seen` and three-way comparison — rather than
guessed at per file → `drift.md`.

---

## Link health is not a separate feature

Every `url` and `file` resource — and every declared `url` custom field — joins the set the link
check walks, **at audit and before releases**.

**Two classes, two strictnesses.**

**Internal links** — relative paths, references between files, links to a task or a role. **A
dangling one is a hard finding**: cheap to detect and usually cheap to fix, since a renamed file
is findable by its id or its history.

**External links** go through a ladder before anything is declared dead: **transient failure →
blocked as a bot (retry as a browser) → moved (follow redirects, hunt the successor) → an archived
copy → only then report it dead.**

**The ladder always terminates at the owner, never at a guess.** Repair automatically **only when
the target is provably the same resource**; two candidates means ask. *"This moved to X — replace,
keep, or drop?"* Nothing is silently rewritten and nothing is silently deleted.

**A link that cannot be repaired is marked broken in place, with a date.** A dead pointer that
used to matter is information; deleting it destroys that.

**Offline is not broken.** A URL that cannot be reached at all is **unchecked**, never dead —
collapsing those two is how a working link gets deleted on a train. **A network failure warns; it
never fails a build.** Only the internal dangling link is hard, because only that one is a fact
about this repository.

**Do not check what was checked recently.** Hammering the same hosts every audit **provokes the
very blocks the ladder then has to interpret**, so the checker manufactures its own false
positives. `last_checked` exists; use it.

**Never repair a link inside a generated block** — fix the source it is generated from
→ `drift.md`.

**The choice is a request, not a report line.** *"Replace, keep, or drop"* needs an owner's answer,
and an answer needed from a report is an answer that does not arrive.

---

## Sources are the other thing

Evidence behind claims lives in its own register, and it holds **slow-rotting canon only** —
findings, methods, standards that age in years.

**Fast-rotting facts never enter**: a price, a current limit, a competitor's live feature stay
*fetch-at-the-moment-of-use*, quoted with their date, **never cached there to rot**.

**One fixed form per entry, so a wrong entry is visibly wrong**: id · full citation · live link ·
**archive link** · licence tier · **a one-paragraph distillate in our own words** · check-date ·
**and who cites it — by file, never by line number**, because a line number is wrong the next
time anything above it is edited.

**The licence tier decides what may be held:** an open licence means a copy may be carried;
**copyrighted means citation, archive link and our own distillate — never the text itself**; a
formula is recorded by name, which is not copyrightable.

**The reverse index is the part worth stealing everywhere else.** Knowing **who depends on this**
before touching it turns "can I update this" from archaeology into a lookup — and the same applies
to a research finding, which should point back at the task that produced it and carry the date it
was true.

**Research rots as a whole document.** A competitor pricing study from six months ago is not a
fact. Citing one past its date **triggers a re-check** rather than being quoted as it stands.

---

## A claim past its check-date, hit mid-task

**The freshness law is not only a release gate.** An agent consulting a source, a catalogue row,
a recorded ceiling or another task's number **mid-task** meets the same rule the checker enforces
at release — except nobody is standing there to fail the build, so **the agent is the gate**.

**The rung drops to `unknown` on the spot.** Past its recheck, or undated and ageing, it may not
be quoted, relied on, or passed downstream as `measured` or `cited` merely because it was sitting
in a register.

**Reachable from here? Re-verify at the moment of use** — the live page, the current response,
the owner's billing location for a price — and **write the new date and source in the same
change**. Found stale and left stale is how a checker becomes decoration.

**Not reachable?** Two moves, decided by whether the outcome leans on it:

| | What to do |
|---|---|
| the task does **not** lean on it | proceed, and **say what was skipped** — visible, not silent |
| the task **leans** on it | a blocker like any other → `escalating.md`: a request carrying the claim and its old date |

**There is no third move.** The stale figure travelling unmarked into a decision is the same
small lie `shipping.md` catches at release, produced one step earlier — where nothing catches it.

