# Requests and attention — what needs a person

**Load when:** something needs a decision, a review, an approval or an answer; or the owner asks
what is waiting on them.

---

## One entity, four kinds

Approvals, reviews, questions and decisions share a lifecycle — **asked → open → answered** — and
while open they block something. So they are one entity with a `kind`, not four mechanisms.

| `kind` | Example |
|---|---|
| `approval` | *"merge?"* · *"publish?"* · *"spend?"* |
| `review` | *"look at this — accept or send back"* |
| `question` | an agent is stuck without information |
| `decision` | *"pick one of these"* |

**A review routed to a non-author *is* the review gate.** There is no separate gate machinery:
the request is the gate. **The author never answers their own**, and preferably the reviewer is
not even running on the same provider — models judge their own output generously.

**A review is addressed to the group, and the group picks the tier** → `addressing.md`. Two
different things wear the word *check*, and staffing them the same way is how a gate becomes a
formality:

| | What it is | Tier |
|---|---|---|
| **verification** | a fact the filesystem can settle — a file exists, the tree is clean, the build ran | **a tier down or further.** A check does not need to be more capable than the thing it checks → `dispatching.md` |
| **review** | a judgement — is this right, is it good, does it meet the bar | **decided in the thread, and named.** Not below the author by default, because a reviewer that cannot follow the work rubber-stamps it |

**The tier is a decision, not a constant.** A tier down is a legitimate answer — a small diff, a
mechanical rubric, a second pass on something already reviewed — and it is **said out loud on the
request** rather than left to whatever was cheapest. What is not legitimate is a judgement review
staffed below the author *by default*: that produces the verdict the author wanted, at a discount.

### Not every review is owed to your own craft

**Finished work usually owes more than one review, and they answer different questions.** A build
that came from a design owes the design group a look at whether what shipped is what was drawn —
and that is not the question the engineering review asks. Neither substitutes for the other, and
running only the same-craft one is the common way a handoff quietly loses fidelity.

| | Asks | Who |
|---|---|---|
| **same craft** | is this good work of its kind — sound, maintainable, correct | the author's own group, never the author |
| **another craft** | is this faithful to what we handed you, and does it work for what comes next | the group whose work this came from, or goes to |

**Both are mentions from the thread, and the group decides who goes** → `addressing.md`. Name the
group and what you need, not a person you guessed; the group's routing rule picks the reviewer,
and **whoever agrees creates the subtask** — which is how a review gets an owner without anyone
assigning it from outside.

**They run in parallel, not in a chain.** The design look and the code look do not depend on each
other, so asking for them one after the other makes the work wait twice for nothing. That is what
*parallel gates inside review* means (`pipelines.md`) — one stage, several gates, all open at once,
and the stage clears when they all come back.

**Mention only the groups whose answer changes something at this stage.** Four mentions are four
runs and four lines in the ledger, and a review board wide enough to be safe is also wide enough
that nobody reads it carefully.

### The owner may switch the gate off

**Offered on by default, with the default visible — and declinable.** The gate is proposed the way
everything here is proposed: the recommended setting already filled in, the runtime's own mechanism
preferred over one we build, and one line on what it buys. **If the owner says they do not want it,
they do not want it.**

**The risk is named once, then the decision is theirs.** *"Without it, nothing but the author reads
this before it ships"* — said plainly, at the moment of the choice, with no second attempt later and
no re-litigating it every time the subject comes near. **A recommendation repeated after an answer
is not diligence, it is nagging**, and it teaches an owner to stop reading what we say.

