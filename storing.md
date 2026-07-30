# Storing — what lands in the repository, what stays with you

**Load when:** about to write the first thing that outlives the session, moving a record between
places, handing a project to someone else, or deleting one.

**The record always exists. The only question is where it lands.** Recovery reads state from the
record, cost is counted from it, decisions live in it — so a mode that switches records off would
switch those off with them. Nothing here removes a capability; it decides a destination.

---

## Six layers, ordered by what they mean to someone without agents

| | Layer | What is in it | Meaning without agents |
|---|---|---|---|
| 1 | **documentation** | architecture, guides, decisions about the product | full |
| 2 | **work** | tasks, pipelines, releases, milestones | full — a tracker in files |
| 3 | **conversation** | threads, direct messages, requests | partial |
| 4 | **team** | roles, roster, skills, commands, agent configuration | none |
| 5 | **telemetry** | runs, cost, the evidence trail | none |
| 6 | **results** | the thing the work produced | it *is* the product |

**The setting is a cut point on that ladder, not six switches** (`PATTERNS.md` §25)**.** Everything above the line goes to
the repository, everything below stays with you. One position to state, one to change, and the
common answer is a nod.

**Layer 6 is different in kind.** Layers 1–5 describe the work; layer 6 *is* the work — a video, a
design file, an article, a batch. **Its destination is dictated by the nature of the artifact, not
by preference**: a 4 GB render does not go in git, a design file lives where it is edited. What
lands in the repository is a pointer note with a snapshot and a distillate → `resources.md`. **A
definition of done may therefore name something outside git**, and the release checks that the
referent still exists → `shipping.md`.

---

## Record, or work?

**The rule that generates the answer: does it describe the thing, or the making of the thing?**
The check is the deletion lens — remove the file; is the shipped thing now wrong or incomplete?

**Layers 3, 4 and 5 are always record.** Delete every thread, roster entry and run log: what
shipped is unchanged.

**Layer 1 is almost always work.** A README, an architecture map, a migration guide — delete them
and the product is incomplete.

**Layer 2 is a legitimate project choice, and that is exactly why there is a dial.** Tasks in
files, for a team that runs its tracker in files, are work. The same tasks kept while fixing
someone else's library are record.

**Decisions split by content, not by layer:** a decision that constrains future work on the
product is work and goes to the repository; a decision about running the project — why this role,
why this model and effort — is record.

**When it is genuinely unclear, it is record.** A record is copied into the repository later; work
misfiled as record has already left the place it belonged in. The cheap error and the expensive
one are not symmetric, so the default points at the cheap one.

---

## Three presets

| | Where the record lands | Read from the ground |
|---|---|---|
| **in-repo** | beside the work, committed | the remote is yours, or there is none |
| **beside** | your own store, or a repository you name | the remote is not yours, `CODEOWNERS`, a PR template, a live `docs/` by many hands |
| **later** | the store, and the question returns on an event | the remote reads, but ownership does not |

**Ambiguity resolves to `later`, never to `in-repo`.** The two errors are not equally priced:
guessing `beside` costs a copy, guessing `in-repo` means a commit in a repository that is not
yours, possibly already in a branch, possibly already in a review. The expensive error is made
unreachable by routing doubt into a question instead of a default.

**`later` is a resting state, not a deferral.** Someone can work this way for weeks, and *leave it
as it is* is a full answer rather than a postponement.

---

## Asking

**The question fires before the first write that outlives the session — not at the door.** Until
then everything is local, so the choice costs nothing and reverses completely. By the time it
fires the project is known, which is what makes the recommendation worth anything. A consultation
that writes nothing therefore never asks.

**It is a filled-in form, not a questionnaire.** Three grouped lines covering all six layers, each
already answered, each carrying **where** and **who will see it** — a destination without its
consequence is just a path, and the whole reason to ask is that the owner should understand.

> **Where the record goes**
>
> The remote is yours and there is no foreign process here. I suggest:
>
> | **repository** | documentation and work — anyone who clones sees it; outlives the laptop |
> | **with me** | conversation, team, telemetry — keeps the repository clean, lives only here |
> | **in place** | results: a design file where it is edited, a render in storage — the repository gets a pointer and a snapshot |
>
> A complete copy is local either way, so **any of this changes later, in both directions, even
> after the work has shipped**. While a copy is local only, it lives exactly as long as this
> machine does.

**Moving a line is one more question, never six.** A single multiple-choice list of layers with
the boxes already ticked. Most owners never reach it.

**Two sentences carry that form.** *A complete copy is local either way* is what makes deciding
later free rather than a decision to work without records. *It lives as long as this machine* is
the price of local, said out loud — omitting it sells a backup that is not one.

---

## Opening a record — the actual steps

**Everything above is the model; this is the act.** Do this the first time work needs a record,
before the change rather than after it.

1. **Derive the key.** The remote, normalised — host and path, no protocol, no credentials, no
   `.git`. No remote? the work tree's absolute path.
2. **Create `~/.opsinist/projects/<slug>/`.** The slug is readable
   (`github.com-acme-oss-widgetlib`); it is a convenience, not the identity.
3. **`git init` it — its own step, because bundled with the line above it gets dropped.** Without
   this the store holds a folder, not a repository: no history, and the deletion warning about
   unpushed history has nothing to warn about.
4. **Write two files and no more.** `record.md` — what this work is, the key, the date, and the
   cut in force. `runs.md` — one appended line per run: what ran, what it produced, what it cost.
