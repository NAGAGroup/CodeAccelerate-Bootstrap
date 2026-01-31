# OpenCode Workflow and Plugin Redesign Plan

**Date:** January 30, 2026  
**Status:** Approved - Ready for Implementation  
**Session:** Collaborative Design with User

---

## Executive Summary

This plan outlines a comprehensive redesign of OpenCode's delegation system, workflow commands, and plugin architecture. The goals are to:

1. Replace narrative delegation with strict Jinja2 template-based delegation
2. Create command-driven workflows with enforced adherence via todo lists
3. Build specialized plugins for skill loading, workflow enforcement, drift prevention, and compaction handling
4. Rewrite the background_task plugin from scratch for cleaner behavior

---

## Scope

### 1. Delegation Revamp with Jinja2 Templates

**Current State:** Delegation skills contain narrative guidance with example templates

**Target State:** Each `skill/delegating-to-*/SKILL.md` file structure:

```markdown
---
name: delegating-to-junior-dev
description: Use when dispatching implementation tasks
---

# When to Delegate
[Simplified guidance - drastically reduced from current version]

# Anti-Patterns
[Keep existing anti-patterns section]

# Task Template

```jinja2
Task: {{task|required}}
Files: {{files|required|list}}
Spec:
{{spec|required|multiline}}
Verify: {{verify|required}}
Constraints: {{constraints|optional}}
```
```

**Key Changes:**
- Agents must fill the Jinja2 template exactly (not narrative)
- System validates all `|required` fields are present
- `|optional` fields can be omitted
- `|list`, `|multiline` provide type hints
- Templates live in markdown code blocks within skill files

**Affected Skills:**
- skill/delegating-to-junior-dev/SKILL.md
- skill/delegating-to-tech-lead/SKILL.md
- skill/delegating-to-tester/SKILL.md
- skill/delegating-to-explore/SKILL.md
- skill/delegating-to-librarian/SKILL.md
- skill/delegating-to-staff-editor/SKILL.md

---

### 2. Plugin Suite (5 Specialized Plugins)

#### A. Skill Loader Plugin

**Purpose:** Auto-load required skills for each agent

**Mechanism:**
- Reads `required_skills` from JSON config per agent
- Auto-loads skills before agent starts processing
- Zero agent action needed (fully automatic)

**Config Format:**
```json
{
  "agent": {
    "tech_lead": {
      "required_skills": [
        "skill-invocation-policy",
        "workspace-core",
        "neo-build-system"
      ]
    }
  }
}
```

**Deliverable:** `plugin/skill-loader.ts`

---

#### B. Workflow Enforcer Plugin

**Purpose:** Validate todo list adherence for command workflows

**Mechanism:**
- Validates at checkpoints (not every action):
  - Before delegation
  - Before file edits
  - Before major workflow steps
- Stops agent if action doesn't align with current todo
- Forces user confirmation to modify todos
- Allows fast-path for read-only operations (glob, grep, read)

**Hook Points:**
- `tool.execute.before` - Check tool call aligns with current todo
- Pre-delegation validation
- Pre-file-edit confirmation

**Deliverable:** `plugin/workflow-enforcer.ts`

---

#### C. Agent Tracker Plugin

**Purpose:** Detect and prevent agent drift

**Drift Types:**
1. **Repetition/circular behavior** - Agent going in loops
2. **Role boundary violations** - Agent performing actions outside their role (e.g., junior_dev debugging, explore editing files)
3. **Process non-compliance** - Skipping required steps in workflows or process skills

**Intervention:** TBD (reminder vs hard stop)

**Deliverable:** `plugin/agent-tracker.ts`

---

#### D. Compaction Handler Plugin

**Purpose:** Manage session compaction for subagents

**Problem:** Session compaction confuses both subagent and caller. Sometimes compaction occurs after a summary, and the agent was actually done but the summary triggered compaction.

**Mechanism:**
1. Detect session compaction event for subagents
2. Pause agent and ask: "Are you done or do you need to continue?"
3. If done: Reformat summary to remove compaction jargon before returning to caller
4. If continue: Let agent proceed with compacted context

