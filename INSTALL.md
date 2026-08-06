# Installing

One repository, one skill, several runtimes. The corpus lives at **`skills/advisor/SKILL.md`**
with one folder per verb beside it (`skills/init/`, `skills/ship/`…) — the layout Claude Code
specifies, where **the folder name becomes the command**: `skills/init/` is `/opsinist:init`.
The companions sit at the repository root and the manifests around them, so the same directory
is a valid plugin for every runtime below. Rows carry the date they were verified, per the
freshness law — past its recheck a row is a claim to re-verify, not a fact.

| Runtime | Manifest it reads | Verified |
|---|---|---|
| Claude Code | `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` | **2026-07-31 · measured end to end** — installed and enabled at 0.1.0, then **upgraded in place to 0.1.1** with `marketplace update` followed by `plugin update`, on 2.1.220 |
| Google Antigravity | `plugin.json` (repo root) + `rules/` | **2026-07-31 · partly measured**: the by-hand route ran here — a `v0.1.1` snapshot placed at `~/.gemini/config/plugins/opsinist/`, root `plugin.json`, `rules/` and the corpus verified on disk afterwards. **Discovery by the IDE itself is not yet observed live**; the paths remain cited from antigravity.google/docs/plugins |
| Codex / ChatGPT | `.codex-plugin/plugin.json` | **2026-07-31 · measured end to end** — `codex plugin marketplace upgrade` then `codex plugin add opsinist@opsinist`; installed and enabled at 0.1.1, the config recording the source revision |
| Kimi Code CLI | `.kimi-plugin/plugin.json` — **which manifest path Kimi reads is unverified** | **2026-07-31 · partly measured**: the command is `kimi plugin install`, and `kimi plugin` is **absent from 0.14.2** here; syntax cited from moonshotai.github.io/kimi-cli |
| Gemini CLI | `gemini-extension.json` + `GEMINI.md` | **2026-07-31 · measured end to end** — at 0.1.1, resolved **from the GitHub release** (`v0.1.1`). **`extensions update` reported "already up to date" while sitting at 0.1.0**: this route follows *releases*, and a pushed tag is not one. Publishing the release, then uninstall and reinstall, moved it — the install prompt is interactive and needs `--consent` in a non-interactive shell |
| OpenCode | `package.json` + `.opencode/plugins/` — or the shared skills path | 2026-07-30 · cited from opencode.ai/docs/skills |
| OpenClaw | a symlink or copy in `~/.openclaw/skills/` (targeting `skills/advisor` works — companion resolution canonicalises the link) | **2026-08-06 · measured live** — `skills list` carries the description, and an embedded agent turn opened `entering.md` through the symlinked install and quoted its heading verbatim. The richest host profile seen so far: **cron, agent hooks and a resident gateway**, which makes it the first candidate to actually *hold* schedule and webhook triggers |
| Hermes Agent | `skills.external_dirs` in `~/.hermes/config.yaml` pointing at the package's `skills/` directory | **2026-08-06 · measured live** — a headless `-z` turn opened `entering.md` through the mounted path and quoted its heading verbatim; the mount does not fence `../../` — which is precisely what lets the mounted `skills/` reach the companions at the package root, so it is the feature this install relies on, not a hole to close. Ships **cron, webhook, hooks and secret sources (Bitwarden · 1Password)** — the second resident host, and the one whose secrets machinery matches `security.md`'s landing-place protocol |
| Cursor | `.cursor-plugin/plugin.json` | 2026-07-30 · not yet run here |
| Factory Droid · GitHub Copilot CLI | `.claude-plugin/marketplace.json` (Claude-compatible) | 2026-07-30 · not yet run here |
| Pi | `package.json` (`pi` field) + `.pi/extensions/` | 2026-07-30 · not yet run here |

## Claude Code

```sh
claude plugin marketplace add jamillazarev/opsinist
claude plugin install opsinist@opsinist
```

Verified end to end on Claude Code **2.1.220**, 2026-07-31 · **measured** — the marketplace
validates against this repository and the plugin installs and enables. Upgrading an existing
install is two commands, and the first is the one people miss:

```sh
claude plugin marketplace update opsinist
claude plugin update opsinist@opsinist
```

**Pick one route per harness, not both.** `npx skills add` copies the whole repository — plugin
manifest included — so Claude Code would see two plugins of one name; **the installed plugin
wins and the copy reports "not loaded"**. Delete `~/.claude/skills/opsinist` if you want the
message gone; the copy still serves every *other* harness from `~/.agents/skills/opsinist`.

**Why the corpus sits under `skills/` and not at the repository root.** A single `SKILL.md` at
the root is the plugin form for **exactly one skill** — and it silently suppresses every other
command in the plugin. That is not a guess: with the corpus at the root, the palette showed only
the skill itself plus one stray entry for the whole `commands/` folder, and **none of the
eighteen doors registered** (measured 2026-07-31, Claude Code 2.1.220). Under `skills/`, each
folder is its own command, exactly as the specification describes.

