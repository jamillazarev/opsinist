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

## Nothing moves by itself

25. A closed blocker does not start the work.
26. All children finishing does not close the parent.
27. A slipped task does not move a date.
28. Everything surfaces as ready and waits.
29. Automatic transitions are how boards begin to lie.
30. The one exception is a parent with no definition of done of its own, because closing an empty folder asserts nothing.

## The team

31. A project starts with one advisor and nothing else.
32. The advisor is Opsinist itself — the session you are talking to.
33. There is exactly one advisor, and a validator refuses a second.
34. A role is created the moment a task needs a craft nobody has, and the reason is recorded then.
35. An unused role still costs: it sits in the roster, in search results, and in every "who should do this" decision.
36. A team assembled before the work is a guess about the work.
37. There are five kinds of role: advisor, worker, expert, persona, human.
38. A human may hold an assignment — taken, never handed out.
39. Nothing dispatches a person, because a queue that can push work onto a human is a queue that will.
40. A grade decides routing and never enters the instructions as an identity.
41. A model told it is junior will act junior, producing worse work on purpose.
42. Never demote a role to make it cheap — its cost history becomes unreadable.
43. You address the group and its routing rule decides who; exactly one may hold an assignment.
44. A role's load is budgeted as a share of the context window, not as a fixed number.
45. A role carrying twelve skills is worse at each of them than a focused one.
46. Caching makes breadth cheap; it does not make it good.
47. The advisor's own model is the one setting the cascade cannot reach, because the advisor is the session.

## Evidence

48. Every claim carries how it is known: measured, cited, recalled, or a judgement call.
49. A lower rung never borrows a higher one's authority.
50. The rung travels with the claim, so agent B cannot promote agent A's guess by quoting it.
51. An argument without a source is an opinion.
52. Signal about people uses a second ladder — live, twin, validated persona, proto — and the two are never pooled.
53. Three live interviews and twenty synthetic runs are never "23 responses".
54. A hundred synthetic respondents are one bias repeated a hundred times.
55. Synthetic audiences are legitimate for surfacing angles and illegitimate for percentages.
56. A percentage is refused before the run, not disclaimed after it.
57. Every persona carries two to four named biases, and each one names its grounding.
58. Persona verdicts are direction-only: which concern appeared, never a magnitude.
59. Agents run bias checkpoints on themselves — anchoring at framing, agreeableness at output.
60. *Is the search phrased to confirm rather than to find?* is a question an agent asks itself.

## Freshness

61. Every recorded fact that can change carries the date it was checked.
62. Past its recheck, a fact is unknown rather than fine.
63. Prices and current limits are fetched at the moment of use and never cached.
64. A stale tick is worse than no tick, because it makes someone skip the check they should have run.
65. Meeting a stale claim mid-task is a procedure: re-verify, or block — never quote it.
66. A snapshot of an external page is a cited claim, honest exactly as long as it is dated.
67. Research rots as a whole document: a pricing study from six months ago is not a fact.
68. A release that ships a stale price or a dead link ships a small lie.

## Gates

69. Four kinds of action route to the owner: spending, leaving the repository, destroying, and changing the shape of the team.
70. The fourth is the one everyone forgets, and it is how a project gets quietly rebuilt around someone else's intent.
71. A gate is a property of the action, not of who performs it.
72. The advisor is not exempt from any gate.
73. A blanket "yes" covers only the ungated.
74. Every gate declares what actually holds it: a request, a validator, the git host, the runtime, or nothing.
75. `prose-only` means nothing enforces it, and those rules are listed by name.
76. A gate believed in but not enforced is worse than a stated rule.
77. `destructive` is always-ask in every preset and cannot be preset away.
78. Loosening exists only as a grant, which is visible while it lives and expires by its own terms.
79. A grant's expiry is evaluated at the gate, not by a timer, because nothing runs while nobody is working.
80. The cascade is one-way: a task may raise the bar and never lower it.
81. Nobody edits the bar they are measured against.
82. A review goes to someone other than the author, because models judge their own output generously.
83. Self-editing is proposed, never self-merged.

