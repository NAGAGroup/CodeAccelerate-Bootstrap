# Phase 1: Delegation Foundation - Implementation Plan

**Date:** January 30, 2026  
**Status:** Ready for Implementation  
**Parent Plan:** [2026-01-30-workflow-and-plugin-redesign.md](./2026-01-30-workflow-and-plugin-redesign.md)

---

## Overview

Phase 1 replaces narrative delegation with strict Jinja2 template-based delegation. This provides:
- Type-safe delegation with validation
- Clear contracts between agents
- Automatic detection of malformed delegations
- Foundation for workflow enforcement (Phase 2)

---

## Architecture Decisions

### Key Decisions from Planning Session

1. **Template Validation:** Plugin-based (not core integration)
2. **Field Definition:** Template-inferred (parse Jinja2 to discover requirements)
3. **Backward Compatibility:** Hard cutover (no dual-format support needed)
4. **Agent Interaction:** Tool-based rendering (`task` tool with template_data parameter)
5. **Plugin Consolidation:** All-in-one task plugin (template rendering + validation + async execution)
6. **Execution Modes:** Both sync (`wait: true`) and async (`wait: false`) supported

### Critical Insight

**The built-in `task` tool will be disabled** for primary-orchestrator and tech_lead. The new background_task plugin will expose a replacement `task` tool that:
1. Requires template-based delegation
2. Reads delegation skill to extract Jinja2 template
3. Renders template with agent-provided key-value pairs
4. Validates all required fields are present
5. Executes delegation (async by default, sync if `wait: true`)

---

## Component Breakdown

### Component 1: Task Plugin with Template System

**File:** `plugin/task.ts` (replaces `plugin/background-task.ts`)

**Responsibilities:**
1. **Tool Registration:** Expose `task` tool to replace built-in
2. **Template Extraction:** Read delegation skill, parse Jinja2 template from markdown code block
3. **Template Rendering:** Fill template with agent-provided data
4. **Template Validation:** Ensure all `|required` fields present, check type hints
5. **Async Execution:** Support `wait: false` for background execution
6. **Sync Execution:** Support `wait: true` for blocking execution

**Tool Signature:**
```typescript
interface TaskToolParams {
  agent: string;                    // Target agent name (e.g., 'junior_dev')
  template_data: Record<string, any>; // Key-value pairs for template rendering
  wait?: boolean;                    // Default false (async)
  session_id?: string;               // Optional session reuse
}
```

**Tool Description:**
```
task(agent, template_data, wait=false, session_id=null)

Delegate work to a subagent using template-based specification.

IMPORTANT: Load the corresponding delegation skill first to understand 
what fields are required for template_data.

Examples:
- Load skill: skill('delegating-to-junior-dev')
- Delegate: task(agent='junior_dev', template_data={
    task: 'Add verbose logging flag',
    files: ['/path/to/main.cpp', '/path/to/logger.h'],
    spec: '1. Add flag parsing\n2. Update logger\n...',
    verify: 'pixi run test && ./build/app --verbose',
    constraints: 'Follow existing arg parsing patterns'
  })

Parameters:
- agent: Target agent ('junior_dev', 'explore', 'tester', etc.)
- template_data: Key-value pairs matching delegation template
- wait: false=async (default), true=blocking
- session_id: Optional session to reuse for stateful work
```

**Template Parsing Logic:**

1. Read `skill/delegating-to-{agent}/SKILL.md`
2. Find markdown code block with `jinja2` language tag
3. Parse Jinja2 template to extract variables and filters
4. Build schema: `{field: {required: bool, filter: string}}`

**Template Validation Logic:**

1. Check all `|required` fields are present in `template_data`
2. Validate type hints:
   - `|list` → value must be array
   - `|multiline` → value contains newlines or is array (joined with `\n`)
   - `|default(val)` → use default if field missing
3. Return clear errors: `"Missing required field 'task' for delegating-to-junior-dev"`

**Async Execution Flow:**
```typescript
async function executeDelegation(params: TaskToolParams) {
  // 1. Load delegation skill
  const skillPath = `skill/delegating-to-${params.agent}/SKILL.md`;
  const skillContent = await readFile(skillPath);
  
  // 2. Extract template from code block
  const template = extractJinja2Template(skillContent);
  
  // 3. Parse template to get schema
  const schema = parseTemplateSchema(template);
  
  // 4. Validate template_data against schema
  validateTemplateData(params.template_data, schema);
  
  // 5. Render template
  const renderedInstruction = renderTemplate(template, params.template_data);
  
  // 6. Execute delegation (async or sync based on wait param)
  if (params.wait) {
    return await executeTaskSync(params.agent, renderedInstruction, params.session_id);
  } else {
    return await executeTaskAsync(params.agent, renderedInstruction, params.session_id);
  }
}
```

