# Template-Based Delegation: Minimal Test Implementation

**Date:** 2026-01-31  
**Status:** Ready for Implementation  
**Goal:** Create minimal working config to validate template-based delegation approach

---

## Executive Summary

We will create a minimal OpenCode configuration to test a new `delegate` tool that wraps the built-in `task` tool with Jinja2 template validation. This proof-of-concept focuses on the `explore` agent only to validate the architecture before expanding to all 6 delegation patterns in the full config.

**Key Innovation:** Instead of reimplementing session management (900+ lines), we import OpenCode's internal `TaskTool` and wrap it with template validation (~200 lines).

---

## Problem Statement

### Current Pain Points with background_task Plugin

1. **No native UI integration** - Progress indicators missing
2. **Token inefficiency** - Results copied into parent context via `background_output`
3. **Polling overhead** - Agent must repeatedly check task status
4. **Complex session management** - 900 lines of custom session tracking code
5. **Edge case issues** - Compaction, cancellation, nested tasks

### Current Pain Points with Narrative Delegation

1. **Inconsistent instructions** - Each agent crafts delegation instructions differently
2. **No validation** - Missing critical information not caught until execution
3. **Hard to maintain** - Delegation patterns spread across agent prompts
4. **Difficult to version** - Can't track delegation template changes

### Desired End State

- **Template-based delegation** - Structured, validated, consistent
- **Built-in session management** - Leverage OpenCode's native implementation
- **Full UI integration** - Progress tracking, clickable session links
- **Token efficient** - Results stay in child sessions
- **Synchronous execution** - Simple blocking model (no background complexity)

---

## Research Findings

### Built-in Task Tool Analysis

**Location:** `opencode/tool/task.ts` (discovered via GitHub)

**Tool Signature:**
```typescript
task(
  description: string,      // 3-5 word task description
  prompt: string,           // Full instructions for agent
  subagent_type: string,    // Agent name to invoke
  session_id?: string,      // Optional: reuse existing session
  command?: string          // Optional: command that triggered task
)
```

**Key Features:**
- Creates child sessions with `Session.create({ parentID })`
- Subscribes to progress events for UI updates
- Handles permissions via `PermissionNext.evaluate()`
- Supports session reuse for multi-turn conversations
- Returns output with `<task_metadata>session_id: ses_xxx</task_metadata>`

**Critical Discovery:** OpenCode package exports all internal modules via `"exports": { "./*": "./src/*.ts" }`, making `TaskTool` importable!

### Plugin System Capabilities

**Auto-discovery:** Plugins in `plugin/` directory are automatically loaded

**External packages:** Specified via `plugin.{packageName}` in opencode.json (not package.json)

**Hooks available:**
- `tool` - Register new tools
- `tool.execute.before` - Intercept tool calls before execution
- `tool.execute.after` - Modify results after execution

**Context provided:**
```typescript
{
  sessionID, messageID, agent,
  directory, worktree,
  abort, metadata, ask
}
```

**Missing from context (vs built-in):**
- `messages` - Conversation history
- `callID` - Tool call identifier  
- `extra` - Additional metadata

---

## Architecture Design

### High-Level Flow

```
Primary Agent (plan)
    │
    ├─> Calls delegate(description, subagent_type, template_data)
    │   │
    │   ├─> Plugin: Find skill file (project/.opencode or ~/.config/opencode)
    │   ├─> Plugin: Extract Jinja2 template from SKILL.md
    │   ├─> Plugin: Validate template_data has required fields
    │   ├─> Plugin: Render template with nunjucks
    │   ├─> Plugin: Call TaskTool.init().execute(prompt=rendered)
    │   │
    │   └─> Built-in TaskTool handles:
    │       ├─ Session creation with parentID
    │       ├─ Permission checks
    │       ├─ Progress event subscriptions (UI updates)
    │       ├─ Prompt execution in child session
    │       └─ Return with session_id metadata
    │
    └─> Receives result with clickable session link
```

