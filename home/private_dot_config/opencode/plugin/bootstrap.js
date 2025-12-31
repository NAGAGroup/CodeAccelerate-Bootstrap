import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Path to the using-superpowers skill
const skillPath = path.join(__dirname, '../skill/using-superpowers/SKILL.md');

// Strip YAML frontmatter from skill content
const stripFrontmatter = (content) => {
  const frontmatterRegex = /^---\n[\s\S]*?\n---\n/;
  return content.replace(frontmatterRegex, '').trim();
};

// Get bootstrap content (full or compact)
const getBootstrapContent = (compact = false) => {
  if (!fs.existsSync(skillPath)) {
    return null;
  }

  const fullContent = fs.readFileSync(skillPath, 'utf8');
  const content = stripFrontmatter(fullContent);

  const toolMapping = compact
    ? `**Tools:** skill (native), todowrite (native), @mention for subagents`
    : `**Tool Mapping for OpenCode:**
- TodoWrite → todowrite (native)
- Task tool → @mention subagent system
- Skill tool → skill (native)
- Read/Write/Edit/Bash → native tools`;

  return `<EXTREMELY_IMPORTANT>
You have superpowers.

**IMPORTANT: The using-superpowers skill content is included below. It is ALREADY LOADED - you are currently following it. Do NOT use the skill tool to load "using-superpowers" - that would be redundant. Use skill only for OTHER skills.**

${content}

${toolMapping}
</EXTREMELY_IMPORTANT>`;
};

// Inject bootstrap content into session
const injectBootstrap = async (client, sessionID, compact = false) => {
  const bootstrapContent = getBootstrapContent(compact);
  if (!bootstrapContent) return false;

  try {
    await client.session.prompt({
      path: { id: sessionID },
      body: {
        noReply: true,
        parts: [{ type: "text", text: bootstrapContent, synthetic: true }]
      }
    });
    return true;
  } catch (err) {
    return false;
  }
};

// Plugin export - using correct ctx.client pattern
export const BootstrapPlugin = async (ctx) => {
  return {
    event: async ({ event }) => {
      const getSessionID = () => {
        return event.properties?.info?.id ||
               event.properties?.sessionID ||
               event.session?.id;
      };

      if (event.type === 'session.created') {
        const sessionID = getSessionID();
        if (sessionID) {
          await injectBootstrap(ctx.client, sessionID, false);
        }
      }

      if (event.type === 'session.compacted') {
        const sessionID = getSessionID();
        if (sessionID) {
          await injectBootstrap(ctx.client, sessionID, true);
        }
      }
    }
  };
};

export default BootstrapPlugin;