---

### Component 2: Jinja2 Template System

**Implementation Options:**

#### Option A: Use Existing Jinja2 Library (Recommended)
- **Package:** `nunjucks` (Jinja2-compatible for JavaScript/TypeScript)
- **Pros:** Battle-tested, full Jinja2 feature set, active maintenance
- **Cons:** Additional dependency

#### Option B: Minimal Custom Parser
- **Approach:** Parse only subset of Jinja2 (variables, filters, no control flow)
- **Pros:** No dependencies, tailored to our needs
- **Cons:** More code to maintain, potential bugs

**Recommendation:** Use `nunjucks` for reliability and full Jinja2 compatibility.

**Filter Implementations:**

```typescript
// Standard filters for delegation templates
const templateFilters = {
  required: (value: any) => {
    if (value === undefined || value === null) {
      throw new Error('Required field is missing');
    }
    return value;
  },
  
  optional: (value: any) => value ?? '',
  
  default: (value: any, defaultValue: any) => value ?? defaultValue,
  
  list: (value: any) => {
    if (!Array.isArray(value)) {
      throw new Error('Expected array value');
    }
    return value.join('\n');
  },
  
  multiline: (value: any) => {
    if (Array.isArray(value)) {
      return value.join('\n');
    }
    return String(value);
  }
};
```

**Template Parsing:**

```typescript
interface TemplateSchema {
  fields: Record<string, FieldSchema>;
}

interface FieldSchema {
  name: string;
  required: boolean;
  filters: string[];  // e.g., ['required', 'list']
  defaultValue?: any;
}

function parseTemplateSchema(template: string): TemplateSchema {
  // Use regex or nunjucks AST to extract variables
  const variableRegex = /\{\{([^}]+)\}\}/g;
  const fields: Record<string, FieldSchema> = {};
  
  let match;
  while ((match = variableRegex.exec(template)) !== null) {
    const varExpr = match[1].trim();
    const parts = varExpr.split('|').map(p => p.trim());
    const fieldName = parts[0];
    const filters = parts.slice(1);
    
    const required = filters.includes('required');
    const defaultMatch = filters.find(f => f.startsWith('default('));
    const defaultValue = defaultMatch ? extractDefaultValue(defaultMatch) : undefined;
    
    fields[fieldName] = {
      name: fieldName,
      required,
      filters,
      defaultValue
    };
  }
  
  return { fields };
}
```

---

### Component 3: Updated Delegation Skills

Each delegation skill will be updated to this structure:

```markdown
---
name: delegating-to-{agent}
description: Use when [triggering condition]
---

# Delegating to {Agent}

## When to Delegate

[Simplified 2-3 sentence summary of agent capabilities]

## Anti-Patterns

[Keep existing anti-patterns - these are valuable]

- Pattern 1
- Pattern 2
- Pattern 3

## Task Template

```jinja2
[Template specific to this agent]
```
```

**Template Specifications by Agent:**

#### delegating-to-junior-dev

```jinja2
Task: {{task|required}}

Files:
{{files|required|list}}

Spec:
{{spec|required|multiline}}

Verify:
{{verify|required}}

Constraints:
{{constraints|optional}}
```

**Required Fields:** task, files, spec, verify  
**Optional Fields:** constraints

---

#### delegating-to-tech-lead

```jinja2
Goal: {{goal|required}}

Context:
{{context|required|multiline}}

Constraints:
{{constraints|optional}}

Non-goals:
{{non_goals|optional}}

Acceptance Criteria:
{{acceptance_criteria|required|multiline}}

Reminders:
- Load your required skills before starting
- Prioritize delegation to specialized subagents
- Check if additional skills can help with this task
```

**Required Fields:** goal, context, acceptance_criteria  
**Optional Fields:** constraints, non_goals

---

#### delegating-to-tester

