# Writing for humans

**Load when:** writing anything a person will read — a task, a handoff, a review, a status, a
decision record, a document.

**Write like a product page.** First line is the point. Lists over prose. Tables for data.
**Readability, not brevity** — terse trims words, this shapes them to be scanned. They are
different goals, and compressed reasoning is for machines → `dispatching.md`.

**Everything opens with what it is and who it is for.**

**What the thread discusses is in the thread.** The artifact under discussion — the screen, the
draft, the diff, the number — is **embedded where it embeds, and linked with a still where it does
not** (`project-layout.md`). A thread debating something nobody in it can see is a meeting without
the document, and the next reader inherits the blindness. The forms, by what is being said:

| Saying something about… | The thread carries |
|---|---|
| an order, a process | a small ```mermaid block beside the words |
| a choice between options | a table — options against sourced criteria |
| a visual state | the image or still, embedded |
| a command, exact text | a fenced block, **verbatim** — a paraphrased command is a mutated one |

**A process is drawn beside the words, not narrated through them.** Anything with more than two
or three steps — a flow being proposed, a handoff sequence, how a change travels — gets a small
fenced ```mermaid block in the thread, because five sentences about ordering hide the fork that a
five-node drawing makes unmissable, and the block renders wherever the thread is read — the git
host, a vault, Notion — with no plugin (`project-layout.md`). Two bounds keep this from becoming
decoration: **where the move already lives on the product map, point at `_ops/MAP.md` instead of
redrawing it** — a second drawing is a second source of truth — and a thread's sketch is working
material, which climbs to the map only by shipping (`mapping.md`).

**The bar is shown, not described.** What follows is each artifact as a weak version and a strong
one, because **the difference is what teaches**. The weak versions are not strawmen — **every one
is a shape agents produce by default.**

---

## Turning a request into work

**Weak — looks complete, is not workable:**

> **Improve search.** Make search better so users can find things.

Nothing is false and nothing is actionable: no definition of "better", no way to know when it is
done, and the whole thing rests on one worker's guess.

**Strong:**