**Deliverable:** `plugin/compaction-handler.ts`

---

#### E. Background Task Plugin (Complete Rewrite)

**Purpose:** Allow tasks to run in background (async execution)

**Approach:**
- Redesign from scratch (clean slate, no investigation of current issues)
- Behave identically to OpenCode's native task tool
- Only addition: support `wait: false` for async execution
- Do NOT reference current implementation to avoid session pollution

**Deliverable:** `plugin/background-task.ts` (rewrite)

---

### 3. Command Workflows (Markdown-Based)

**Context:** Files in `commands/*.md` are auto-converted to slash commands by OpenCode.

#### Three Initial Commands

##### `/plan-custom-workflow` (Plan Agent)

**Purpose:** Interactive planning session for one-off tasks

**Flow:**
1. User switches to plan agent via `<Tab>`
2. Runs `/plan-custom-workflow`
3. Plan agent conducts requirements gathering
4. Produces complete plan in chat
5. Instructs user: "Switch to primary-orchestrator with `<Tab>`, then run `/execute-custom-workflow`"

**Context Sharing:** Plan agent and primary-orchestrator share same context after `<Tab>` switch

**Deliverable:** `commands/plan-custom-workflow.md`

---

##### `/design-workflow` (Plan Agent)

**Purpose:** Create reusable workflow definition to save permanently

**Flow:**
1. User switches to plan agent
2. Runs `/design-workflow`
3. Plan agent collaborates to design workflow steps
4. Saves workflow definition to `commands/<workflow-name>.md`
5. New workflow becomes available as slash command automatically

**Deliverable:** `commands/design-workflow.md`

---

##### `/execute-custom-workflow` (Primary-Orchestrator)

**Purpose:** Execute plan produced by `/plan-custom-workflow`

**Flow:**
1. User switches to primary-orchestrator after planning phase
2. Runs `/execute-custom-workflow`
3. Loads plan from context (shared with plan agent)
4. Creates todo list from plan steps
5. Gets user approval of todos
6. Executes with workflow enforcer plugin validating adherence

**Plugin Integration:** Workflow enforcer plugin ensures strict todo list adherence

**Deliverable:** `commands/execute-custom-workflow.md`

---

## Non-Goals

- ❌ Not replacing build/plan agents (using OpenCode built-ins)
- ❌ Not creating comprehensive command library initially (start minimal)
- ❌ Not giving primary-orchestrator file access
- ❌ Not investigating current background_task issues
- ❌ Not auto-inferring required skills from agent.md files
- ❌ Not storing templates separately from skill files
- ❌ Not validating every single agent action (checkpoint-based validation only)

---

## Implementation Approach

### Phase 1: Delegation Foundation ⭐ **START HERE**

**Goal:** Replace narrative delegation with strict Jinja2 templates

**Tasks:**

1. **Design Jinja2 Template Format**
   - Define standard filters: `|required`, `|optional`, `|list`, `|multiline`, `|default(value)`
   - Document template syntax and validation rules
   - Create example templates for each delegation type

2. **Create Template Validation System**
   - Build validator that parses Jinja2 templates
   - Checks all `|required` fields are present
   - Validates type hints (`|list`, `|multiline`)
   - Returns clear error messages for invalid templates
   - Can be plugin or built-in system (TBD)

3. **Update Delegation Skills**
   - Pick reference implementation: `skill/delegating-to-junior-dev/SKILL.md`
   - Drastically simplify "When to Delegate" section
   - Keep "Anti-Patterns" section
   - Add "Task Template" section with Jinja2 code block
   - Apply pattern to remaining 5 delegation skills

**Acceptance Criteria:**
- [ ] Jinja2 template validation system works (rejects invalid templates)
- [ ] All 6 `delegating-to-*` skills updated with templates
- [ ] Agents successfully fill templates and system validates them
- [ ] Template validation errors are clear and actionable

---

### Phase 2: Plugin Development

**Implementation Order:**

1. **Skill Loader Plugin** (foundation for others)
   - Read JSON config for `required_skills` per agent
   - Auto-load skills before agent starts
   - Test with tech_lead agent (has multiple required skills)