```jinja2
Task: {{task|required}}

Context:
{{context|required}}

Build Commands:
```bash
{{build_commands|optional}}
```

Test Commands:
```bash
{{test_commands|required}}
```

Expected Results:
{{expected_results|required|multiline}}

On Failure:
```bash
{{failure_diagnostics|optional}}
```
```

**Required Fields:** task, context, test_commands, expected_results  
**Optional Fields:** build_commands, failure_diagnostics

---

#### delegating-to-explore

```jinja2
Goal: {{goal|required}}

Search Scope:
{{search_scope|required}}

Specific Questions:
{{questions|required|multiline}}
```

**Required Fields:** goal, search_scope, questions  
**Optional Fields:** None

---

#### delegating-to-librarian

```jinja2
Question: {{question|required}}

Context:
{{context|required}}

Desired Output:
{{desired_output|optional|default('API documentation with examples and links')}}
```

**Required Fields:** question, context  
**Optional Fields:** desired_output (has default)

---

#### delegating-to-staff-editor

```jinja2
Document:
{{document|required|multiline}}

Review Focus:
{{review_focus|required|multiline}}

Context:
{{context|optional}}
```

**Required Fields:** document, review_focus  
**Optional Fields:** context

---

## Implementation Sequence

### Step 1: Create Task Plugin Skeleton

**Files to create:**
- `plugin/task.ts` - Main plugin file
- `plugin/task/template-parser.ts` - Template extraction and parsing
- `plugin/task/template-renderer.ts` - Jinja2 rendering with nunjucks
- `plugin/task/template-validator.ts` - Schema validation
- `plugin/task/task-executor.ts` - Async/sync execution logic

**Dependencies:**
```json
{
  "dependencies": {
    "nunjucks": "^3.2.4"
  },
  "devDependencies": {
    "@types/nunjucks": "^3.2.6"
  }
}
```

**Plugin Registration:**
```typescript
// plugin/task.ts
export default {
  name: 'task',
  version: '2.0.0',
  description: 'Template-based task delegation with async support',
  
  tools: {
    task: {
      description: '[Tool description from Component 1]',
      parameters: {
        type: 'object',
        properties: {
          agent: { type: 'string', description: 'Target agent name' },
          template_data: { type: 'object', description: 'Key-value pairs for template' },
          wait: { type: 'boolean', default: false },
          session_id: { type: 'string' }
        },
        required: ['agent', 'template_data']
      },
      handler: async (params) => executeDelegation(params)
    }
  },
  
  hooks: {
    // Background task management hooks
    'task.complete': notifyParentSession,
    'task.cancel': cleanupTask
  }
};
```

**Disable Built-in Task:**
```json
// opencode.json
{
  "agent": {
    "primary-orchestrator": {
      "tools": {
        "*": false,
        "question": true,
        "skill": true,
        "task": false  // Disable built-in
        // Plugin task tool will be available automatically
      }
    },
    "tech_lead": {
      "tools": {
        "*": false,
        "read": true,
        "grep": true,
        "glob": true,
        "skill": true,
        "task": false  // Disable built-in
      }
    }
  }
}
```

---

### Step 2: Implement Template Parser

**File:** `plugin/task/template-parser.ts`

```typescript
export function extractJinja2Template(skillMarkdown: string): string {
  // Find code block with jinja2 language tag
  const templateRegex = /```jinja2\n([\s\S]*?)\n```/;
  const match = skillMarkdown.match(templateRegex);
  
  if (!match) {
    throw new Error('No jinja2 template found in delegation skill');
  }
  
  return match[1];
}

export function parseTemplateSchema(template: string): TemplateSchema {
  // Implementation from Component 2
  // Returns schema with required/optional fields
}
```

**Test Cases:**
```typescript
describe('extractJinja2Template', () => {
  it('extracts template from markdown code block', () => {
    const markdown = `
# Delegating to Junior Dev
## Task Template
\`\`\`jinja2
Task: {{task|required}}
Files: {{files|required|list}}
\`\`\`
    `;
    const template = extractJinja2Template(markdown);
    expect(template).toContain('Task: {{task|required}}');
  });
  
  it('throws error if no template found', () => {
    const markdown = '# No template here';
    expect(() => extractJinja2Template(markdown)).toThrow();
  });
});
```

---

### Step 3: Implement Template Renderer

**File:** `plugin/task/template-renderer.ts`

```typescript
import nunjucks from 'nunjucks';

// Configure nunjucks with custom filters
const env = new nunjucks.Environment(null, { autoescape: false });