> **Search returns the right result in the first three.**
>
> **Why:** 38% of support tickets this month are "I can't find my recording" (#204). People search
> by what they remember — a name, roughly when — and we only match a title they never set.
>
> **Success:** searching a participant's name or a month returns the intended item within the
> first three results, on a library of 500+.
>
> **Does not count:** a plan for search; matching titles only; "works on my 12-item test library";
> a relevance improvement nobody can measure.
>
> **Done when:** the acceptance set — 20 real searches from tickets — passes at ≥90%; p95 under
> 400ms; before-and-after numbers recorded.

**Every fact carries its source, or is written as "verify X".** The 38% cites its ticket. A figure
lifted from memory is either sourced and dated or **written as work**.

**And the acceptance set is built before the ranking work, by someone else** — so the bar is not
authored by whoever is measured against it. That is sequencing, not just prohibition.

---

## A handoff

**Weak:**

> @designer done, please review

The next person now opens the diff and reconstructs what happened — **paying in tokens for what
one sentence would have carried.**

**Strong:**

> **Done:** query parsing and ranking, behind a flag, off in production.
> **Evidence:** acceptance set 19/20 — before/after table in the description.
> The failure is "meeting with Ana" where two participants are named Ana; ranking is correct, the
> interface gives no way to disambiguate.
> **You're up:** the empty and ambiguous states — the ambiguous one is new, it was not in the
> original design.
> **Not done, on purpose:** typo tolerance. Deferred with a trigger.

It states what was built, what proves it, **what is deliberately absent**, and what the next person
has to decide. And it is **readable without the thread** — which matters because a run that dies
takes its context with it.

---

## A review verdict

**Weak:**

> Looks good to me 👍

Not a review. No evidence, and once it is in the record **nobody can tell whether the gate
actually ran.**

**Strong — a pass:**

> **Verified:** ran the acceptance set locally (19/20, matching the claim), read the ranking
> change, checked the migration is reversible.
> **Not verified:** behaviour above 5k items — out of scope here, worth its own task before the
> enterprise tier.
> **Verdict:** pass.

**The "not verified" line is what makes it a review rather than a signature.**

**Strong — a fail that escalates instead of ping-ponging:**

> **Third round on the same point**, so this is a spec problem, not a quality problem. The
> disagreement is whether "first three" is per page or overall; the task says one thing and the
> acceptance set assumes the other.
> **Stopping the loop** and escalating to settle the definition. Nothing is wrong with the code as
> written against the reading its author used.

**Strong — a grade signal:**

> The parsing is fine. The ranking change touches the scoring model, which nobody here has changed
> before, and the third attempt reproduces the same regression.
> **This needs a senior, not another retry** — reassigning up with what has been tried.

---

## A cost entry

**Weak:**

> This release cost about $30.

**Strong:**

> | | Tokens | $ (est.) | Time |
> |---|---|---|---|
> | Backend | 14.2M | 18.40 | 6h 10m |
> | Design | 3.1M | 4.05 | 2h 30m |
> | QA | 2.4M | 3.10 | 1h 45m |
> | **Total** | **19.7M** | **25.55** | **10h 25m** |
>
> **Cache reads:** 88% of tokens. **Against the envelope:** $25.55 of $300, sixth release this
> month, $212 spent. **$ is an estimate** from list prices, not an invoice. **Versus the last two:**
> the design share doubled — this one had three new states rather than one, **which is expected,
> not a signal.**

Itemised, because that is what makes an expensive role **visible rather than suspected**. The
estimate is labelled as one. And the comparison **interprets** rather than reporting: a number that
moved and a number that means something are different things.

---

## A status

**Weak:**

> Everything's going well! Great progress on search 🎉

**Strong:**

> **Moving:** ranking (wave 2, backend, day 2 of ~3).
> **Waiting on you:** the disambiguation decision — **4 days old, blocking wave 3. Keeping it open
> costs roughly a day of idle design per week.**
> **Stopped:** localization, limit hit 02:10, resets 07:00 — not a failure, resumes on rerun.
> **Money:** $212 of $300; at this rate the envelope holds until the 28th.
> **What I'd do:** settle disambiguation today, or drop it from this release explicitly rather than
> by drift.

No praise, **an age on the pending decision and a cost for the wait**, and one recommendation.
*"Great progress"* would have been the same words whether or not anything moved.

---

## A decision put to someone

**Weak:**

> We could go with Paddle, Stripe or Polar. Stripe is the most popular, Paddle handles VAT for
> you, Polar is developer-first. Which do you prefer?

Three names and a mood each — no recommendation, no sources, and nothing about what would settle
it. A bare choice handed over, which is forbidden even between agents.

**Strong:**

> **Recommendation: Paddle** — we sell to EU consumers with no tax entity, and a merchant of
> record removes that entire class of work.
>
> | | Paddle | Stripe | Polar |
> |---|---|---|---|
> | VAT | handled (MoR) | ours to file | handled (MoR) |
> | fee on a €10 sale | fetched today, dated | fetched today, dated | fetched today, dated |
>
> **Flips if:** we open an EU entity this year — then Stripe's lower fee wins. If that is likely,
> this is not decided yet, and what settles it is the entity question, not more comparison.
>
> On yes: one line in `_ops/DECISIONS.md`, revisit-if included.

**The recommendation is first, every cell is fetched and dated, and the *flips-if* line is the
"survives being wrong" check made visible** (`SKILL.md`, the decision loop). Where the runtime has
a native question affordance, it is used — recommendation first, trade-offs on each option.

**And where several questions are owed at once — an interview wave, a migration's answerable
pile — the affordance carries the batch, not a queue.** Asked one at a time it becomes the
sequence of individually reasonable prompts that every flow here forbids; **where the runtime can
only ask one, they go in a single message rather than one per turn.** The rule is the batch, and
the affordance is how the batch is delivered where it exists. **A free answer wins over the
buckets in either form** — an owner who describes their own practice has answered better than the
options could, and shaping that into a configuration is the advisor's work, not theirs.

**Presented together, consented per line** → `requests.md`.

**Options may be produced in parallel when speed matters** — one worker per option, isolated, the
fan-out announced with its cost (`consulting.md`); one agent working the options in sequence is
the cheap default. Two bounds: **the comparison is assembled by someone who authored none of the
options**, for the same reason a review never goes to the author — an option's author scores it
generously. And **options from one provider converge on that provider's tastes**: where the choice
carries weight, source them from different models, the same logic that prefers a reviewer off the
author's provider.

**Where measurement settles it cheaper than argument, propose the experiment instead of the
table**: the split, the metric and the threshold, all named before anything runs — a threshold
chosen after the data is a fit, not a test. Synthetic panels stay direction-only (`audience.md`).

## A rejected decision

**Weak:** *nothing recorded — it was discussed and dismissed.*

Six weeks later somebody proposes it again and the argument is re-run from memory.

**Strong:**

> **2026-06-14 — Search stays in the main database, no dedicated engine**
>
> **Considered:** built-in full-text · a self-hosted engine · a managed service
> **Chose:** built-in · **Rejected:** the other two
> **Because:** the acceptance set passes 19/20 on the built-in one, so the quality gap we assumed
> is not there at our size. The managed service is $50/mo above the envelope at current volumes
> (`checked 2026-06-14`, with the link — backticked here because this is a worked example, and a
> shown date must not age the way a claimed one does). The self-hosted one is free but adds a service to run, back
> up and upgrade, which nobody here owns.
> **Would revisit if:** we pass ~50k items per account, or non-Latin search becomes a requirement.
> **Decided by:** the owner, with the backend engineer.

**Every field earns its place:** what was considered, so the alternatives are not re-argued · **the
evidence, priced and dated**, not "it felt cleaner" · and **the revisit trigger**, so the decision
is provisional on the thing that would change it. *That is the difference between a decision log
and a graveyard of opinions.*

---

## The AI smell — a ban list, not an aspiration

**Slop is a vocabulary and a rhythm, and both are enumerable** — which is what makes this a form
rather than a plea to "write naturally". The list every agent carries (the guide template holds
the two-line version; this is the full one):

- **significance inflation** — *stands as a testament · pivotal moment · underscores the
  importance · evolving landscape · marking a shift*. Say what happened; the reader ranks it
- **the rule of three** as filler — *fast, simple, and reliable* — when only one word is load-bearing
- **negative parallelism** — *it's not just X, it's Y* — state Y
- **essay wrap-ups** — *In conclusion · Ultimately, this shows* — a document ends when it is done
- **AI vocabulary** — *delve · leverage · seamless · robust · crucial · foster · empower ·
  navigate the complexities* — and the Russian smell the English lists miss: *стоит отметить ·
  давайте разберёмся · в современном мире · играет ключевую роль · не секрет, что*
- **hedging stacks** — *could potentially perhaps* — one hedge, or a claim with a rung
- **sycophancy openers** — *Great question! · Certainly!* — answer
- **uniform rhythm** — every paragraph three sentences, every sentence the same length: vary or cut
- **bold-everywhere and bullet-itis** — emphasis that marks everything marks nothing

**The deep pass is a skill, not a longer list** — the shelf names it, with its limits
(`catalogue.md` → *Writing without the AI smell*): it attaches to roles that write for humans,
never runs over quotations, and may not invent a fact the source did not carry. **A rewrite that
smuggles a new fact in is worse than slop** — slop wastes attention; a fabricated specific
spends trust.

## Two habits that apply everywhere

**Say which claim you are making.** *"Built"* and *"works"* are different, and a status that blurs
them is worse than one that admits uncertainty.

**Offer a next action only when it is earned** — a blocker was exposed, something fixable was
exposed, or the next step is expensive and the offer *is* the gate. **Never after a plain fact,
never generic, never more than two.** One concrete sentence derived from this state. The value of a
suggestion is inversely proportional to how often one appears: an advisor that ends every reply
with an offer teaches the owner to skip the last line, and the one offer that mattered goes with
it.
