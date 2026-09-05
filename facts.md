# Facts — the system in single sentences

**Load when:** writing about this system for people, or needing one true line about a part of it.

**Every line here stands alone.** No *this*, no *it* pointing at a neighbour — each is readable
out of order, because that is how they get used: on a card, in a post, in a page where they move.

**Every line is also true and traceable**, which is the whole constraint. A fact that overstates
is worse here than a fact that bores, because this file is what other writing quotes — and a
claim quoted out of a marketing page becomes a promise nobody checked. When a rule changes, the
line changes with it.

---

## The premise

1. One private git repository per project, and every entity inside it is a file.
2. Clone the repository and the project comes with it — the team, the process, the history, the budget.
3. Delete every cache and the system rebuilds it.
4. There is no export feature because there is nothing to export from.
5. Nothing load-bearing lives in a chat log or anyone's memory.
6. One repository is one project; several deliverables inside it are areas, not projects.
7. The tree you work in is not always the project's repository.
8. Because nothing load-bearing lives in the session, the session is replaceable.

## Work

9. A task has an id, an assignee, a thread, runs and a cost; a checklist line has none of those.
10. An id is six characters from a 32-symbol alphabet, and it is never reused.
11. Ids are minted by a script that skips what the tree already uses, because a model asked for a random id is not a random source.
12. Links point at the id and never at the name, which is what makes renaming safe.
13. There are six status categories, and the project names its own stages inside them.
14. `blocked` is not a status — a blocked task is *started*, with a blocker.
15. A stage is a step of a pipeline; a wave is a barrier between sibling children.
16. Two children in the same wave never own the same file, and ownership is assigned at decomposition rather than discovered at merge.
17. Relations are typed pairs with one side stored and the other generated.
18. Priority is opt-in, and dates beat priority.
19. Priority is not the order.
20. Raw intake lands in triage, off the board, with four dispositions: accept, decline with a reason, duplicate, snooze.
21. A parent that spans three crafts belongs to nobody and is left unassigned.
22. Progress is derived from the atoms every time and never stored as a rollup.
23. A task that cannot finish in one run is decomposed rather than hoped through.
24. Every task states what does *not* count as done — a plan instead of a result, a quietly narrowed scope, one example treated as verification.
25. A type proposes its task's fields at its birth — only the few its craft's own standard names, each carrying what it means and when to set it.

## Nothing moves by itself

26. A closed blocker does not start the work.
27. All children finishing does not close the parent.
28. A slipped task does not move a date.
29. Everything surfaces as ready and waits.
30. Automatic transitions are how boards begin to lie.
31. The one exception is a parent with no definition of done of its own, because closing an empty folder asserts nothing.

## The team

32. A project starts with one advisor and nothing else.
33. The advisor is Opsinist itself — the session you are talking to.
34. There is exactly one advisor, and a validator refuses a second.
35. A role is created the moment a task needs a craft nobody has, and the reason is recorded then.
36. An unused role still costs: it sits in the roster, in search results, and in every "who should do this" decision.
37. A team assembled before the work is a guess about the work.
38. There are five kinds of role: advisor, worker, expert, persona, human.
39. A human may hold an assignment — taken, never handed out.
40. Nothing dispatches a person, because a queue that can push work onto a human is a queue that will.
41. A grade decides routing and never enters the instructions as an identity.
42. A model told it is junior will act junior, producing worse work on purpose.
43. Never demote a role to make it cheap — its cost history becomes unreadable.
44. You address the group and its routing rule decides who; exactly one may hold an assignment.
45. A role's load is budgeted as a share of the context window, not as a fixed number.
46. A role carrying twelve skills is worse at each of them than a focused one.
47. Caching makes breadth cheap; it does not make it good.
48. The advisor's own model is the one setting the cascade cannot reach, because the advisor is the session.

## Evidence

