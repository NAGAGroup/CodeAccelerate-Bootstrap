---
name: writing-skills
description: Use when creating new skills or editing existing skills in the .opencode configuration
---

# Writing Skills

## Overview

Skills are reusable reference guides for techniques, patterns, and tools. They help agents find and apply effective approaches across sessions.

**Skills are:** Techniques, patterns, tools, reference guides

**Skills are NOT:** One-off solutions, project-specific conventions, narratives about past sessions

## When to Create a Skill

**Create when:**

- Technique applies broadly across projects
- You'd reference this pattern again
- Pattern wasn't intuitively obvious
- Others would benefit from documented approach

**Don't create for:**

- One-off solutions
- Standard practices well-documented elsewhere
- Project-specific conventions (put in workspace docs instead)
- Mechanical constraints (automate with validation instead)

## Directory Structure

```
.opencode/skill/
  skill-name/
    SKILL.md              # Main reference (required)
    supporting-file.*     # Only if needed
```

**Keep it simple:** One SKILL.md file per skill. Only add supporting files for heavy reference material (100+ lines) or reusable tools/scripts.

## SKILL.md Structure

### Frontmatter (YAML)

```yaml
---
name: skill-name-with-hyphens
description: Use when [specific triggering conditions and symptoms]
---
```

**Rules:**

- `name`: Letters, numbers, and hyphens only (no special characters)
- `description`: Third-person, describes WHEN to use (not what it does)
  - Start with "Use when..." to focus on triggering conditions
  - Include specific symptoms, situations, contexts
  - Do NOT summarize the skill's workflow or process
  - Keep under 500 characters

**Why "Use when" matters:** Agents read the description to decide which skills to load. If you summarize the workflow in the description, agents may follow that summary instead of reading the full skill content.

**Examples:**

```yaml
# BAD: Summarizes workflow
description: Use when executing plans - dispatches subagent per task with code review between tasks

# BAD: Too abstract
description: For async testing

# GOOD: Just triggering conditions
description: Use when implementing any feature or bugfix, before writing implementation code

# GOOD: Specific symptoms
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
```

### Content Structure

```markdown
# Skill Name

## Overview

What is this? Core principle in 1-2 sentences.

## When to Use

- Bullet list with symptoms and use cases
- When NOT to use (if applicable)

## Quick Reference

Table or bullets for common operations

## Implementation

- Steps, patterns, or techniques
- Code examples (inline for < 50 lines, separate file for longer)
- Links to supporting files if needed

## Common Mistakes (optional)

What goes wrong and how to fix it
```

## Writing Good Descriptions

**Focus on triggers, not process:**

| Bad                                                               | Good                                                                                                                           |
| ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Use for TDD - write test first, watch fail, write code, refactor  | Use when implementing any feature or bugfix, before writing implementation code                                                |
| Use when triaging CI - fetch logs via curl and interpret failures | Use when triaging NEO Jenkins CI results, fetching build status/logs via curl, or interpreting common Jenkins failure patterns |
| Helps with delegation to junior_dev by providing templates        | Use when dispatching implementation work to junior_dev                                                                         |

**Include searchable keywords:**

- Error messages agents will see
- Symptoms they'll encounter
- Tool names they'll use
- Common problem phrases

## File Organization

**Self-contained (preferred):**

```
skill-name/
  SKILL.md    # Everything inline
```

**With supporting files (only if needed):**

```
skill-name/
  SKILL.md           # Overview and main content
  reference.md       # Heavy reference material (API docs, etc.)
  example-tool.sh    # Reusable script/tool
```

## Code Examples

**One excellent example beats many mediocre ones.**

- Use the most relevant language for the domain
- Make it complete and runnable
- Comment the WHY, not the WHAT
- Show the pattern clearly
- Make it easy to adapt

Don't create examples in multiple languages - agents can port code.

## Naming Skills

**Use verb-first, active voice:**

- Good: `creating-mermaid-diagrams` not `mermaid-diagram-creation`
- Good: `delegating-to-junior-dev` not `junior-dev-delegation`
- Good: `systematic-debugging` not `debugging-system`

**Use hyphens, not underscores or spaces:**

- Good: `neo-build-system`
- Bad: `neo_build_system` or `neo build system`

## Keep It Concise

Skills load into agent context. Every word counts.

**Target lengths:**

- Frequently-used skills: < 200 lines
- Other skills: < 300 lines
- Heavy reference: Separate files, link from main SKILL.md

**Be specific, not verbose:**

- Use tables for reference material
- Link to tool `--help` instead of documenting all flags
- One clear example instead of many variations
- Remove redundant explanations

## Common Mistakes

**Mistake:** Description summarizes what the skill does
**Fix:** Description should only describe when to use it

**Mistake:** Creating project-specific skills
**Fix:** Put project-specific conventions in workspace documentation

**Mistake:** Making skills too abstract or general
**Fix:** Focus on concrete techniques with clear triggers

**Mistake:** Including multiple language examples
**Fix:** One excellent example in the most relevant language

**Mistake:** Overly long reference material in SKILL.md
**Fix:** Move heavy reference to separate file, link from SKILL.md

## Checklist

When creating or editing a skill:

- [ ] Name uses only letters, numbers, hyphens
- [ ] YAML frontmatter with name and description
- [ ] Description starts with "Use when..."
- [ ] Description includes specific triggers/symptoms (no workflow summary)
- [ ] Clear overview with core principle
- [ ] Quick reference section for common operations
- [ ] Code examples inline (or linked if long)
- [ ] Concise (under 300 lines if possible)
- [ ] Supporting files only if truly needed