5. **Say where it is, in one line.** *"Keeping the record at `~/.opsinist/projects/<slug>/` —
   say the word if you want it in the repo instead."*
6. **Then do the work.**

**Two files, not a skeleton.** Anything more is the machinery a small job is entitled not to
have; anything less and a run that dies has nothing to come back to.

**This is the step that gets skipped**, because the restraint around it is memorable and the act
is not: an agent that has read this far agrees the record matters and then writes nothing.
**Agreeing is not doing.**

---

## The store

**`~/.opsinist/projects/<slug>/` is a directory of ordinary git repositories, not a database.**
The store root takes its name from this skill's frontmatter **`display_name`** — the product's
identity, lowercased; the literal path here is the current resolution, not a second identity.
It deliberately is **not** `name`, which is the plugin's invocation name (`/opsinist:advisor`):
the two answer different questions, and tying records to a command name would rename every
owner's store the day a command is renamed.
Enter one, read its log, push it, delete it. No index and no manifest of its own: the list of
projects is built by scanning, because a manifest is a database and would disagree with reality
the first time someone removes a folder by hand.

**It is always complete, and completeness is not authority.** Every layer is present locally so
the graph resolves, search answers, and a migration needs no interrogation. **Who is canonical is
declared once per connection and does not move** — a source of truth that changes owner over time
is the reliable way to produce a conflict nobody can adjudicate → `drift.md`.

**The key is not the identity.** A record holds a generated id and an **append-only list of every
key it has carried** — a normalised remote (host and path, without protocol, credentials or
`.git`), or the work tree's path when there is no remote. A repository renamed or moved to another
organisation appends a key and keeps the old one. **The directory name is a convenience**: rename
it freely, lookup reads content.

**Treat the store like terminal history, because that is what it is.** It holds threads,
decisions, what things cost and whatever was quoted into a task — business context, third-party
names, sometimes a customer's words. **No secret values live there** (`permissions.md`), but the
contents are still the project's private material sitting in a home directory that nothing
protects by default. **Say that once when the store is created**, and treat a request to hand it
to someone as `outward`, because it is.

**Anything living only in the store is marked as such, with its durability named.** It is a
machine, not a repository. Offering to push it is a one-time, explicit offer, never a default.

**The link graph beside it is a cache, and is treated like one.** It answers *what points at
this* fast enough to be worth having, and a generated code index can sit next to it for the same
reason → `catalogue.md`. **Delete it and it rebuilds by rescanning; nothing is lost but time.**
So it is never committed and **never the authority for a reference** — a link that only resolves
because the cache remembered it is a link that breaks on a clean machine, which is exactly what
the cut is supposed to survive (`cost.md` draws this same line for rollups).

---

## The manifest

**One line per layer, in the repository, saying where that layer lives.** Without it, "docs in the
repository, the rest outside" produces a project nobody can find — a clone would give content with
no map. With it, a clone always gives the map even when it does not give the contents.

**Every project-level operation resolves the manifest first, then acts per destination.** Deletion,
audit, handover, search, release and cost are all this one step followed by a fan-out.

**An operation that cannot reach a declared destination stops and says so.** A partial deletion
that reports success is the worst outcome available here.

---

## References that survive the cut

**Links run downward — a document cites a task, a task cites a run.** A cut removes what is below,
so downward links are exactly the ones that break.

**A reference pointing below the cut must read without its target.** Not a bare link: a sentence
carrying the substance, with the link as an addition. This is `Everything carries its why` applied
to linking.

**And it is `prose-only` — nothing enforces it.** Whether a sentence still reads without its link
is a judgement, not a pattern; a checker firing on every bare link would be bypassed within a
week. What *is* enforced is one rung down: **the manifest must exist whenever the layers are
split**, so what is missing from a clone is always discoverable. The four lenses are the
compensating control for the rest → `lenses.md`.

---

## Where a destination is not worth offering

**Team configuration does not belong in an external service.** It is read on every dispatch; a
network round-trip per role is slow and fails exactly when the network does. A separate repository
is right — and it is the answer when a colleague cannot work because they are missing layer 4.

**Work and conversation do not belong in object storage.** A tracker on a bucket is not a tracker.
Storage earns layer 6 and heavy attachments.

**Telemetry is usually local only**, and that is fine as long as it is declared.

**One deep connection beats five shallow ones.** A one-time import needs no adapter at all — an
export and the method carry it, and the source can be anything → `importing.md`. A standing
arrangement needs a live connection, and that is where the list stays short. **Before building
anything, inventory what the runtime already has connected** rather than assuming it has nothing.

---

## Moving, and deleting

**Four directions, and no new gates:** into the repository is `outward` · out of it is
`destructive`, because files leave a tracked place · to another repository is `outward` · deletion
is `destructive` → `permissions.md`.

**Deletion of a store record differs in kind, not in volume.** That directory is a git repository
that was never pushed, so `rm -rf` destroys history that exists nowhere else — unlike deleting
files from a repository, where the history remains. So deletion **lists what it found per
destination, marks the unpushed as unrecoverable, and names separately what it cannot delete at
all**: someone else's tracker, a shared repository holding other people's work.

**Nothing is deleted on a timer, and nothing expires.** Undecided records surface for a decision on
two events — **returning to the same work tree**, and **the work closing upstream** (the referenced
commit reaches the default branch, or the review closes). A reminder on a schedule is nagging; a
reminder on re-entry is free.