### Component Architecture

```
delegate tool (plugin/delegate.ts)
    │
    ├─> findSkillFile()          # Search project then global
    ├─> extractTemplate()         # Parse SKILL.md for Jinja2 block
    ├─> validateTemplateData()    # Check required fields present
    ├─> renderTemplate()          # Nunjucks with custom filters
    │
    └─> TaskTool.init().execute() # Delegate to built-in
```

### Skill File Resolution

**Priority order:**
1. `<project>/.opencode/skill/delegating-to-{agent}/SKILL.md` (highest priority)
2. `~/.config/opencode/skill/delegating-to-{agent}/SKILL.md` (fallback)

**Rationale:**
- Project-specific customization overrides global defaults
- Users can define custom delegation templates per project
- Global templates work across all projects as baseline

### Template Syntax

**Jinja2 with custom filters:**
- `{{field|required}}` - Must be provided, error if missing
- `{{field|optional}}` - Can be omitted, defaults to empty string
- `{{field|list}}` - Expects array, joins with newlines
- `{{field|multiline}}` - Preserves multi-line text

**Example template:**
```jinja2
**Goal:** {{goal|required}}

**Search Scope:** {{search_scope|required}}

**Questions:**
{{questions|required|multiline}}
```

**Example template_data:**
```typescript
{
  goal: "Locate authentication implementation",
  search_scope: "src/ directory, *.ts files",
  questions: "Where is login handled?\nHow are tokens stored?"
}
```

**Rendered output:**
```
**Goal:** Locate authentication implementation

**Search Scope:** src/ directory, *.ts files

**Questions:**
Where is login handled?
How are tokens stored?
```

---

## Implementation Plan

### Phase 1: Create Minimal Test Configuration

**Directory:** `opencode-delegate-minimal-config/` (new, isolated from main config)

**Why isolated?**
- Safe testing without affecting existing workflows
- Easy to iterate and experiment
- Clean validation before full rollout

### Phase 2: File Structure

```
opencode-delegate-minimal-config/
  opencode.json                           # Agent overrides + nunjucks dependency
  plugin/
    delegate.ts                           # Auto-discovered delegate tool
  skill/
    delegating-to-explore/
      SKILL.md                            # Jinja2 template for explore agent
```

### Phase 3: Component Specifications

#### **Component 1: opencode.json**

**Purpose:** Configure agents and external dependencies

**Key settings:**
- Override `plan` agent to disable `task`, enable `delegate`
- Define `explore` subagent with read-only tools
- Specify `nunjucks` external package dependency
- No need to explicitly list plugin file (auto-discovered)

**Tool permissions:**
```json
"plan": {
  "permission": {
    "task": { "*": "deny" },      // Hide built-in
    "delegate": { "*": "allow" }   // Show our wrapper
  }
}
```

#### **Component 2: plugin/delegate.ts**

**Purpose:** Wrap TaskTool with template validation

**Key functions:**

1. **findSkillFile(agentType, worktree)**
   - Searches `{worktree}/.opencode/skill/delegating-to-{agentType}/SKILL.md`
   - Falls back to `~/.config/opencode/skill/delegating-to-{agentType}/SKILL.md`
   - Throws helpful error if not found in either location

