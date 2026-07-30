# Drift — when something changed that we did not change

**Load when:** a file looks edited, a synced thing disagrees with its source, or a session starts
after time away.

**A human's edit is truth about intent.** Agents read before they write and never clobber. But
**respecting intent is not the same as accepting anything**: an edit that makes the data
inconsistent is **a finding, not something to adapt to**.

*Adding `blocked_by` to a task that is in progress is a finding, not a silent status change.* The
field is the reason, the status is the state — and tidying it up on the owner's behalf is the
same automatic transition that makes boards lie, only started by a person.

---

## Three mechanisms, three questions

They are routinely blurred into one, and each answers something the others cannot.

| Question | Mechanism |
|---|---|
| **Who authored this?** | `created_by` — a field, written once at creation |
| **Who changed it?** | **git** — the commit and its trailer. Not a field: a declared "last edited by" rots the first time someone forgets it |
| **Was a generated block edited by hand?** | **a content hash**, stored when the generator wrote it |

**The hash is over content, never over modification time.** A timestamp changes when nothing did,
and does not change when a file is restored — both failure directions at once.

---

## Generated blocks — views, never sources (`PATTERNS.md` §6)

The generator writes between markers **and stores the hash of what it wrote**. Before the next
regeneration it hashes what is there now:

- **matches** — rewrite silently, nothing happened
- **differs** — someone edited by hand, and it is **reported before it is overwritten**

That "before" is the whole promise, and it only holds if something checks regularly. Regeneration
is one trigger; **the audit is the second**, and without it the promise depends on the accident of
someone regenerating soon.

**Never repair a link or fix a typo inside a generated block.** It is overwritten at the next
regeneration, and worse — the hash check then reports your own fix as an unexplained hand edit,
so the system accuses itself. **Fix the source the block is generated from.**

---

## Synced things: compare three ways

Anything with a source outside this repository records its **last-known state** — `version_seen`,
`last_synced`. Before acting, compare three ways:

| | Meaning | Response |
|---|---|---|
| **theirs changed** | upstream moved | show what moved, offer to take it |
| **ours changed** | we edited locally | show it, offer to push or keep |
| **both** | genuine divergence | **surface with options — never merge silently** |

**Take theirs · keep ours · reconcile.** The owner picks. A silent merge is how a deliberate local
change disappears without anyone noticing it is gone.

**A template is copied, not linked.** After importing one, it is ours and it diverges — that is
normal. Wanting to track upstream is a **different, explicit choice**: an external pointer with
`version_seen`, which is a dependency rather than a template. You cannot silently have both.

---

## The environment fingerprint

*Three-way compare when both sides can change — `PATTERNS.md` §17.*

**`project = f(repo)` is false until this exists.** Skills, plugins, hooks, settings and servers
load from outside the repository into every session, so the same repo on two machines behaves
differently — and nothing in the repo says so.

**Write a hash per class after any operation that changes state; compare on waking.** Store the
map plus the commit it was taken at.

**A hash detects; it does not rebuild.** Cloned onto a second machine the fingerprint says
*different* and stops there, which leaves the premise half-kept. So alongside the hashes the
project **declares what it requires from outside** — each MCP server, skill or plugin by name,
with **what it is for, where it comes from, and which credential it needs by reference**. Values
stay out (`permissions.md`); the requirement does not. **Detection answers "has this changed";
the declaration answers "what do I install to work here"**, and only the second survives a new
laptop.

Classes: **skills · plugins · hooks · settings · MCP servers · agent definitions · harness
version**.

**A class nobody hashes is drift nobody sees.** When the harness gains a new kind of thing, the
fingerprint is blind to it until someone adds it here — so **this list is canonical**, and health,
entering and upgrading all compare against it rather than each carrying their own.

**On a difference: attribute first, then ask why, then record the why.** Most changes explain
themselves from git or from the session history. What stays unexplained becomes **a question to
whoever made it**, and the answer goes into the project's own documentation. Not "revert" and not
"accept" — **find out the intent and write it down**, because the next session will otherwise ask
the same question.

**Reads outside the repository are a separate axis.** Inside the repo an agent reads freely;
reaching outside it needs an explicit allowance. That is about the **perimeter**, not about
hierarchy, and conflating the two is easy — `enforced_by: prose-only`, partly held by the
harness's own permission settings.

---

## Coming back after time away

Three different questions, and blending them hides the third:

| Question | Answer from |
|---|---|
| what needs me | open requests → `requests.md` |
| what happened | the notification feed → `requests.md` |
| **what changed that we did not change** | **this file** |

The summary is **computed from the task histories**, never stored: closed since the last session,
requests open and their ages, spend since then, anything that regressed. Atoms recorded, summary
derived.

**Leaving should be as deliberate as arriving** → `entering.md`, which owns both ends of it.