## Cost

84. Cost is recorded as four token numbers, never one total.
85. Cache reads are the overwhelming majority of tokens, and a single total hides the only lever that moves the bill.
86. A run also records what it spent outside the model, because two hundred generated images cost money and no tokens.
87. Five of the ten cost slices measure waste rather than spend.
88. One slice answers what was spent on runs that produced nothing.
89. Another prices not getting it right the first time.
90. Another asks whether an expensive setting bought anything.
91. Another compares skills declared against skills used.
92. The advisory conversation is a separate bill from the work.
93. A budget changes what gets recommended in the first place, not only what gets stopped at the end.
94. With no budget declared, the system assumes no money and says so.
95. Credits and free months are runway, not income, and the advice names the cliff.
96. The dispatcher records the numbers, because a worker does not reliably see its own usage.

## Recovery

97. A run that dies resumes instead of restarting.
98. Recovery reads committed state from the repository, not from a session that no longer exists.
99. Work already applied is never redone.
100. A run that never returned is marked interrupted, and the task visibly regresses rather than sitting done-ish.
101. A board that went backwards overnight is reporting a failure, not somebody's edit.
102. Agents commit incrementally, around two thirds through the context, because a run that dies takes everything unwritten with it.
103. Three attempts at the same error is a signal, not a reason to try harder.
104. A third review round on the same point is a specification problem, not a review problem.

## Where things live

105. Six layers — documentation, work, conversation, team, telemetry, results — ordered by what they mean to someone with no agents at all.
106. Which of them land in the repository is one position on a ladder, not six switches.
107. A complete copy is always local, so the choice can be made after the work is done.
108. Fixing an issue in someone else's library leaves not one of our files in their tree.
109. In a repository that is not yours, the record still gets made — elsewhere, and you are told where.
110. Guest work is where a record matters most, because the checkout may be deleted the moment the work lands.
111. When ownership of a repository is unclear, the system treats you as a guest.
112. A guest produces no unsolicited debt list for maintainers.
113. A manifest in the repository says where each layer lives, so a clone always gives the map even when it does not give the contents.
114. Deleting a project lists what it found per destination and names separately what it cannot delete at all.
115. An operation that cannot reach a declared destination stops rather than half-finishing.

## The toolkit

116. A routine repeated twice becomes a skill; once is a task, and "we might need it" is neither.
117. An imported skill is screened as untrusted code *and* untrusted instructions.
118. A skill's text becomes part of what an agent believes, which is why it passes a gate before it attaches.
119. Fitting a skill to a role means dropping sections, never rewording them.
120. Compression preserves commands, paths, numbers and security rules verbatim.
121. If fitting fails, the role gets the original, never a truncation.
122. A skill that earned its keep across two projects can be de-identified and released on its own.
123. A tool entry records where the free tier ends, in the unit that will actually bite.
124. Throttling, hard-stopping and charging automatically are three different risks, and only the third surprises a budget.
125. A resource without a stated `why` is a bookmark, and nobody removes it because nobody knows what it was for.
126. A webhook URL is a credential, because holding it is enough to spend money under the project's name.
127. Secrets are registered by reference — name, purpose, prefix, expiry — and never by value.
128. Automations create work and never move anyone else's.
129. An automation dry-runs before it runs, and its failures are visible.

## Waiting, and what it costs

167. Work that would take minutes leaves the turn, so the conversation keeps going.
168. An agent asked something long says it is going to look, and comes back with the answer.
169. A reply that arrives late with substance beats a silence that looked like a reply being typed.
170. An estimate being overrun is said out loud, because silence that contradicts a promise reads as a crash.
171. Two things never go to the background: work the next sentence depends on, and work that will stop at a gate.
172. A helper is chosen at the tier its own work needs, never at its parent's.
173. Search, extraction and verification run a tier down or further.
174. "Same as me" is the most expensive default available, and it hides in the bill as ordinary work.
175. Every helper that ran is named in the record with its tier and what it was for.
176. An answer produced by three helpers is never reported as one agent's.
177. Before anything likely to exceed thirty seconds, you are told what is happening and roughly how long.
178. Silence during a long run reads as a crash, which is why there is a progress line at each meaningful completion.