49. Every claim carries how it is known: measured, cited, recalled, or a judgement call.
50. A lower rung never borrows a higher one's authority.
51. The rung travels with the claim, so agent B cannot promote agent A's guess by quoting it.
52. An argument without a source is an opinion.
53. Signal about people uses a second ladder — live, twin, validated persona, proto — and the two are never pooled.
54. Three live interviews and twenty synthetic runs are never "23 responses".
55. A hundred synthetic respondents are one bias repeated a hundred times.
56. Synthetic audiences are legitimate for surfacing angles and illegitimate for percentages.
57. A percentage is refused before the run, not disclaimed after it.
58. Every persona carries two to four named biases, and each one names its grounding.
59. Persona verdicts are direction-only: which concern appeared, never a magnitude.
60. Agents run bias checkpoints on themselves — anchoring at framing, agreeableness at output.
61. *Is the search phrased to confirm rather than to find?* is a question an agent asks itself.

## Freshness

62. Every recorded fact that can change carries the date it was checked.
63. Past its recheck, a fact is unknown rather than fine.
64. Prices and current limits are fetched at the moment of use and never cached.
65. A stale tick is worse than no tick, because it makes someone skip the check they should have run.
66. Meeting a stale claim mid-task is a procedure: re-verify, or block — never quote it.
67. A snapshot of an external page is a cited claim, honest exactly as long as it is dated.
68. Research rots as a whole document: a pricing study from six months ago is not a fact.
69. A release that ships a stale price or a dead link ships a small lie.

## Gates

70. Four kinds of action route to the owner: spending, leaving the repository, destroying, and changing the shape of the team.
71. The fourth is the one everyone forgets, and it is how a project gets quietly rebuilt around someone else's intent.
72. A gate is a property of the action, not of who performs it.
73. The advisor is not exempt from any gate.
74. A blanket "yes" covers only the ungated.
75. Every gate declares what actually holds it: a request, a validator, a hook that ships with the plugin, the git host, the runtime, or nothing.
76. `prose-only` means nothing enforces it, and those rules are listed by name.
77. A gate believed in but not enforced is worse than a stated rule.
78. `destructive` is always-ask in every preset and cannot be preset away.
79. Loosening exists only as a grant, which is visible while it lives and expires by its own terms.
80. A grant's expiry is evaluated at the gate, not by a timer, because nothing runs while nobody is working.
81. The cascade is one-way: a task may raise the bar and never lower it.
82. Nobody edits the bar they are measured against.
83. A review goes to someone other than the author, because models judge their own output generously.
84. Self-editing is proposed, never self-merged.
85. A repository being taken over cannot carry the preflight that would constrain the takeover, so those gates travel with the plugin as hooks.
86. An outward act — a push, a release, a publish, a deploy — is stopped by a hook that names two doors: the owner runs the command, or switches the gate off on purpose; the retry is not a door.
87. A rule spoken to be remembered is refused a home in the harness's private agent memory — the refusal names the files workers actually read.
88. In a takeover, a mutating call made before the debt list exists is refused, and a run that presented deferrable findings without writing them down is stopped.
89. A guest trips neither gate, because a guest owes no debt list at all.
90. No gate decides whether the owner said yes: any evidence of approval could be written by the party the gate constrains.

## Cost

91. Cost is recorded as four token numbers, never one total.
92. Cache reads are the overwhelming majority of tokens, and a single total hides the only lever that moves the bill.
93. A run also records what it spent outside the model, because two hundred generated images cost money and no tokens.
94. Five of the ten cost slices measure waste rather than spend.
95. One slice answers what was spent on runs that produced nothing.
96. Another prices not getting it right the first time.
97. Another asks whether an expensive setting bought anything.
98. Another compares skills declared against skills used.
99. The advisory conversation is a separate bill from the work.
100. A budget changes what gets recommended in the first place, not only what gets stopped at the end.
101. With no budget declared, the system assumes no money and says so.
102. Credits and free months are runway, not income, and the advice names the cliff.
103. The dispatcher records the numbers, because a worker does not reliably see its own usage.
104. A task that closes with no run record naming it is warned about at the moment it closes, because cost is stored once at the run and every other number is derived from it.
105. That warning names both honest answers — write the record, or say in History that a person did the work — so it can be answered rather than lived with.

## Recovery

106. A run that dies resumes instead of restarting.
107. Recovery reads committed state from the repository, not from a session that no longer exists.
108. Work already applied is never redone.
109. A run that never returned is marked interrupted, and the task visibly regresses rather than sitting done-ish.
110. A board that went backwards overnight is reporting a failure, not somebody's edit.
111. Agents commit incrementally, around two thirds through the context, because a run that dies takes everything unwritten with it.
112. Three attempts at the same error is a signal, not a reason to try harder.
113. A third review round on the same point is a specification problem, not a review problem.

