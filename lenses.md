# The four lenses — read before this ships

**Load when:** a change of consequence is about to land — a release, a merge into the guide, a
new capability, a rewritten rule. Also on request: *"run the lenses over this."*

Four readings, **one question each**, **in this order**, **by someone who is not the author**.
They are the **compensating control for every `prose-only` gate** — the reason it is honest to
write `enforced_by: prose-only` at all is that these run.

**Why four separate readings instead of one careful one.** A reader holding four questions holds
none of them. Each lens is cheap because it ignores everything except its own question, and the
order matters: deleting first means the later lenses read less.

**Why not the author.** Not distrust — **the author's context is invisible to the author**. They
cannot see what they assumed, because assuming it is what made the text feel complete.

---

## 1 · Deletion — what can go?

*Fights: additive drift.*

- What breaks if this is simply removed?
- Does it restate a rule that already lives somewhere? (If so, one of the two is the home and
  the other points.)
- Is a new entity doing work an existing one could do with **one more value**?
- Is this a pattern already named in `PATTERNS.md`, being paraphrased instead of cited?

The bar is not "is this good" but "would we notice it gone". A change that survives deletion is
the smallest version of itself, and that is the only version worth reviewing further.

## 2 · Adversarial — how does this fail?

*Fights: authors test what they intended.*

- The unhappy path. Misuse by someone in a hurry.
- **Does a failure fail loudly or quietly?** A gate that fails open is worse than no gate,
  because it is believed.
- What does a half-finished write leave behind?
- What is the **cheapest way to comply with the letter and violate the rule**?
- Who pays for it — in tokens, in attention, in a wait nobody sees?

## 3 · Contradiction — does this fight anything?

*Fights: local correctness.*

Against the corpus, not against taste. **Name both sides**, with locations.

- Does it promise something nothing delivers — a referenced file that does not exist, a check
  described but not implemented, a capability no door reaches?
- Does it use a glossary term in a second meaning?
- **A reversal is legitimate; an unstated one is not.** If this overturns an earlier decision,
  say so and say why, and the earlier decision gets its revisit note.

## 4 · Cold-read — understandable by someone who was not here?

*Fights: the author's context is invisible to the author.*

- Does it explain **why**, not only what?
- Does it depend on context that exists only in a conversation?
- Would a newcomer act correctly from this text alone — or **correctly by accident**?
- Is the example still an example of the rule, or did the rule move?

---

## Running them

**Each lens is stated, including when it found nothing.** *"Deletion: nothing found"* is a
result; silence is indistinguishable from a skipped lens.

**A finding names its place and its fix:** path, line, the defect in one sentence, and what
would resolve it. A finding without a location is an opinion.

**Findings are not votes.** The lenses report; the owner of the change decides, and a rejected
finding is answered, not ignored — one line saying why.

**They run on this skill and on the user's project alike.** The corpus is not more fragile than
the work; the same four questions catch the same four failures in a spec, a role's instructions
or a pipeline change.

**Temporary readers.** When they run as agents, they are created for the release and archived
after — they read, they do not own. Archiving them is part of finishing the release
(`PATTERNS.md` → *promote what outgrew itself* does not apply here: a lens never grows into a
role).

---

## What the lenses do not cover

They read **text**. They do not run the code, walk the links, or measure a number — those are
`checking.md` and the eval suite. Four green lenses over a claim that was never true is exactly
the failure mode the corpus names: *a statement that parsed perfectly, linked correctly, and was
false*. The six reading rules in `AGENTS.md` are the companion habit for that, and the eval
pass-rate is the measurement.