## Leaving and coming back

179. There is no log-out: a session ends when you close it, and the advisor cannot end its own.
180. What ends a session cleanly is a wrap-up, and the words that start it are ordinary — "I'm done for now".
181. The wrap-up is offered when the signals are there, not remembered by you.
182. It is three writes: the tail to its thread, applied work committed, decisions recorded.
183. After that the session can be closed from anywhere, because nothing is left in it.
184. Clearing a terminal costs nothing, because the transcript is a source and never a dependency.
185. Opening the project again — same tool or another — starts with the arrival summary rather than a blank prompt.
186. A session that ended badly costs a summary line, not the work.

## Method

130. Every real decision runs one loop: frame, search, compare, choose, check it survives being wrong, record, act.
131. If a small error would flip the decision, the decision is undecided, and saying so beats faking precision.
132. Find the process before the tools, then find a tool per step, by function.
133. A literal "designer" finds nothing; "map the user journeys" finds everything.
134. A step with no tool is a gap, written as one, never papered over with improvisation.
135. Free, then open source, then self-hostable, then embeddable, then drivable by an agent — a paid option earns the exception with a recorded reason.
136. "Drivable by an agent" is not last by accident: a tool only a human can operate makes the owner the bottleneck.
137. Licensing is settled before the first line of work, because in licence-heavy domains it decides what you may ship.
138. Not knowing is normal; not looking is the failure.
139. Asked what *we* have, the registers are the first source and the web is where the register ran out.

## Talking to people

140. Two questions are never skipped: how much you want to be in the loop, and who may direct this.
141. An agent once ran an entire project hands-off because the first one was never asked.
142. Nobody is asked to choose a command; the entrance is read from what is there.
143. Anything readable from the ground is read, never asked.
144. A defensible default is stated as a filled-in form needing a nod, not asked as an open question.
145. Over-serving someone who asked for very little is the most common failure in practice.
146. A quick job gets three questions, one or two agents, build and review, and deliberately none of the machinery.
147. What a small job does *not* get is written down rather than left to judgement.
148. No praise by default, and disagreement comes with an alternative.
149. "Built" and "works" are different claims, and the system says which one it is making.
150. Advice arrives while the decision can still change for free, because a warning delivered after the work is built on it is just criticism.

## Outside software

151. *Ship* is the go-live moment whatever you make: an episode published, a production batch sent, a finding published.
152. *Urgent* means something different in every medium, and it is defined per medium.
153. A chip maker has no data flows, a channel has no sprints, a bakery has no deploys.
154. If a sentence would sound absurd to someone outside software, the sentence is wrong, not the reader.
155. There is no per-industry catalogue, because the moment one domain gets its own list this stops being a method.

## The system on itself

156. A change to the machinery goes through the same tasks, gates and history as the work.
157. Behavioural scenarios run against fixtures built by a script, so a suite is re-run rather than reconstructed.
158. The player in an eval never sees the rubric, and the judge never wrote the transcript it grades.
159. Evals are scored as a pass-rate, because one run of a nondeterministic actor is an anecdote.
160. The eval pass-rate is a regression detector and is deliberately not treated as a measure of success.
161. Four lenses read every change of consequence — deletion, adversarial, contradiction, cold-read — by someone who did not write it.
162. A lens that found nothing says so, because a silent lens is indistinguishable from a skipped one.
163. Validators refuse duplicate ids, dangling links, ageing claims, orphaned templates and a rule living in two files.
164. A rule kept in two files goes stale in one of them.
165. When a rule does not hold, the repair is a form — a list, a required field, a gate — and never a stronger sentence.
166. That last one was measured rather than argued.
