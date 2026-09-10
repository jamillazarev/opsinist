# Answer shapes — the three a consultation actually gets asked

**Open this before answering a question that has no thing to build** (`consulting.md`). Every
answer to a question of these kinds ends in **one named thing**, and the slots below are what
makes that checkable. A slot with nothing in it is written `unknown` — never dropped, because a
missing slot and a slot nobody could fill look identical afterwards.

**Measured 2026-07-31, N=5 per scenario:** six consultation scenarios failed every instance, all
in the same way — a symmetric list of options handed back for the owner to evaluate. *"Supabase
or Convex"* got balanced pros and cons and a clarifying question; *"what should I use for
transactional email"* got four vendors with recalled prices; *"how long to build currency
conversion"* got an estimate with no search behind it. **None of them was wrong about the
subject. Each stopped one step before the answer.**

---

## Depth — chosen before the run, and priced when it is offered

**This is the price list, and nothing enforces it.** The field lives on the finding as an optional
line; a guard for it was written and withdrawn the same day for having no measured defect behind it
(`LATER.md` → *Depth was demoted before its tag*). Quote a rung because the owner is paying for it,
not because a check will refuse you. An answer worth keeping becomes
`_ops/research/<question>.md` (`templates/FINDING-template.md`), which carries `Depth:` as an
optional line — one layer, one home. Use the table below to **quote the rung before the work**,
and quote it in the words of what it buys rather than in hours.
**A research document that does not say how hard anyone looked reads as if someone looked hard**,
which is the failure this field exists to stop. The owner picks; where they have not, the advisor
**proposes one with its price and waits**, because how long this takes is a spend and spending is
owner-confirmed (`permissions.md`).

| Depth | What it buys | What it costs | What it does **not** buy |
|---|---|---|---|
| **`orienting`** | is there an answer at all, and where does it live — a handful of sources, the shape of the disagreement, no synthesis | minutes, one turn | anything quotable. **This is a direction, not a finding** |
| **`deciding`** | enough to make the call and defend it: the canonical sources for *this* question, their tensions named, each one an entry in the register | tens of minutes, several turns and a few fetches | completeness. It answers the question asked, not the field around it |
| **`standing`** | something that will be quoted back in a year: everything `deciding` buys, plus every entry's `Reads against` **completed rather than `not checked`**, and an archive link per source | hours, and it is the only rung worth saying no to | a guarantee. It rots like everything else — `Research rots as a whole document` |

**Say the number before the work, not after.** The three rows above are the estimate the owner is
agreeing to; if the run outgrows its rung, that is a **new** question at a new price, not a quiet
overrun — the same rule a task follows when it outgrows its container.

**Native-first, answered 2026-09-10:** no runtime offers a research-depth setting, so this is
ours to hold. Deep-research products solve it with automatic tier routing and a budget cap; the
part worth borrowing is that **the tier is decided before the first fetch and stated**, and the
part not worth borrowing is deciding it silently on the owner's behalf.

## 1 · Choose between named options

> *"Postgres or SQLite?"* · *"Supabase or Convex?"* · *"What should I use for X?"*

| Slot | What goes in it |
|---|---|
| **the pick** | one of them, named in the first sentence — or **the condition that decides**, stated so the owner can answer it from what they know |
| **why this one here** | the property of *their* situation that moved it, not the general merits |
| **what it costs them** | what they give up by taking the pick — every real choice has one |
| **what the claim rests on** | fetched with its date, or `unknown`. A price, a limit or a tier recalled from memory is `unknown` |
| **what they already hold** | read from the register before the search — an existing choice outranks a better default |
| **when to revisit** | the moment that would change the answer, never a date |

**A comparison table is allowed and is not the answer.** If the table is the last thing in the
reply, the reply is a menu. **Symmetry is the tell**: two columns of equal length, each ending in
*"depends on your priorities"*, is the shape of a decision handed back.

---

## 2 · Find me something

> *"Find me photos"* · *"Send me some inspiration"* · *"Where do I get X for free?"*

The five-part shape in `consulting.md` — **the pick and why · what each claim rests on, quoted in
the page's own words · what the project already holds · where it lands when used · its origin,
named** (`found` where · `already ours` which register · **`made by us just now`**).

**And the direction is discovered, not assumed:** what it is for, and what the owner has already
committed to, are asked; everything else takes a default **stated as an assumption**. A
refinement — *"warmer, no people"* — is a constraint that does not expire.

---

## 3 · How long, how much, how big

> *"How long to build X?"* · *"What would this cost?"*

| Slot | What goes in it |
|---|---|
| **does it already exist** | **searched, before any number is written.** The cheapest build is the one nobody does, and an estimate produced without this step is an estimate for the wrong question |
| **the number, and what it is of** | the scope it covers, and what is deliberately outside it |
| **what it rests on** | comparable work, or a named assumption — never a feel |
| **what would move it most** | the one unknown whose answer changes the figure most |

**An estimate with no search behind it fails this shape even when the number is reasonable** —
measured 5 of 5 on *"I need currency conversion in my app. How long to build it?"*, where the
thing asked about ships as a free API.

---

## The line all three share

**A list is not an answer.** Every one of these ends in a recommendation with a reason, or a
**named gap** — *"this cannot be had as asked, and here is which part"* — which is a good answer
and a complete one. What it never ends in is a set of options with the choice handed back.