2. **Workflow Enforcer Plugin** (needed for command workflows)
   - Implement checkpoint validation at hook points
   - Validate tool calls against current todo
   - Force user confirmation for todo modifications
   - Test with mock workflow

3. **Background Task Plugin Rewrite** (independent, can be parallel)
   - Start from scratch, no reference to current implementation
   - Mirror native task tool behavior exactly
   - Add `wait: false` support for async execution
   - Test parallel task execution

4. **Agent Tracker Plugin** (depends on understanding behavior patterns)
   - Implement drift detection for one type first (e.g., repetition)
   - Add detection for role violations
   - Add detection for process non-compliance
   - Define intervention mechanism

5. **Compaction Handler Plugin** (most specialized, build last)
   - Detect session compaction events
   - Implement interactive "done or continue?" check
   - Implement summary reformatting for caller
   - Test with subagent scenarios

**Acceptance Criteria:**
- [ ] Skill loader auto-loads skills from JSON config without agent awareness
- [ ] Workflow enforcer stops agents at checkpoints when out-of-bounds
- [ ] Background task plugin behaves identically to native task tool + `wait: false`
- [ ] Agent tracker detects at least one type of drift reliably
- [ ] Compaction handler successfully reformats summaries after compaction

---

### Phase 3: Command Workflows

**Tasks:**

1. **Define Markdown Workflow Format**
   - Establish structure for workflow steps in `commands/*.md`
   - Define how workflows integrate with todo tool
   - Document workflow → todo list conversion

2. **Implement `/plan-custom-workflow`**
   - Create command file in `commands/`
   - Define interactive planning session flow
   - Output format: plan in chat with next-step instructions
   - Test with plan agent

3. **Implement `/design-workflow`**
   - Create command file in `commands/`
   - Define collaborative workflow design process
   - Save new workflows to `commands/`
   - Verify new workflows become available as slash commands

4. **Implement `/execute-custom-workflow`**
   - Create command file in `commands/`
   - Load plan from shared context
   - Create todo list from plan
   - Get user approval before execution
   - Integrate with workflow enforcer plugin

5. **Test Full Cycle**
   - User runs `/plan-custom-workflow` in plan agent
   - Switches to primary-orchestrator with `<Tab>`
   - Runs `/execute-custom-workflow`
   - Verify workflow enforcer validates adherence
   - Verify todos can't be modified without permission

**Acceptance Criteria:**
- [ ] All three workflow commands are functional slash commands
- [ ] Plan agent → switch → primary-orchestrator flow works end-to-end
- [ ] Workflow enforcer validates todo adherence during `/execute-custom-workflow`
- [ ] User can create and save new workflows via `/design-workflow`

---

## Technical Details

### Jinja2 Template Syntax

**Standard Filters:**
- `{{variable|required}}` - Must be provided, validation fails if missing
- `{{variable|optional}}` - Can be omitted
- `{{variable|default('value')}}` - Provides default if not specified
- `{{variable|list}}` - Expects array/list
- `{{variable|multiline}}` - Expects multi-line text block

**Example Template:**
```jinja2
Task: {{task|required}}
Files: {{files|required|list}}
Spec:
{{spec|required|multiline}}
Verify: {{verify|required}}
Constraints: {{constraints|optional}}
Non-goals: {{non_goals|default('None specified')}}
```

**Example Agent Usage:**
```markdown
Task: Add verbose logging flag
Files: 
- src/main.cpp
- src/logger.h
Spec:
1. Add --verbose flag to argument parser
2. Pass flag to Logger::initialize()
3. Set log level to debug when flag is present
Verify: ./tests/test_logging.sh
Constraints: No changes to Logger API outside initialize()
```

---

### JSON Config for Required Skills

**Location:** `opencode.json` or separate config file (TBD)

**Format:**
```json
{
  "agent": {
    "tech_lead": {
      "required_skills": [
        "skill-invocation-policy",
        "workspace-core",
        "neo-build-system"
      ]
    },
    "junior_dev": {
      "required_skills": [
        "skill-invocation-policy"
      ]
    },
    "explore": {
      "required_skills": [
        "skill-invocation-policy"
      ]
    }
  }
}
```