// Add custom filters
env.addFilter('required', (value) => {
  if (value === undefined || value === null) {
    throw new Error('Required field missing');
  }
  return value;
});

env.addFilter('optional', (value) => value ?? '');
env.addFilter('default', (value, defaultVal) => value ?? defaultVal);
env.addFilter('list', (value) => {
  if (!Array.isArray(value)) {
    throw new Error('Expected array');
  }
  return value.join('\n');
});
env.addFilter('multiline', (value) => {
  if (Array.isArray(value)) {
    return value.join('\n');
  }
  return String(value);
});

export function renderTemplate(template: string, data: Record<string, any>): string {
  try {
    return env.renderString(template, data);
  } catch (error) {
    throw new Error(`Template rendering failed: ${error.message}`);
  }
}
```

**Test Cases:**
```typescript
describe('renderTemplate', () => {
  it('renders simple template', () => {
    const template = 'Task: {{task|required}}';
    const data = { task: 'Add logging' };
    const result = renderTemplate(template, data);
    expect(result).toBe('Task: Add logging');
  });
  
  it('throws error for missing required field', () => {
    const template = 'Task: {{task|required}}';
    const data = {};
    expect(() => renderTemplate(template, data)).toThrow();
  });
  
  it('handles list filter', () => {
    const template = 'Files:\n{{files|list}}';
    const data = { files: ['a.cpp', 'b.h'] };
    const result = renderTemplate(template, data);
    expect(result).toBe('Files:\na.cpp\nb.h');
  });
});
```

---

### Step 4: Implement Template Validator

**File:** `plugin/task/template-validator.ts`

```typescript
export function validateTemplateData(
  data: Record<string, any>,
  schema: TemplateSchema
): ValidationResult {
  const errors: string[] = [];
  
  // Check all required fields are present
  for (const [fieldName, fieldSchema] of Object.entries(schema.fields)) {
    if (fieldSchema.required && !(fieldName in data)) {
      errors.push(`Missing required field '${fieldName}'`);
    }
    
    // Validate type hints
    if (fieldName in data) {
      const value = data[fieldName];
      
      if (fieldSchema.filters.includes('list') && !Array.isArray(value)) {
        errors.push(`Field '${fieldName}' must be an array (has |list filter)`);
      }
    }
  }
  
  return {
    valid: errors.length === 0,
    errors
  };
}
```

**Test Cases:**
```typescript
describe('validateTemplateData', () => {
  it('validates required fields present', () => {
    const schema = {
      fields: {
        task: { name: 'task', required: true, filters: ['required'] }
      }
    };
    const data = { task: 'Add logging' };
    const result = validateTemplateData(data, schema);
    expect(result.valid).toBe(true);
  });
  
  it('detects missing required fields', () => {
    const schema = {
      fields: {
        task: { name: 'task', required: true, filters: ['required'] }
      }
    };
    const data = {};
    const result = validateTemplateData(data, schema);
    expect(result.valid).toBe(false);
    expect(result.errors).toContain("Missing required field 'task'");
  });
});
```

---

### Step 5: Implement Task Executor

**File:** `plugin/task/task-executor.ts`

```typescript
// This is the existing background_task logic, just integrated
// with the template system

export async function executeTaskAsync(
  agent: string,
  instruction: string,
  sessionId?: string
): Promise<TaskResult> {
  // Create background task
  const task = createBackgroundTask({
    agent,
    instruction,
    parentSessionId: getCurrentSessionId(),
    sessionId
  });
  
  // Start execution in background
  executeInBackground(task);
  
  // Return task ID immediately
  return {
    task_id: task.id,
    status: 'running',
    message: `Background task started for ${agent}. Use background_output(task_id="${task.id}") to check status.`
  };
}

export async function executeTaskSync(
  agent: string,
  instruction: string,
  sessionId?: string
): Promise<TaskResult> {
  // Execute and wait for completion
  const task = createBackgroundTask({
    agent,
    instruction,
    parentSessionId: getCurrentSessionId(),
    sessionId
  });
  
  // Execute and block until complete
  const result = await executeAndWait(task);
  
  return {
    status: 'completed',
    result: result.output
  };
}
```

---

### Step 6: Update Delegation Skills

For each of the 6 delegation skills, apply this transformation:

**Before (current narrative format):**
```markdown
## Instruction Template

