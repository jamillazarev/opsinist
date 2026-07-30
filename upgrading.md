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
| **this system's bytes** | the skill files on the machine |
| **the project's format** | `schema_version` and the codemods that move a repo from one to the next |
| **attached skills** | third-party skills, re-screened |
| **tooling versions** | the things in the register, checked against their release feeds |

**Preview first, always.** What would change, what it touches, and what it would require. Then
apply, then verify.

**The changelog is the migration map** — read the entries between the version the project is on
and the current one, and act on what they say rather than on the diff.

**Rollback is normal.** The previous commit is the restore point; there is nothing separate to
keep.

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
