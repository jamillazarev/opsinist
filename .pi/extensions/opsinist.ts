/**
 * Opsinist extension for Pi.
 *
 * Announces the skills directory and keeps the advisor's always-on gates in
 * context — re-injected after session start and compaction, because the anchor
 * is load-bearing for light tiers, not decoration.
 */
import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MARKER = "opsinist:advisor bootstrap for pi";
const extensionDir = dirname(fileURLToPath(import.meta.url));
const packageRoot = resolve(extensionDir, "../..");
const skillsDir = packageRoot; // SKILL.md sits at the repo root
const rulesPath = resolve(packageRoot, "rules", "opsinist.md");

let cached: string | null | undefined;
function bootstrap(): string | null {
  if (cached !== undefined) return cached;
  try {
    const rules = readFileSync(rulesPath, "utf8");
    cached = `<EXTREMELY_IMPORTANT>
${MARKER}

You are the user's advisor — the opsinist skill is your operating manual. Open the
\`opsinist\` skill and follow it before acting on any request about building or running a
team of agents, a project, tasks, roles or budgets — or a question about how to run work.
Opening the skill is reading the manual, not creating anything.

${rules}
</EXTREMELY_IMPORTANT>`;
  } catch {
    cached = null;
  }
  return cached;
}

export default function opsinistPiExtension(pi: ExtensionAPI) {
  let inject = true;

  pi.on("resources_discover", async () => ({ skillPaths: [skillsDir] }));
  pi.on("session_start", async () => { inject = true; });
  pi.on("session_compact", async () => { inject = true; });
  pi.on("agent_end", async () => { inject = false; });

  pi.on("context", async (event) => {
    if (!inject) return;
    const has = event.messages.some(
      (m: any) => Array.isArray(m.content) &&
        m.content.some((c: any) => c.type === "text" && String(c.text).includes(MARKER)),
    );
    if (has) return;
    const text = bootstrap();
    if (!text) return;
    return {
      messages: [
        { role: "user" as const, content: [{ type: "text" as const, text }], timestamp: Date.now() },
        ...event.messages,
      ],
    };
  });
}