## Where things live

114. Six layers — documentation, work, conversation, team, telemetry, results — ordered by what they mean to someone with no agents at all.
115. Which of them land in the repository is one position on a ladder, not six switches.
116. A complete copy is always local, so the choice can be made after the work is done.
117. Fixing an issue in someone else's library leaves not one of our files in their tree.
118. In a repository that is not yours, the record still gets made — elsewhere, and you are told where.
119. Guest work is where a record matters most, because the checkout may be deleted the moment the work lands.
120. When ownership of a repository is unclear, the system treats you as a guest.
121. A guest produces no unsolicited debt list for maintainers.
122. A manifest in the repository says where each layer lives, so a clone always gives the map even when it does not give the contents.
123. Deleting a project lists what it found per destination and names separately what it cannot delete at all.
124. An operation that cannot reach a declared destination stops rather than half-finishing.
125. Everything the machinery owns lives under `_ops/` — one directory, named to sort first and collide with nothing — and the root stays the craft's.
126. The layout migrator moves a flat project as history-preserving renames, refuses a dirty tree so the move is its own diff, and leaves what it does not recognise where it is, named.

## The toolkit

127. A routine repeated twice becomes a skill; once is a task, and "we might need it" is neither.
128. An imported skill is screened as untrusted code *and* untrusted instructions.
129. A skill's text becomes part of what an agent believes, which is why it passes a gate before it attaches.
130. Fitting a skill to a role means dropping sections, never rewording them.
131. Compression preserves commands, paths, numbers and security rules verbatim.
132. If fitting fails, the role gets the original, never a truncation.
133. A skill that earned its keep across two projects can be de-identified and released on its own.
134. A tool entry records where the free tier ends, in the unit that will actually bite.
135. Throttling, hard-stopping and charging automatically are three different risks, and only the third surprises a budget.
136. A resource without a stated `why` is a bookmark, and nobody removes it because nobody knows what it was for.
137. A resource serves every flow that meets its need — filed by one flow, scoped to none, read wherever relevant rather than re-asked for.
138. A webhook URL is a credential, because holding it is enough to spend money under the project's name.
139. Secrets are registered by reference — name, purpose, prefix, expiry — and never by value.
140. Automations create work and never move anyone else's.
141. An automation dry-runs before it runs, and its failures are visible.

## Waiting, and what it costs

142. Work that would take minutes leaves the turn, so the conversation keeps going.
143. An agent asked something long says it is going to look, and comes back with the answer.
144. A reply that arrives late with substance beats a silence that looked like a reply being typed.
145. An estimate being overrun is said out loud, because silence that contradicts a promise reads as a crash.
146. Two things never go to the background: work the next sentence depends on, and work that will stop at a gate.
147. A helper is chosen at the tier its own work needs, never at its parent's.
148. Search, extraction and verification run a tier down or further.
149. "Same as me" is the most expensive default available, and it hides in the bill as ordinary work.
150. Every helper that ran is named in the record with its tier and what it was for.
151. An answer produced by three helpers is never reported as one agent's.
152. Before anything likely to exceed thirty seconds, you are told what is happening and roughly how long.
153. Silence during a long run reads as a crash, which is why there is a progress line at each meaningful completion.

## Leaving and coming back

154. There is no log-out: a session ends when you close it, and the advisor cannot end its own.
155. What ends a session cleanly is a wrap-up, and the words that start it are ordinary — "I'm done for now".
156. The wrap-up is offered when the signals are there, not remembered by you.
157. It is three writes: the tail to its thread, applied work committed, decisions recorded.
158. After that the session can be closed from anywhere, because nothing is left in it.
159. Clearing a terminal costs nothing, because the transcript is a source and never a dependency.
160. Opening the project again — same tool or another — starts with the arrival summary rather than a blank prompt.
161. A session that ended badly costs a summary line, not the work.

## Method