### Task
[Single sentence: what to accomplish]

### Files
[Absolute paths only - list all files]

### Spec
[Numbered steps with exact locations]
```

**After (Jinja2 template format):**
```markdown
## Task Template

```jinja2
Task: {{task|required}}

Files:
{{files|required|list}}

Spec:
{{spec|required|multiline}}

Verify:
{{verify|required}}

Constraints:
{{constraints|optional}}
```
```

**Simplification Guidelines:**
- Reduce "When to Delegate" from 5-10 lines to 2-3 sentences
- Keep all anti-patterns (they're valuable)
- Remove verbose instruction template explanations (template is self-documenting)

**Order of Updates:**
1. `delegating-to-junior-dev` (reference implementation)
2. `delegating-to-tester` (similar to junior_dev)
3. `delegating-to-tech-lead` (different structure)
4. `delegating-to-explore` (simplest)
5. `delegating-to-librarian` (simple with default)
6. `delegating-to-staff-editor` (multiline heavy)

---

### Step 7: Update opencode.json

Disable built-in task tool and configure plugin:

```json
{
  "agent": {
    "primary-orchestrator": {
      "tools": {
        "*": false,
        "question": true,
        "skill": true,
        "task": false  // Disable built-in, plugin provides replacement
      }
    },
    "tech_lead": {
      "tools": {
        "*": false,
        "read": true,
        "edit": true,
        "write": true,
        "grep": true,
        "glob": true,
        "skill": true,
        "todowrite": true,
        "todoread": true,
        "diagrams*": true,
        "task": false  // Disable built-in, plugin provides replacement
      }
    }
  },
  "plugins": [
    {
      "path": "./plugin/task.ts",
      "enabled": true
    },
    {
      "path": "./plugin/throttle.ts",
      "enabled": true
    }
  ]
}
```

---

## Testing Strategy

### Unit Tests

**Template Parser Tests:**
- Extract template from valid markdown
- Throw error on missing template
- Parse schema correctly
- Handle edge cases (empty template, malformed jinja2)

**Template Renderer Tests:**
- Render simple templates
- Apply filters correctly
- Throw errors on missing required fields
- Handle optional fields with defaults
- Handle list and multiline filters

**Template Validator Tests:**
- Detect missing required fields
- Validate type hints
- Allow optional fields to be missing
- Clear error messages

### Integration Tests

**End-to-End Delegation:**
1. Agent loads delegation skill
2. Agent calls task tool with template_data
3. Plugin extracts template, validates, renders
4. Delegation executes (async or sync)
5. Result returned to caller

**Test Cases:**
```typescript
describe('Template-based delegation E2E', () => {
  it('delegates to junior_dev with valid template data', async () => {
    // Setup: Mock skill file exists
    const skillContent = `
# Delegating to Junior Dev
## Task Template
\`\`\`jinja2
Task: {{task|required}}
Files: {{files|required|list}}
Spec: {{spec|required|multiline}}
Verify: {{verify|required}}
\`\`\`
    `;
    mockReadFile('skill/delegating-to-junior-dev/SKILL.md', skillContent);
    
    // Agent calls task tool
    const result = await task({
      agent: 'junior_dev',
      template_data: {
        task: 'Add logging',
        files: ['/path/to/main.cpp'],
        spec: '1. Add include\n2. Add log call',
        verify: 'pixi run test'
      },
      wait: false
    });
    
    expect(result.task_id).toBeDefined();
    expect(result.status).toBe('running');
  });
  
  it('throws error for missing required field', async () => {
    await expect(task({
      agent: 'junior_dev',
      template_data: {
        // Missing 'task' field
        files: ['/path/to/main.cpp']
      }
    })).rejects.toThrow("Missing required field 'task'");
  });
});
```

---

## Acceptance Criteria

**Phase 1 Complete When:**

- [x] Task plugin created with template system integrated
- [ ] Template parser extracts Jinja2 from delegation skills
- [ ] Template renderer fills templates with agent data
- [ ] Template validator checks required fields and type hints
- [ ] All 6 delegation skills updated with Jinja2 templates
- [ ] Built-in task tool disabled for primary-orchestrator and tech_lead
- [ ] Plugin task tool works for async (`wait: false`) and sync (`wait: true`)
- [ ] Agents successfully delegate using template_data parameter
- [ ] Clear error messages for invalid delegations
- [ ] Unit tests pass for all template components
- [ ] Integration tests pass for E2E delegation

---

## Rollout Plan

### Stage 1: Plugin Development (Days 1-3)

1. Create plugin skeleton
2. Implement template parser
3. Implement template renderer (with nunjucks)
4. Implement template validator
5. Integrate with task executor
6. Write unit tests

### Stage 2: Skill Updates (Days 4-5)

1. Update `delegating-to-junior-dev` (reference implementation)
2. Test with tech_lead agent
3. Update remaining 5 delegation skills
4. Update opencode.json to disable built-in task

### Stage 3: Testing & Validation (Day 6)

1. E2E tests for each delegation type
2. Test error handling (missing fields, wrong types)
3. Test async vs sync execution
4. Test session reuse
5. Performance testing (template parsing overhead)

### Stage 4: Documentation (Day 7)

1. Document task tool usage for agents
2. Document template syntax and filters
3. Create migration guide (old format → new format)
4. Update agent prompts to reference new delegation method

---

## Risk Mitigation

### Risk 1: Nunjucks Dependency Issue

**Risk:** Nunjucks not compatible with OpenCode's runtime  
**Mitigation:** Test early, have fallback minimal parser ready  
**Fallback:** Implement simple regex-based template engine

### Risk 2: Template Parsing Overhead

**Risk:** Reading/parsing delegation skills adds latency  
**Mitigation:** Cache parsed templates in memory  
**Implementation:** 
```typescript
const templateCache = new Map<string, {template: string, schema: TemplateSchema}>();
```

### Risk 3: Error Messages Not Clear

**Risk:** Agents confused by validation errors  
**Mitigation:** Design error messages with agent UX in mind  
**Example:**
```
Template validation failed for delegating-to-junior-dev:
- Missing required field 'task'
- Missing required field 'verify'