2. **extractTemplate(skillPath)**
   - Reads SKILL.md file
   - Extracts Jinja2 template from ` ```jinja2` code block
   - Parses template for `{{field|required}}` and `{{field|optional}}` patterns
   - Returns `{ content, required[], optional[] }`

3. **validateTemplateData(data, template, agentType)**
   - Checks all required fields present in data
   - Throws error with detailed message if validation fails:
     - Lists missing fields
     - Shows required vs optional fields
     - Shows what was provided
     - Displays full template for reference

4. **renderTemplate(template, data)**
   - Creates nunjucks environment with custom filters
   - Renders template string with provided data
   - Throws error if rendering fails (undefined required field, wrong type, etc.)

**Tool registration:**
```typescript
tool({
  description: "Delegate work to specialized agents using structured templates",
  args: {
    description: string,
    subagent_type: string,
    template_data: Record<string, any>,
    session_id?: string,
    command?: string,
  },
  async execute(args, context) {
    // 1. Find skill file
    // 2. Extract template
    // 3. Validate data
    // 4. Render prompt
    // 5. Call TaskTool.init().execute()
    // 6. Return result
  }
})
```

**Critical implementation detail:**

When calling TaskTool, we need to provide a compatible context object:
```typescript
{
  sessionID: context.sessionID,
  messageID: context.messageID,
  agent: context.agent,
  abort: context.abort,
  metadata: context.metadata,
  ask: context.ask,
  messages: [],              // Empty - TaskTool fetches if needed
  callID: context.messageID, // Use messageID as callID
  extra: {},                 // Empty extra metadata
}
```

**Import strategy:**

Primary attempt: `import { TaskTool } from "opencode/tool/task"`

Based on package.json exports pattern `"./*": "./src/*.ts"`, this should resolve correctly.

If import fails at runtime, we'll see immediate error and can adjust to `opencode/src/tool/task`.

#### **Component 3: skill/delegating-to-explore/SKILL.md**

**Purpose:** Define delegation template for explore agent

**Structure:**
```markdown
---
name: delegating-to-explore
description: Use when dispatching file discovery or structure analysis to explore
---

# Delegating to Explore Agent

## When to Delegate
[Brief description of when to use explore]

## Delegation Template

```jinja2
[Template with required/optional fields]
```

### Required Fields
[List with descriptions]

### Optional Fields
[List with descriptions]

### Example
[Working example with actual values]
```

**Template design for explore:**
- `goal` - What to find/understand (required)
- `search_scope` - Where to search (required)
- `questions` - Specific questions to answer (required, multiline)

**Rationale:**
- Explore is search-focused, needs clear goal and scope
- Questions provide structure to the exploration
- Simple enough to validate minimal implementation

---

## Testing Strategy

### Test Case 1: Basic Delegation

**Objective:** Verify end-to-end delegation works

**Setup:**
```bash
cd opencode-delegate-minimal-config
opencode
```

**Test:**
```
User prompt: "Find all plugin files in this repository"
```

**Expected behavior:**
1. Plan agent analyzes request
2. Decides to use `delegate` tool
3. Constructs template_data:
   ```typescript
   {
     goal: "Find all plugin files",
     search_scope: "entire repository, focusing on *.ts files",
     questions: "Where are plugins located?\nWhat naming conventions are used?"
   }
   ```
4. Plugin validates fields (all required present)
5. Plugin renders Jinja2 template to prompt
6. Built-in TaskTool creates child session
7. Explore agent executes in child session
8. Results return with clickable session link
9. Plan agent summarizes findings

**Success criteria:**
- ✅ No import errors (TaskTool loaded successfully)
- ✅ No validation errors (template_data complete)
- ✅ Explore session created with clickable link in UI
- ✅ Explore agent receives properly formatted instructions
- ✅ Results returned without polling
- ✅ Session management handled by built-in (no custom code)

### Test Case 2: Validation Error

**Objective:** Verify template validation catches missing fields

**Test:** Manually trigger incomplete delegation (modify agent prompt or direct tool call)
```typescript
delegate({
  description: "Find files",
  subagent_type: "explore",
  template_data: {
    goal: "Find plugins"
    // Missing: search_scope, questions
  }
})
```

**Expected error:**
```
Missing required template fields for explore:

Missing: search_scope, questions
Required: goal, search_scope, questions
Optional: 

You provided: goal

