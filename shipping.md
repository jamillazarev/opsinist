# Shipping — going live, and finding out whether it worked

**Load when:** cutting a release, publishing anything, or asking whether the last one did what it
was supposed to.

**Ship means whatever "live" means here** — deploy code, publish an episode, send a production
batch, mail the issue. Every verb in this system is domain-neutral, and this is the one where that
matters most.

**The loop does not end at merge.** Discovery set success metrics, and **a piece of work is not
done until it has shipped and been measured against them**. The loop closes at *learn*, not at
*accept*.

---

## Before the release

**Gates green.** Not "the work looks finished" — the gates that can independently reject it have
each returned.

**Launch completeness is analysed up front and re-checked here**, not discovered at the end. The
medium's actual go-live requirements — store rules, platform policies, format constraints,
required assets — are **researched rather than recalled**, because platforms change and the
classic misses are per-medium: an app store's review requirements, a channel's thumbnail and
caption rules, a mailing's unsubscribe obligations, a physical batch's labelling.

**The checks, run in a clean checkout**: health · link health · **facts past their check-date** ·
the eval pass. A release that ships a stale price or a dead link ships a small lie.

**Where done names something outside git, the referent is checked here.** A design file, a render,
a hosted batch — a clean checkout proves nothing about them, so the release confirms the thing is
still where the pointer says and still what the snapshot described → `storing.md`. **And every
declared destination is reachable**: a release that quietly skipped one has shipped a partial
truth about its own completeness.

**The four lenses**, read by someone who did not write the change → `lenses.md`.

**Keep the guards current.** *A guard that no longer matches reality passes silently*, which is
worse than no guard.

**Anything published *from* this project ships with it.** A docs site, a generated reference, a
README on a registry — each is a surface derived from the source, and **a derived surface left
behind does not go blank, it keeps confidently stating the previous version.** Regenerate it in the
same release, from the tree being tagged, and check the numbers it prints against the numbers the
repository actually has. **Health checks a generated surface against hand edits** (`checking.md`);
this is the other direction, and only the release notices it.

**Every capability has a door.** A capability nothing points at — no entrance, no use case, no
index — **does not exist for whoever needs it**. The door ships in the same commit as the
capability, or the commit says why not.

---

## Cutting it

**Deploy and announce are outward** — owner-confirmed, every time, and confirmed **naming what
goes where**.

**Write the notes, tag it, record what it cost.**

**The skeleton is generated; the prose stays the author's.** `scripts/changelog.py` collects
the commits since the last tag — subjects, files touched, trailers — into a dated draft, which
is collation, not writing: leading with the capability is the part no script does.

**The changelog leads with the capability, not the archaeology.** What someone can now do, and why
it helps. Not which files moved.

**And it says what kind of change it is** — a fix that alters no instruction, a new capability, or
something that requires existing projects to act — **because the changelog is the migration map**
→ `upgrading.md`.

**Batch, don't drip.** A release of *"renamed a column"* reads as a product made of noise. Pool
small changes; ship an urgent one alone; keep the note short and aimed at the reader rather than
at the author.

**Non-code work has no branches** — the version is a date or an edition — but the batching and the
audience-facing note are identical.

---

## Measuring

**Pull the metrics discovery set**, compare to target, and report the outcome plainly. **"Built"
and "works" are different claims; say which one you are making.**

**A miss is a result**, not a failure to report. Killing something that is not working is the point
of measuring, and a measurement that can only confirm was never a measurement.

**Compare the impact predicted with the impact that arrived** → `grouping.md`. Without that,
scoring never improves; it only accumulates.

**A surprise becomes a learn item on the roadmap**, with what was expected and what happened.

**Record the cost beside it** — what this shipment consumed, per role, with the trend rather than
the level → `cost.md`. Cost next to outcome is the only place either number means anything.

---

## Urgent work

An urgent lane exists and it **jumps the queue**: minimal spec straight to build and review, the
owner notified rather than asked.

**And it starts by building a deterministic pass-or-fail signal**, before forming hypotheses.
**When the thing will not reproduce, ask for artifacts rather than guessing at an unverifiable
fix** — a fix nobody can verify is a change with a story attached.

**Urgency is not consent.** The gates hold: publishing, spending and destroying are asked about at
the same speed they always were. *"No time to explain, just publish it"* is the pressure this rule
exists to survive.

---

## After

**Feedback arriving from users is triaged, not filed.** It lands in `triage` with the four
dispositions, and what recurs is what matters — a report seen once is a data point, and the same
report five times is a finding.

**A release that has to be undone is undone.** Rollback is normal → `recovering.md`.

**The site and anything generated from the release regenerate from the released ref, never from
the working tree** — a regeneration from a working tree with an unmerged branch checked out
publishes unreleased content, which is learned once and expensively.

**And the shareable image is a cached copy of your positioning on someone else's server.** It goes
stale the moment the tagline changes, so regenerating it is **a line in this ritual** rather than a
task somebody remembers.