Tip: Load the delegation skill to see the template:
  skill('delegating-to-junior-dev')
```

### Risk 4: Breaking Existing Workflows

**Risk:** Agents break when built-in task disabled  
**Mitigation:** Test thoroughly with all agents  
**Contingency:** Feature flag to enable/disable plugin

---

## Success Metrics

**Quantitative:**
- 100% of delegation skills use Jinja2 templates
- 0 uses of old narrative delegation format
- < 50ms template parsing/rendering overhead
- 95%+ validation catch rate for malformed delegations

**Qualitative:**
- Agents understand how to use template_data parameter
- Error messages are clear and actionable
- Template syntax is intuitive
- No confusion about "how to delegate"

---

## Open Questions

1. **Should we support template inheritance?** (e.g., base template for all delegations)
   - Decision: Defer to future iteration if needed

2. **Should templates support conditionals?** (e.g., `{% if constraints %}`)
   - Decision: No - keep templates simple, use optional fields instead

3. **Should we validate against OpenAI's function calling schema?**
   - Decision: No - template_data is flexible object, not strict schema

4. **How to handle multi-agent delegation?** (delegate to multiple agents in parallel)
   - Decision: Call task() multiple times, plugin handles concurrency

---

## Next Steps After Phase 1

Once Phase 1 is complete and validated:

1. **Phase 2: Plugin Suite** - Build workflow enforcer, agent tracker, etc.
2. **Phase 3: Command Workflows** - Implement `/plan-custom-workflow`, `/design-workflow`, `/execute-custom-workflow`
3. **Integration Testing** - Validate entire system end-to-end
4. **Production Rollout** - Deploy to live OpenCode config

---

## Appendix: Example Agent Workflow

**Before (current narrative delegation):**
```
Tech_lead agent:
1. Reads delegating-to-junior-dev skill
2. Manually formats instruction following template
3. Calls task(agent='junior_dev', instruction='Task: Add logging\nFiles:\n- /path/to/main.cpp\n...')
4. Hopes format is correct
```

**After (template-based delegation):**
```
Tech_lead agent:
1. Loads delegation skill: skill('delegating-to-junior-dev')
2. Calls task tool with structured data:
   task(agent='junior_dev', template_data={
     task: 'Add logging',
     files: ['/path/to/main.cpp'],
     spec: '1. Add include\n2. Add log call',
     verify: 'pixi run test'
   })
3. Plugin validates template_data, renders template, executes
4. Guaranteed correct format or clear error
```

---

**End of Implementation Plan**

Ready to proceed with implementation!