162. Every real decision runs one loop: frame, search, compare, choose, check it survives being wrong, record, act.
163. If a small error would flip the decision, the decision is undecided, and saying so beats faking precision.
164. Find the process before the tools, then find a tool per step, by function.
165. A literal "designer" finds nothing; "map the user journeys" finds everything.
166. A step with no tool is a gap, written as one, never papered over with improvisation.
167. Free, then open source, then self-hostable, then embeddable, then drivable by an agent — a paid option earns the exception with a recorded reason.
168. "Drivable by an agent" is not last by accident: a tool only a human can operate makes the owner the bottleneck.
169. Licensing is settled before the first line of work, because in licence-heavy domains it decides what you may ship.
170. Not knowing is normal; not looking is the failure.
171. Asked what *we* have, the registers are the first source and the web is where the register ran out.

## Talking to people

172. Two questions are never skipped: how much you want to be in the loop, and who may direct this.
173. An agent once ran an entire project hands-off because the first one was never asked.
174. Nobody is asked to choose a command; the entrance is read from what is there.
175. Anything readable from the ground is read, never asked.
176. A defensible default is stated as a filled-in form needing a nod, not asked as an open question.
177. Over-serving someone who asked for very little is the most common failure in practice.
178. A quick job gets three questions, one or two agents, build and review, and deliberately none of the machinery.
179. What a small job does *not* get is written down rather than left to judgement.
180. No praise by default, and disagreement comes with an alternative.
181. "Built" and "works" are different claims, and the system says which one it is making.
182. Advice arrives while the decision can still change for free, because a warning delivered after the work is built on it is just criticism.

## Outside software

183. *Ship* is the go-live moment whatever you make: an episode published, a production batch sent, a finding published.
184. *Urgent* means something different in every medium, and it is defined per medium.
185. A chip maker has no data flows, a channel has no sprints, a bakery has no deploys.
186. If a sentence would sound absurd to someone outside software, the sentence is wrong, not the reader.
187. There is no per-industry catalogue, because the moment one domain gets its own list this stops being a method.

## The system on itself

188. A change to the machinery goes through the same tasks, gates and history as the work.
189. Behavioural scenarios run against fixtures built by a script, so a suite is re-run rather than reconstructed.
190. The player in an eval never sees the rubric, and the judge never wrote the transcript it grades.
191. Evals are scored as a pass-rate, because one run of a nondeterministic actor is an anecdote.
192. The eval pass-rate is a regression detector and is deliberately not treated as a measure of success.
193. Four lenses read every change of consequence — deletion, adversarial, contradiction, cold-read — by someone who did not write it.
194. A lens that found nothing says so, because a silent lens is indistinguishable from a skipped one.
195. Validators refuse duplicate ids, dangling links, ageing claims, orphaned templates and a rule living in two files.
196. A rule kept in two files goes stale in one of them.
197. When a rule does not hold, the repair is a form — a list, a required field, a gate — and never a stronger sentence.
198. That last one was measured rather than argued.

## The ladder and the door

199. Where the description of work lives is a ladder: the value names the cut, the rungs below are presumed, and a skipped rung is declared.
200. A spec document and a failing test are one cut, not two modes to choose between.
201. An exemplar is validator-checked or gauge-checked, and a gauge needs a judge who is not the author.
202. The kind of work owns the default cut, proposed from the craft's own standards at the type's first wave.
203. A stage changes through one door, which refuses with the reason, records the move — and never starts the next step.
204. A dispatched worker receives its legal moves generated from the pipeline's own block, never recited from memory.
205. A run's strategy resolves like its model does, lands on the record with its source, and the selector reads fields, never vibes.
206. Silence on a request does only what a grant, written in advance, allows.
207. A fact is cited to its place with a content-hash, so a passage that moves under the citation turns the fact unknown rather than quietly wrong.
208. Compaction is safe for exactly what is already in the repository, and the three writes come before the shrink.
209. Where the runtime can resume a dead session, the transcript is a readable source once — salvage, never the record.
210. A gap found mid-build goes to the group that owns the invalidated artefact, and nobody edits what another craft is standing on.
211. A release names its rollout, guardrail measures own the halt, and expansion surfaces as ready rather than advancing itself.
212. The kill switch is named before the first user sees the change, whatever the craft calls a kill switch.
213. A survey instrument matches its layer — the step, the scenario, the software, the brand — and reading one layer with another's tool is the trap.

## Assets and their recipes