**The in-session `/plugin` route is a menu, and the two lines are two steps.** Paste **only the
source** — `jamillazarev/opsinist` — into its *Add Marketplace* field (its own examples say
`owner/repo`), then pick `opsinist@opsinist` from the list. Pasting both lines into that single
field returns *"not a valid GitHub owner/repo shorthand"*, which is the field reporting exactly
what it was given.

Or for local development: `claude --plugin-dir /path/to/opsinist`. Skills arrive namespaced —
`/opsinist:init`, `/opsinist:consult` — and the plain-language front door needs no command at
all.

## Google Antigravity

Place this repository (the whole folder) where Antigravity discovers plugins:

- workspace: `<workspace>/.agents/plugins/opsinist/`
- global: `~/.gemini/config/plugins/opsinist/`

```sh
agy plugin install https://github.com/jamillazarev/opsinist
```

Or place the repository by hand. **Clone it yourself, outside the agent.** Antigravity's sandbox policy can block agent-driven
`git clone` of github.com (observed as `403 · not allowed by policy`, 2026-07-29) — asking the
agent to install this skill mid-session fails and then runs the corpus as loose files, which
is the degraded mode most of its process failures were traced to. The `rules/` folder keeps
the hard gates always-on there.

## Codex / ChatGPT

The `.codex-plugin/plugin.json` manifest follows the documented format (name, version,
description, `skills: ./skills/`). Distribution goes through the OpenAI plugin directory;
for local testing use the `$plugin-creator` flow described in their docs. Plugins surface in
ChatGPT Work and Codex (desktop + CLI) — not in consumer Chat or mobile.

## Kimi Code CLI

```sh
kimi plugin install https://github.com/jamillazarev/opsinist.git
```