Template:
**Goal:** {{goal|required}}
**Search Scope:** {{search_scope|required}}
**Questions:**
{{questions|required|multiline}}
```

**Success criteria:**
- ✅ Error caught before TaskTool execution
- ✅ Clear indication of what's missing
- ✅ Full template displayed for reference
- ✅ Agent can self-correct and retry

### Test Case 3: Session Reuse

**Objective:** Verify multi-turn delegation works

**Test:**
```
First delegation: "Find authentication files"
  → Returns session_id: ses_abc123

Second delegation: "Continue exploring the auth patterns"
  → Uses session_id: ses_abc123
```

**Expected behavior:**
1. First delegation creates new explore session
2. Session ID returned in metadata
3. Second delegation with session_id parameter reuses same session
4. Explore agent has context from previous turn
5. Conversation continues naturally

**Success criteria:**
- ✅ session_id captured from first delegation
- ✅ Second delegation with session_id doesn't create new session
- ✅ Context preserved between delegations
- ✅ No session leakage or conflicts

### Test Case 4: Skill File Resolution

**Objective:** Verify project-local overrides global

**Setup:**
```bash
# Place skill in global location
mkdir -p ~/.config/opencode/skill/delegating-to-explore
ln -s $(pwd)/opencode-delegate-minimal-config/skill/delegating-to-explore/SKILL.md \
      ~/.config/opencode/skill/delegating-to-explore/SKILL.md