214. A generated asset records the model, the prompt, the seed and the reference image it was made from.
215. A generated image whose recipe was not written down cannot be made again, and the set it belongs to drifts without anyone deciding to let it.
216. `seed: none` is an accepted answer, because some models expose no seed and an honest gap beats a fabricated number.
217. A style preset library is a vocabulary for talking to the owner, not the thing that makes two images match.
218. Reading a lost prompt back out of an image is salvage — what comes out resembles the original and is not it.
219. A transcript is taken from the caption track that already exists before any audio is sent to a model.
220. A deck kept as text in the repository can be diffed, reviewed and gated; one kept as a binary cannot.

## When the executor cannot

221. A worker missing a capability keeps the task and asks for one operation, because a task handed to a person has no runs and no capacity and its progress goes invisible.
222. A request has five kinds, and the fifth is a relay: one operation the worker cannot perform, and nothing else.
223. A relay carries the payload verbatim, the predicate and the destination — or the commit is refused.
224. The predicate is written before the payload, because a check written after the artefact arrives is written to fit it.
225. Production and perception fail separately, which is why a model that cannot draw an image can still judge one.
226. Where the worker cannot perceive the result either, it says so instead of performing an inspection it cannot do.
227. A capability gap is met mid-run, unlike every other missing capability, which is announced at dispatch.
228. The second time the same capability is missing, it stops being an escalation and becomes either a wired tool or a person on the roster who owns that surface.
229. A standing arrangement left as an escalation ages and surfaces every time, until the surface built to catch real trouble is the one nobody reads.

## Arriving where there is no repository

230. A directory that is not a git repository is told so at session start, because a person who has never run `git init` cannot act on a silence.
231. The fact names what the fix costs — one local command, nothing leaving the machine, undone by deleting one directory — rather than asking a question only someone who knows git can answer.
232. A folder that already holds work is told that `git init` moves and changes nothing, because that is the fear that stalls the takeover.
233. The no-repository fact is said once per directory and never in the home directory, because a hook that speaks in every folder is one people learn to ignore.
234. Auditing a tree with no history is a thinner job than auditing one with history, and saying so beats performing the fuller one on evidence that is not there.
235. A plugin's scope is where it is declared, never where its files are: the code lives in one machine-wide cache that every project shares.
236. A project-scoped plugin declaration without its marketplace tells a clone to enable something without saying where to get it.
237. A relay also carries what to return with the result, and that field is caught downstream rather than at the relay: without the model and the seed the recipe cannot be filled, and it is that commit which is refused.
238. A council's synthesis declares what it was made of — angles, voices, and whether they came from one provider — because a warning that agreement across one model is one bias repeated is a warning, while `provider: one` printed above the verdict is the reader seeing it.
239. The strongest dissent is what a council is bought for: a panel that converged instantly measured nothing, and the agreement is the part that was always going to be cheap.

240. A move on the map carries the job it is hired for, written as a job story — *when this happens, someone wants to do this, so they can get this* — and the guard refuses a move added without one. A route is a *how*; the job is the *why* somebody walked it, and a roadmap reading a map of routes alone proposes routes nobody asked for.

241. A market figure carries where it came from and when, or the guard refuses it — and `unknown` is an accepted answer. The gate does not ask a project to have numbers; it asks that a number, once written, be traceable, because a market size is the easiest thing in a project to invent and the hardest to check.

242. The record is written while the work happens, not filed when it finishes — a run does not choose when it ends, and a limit, a crash and a closed terminal each land on whatever was still only in the session's head. The outcome is the last field filled, never the first.

243. A finding does not become a rule the day it is found: a dated line costs nothing, a second occurrence earns it a task, and a promotion into the guide waits a week — spent doing other work, because what still reproduces with the panic gone is about the system. Repairs never wait; the ladder governs lessons.

244. Three attempts bound failure, and two runs that disagree bound contradiction — the worse state, because every run inside it looks like a success. The work stops at the second disagreement, and what escalates is that the question is unstable, never which run was right.

245. A run may not end leaving the machinery uncommitted — in a project this system operates, in a session that opened it, the hook refuses the ending once and names the files. It watches `_ops/` and the package manifests, because those are what every other gate keys on: each is enforced at the commit, so work that stops short of one is held by prose alone.