---

### Workflow Enforcer Checkpoint Logic

**Hook Points:**
```typescript
// Check tool calls before execution
hooks.on('tool.execute.before', async (context) => {
  const currentTodo = await getCurrentTodo(context.sessionId);
  if (!isActionAlignedWithTodo(context.tool, context.args, currentTodo)) {
    throw new Error('Action does not align with current todo. Please confirm with user.');
  }
});

// Pre-delegation validation
hooks.on('task.delegate.before', async (context) => {
  const currentTodo = await getCurrentTodo(context.sessionId);
  if (!isDelegationInTodo(context.agent, context.instruction, currentTodo)) {
    throw new Error('Delegation not in todo list. Get user approval first.');
  }
});

// Pre-file-edit confirmation
hooks.on('tool.edit.before', async (context) => {
  const currentTodo = await getCurrentTodo(context.sessionId);
  if (!isFileInScope(context.filePath, currentTodo)) {
    throw new Error('File edit out of scope. Confirm with user.');
  }
});
```

**Fast-path for read-only:**
```typescript
const READ_ONLY_TOOLS = ['read', 'glob', 'grep', 'bash:readonly'];
if (READ_ONLY_TOOLS.includes(context.tool)) {
  return; // Allow without validation
}
```

---

## Open Questions / Decisions Needed

### Phase 1
- [ ] Should template validator be a plugin or built-in system?
- [ ] Where exactly should Jinja2 validator be implemented? (separate package? plugin? core?)
- [ ] Should we support full Jinja2 syntax or just the standard filters?

### Phase 2
- [ ] Should agent tracker use reminders or hard stops for drift intervention?
- [ ] Should compaction handler be a separate plugin or integrated with agent tracker?
- [ ] Where should `required_skills` config live? (opencode.json vs separate file)

### Phase 3
- [ ] What specific format for workflow steps in markdown? (numbered list? YAML frontmatter? custom syntax?)
- [ ] Should workflow enforcer be strict (block all non-todo actions) or permissive (warn only)?
- [ ] How should `/design-workflow` validate new workflow definitions before saving?

---

## Migration Path

**For Existing Configs:**

1. Current delegation skills continue to work (backward compatible)
2. Template validation is opt-in initially
3. Plugins can be enabled incrementally
4. No breaking changes to existing workflows

**Deprecation Timeline:**
- Phase 1 complete: New template format available, old format still works
- Phase 2 complete: Plugins available, agents can enable them
- Phase 3 complete: Command workflows available
- Future: Deprecate narrative delegation format (timeline TBD)

---

## Success Metrics

**Phase 1:**
- All delegation skills use Jinja2 templates
- Template validation catches 90%+ of malformed delegations
- Agent confusion about "how to delegate" is eliminated

**Phase 2:**
- Skill loader reduces agent startup token usage by 20%+
- Workflow enforcer prevents 95%+ of todo violations
- Agent drift detection catches common failure modes
- Background task plugin has zero "weird behavior" reports

**Phase 3:**
- Users can successfully complete plan → execute cycle
- Custom workflows can be designed and saved in <15 minutes
- Workflow adherence is enforced without excessive friction

---

## Next Steps

1. **Review this plan** ✅ - Confirmed with user
2. **Create Phase 1 implementation spec** - Detail Jinja2 template format
3. **Build template validator** - Standalone system to test rendering/validation
4. **Pick reference delegation skill** - Use `delegating-to-junior-dev` as first implementation
5. **Update all 6 delegation skills** - Apply template format systematically

---

## Related Documents

- Current delegation skills: `skill/delegating-to-*/SKILL.md`
- Current plugins: `plugin/background-task.ts`, `plugin/throttle.ts`
- Current commands: `commands/*.md`
- Agent definitions: `agent/*.md`

---

## Revision History

- **2026-01-30:** Initial plan created via collaborative design session
- Status: Approved, ready for Phase 1 implementation
