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
| `cited-by` | **generated, never hand-written** (`PATTERNS.md` §5): the files that reference this resource, found by its name and targets — the delta sweep's stored input. Absent until a generator runs; **until then the sweep searches**, and says so |

**`why` is mandatory, and it is the whole difference between a resource and a bookmark**
(`PATTERNS.md` §14)**.** A link
with no stated purpose is consulted by nobody and removed by nobody, because removing it might
lose something and nobody knows what.

**Typing the purpose is optional and belongs to the project.** Reference, specification,
documentation, example — a project that wants board columns and filters over those declares a
`select` field and gets them. **A taxonomy baked into the core would be right for one domain and
wrong for the rest.** The seeds worth naming when a project does declare one: `depends-on` ·
`promotes` (the campaign's subject, `tooling.md`) · `competes-with` (a register row,
`templates/COMPETITORS-template.md`) · `informs` — because **`why` says the words and the
relation makes them walkable**: a sweep can group by relation, and a delta knows that
`depends-on` breaking is a request while `competes-with` moving is content.

**One thing with several doors is one resource with several surfaces, never several
resources.** A promoted library is a repo *and* a site *and* docs *and* a pricing page — one
`why`, one relation, and a `targets:` map (`repo:` · `site:` · `docs:` · `pricing:`), **each
surface carrying its own `last_checked`**, because they rot at different speeds and the watch
compares each against its own last-seen. Splitting them into four rows loses the fact that
they are one thing; merging them into one URL loses three doors.

**Walking a resource starts from its own map, never from crawling.** Its `llms.txt`, its
sitemap, its README — the thing's self-description is the cheapest index there is, and only
where none exists does the deep pass earn its cost (`catalogue.md` → reading pages, Crawl4AI
for *a corpus, not a page*). **The register read whole is the map of resources**; a generated
view over it earns itself when the register outgrows a screenful — the same bar as every
derived surface.

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

**And a resource serves every flow that meets its need.** Filed by one flow, scoped to none:
the shelf a review cites is the same shelf a build or a consultation opens; a link the owner
hands over on a task joins the register with its why and is read wherever it is relevant —
never re-asked for (`quick.md`). This holds for the stock shelves (`catalogue.md`) and for
everything the project's own register carries, alike.

**And the point of a shelf is a shorter search, which puts it at the search's head.** The same
order every choice runs (*look inward first*, `SKILL.md`; the ladder's search step,
`choosing-tools.md`): **the register first** — pre-read, its licences already read — **the live
web where the register runs out**, and a find worth keeping **lands back on a register with its
why**, so the next search starts further along. Recalling from memory is not a step on this
path at all.

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

## The record is a pointer; the thing it points at outranks it

**Every register here describes something that exists somewhere else** — a licence file, a live
page, a directory of assets, a block of generated markup, a line of code. **The row is what
somebody typed about the thing, on the day they typed it.** When the two disagree, the thing
wins, and it wins silently unless someone opens it.

**So: before acting on what a record says about an artifact, open the artifact — when it is
reachable, and it usually is.** Reachable means in this tree or one fetch away. Not reachable is
an answer too, and it is written down as one.

| The record | The thing it points at | What the run opens first |
|---|---|---|
| a tooling row naming a licence | the licence file shipped beside the dependency | the file |
| a source entry with a live URL | the page | the page — a URL that resolves is not a URL that still says it |
| an asset log | the directory it names | the directory, before proposing anything new |
| a generated block | what the generator would produce now | both, before regenerating over a hand edit |
| a task saying something is **built** | the code | the code — *"it works"* is a claim in a file like any other |

**Measured 2026-07-31, five scenarios, every instance:** a run listed `vendor/` and never opened
the licence sitting in it, so a Business Source License recorded as `MIT` survived into a paid
product · a run read a source entry and a decision and never fetched the dead link between them ·
a run fetched stock photography without opening the asset log naming a commissioned shoot one
directory away · a run regenerated a team table over a hand edit it never inspected · a run
declared a payment step built without checking that the function it calls is defined nowhere.
**None of these runs was careless about its own reasoning.** Each of them read a description and
acted on it, which is the cheapest possible move and looks identical to diligence in a transcript.

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

**A row you have just learned is wrong is marked `unknown` now — that correction needs no new
information.** The rule above says re-verify and write the new date *in the same change*, which
reads as though a correction requires a successful check; it does not. When the old value is
known false and the true one is not yet known, **`unknown` plus today's date is the true state**,
and writing it costs one edit. **Measured three times on one fixture:** a run found a vendor's
free tier gone, said so clearly, listed *update the register* as something for the owner to do,
and left the row reading `free tier, 1,000/month` — so the next reader meets the same false fact
the run had already disproved.

**Unreachable, or there was never a figure to reach? Then the answer is `unknown`** — never an
estimate, never a range that sounds researched. **A number nobody can point at is invented**, and
it does more damage than the silence it replaced, because the next reader cannot tell the two
apart. Measured: a run met a vendor that had closed its free tier and produced *"1¢–5¢ per
screenshot depending on volume"* for a price it had not fetched, alongside a competitor's free
tier it had also not fetched.

**A register's check-date belongs to the register, and may never be attached to a present-tense
claim.** `Checked 2025-09-02, and their pricing page now shows no free tier` reads as
verification and is its opposite: an eleven-month-old date laundering a claim about today.
**Either the date is today's because the page was just read, or the claim is not in the present
tense.**

**Not reachable?** Two moves, decided by whether the outcome leans on it:

| | What to do |
|---|---|
| the task does **not** lean on it | proceed, and **say what was skipped** — visible, not silent |
| the task **leans** on it | a blocker like any other → `escalating.md`: a request carrying the claim and its old date |

**There is no third move.** The stale figure travelling unmarked into a decision is the same
small lie `shipping.md` catches at release, produced one step earlier — where nothing catches it.