246. A commit that adds a dependency names it in the decision log, with what it replaces and what was rejected — the guard asks for the dependency's own name, not a keyword, because a gate satisfied by vocabulary teaches people to sprinkle words. A version bump is not a new dependency.

247. The rung above choosing a tool is asked where there is no code at all: a row added to the tooling register is refused unless something says what it replaces, because a supplier, a subscription and a stock licence arrive in a minute and are maintained for a year exactly as a library does. **`we had none` passes** — outside software that is usually the true answer, and a gate that would not accept it teaches people to invent a predecessor. It refuses rather than warns because the warning was measured at 0 of 5 and the refusal at 2 of 5 (2026-08-22).

248. A tool an agent can reach is weight it pays for, not only a thing it can do: where a runtime loads every tool's schema before the first word, forty tools are tens of thousands of tokens spent on a session that says hello. That is the same budget as a skill's `core_budget` and a role's always-loaded weight, arriving from outside the repository — so the register's question is not only *what can this reach* but *what does reaching cost when nothing uses it*. Runtimes have begun answering it themselves, by listing tools by name and loading a schema only when one is called for; where a runtime does not, the cost is real and the remedy is fewer servers wired, not a cleverer wrapper.

249. **More documentation, iterated without a human curating it, plateaus and then hurts.** Runs latch onto different parts of a grown document or ignore some of it, and the rate stops improving while the text keeps growing. The instinct when a run gets something wrong is to explain more; that is the move that stops working first, and what the document needs is someone deciding what comes OUT. Measured by Sanity Labs on their own design-system documentation and published 2026 (`catalogue.md`, *Does the design system survive an agent?*) — their models, their task, not this project's. It is the noise rule this system already applies to checkers and to migrated backlogs, arriving at the documents themselves.

250. **A multi-step flow a run must complete UNATTENDED is a form that does not hold** — a run walked through a configuration wizard abandons it partway, while a pre-written chunk of what that wizard would have produced held at 93–100% on the stronger tiers (Sanity Labs, 2026, their models — `catalogue.md`). **This is not the progressive interview**, which has a person answering at every turn and holds because they are the thing that forces the next step; it is the case where nothing is present to force one. A refusal and a template hole both survive being left alone. A conversation does not.

251. **The same document produces very different rates by tier, and improving it does not close the gap.** One before-and-after on one team's design-system docs — Sanity Labs, 2026, their models and their task (`catalogue.md`): 3% → 47% on their weakest tier, 20% → 90% in the middle, 40% → 100% at the top. Every band improved and the floor stayed a floor. So a document is not good or bad, it is good *for a tier*, and a rewrite that triples the weak tier can still leave it failing half the time. **State the tier with the rate**, and do not price work at the top band's number.

252. Whether a document WORKS is measurable, and measuring whether a rule holds does not measure it: a rule is measured by running the situation and counting the outcome, a document by giving several runs the same task with it and counting what came back. **The counts say where, never why.** The method, the measurements it uses and why this project has not run it are in `LATER.md`, *Nothing here measures whether a DOCUMENT works*.

253. **A ledger that records how a run ENDED cannot see two runs disagreeing about what is true**, and that is the worse failure — every run inside it finished, so every run reports confidently. Two workers answering one question opposite ways both write `completed`, and the contradiction leaves no trace at all. Measured on this project 2026-08-28: the rule bounding it had been written in nine files and enforced by nothing, because there was no field holding what a run *concluded* — only how it stopped. Adding that field made the bound countable, and five mutants of the resulting gate each fail assertions the honest version passes. **The general shape: a rule that names a state nothing records is not enforced and cannot be, however many times it is written.**

254. **A guard that reads a format its own template does not produce is green because it read nothing**, and that is worse than an absent guard: it issues a report on a check that did not happen. Measured 2026-09-05 on a live migration — two checks parsed YAML frontmatter while the shipped role template writes `**Type**: advisor` and a markdown table, so a role written from that template was invisible to both: two declared advisors, one found; nineteen skills, zero counted. **The pair had already been repaired once**, for the directory it looked in, and the format mismatch survived the repair untouched. The general question to put to every check that greps a file the corpus also ships a template for: *does this read the shape that template writes?* — and the answer is a fixture of each shape, not a reading.