**Three honest caveats, because this row was wrong once.** The command is a **CLI subcommand,
not a slash command** — an earlier version of this file said `/plugins install`, which does not
exist (corrected 2026-07-31 against
[the plugin docs](https://moonshotai.github.io/kimi-cli/en/customization/plugins.html)).
**Plugin support is version-gated**: `kimi plugin` is absent from **0.14.2**, measured on this
machine 2026-07-31 — check `kimi plugin --help` before relying on it, and upgrade first if it
falls through to the general help. And the docs describe a plugin directory holding a
**`plugin.json`**, while this repository ships `.kimi-plugin/plugin.json` (the path a
third-party index documents); **which one Kimi actually reads is unverified here** — if the
install does not surface the skills, the bare-skill route below is the one that works.

Kimi also supports `sessionStart.skill` for an always-on advisor; it is deliberately not preset
here — turn it on per workspace once you want the resident mode.

## Gemini CLI

```sh
gemini extensions install https://github.com/jamillazarev/opsinist
```

**It asks before it installs**, twice: an untrusted workspace is refused outright (run it from a
directory you have trusted), and third-party extensions carry a confirmation naming what a skill
can do to your session — answer it yourself rather than piping a `Y`.

**Upgrade by uninstalling and installing again**, rather than with `extensions update`:

```sh
gemini extensions uninstall opsinist
gemini extensions install https://github.com/jamillazarev/opsinist
```

**Why, and the honest boundary of what was tested.** `extensions update` has failed here twice,
differently. Once it reported *"already up to date"* while sitting on the old version — this
route follows **releases**, and a pushed tag is not one; that failure hits everybody. Once it
produced **no output for minutes**, which was the third-party consent prompt waiting on a stdin
nobody was holding — **that one was in a non-interactive shell, and in a real terminal you would
simply see the prompt and answer it.** Both look like a slow download and neither is. The two
commands above took seconds and moved `0.1.1 → 0.1.2` (measured `2026-07-31`); add `--consent`
to the second one only when scripting it, where there is no one to answer.

The extension manifest points Gemini CLI at this repository, and
`GEMINI.md` rides along as always-on context — the anchor that keeps the hard gates loaded
even when a light model skips the router. Gemini-derived CLIs (Qwen Code, iFlow) share this
extension format; verify per tool before relying on it.

## OpenCode

Add the plugin to `opencode.json` (global or project-level) — it registers the skills and
keeps the advisor's gates loaded:

```json
{ "plugin": ["opsinist@git+https://github.com/jamillazarev/opsinist.git"] }
```

Or skip the plugin and use the shared skills path, which OpenCode also reads:

```sh
ln -s "$(pwd)" ~/.agents/skills/opsinist
```

OpenCode discovers skills in `.opencode/skills/`, `.claude/skills/` and `.agents/skills/`
(project or global), reading the same `SKILL.md` files with unknown frontmatter ignored. The
`~/.agents/skills` symlink also covers Antigravity's global location and other tools adopting
the shared path. Cursor, Copilot agent mode, Cline, Roo Code and Goose read the Agent Skills
standard the same way — point them at this repository per each tool's skills directory.

## Factory Droid

```sh
droid plugin marketplace add https://github.com/jamillazarev/opsinist
droid plugin install opsinist@opsinist
```

## GitHub Copilot CLI

```sh
copilot plugin marketplace add jamillazarev/opsinist
copilot plugin install opsinist@opsinist
```

Both read the Claude-compatible marketplace manifest this repository already carries.

## Cursor

The repository ships Cursor's manifest (`.cursor-plugin/plugin.json`). In Cursor Agent
chat, `/add-plugin opsinist` installs it once the plugin is listed in Cursor's marketplace;
until the listing lands, use the bare-skill route below.

## Pi

```sh
pi install git:github.com/jamillazarev/opsinist
```

The package's `pi` field registers the skills and an extension that keeps the advisor's
gates in context across session starts and compactions.

## OpenClaw

Symlink the skill into OpenClaw's skills directory:

```sh
ln -s "$(pwd)" ~/.openclaw/skills/opsinist
```

**Add a trigger rule to your workspace `AGENTS.md`** — open the `opsinist` skill before acting on
requests about running a team, a project, tasks, roles or budgets, **on anything that spends,
ships, deletes, or takes a project over**, and on questions about how to run work — so the gates
hold even when discovery is skipped.

**Both ends of the range need it, and for opposite reasons.** A light model may not open the
skill because it does not connect the request to it. **A strong one may not open it because it
does not need to**: measured 2026-08-01, three runs of *"I want to build a macOS app that fixes
system audio. Set it up."* on a tier above the advisor's floor **never invoked the skill and
never read a corpus file** — they wrote the app and compiled it. That is a defensible reading of
the request, and it is exactly why the rule cannot be left to discovery. **Capability suppresses
recourse to a methodology**, and the anchor is what makes the choice explicit instead of
implicit.

**The class in that sentence is machinery, not phrasing.** Measured 2026-08-01: on *"Delete this
project"* — one of the four gated kinds — five runs in five opened nothing at all, in a fixture
whose anchor was present and whose class list named state, work, team, cost and shipping but not
destroying. **The acts most worth a manual are the ones a narrow trigger silently excludes**, and
a repository with no guide at all — the ordinary shape of a takeover — has no anchor to widen,
which is why those situations get a door instead (`/opsinist:join`).

## hermes-agent

Mount the skill read-only via `skills.external_dirs` in `~/.hermes/config.yaml`:

```yaml
skills:
  external_dirs:
    - /path/to/opsinist/skills
```

An always-on personality that names the skill is what makes light models open it — add one
under `agent.personalities` and switch with `/personality`.

## Anything else that reads bare Agent Skills

```sh
npx skills add jamillazarev/opsinist
```

**Measured 2026-07-31**: the installer finds `skills/advisor/SKILL.md` inside this repository —
the corpus does **not** need to sit at the repo root — lands it in **`~/.agents/skills/opsinist`**,
and symlinks it into every harness that reads its own path. **Run it from your home directory
unless you mean a project-scoped install**: from inside a project it writes
`<project>/.agents/skills/` instead, which is easy to lose track of.

Some thirty tools read the Agent Skills standard directly — point them at
`skills/advisor/`. CrewAI: `Agent(skills=[Path(".")])`. The capabilities differ per runtime even
when installation succeeds — `runtimes.md` is the map of what degrades
where.

---

## Updating — one route per harness

**There is no single command, and assuming there is one is how a runtime sits on an old version
while reporting itself current.** The choice made above decides how it updates. Measured end to
end on `2026-07-31`, and the flow that uses this table is `upgrading.md` — **updating moves the
bytes; upgrading moves the project.**

| Installed as | What moves it | The trap |
|---|---|---|
| **a plugin, Claude Code** | `claude plugin marketplace update <name>` **then** `claude plugin update <plugin>@<marketplace>` | **the first step is the one people skip** — without it the second honestly reports nothing to update. Restart to apply |
| **a plugin, Codex** | `codex plugin marketplace upgrade` then `codex plugin add <plugin>@<marketplace>` | `add` without `@marketplace` refuses when two marketplaces are configured |
| **an extension, Gemini CLI** | **uninstall, then `gemini extensions install <url>`** — after the GitHub release is published; add `--consent` only when scripting | **`extensions update` is not the route.** Twice, differently: it answered *"already up to date"* on an old version — this route follows *releases*, and **a pushed tag is not one**, which hits every user — and it produced **no output for minutes** in a non-interactive shell, where the consent prompt had no one to answer it. Both look like a slow network and neither is. Uninstall-then-install took seconds and moved 0.1.1 → 0.1.2 |
| **a copied skills directory** | re-copy the source | the drift announces itself nowhere, so the announcement is a command: `scripts/find-installs.sh` after every update, and the copy's row shows the new version or the copy did not move |

An earlier version of that row said only *"nothing announces that the copy drifted"* — a property,
not an instruction — and within the hour the machine it described was caught holding exactly such
a copy. **A rule that names a property gets nodded at; a rule that names a command gets run.**

**Verify by reading the installed copy, never the command's output.** Each of the routes above
reported success at least once for a version it had not moved to — check the version in the
installed manifest, and that the core and the verb doors are all present.