# Create project-local override with different template
mkdir -p opencode-delegate-minimal-config/.opencode/skill/delegating-to-explore
# ... create modified SKILL.md
```

**Test:**
Run delegation and verify project-local template is used (not global)

**Success criteria:**
- ✅ Project-local skill loaded when present
- ✅ Global skill used when project-local absent
- ✅ Clear error when neither exists

### Test Case 5: Import Path Validation

**Objective:** Verify OpenCode internals are accessible

**Test:** Plugin loads at startup

**Expected:**
- ✅ `import { TaskTool } from "opencode/tool/task"` succeeds
- ✅ `import { Tool } from "opencode/tool/tool"` succeeds
- ✅ No module resolution errors

**If import fails:**
- Try fallback: `opencode/src/tool/task`
- Document which path works for future reference

---

## Risk Assessment

### High Confidence Items

✅ **Template validation logic** - Straightforward string parsing and comparison  
✅ **Jinja2 rendering** - Nunjucks is battle-tested  
✅ **Skill file discovery** - Simple fs.access() with priority order  
✅ **Auto-discovery** - OpenCode feature, well-documented  

### Medium Confidence Items

⚠️ **Import path resolution** - 99% confident `opencode/tool/task` works, but untested  
⚠️ **Context object compatibility** - Missing fields might cause issues in TaskTool  
⚠️ **External package installation** - `plugin.nunjucks` should work but unverified  

### Low Confidence Items

❓ **TaskTool.init() parameters** - Mocking agent info might fail validation  
❓ **Type compatibility** - TypeScript types between plugin and built-in might conflict  

### Mitigation Strategies

**For import path issues:**
- Add try/catch with fallback to `opencode/src/tool/task`
- Log which path successfully resolves

**For context issues:**
- Start with minimal context (empty arrays/objects)
- Add fields only if TaskTool errors indicate they're needed
- Use SDK to fetch messages if TaskTool requires them

**For TaskTool.init() issues:**
- Try with undefined initContext first
- If that fails, fetch real agent info via `client.app.agents()`
- Mock minimal agent object as last resort

---

## Success Criteria

### Minimal Viable Success

✅ Plugin loads without errors  
✅ TaskTool import succeeds  
✅ Template extraction works  
✅ Validation catches missing fields  
✅ Jinja2 rendering produces correct output  
✅ TaskTool creates child session  
✅ Explore agent receives instructions  
✅ Results return with session_id  

### Full Success

✅ All minimal criteria above  
✅ UI shows progress indicators  
✅ Session links are clickable  
✅ Session reuse works  
✅ Skill file priority (project > global) works  
✅ Error messages are clear and actionable  
✅ No token inefficiency vs built-in task  
✅ Performance equivalent to built-in task  

---

## Next Steps After Validation

### Phase 1 Expansion: All Delegation Skills

Once minimal config validates the approach:

1. **Create delegation skills for remaining agents:**
   - `delegating-to-junior-dev` - Implementation work
   - `delegating-to-tech-lead` - Architecture and design
   - `delegating-to-tester` - Testing and verification
   - `delegating-to-librarian` - External research
   - `delegating-to-staff-editor` - Documentation review

2. **Design Jinja2 templates for each:**
   - junior_dev: `task, files, spec, verify, constraints`
   - tech_lead: `goal, context, constraints, acceptance_criteria`
   - tester: `task, context, test_commands, expected_results`
   - librarian: `question, context, desired_output`
   - staff_editor: `document, review_focus, context`

3. **Place in global config:**
   ```bash
   mkdir -p ~/.config/opencode/skill/delegating-to-*/
   # Copy SKILL.md files
   ```

### Phase 2: Full Config Integration

1. **Update main opencode_changes/opencode.json:**
   - Add `plugin.nunjucks` dependency
   - Update all primary agents: disable `task`, enable `delegate`
   - Keep subagents as-is (they don't delegate)

2. **Add delegate.ts to main config:**
   ```bash
   cp opencode-delegate-minimal-config/plugin/delegate.ts \
      opencode_changes/plugin/delegate.ts
   ```

3. **Delete background-task.ts:**
   ```bash
   rm opencode_changes/plugin/background-task.ts
   ```

4. **Update agent system prompts:**
   - Remove narrative delegation instructions
   - Add guidance on using `delegate` with template_data
   - Provide examples for each delegation pattern

### Phase 3: Testing & Refinement

1. **Test all 6 delegation pathways:**
   - primary-orchestrator → junior_dev
   - primary-orchestrator → tech_lead
   - primary-orchestrator → librarian
   - tech_lead → junior_dev
   - tech_lead → tester
   - tech_lead → explore

2. **Iterate on templates based on usage:**
   - Add optional fields if frequently needed
   - Clarify field descriptions if confusion occurs
   - Add examples for complex cases

3. **Performance validation:**
   - Compare token usage vs old approach
   - Verify no UI degradation
   - Check session management edge cases

---

## Open Questions

### Implementation Details

1. **Context object:** Should we populate `messages` array via SDK, or leave empty?
   - **Recommendation:** Start empty, add if TaskTool errors
   - **Rationale:** TaskTool likely fetches internally if needed

2. **Template strictness:** Allow extra fields in template_data, or error?
   - **Recommendation:** Allow extra fields (silently ignored)
   - **Rationale:** Flexibility for future extensions, LLMs might add metadata

3. **Error verbosity:** Show full template on validation error?
   - **Decision made:** Yes, show full template
   - **Rationale:** Helps agent self-correct without additional tool calls

4. **Import path fallback:** Add try/catch for alternate path?
   - **Recommendation:** Yes, try `opencode/tool/task` first, then `opencode/src/tool/task`
   - **Rationale:** Low cost, high reliability

### Future Enhancements

1. **Template inheritance:** Could delegation skills extend base templates?
2. **Conditional fields:** Support `{{field|required_if(other_field)}}`?
3. **Template composition:** Break large templates into reusable components?
4. **Type validation:** Check field types (string vs array) not just presence?
5. **Schema generation:** Auto-generate TypeScript types from templates?

**Decision:** Defer all to Phase 4 (after full rollout validated)

---

## Appendix A: File Contents

### opencode.json

```json
{
  "$schema": "https://opencode.ai/config.json",
  
  "agent": {
    "plan": {
      "mode": "primary",
      "model": {
        "providerID": "anthropic",
        "modelID": "claude-sonnet-4"
      },
      "permission": {
        "task": { "*": "deny" },
        "delegate": { "*": "allow" }
      }
    },
    "explore": {
      "mode": "subagent",
      "description": "Fast agent specialized for exploring codebases. Use when you need to quickly find files by patterns, search code for keywords, or answer questions about the codebase structure.",
      "permission": {
        "read": { "*": "allow" },
        "glob": { "*": "allow" },
        "grep": { "*": "allow" },
        "task": { "*": "deny" }
      }
    }
  },
  
  "plugin": {
    "nunjucks": "^3.2.4"
  }
}
```

### plugin/delegate.ts

```typescript
import { type Plugin, tool } from "@opencode-ai/plugin"
import { TaskTool } from "opencode/tool/task"
import { Tool } from "opencode/tool/tool"
import { readFile, access } from "fs/promises"
import { join } from "path"
import { homedir } from "os"
import nunjucks from "nunjucks"