**But it goes off in writing, never quietly.** A declined gate lands on the deferred list with what
it was, why it was declined, and a revisit trigger that is a moment rather than a date — *"before
anything public ships"*. **And the manifest tells the truth afterwards:** what was `enforced_by:
request` becomes `prose-only`, because that is now what actually holds it. A gate that disappears
without changing what the project says about itself is how a board starts lying.

**This is the owner's lever, never the agent's.** Nothing here loosens the rule that a worker does
not edit the bar it is measured against (`SKILL.md`) — an agent proposing to skip its own review is
the failure that rule exists for. **The four owner-gated kinds do not become declinable either**:
spending, leaving the project, destroying, and changing the shape of the team stay where they are,
because those protect the owner from us rather than the work from itself.

**Presented together, consented per line.** Related decisions arrive as one list — the same rule
as the debt list and the interview's waves — but a single *"approve?"* over the bundle buys
approvals nobody gave. **Each line is its own yes**, and *"all of it"* is a shortcut the owner
chooses, never the shape of the question. The standing case: a pending spend request is not swept
along by the larger proposal that happens to mention it.

**Age is shown and audited.** A pending decision must never be invisible: it carries how long it
has been open, and **what the wait costs** where that is knowable — *"four days, blocking wave 3,
roughly a day of idle designer per week"*. A cost turns a nag into a decision input.

**Every escalation is a request** → `escalating.md`. So is every proposal that needs an owner's
answer: an audit finding, a link that cannot be repaired unambiguously, a deadline at risk, a
skill worth replacing. **The failure mode all of those share is arriving as a report** — and a
report lives until the end of the scroll.

---

## The attention view — computed, not a stream

Two parts, because they differ **in kind**:

**Needs you** — the open requests. **State**: it stays until answered, and it disappears because
it was answered rather than because it aged out.

**Happened** — notifications. **Events**: a bounded feed that ages out on its own.

**There is nothing to mark read and no inbox to keep at zero.** A queued notification lies the
moment its cause resolves; a computed view is always exactly true. That is the whole argument,
and it is why this is a view rather than a mailbox.

**A failed run is an ordinary resident of this view.** The predecessor's worst property was that
an automated run could fail and notify nobody; here failure is as visible as anything else.

**Grants show their remaining life here** while they live → `permissions.md`.

**Waits age here too** — a `waiting_on` past its threshold surfaces, because a wait nobody chased
and a wait everybody forgot look identical from outside.

---

## Coming back after time away

The question a returning owner actually asks is *"what happened while I was gone"*, and it has
three different answers that must not be blended:

| Question | Source |
|---|---|
| what needs me | the open requests — **state** |
| what happened | the notification feed — **events** |
| what changed that we did not change | the environment fingerprint → `drift.md` |
| what outgrew its container | the seams, **each ending in a named offer** → `checking.md` |

The first two are this file. The last two are different questions and reporting them in the same
list would hide them.

**One line of state before the narrative.** *"3 need you · 2 running · 1 blocked · 4 closed since
Tuesday"* — countable, scannable, and answerable at a glance before anyone reads a sentence. A
returning owner wants to know **whether** something needs them before they read **what**, and a
summary that opens in prose makes them read to find out.

**It is offered, not waited for.** Coming back to a project after time away, the summary is the
first thing said — before any question is asked and without being requested. An owner who has to
know the word for it to see what happened in their absence has a log, not a console. If
nothing happened, that is the summary: *"nothing ran since Tuesday"* is an answer, and a short
one is not a reason to skip it.

**The summary is computed from the task histories**, not stored: closed since your last session,
requests open and their ages, spend since then, anything that regressed. Same rule as everything
else — the atoms are recorded, the summary is derived (`PATTERNS.md` §4).

---

## Triage is where intake lands, not where it lives

Everything arriving from outside — user feedback, an audit finding, an imported ticket, a
proposal — lands in the `triage` category, **excluded from boards and planning by default**, so
raw intake never pollutes what is committed.

**The advisor sorts and proposes; the owner decides.** Four dispositions, and the details are in
`writing-work.md`: accept · decline **with a reason** · duplicate **as a relation** · snooze until
a date **or until new activity**.

**Two habits that keep triage from becoming a second backlog.** Sort it at natural checkpoints
rather than continuously — it is intake, not work. And **declining is a normal, cheap outcome**:
a triage queue where nothing is ever declined is a backlog wearing a different label.
