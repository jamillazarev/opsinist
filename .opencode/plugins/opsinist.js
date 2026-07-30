/**
 * Opsinist plugin for OpenCode.ai
 *
 * Registers the skills directory and injects the advisor's always-on gates
 * into the first user message of a session — the anchor that holds when a
 * light model skips skill discovery (measured; see evals/RUNS.md upstream).
 */
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const skillsDir = path.resolve(__dirname, '../..'); // SKILL.md sits at the repo root
const rulesPath = path.resolve(__dirname, '../../rules/opsinist.md');
const MARKER = '<OPSINIST_ADVISOR_BOOTSTRAP>';

let _bootstrap; // undefined = not loaded, null = rules file missing
const bootstrap = () => {
  if (_bootstrap !== undefined) return _bootstrap;
  try {
    const rules = fs.readFileSync(rulesPath, 'utf8');
    _bootstrap = `${MARKER}
You are the user's advisor — the opsinist skill is your operating manual. Open the
\`opsinist\` skill and follow it before acting on any request about building or running a
team of agents, a project, tasks, roles or budgets — or a question about how to run work.
Opening the skill is reading the manual, not creating anything.

${rules}
</OPSINIST_ADVISOR_BOOTSTRAP>`;
  } catch {
    _bootstrap = null;
  }
  return _bootstrap;
};

export const OpsinistPlugin = async () => ({
  // Register the skills path in live config so discovery needs no symlinks.
  config: async (config) => {
    config.skills = config.skills || {};
    config.skills.paths = config.skills.paths || [];
    if (!config.skills.paths.includes(skillsDir)) config.skills.paths.push(skillsDir);
  },
  // Inject the anchor into the first user message; a marker guard prevents
  // double injection when the hook sees an already-transformed array again.
  'experimental.chat.messages.transform': async (_input, output) => {
    const text = bootstrap();
    if (!text || !output.messages.length) return;
    const firstUser = output.messages.find((m) => m.info.role === 'user');
    if (!firstUser || !firstUser.parts.length) return;
    if (firstUser.parts.some((p) => p.type === 'text' && p.text.includes(MARKER))) return;
    const ref = firstUser.parts[0];
    firstUser.parts.unshift({ ...ref, type: 'text', text });
  },
});