interface TemplateInfo {
  content: string
  required: string[]
  optional: string[]
}

async function findSkillFile(
  agentType: string,
  worktree: string
): Promise<string> {
  const locations = [
    join(worktree, `.opencode/skill/delegating-to-${agentType}/SKILL.md`),
    join(homedir(), `.config/opencode/skill/delegating-to-${agentType}/SKILL.md`),
  ]
  
  for (const path of locations) {
    try {
      await access(path)
      return path
    } catch {
      continue
    }
  }
  
  throw new Error(
    `No delegation skill found for ${agentType}.\n\n` +
    `Searched:\n${locations.map(p => `  - ${p}`).join('\n')}\n\n` +
    `Create a skill file at one of these locations.`
  )
}

async function extractTemplate(skillPath: string): Promise<TemplateInfo> {
  const markdown = await readFile(skillPath, 'utf-8')
  
  const match = markdown.match(/```jinja2\n([\s\S]+?)\n```/)
  if (!match) {
    throw new Error(`No jinja2 template found in ${skillPath}`)
  }
  
  const content = match[1]
  const required = [...content.matchAll(/\{\{(\w+)\|required/g)].map(m => m[1])
  const optional = [...content.matchAll(/\{\{(\w+)\|optional/g)].map(m => m[1])
  
  return { content, required, optional }
}

function validateTemplateData(
  data: Record<string, any>,
  template: TemplateInfo,
  agentType: string
): void {
  const missing = template.required.filter(field => !(field in data))
  
  if (missing.length > 0) {
    throw new Error(
      `Missing required template fields for ${agentType}:\n\n` +
      `Missing: ${missing.join(', ')}\n` +
      `Required: ${template.required.join(', ')}\n` +
      `Optional: ${template.optional.join(', ')}\n\n` +
      `You provided: ${Object.keys(data).join(', ')}\n\n` +
      `Template:\n${template.content}`
    )
  }
}

function renderTemplate(
  template: string,
  data: Record<string, any>
): string {
  const env = new nunjucks.Environment()
  
  env.addFilter('required', (val) => {
    if (val === undefined || val === null) {
      throw new Error('Required field is missing')
    }
    return val
  })
  
  env.addFilter('optional', (val) => val ?? '')
  
  env.addFilter('list', (val) => {
    if (!Array.isArray(val)) {
      throw new Error('Expected array for |list filter')
    }
    return val.join('\n')
  })
  
  env.addFilter('multiline', (val) => String(val))
  
  return env.renderString(template, data)
}

export const DelegatePlugin: Plugin = async ({ worktree, client }) => {
  return {
    tool: {
      delegate: tool({
        description: `Delegate work to specialized agents using structured templates.

This replaces the built-in task tool with template-based validation.
Each agent has a delegation skill defining required/optional fields.

Use this for all subagent delegations.`,

        args: {
          description: tool.schema
            .string()
            .describe("3-5 word description of the task"),
          
          subagent_type: tool.schema
            .string()
            .describe("Agent name (e.g., explore, librarian, junior_dev)"),
          
          template_data: tool.schema
            .record(tool.schema.string(), tool.schema.any())
            .describe("Structured data for template (fields depend on agent)"),
          
          session_id: tool.schema
            .string()
            .optional()
            .describe("Reuse existing session ID"),
          
          command: tool.schema
            .string()
            .optional()
            .describe("Command that triggered this"),
        },

        async execute(args, context) {
          // 1. Find delegation skill (project-local or global)
          let skillPath: string
          try {
            skillPath = await findSkillFile(args.subagent_type, worktree)
          } catch (error) {
            throw new Error(error.message)
          }
          
          // 2. Extract template from skill
          let template: TemplateInfo
          try {
            template = await extractTemplate(skillPath)
          } catch (error) {
            throw new Error(
              `Failed to extract template from ${skillPath}: ${error.message}`
            )
          }
          
          // 3. Validate template data
          validateTemplateData(args.template_data, template, args.subagent_type)
          
          // 4. Render prompt from template
          let prompt: string
          try {
            prompt = renderTemplate(template.content, args.template_data)
          } catch (error) {
            throw new Error(
              `Template rendering failed for ${args.subagent_type}: ${error.message}\n\n` +
              `Template:\n${template.content}\n\n` +
              `Data provided:\n${JSON.stringify(args.template_data, null, 2)}`
            )
          }
          
          // 5. Get built-in TaskTool and initialize it
          const taskTool = await TaskTool.init({
            agent: {
              name: context.agent,
              mode: "primary" as any,
              permission: [],
            } as any
          })
          
          // 6. Call built-in task with rendered prompt
          const result = await taskTool.execute(
            {
              description: args.description,
              prompt: prompt,
              subagent_type: args.subagent_type,
              session_id: args.session_id,
              command: args.command,
            },
            {
              sessionID: context.sessionID,
              messageID: context.messageID,
              agent: context.agent,
              abort: context.abort,
              metadata: context.metadata,
              ask: context.ask,
              messages: [],
              callID: context.messageID,
              extra: {},
            } as any
          )
          
          // 7. Return formatted output (includes session_id metadata)
          return result.output
        },
      }),
    },
  }
}
```

### skill/delegating-to-explore/SKILL.md

```markdown
---
name: delegating-to-explore
description: Use when dispatching file discovery or structure analysis to explore
---

# Delegating to Explore Agent

## When to Delegate

Delegate to explore when you need to find files, search code, or understand codebase structure.

## Delegation Template

```jinja2
**Goal:** {{goal|required}}

**Search Scope:** {{search_scope|required}}

**Questions:**
{{questions|required|multiline}}
```

### Required Fields

- `goal` (string): What you're trying to find
- `search_scope` (string): Where to search (e.g., "entire codebase", "src/", "*.ts files")
- `questions` (string): Specific questions to answer (can be multi-line)

### Example

```typescript
delegate({
  description: "Find auth code",
  subagent_type: "explore",
  template_data: {
    goal: "Locate authentication implementation",
    search_scope: "src/ directory, *.ts files",
    questions: "Where is login handled?\nHow are tokens stored?"
  }
})
```
```

---

## Estimated Effort

**Setup:** 15 minutes  
**Implementation:** Already complete (files defined in this plan)  
**Testing:** 30 minutes  
**Iteration:** 15 minutes  
**Total:** ~1 hour

---

## Dependencies

- OpenCode v1.1.47+ (for plugin system features)
- nunjucks ^3.2.4 (auto-installed via plugin config)
- No package.json changes needed

---

## Conclusion

This minimal implementation validates the template-based delegation approach with minimal risk and effort. By focusing on just the explore agent, we can quickly verify:

1. Import of OpenCode internals works
2. Template extraction and validation is sound
3. Built-in TaskTool integration is seamless
4. UI and session management work as expected
5. Skill file discovery logic functions correctly

Once validated, we have a clear path to expand to all 6 delegation patterns in the full config, replacing the complex background_task plugin with a simpler, more maintainable solution that leverages OpenCode's native capabilities.

**Status:** Ready for implementation. All design decisions finalized, all files specified, all test cases defined.
