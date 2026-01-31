---
name: collaborative-design
description: Use when requirements are unclear and an interactive dialogue is needed to converge on a design and success criteria before implementation
---

# Collaborative Design

## Goal

Converge on a clear design and acceptance criteria through structured user interaction before implementation.

## When to Invoke

Use collaborative-design when:

- [ ] Requirements are ambiguous or incomplete
- [ ] Multiple valid approaches exist and user should choose
- [ ] User asks "what do you think?" or wants brainstorming
- [ ] Scope needs narrowing before implementation
- [ ] User explicitly requests collaboration/discussion

## Core Principles

1. **Structured questions over open-ended discussion**
2. **One decision at a time**
3. **Present options with trade-offs**
4. **STOP and wait for user input**
5. **Converge on actionable spec**

## Workflow

### Step 1: Restate the Objective

Start by restating what you understand in one clear sentence.

**Example:**

```
I understand the objective as: redesigning the agent prompts to be more
consistent and easier to maintain by establishing a standard template
structure.
```

### Step 2: Identify Unknowns

List what you don't know or what needs user input.

**Example:**

```
Key unknowns:
1. Should we prioritize brevity or comprehensive guidance?
2. What's the acceptable length range (100 lines? 200 lines?)
3. Do all agents need the same structure, or can some vary?
```

### Step 3: Use the Question Tool

> [!IMPORTANT]
> ALWAYS use the `question` tool for structured decision-making. DO NOT ask questions in plain text.

The `question` tool provides:

- Clear, selectable options
- Multiple choice for faster decisions
- Custom input when needed
- Better UX than free-form questions

**When to use `question` tool:**

- Presenting 2-4 options for user to choose
- Yes/No decisions
- Prioritization choices
- Any time you need user input to proceed

**Example usage:**

```typescript
question({
  questions: [
    {
      header: "Template Length Priority",
      question:
        "Should agent prompts prioritize brevity or comprehensive guidance?",
      options: [
        {
          label: "Brevity (100-150 lines)",
          description: "Shorter prompts, faster loading, essential rules only",
        },
        {
          label: "Comprehensive (200+ lines)",
          description: "Detailed guidance, more examples, exhaustive rules",
        },
        {
          label: "Balanced (150-200 lines)",
          description: "Core rules with key examples, moderate detail",
        },
      ],
    },
  ],
});
```

### Step 4: Present Options with Trade-offs

When proposing approaches, show pros/cons clearly:

**Template:**

```
Option A: [Approach name]
- Description: [What it is]
- Pros: [Benefits]
- Cons: [Drawbacks]

Option B: [Approach name]
- Description: [What it is]
- Pros: [Benefits]
- Cons: [Drawbacks]

Recommendation: [Which one and why]
```

Then use `question` tool to let user choose.

### Step 5: STOP Points

> [!WARNING]
> STOP means END YOUR MESSAGE. Wait for user response.

**STOP after:**

- Using `question` tool (wait for answer)
- Presenting options (wait for choice)
- Each major design decision (wait for confirmation)
- Before starting implementation (wait for final approval)

**Do NOT:**

- Continue with speculative next steps
- Make assumptions about user's choice
- Start implementation before user confirms

### Step 6: Produce Agreed Spec

When collaboration converges, summarize the agreed design:

```
## Agreed Spec

**Scope:**
- What we're implementing
- What's included

**Non-goals:**
- What we're explicitly NOT doing
- Out of scope items

**Approach:**
- Chosen option/strategy
- Key decisions made

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Next Step:**
- What happens next (implementation, further planning, etc.)
```

## Question Tool Best Practices

### Good Question Structure

**Header:** Short label (< 30 chars)
**Question:** Complete, clear question
**Options:** 2-5 choices with labels and descriptions

**Good example:**

```typescript
{
  header: "Skill Organization",
  question: "How should we organize the skills directory?",
  options: [
    {
      label: "By category",
      description: "Group skills into subdirs like core/ or development/"
    },
    {
      label: "Flat namespace",
      description: "All skills in one directory for easy searching"
    },
    {
      label: "By agent",
      description: "Organize by which agent uses them"
    }
  ]
}
```

**Bad example (plain text):**

```
So, how should we organize the skills? We could do categories, or keep
them flat, or organize by agent. What do you think?
```

### Multiple Questions Pattern

For sequential decisions, ask one at a time:

```typescript
// First question
question({
  questions: [
    {
      /* Question 1 */
    },
  ],
});
// STOP - wait for answer

// Then in next message, after receiving answer:
question({
  questions: [
    {
      /* Question 2 */
    },
  ],
});
// STOP - wait for answer
```

### When Custom Input is Needed

The `question` tool automatically adds "Type your own answer" when `custom: true` (default), so you don't need to add catch-all options like "Other".

## Common Patterns

### Pattern 1: Ambiguous Requirements

1. Restate what you understand
2. Use `question` tool to clarify ambiguity
3. STOP
4. After answer, propose options
5. Use `question` tool for user to choose
6. STOP
7. After choice, summarize agreed spec

### Pattern 2: Multiple Valid Approaches

1. Restate objective
2. Present 2-3 approaches with pros/cons
3. Recommend one with rationale
4. Use `question` tool for user to choose
5. STOP
6. After choice, drill into details if needed
7. Produce agreed spec

### Pattern 3: Scope Definition

1. Restate objective
2. List potential scope items
3. Use `question` tool (multiple: true) to let user select which to include
4. STOP
5. After selection, confirm non-goals
6. Produce agreed spec

## Anti-Patterns

**DON'T:**

- Ask open-ended questions in plain text instead of using `question` tool
- Present 5+ options at once (too many choices)
- Continue after asking a question (always STOP)
- Make decisions for the user
- Skip trade-off analysis
- Assume user's priorities
- Start implementation before agreed spec

**DO:**

- Use `question` tool for ALL user input
- Present 2-4 clear options
- STOP and wait after questions
- Let user make the call
- Show pros/cons clearly
- Confirm understanding frequently
- Get explicit approval before implementation

## Checklist

Before starting implementation:

- [ ] Objective restated and confirmed
- [ ] Key unknowns identified and resolved (using `question` tool)
- [ ] Options presented with trade-offs
- [ ] User chose approach (via `question` tool)
- [ ] Agreed spec written with scope, non-goals, approach, criteria
- [ ] User explicitly approved the spec
- [ ] Next steps are clear

If you can't check all boxes, continue the collaborative process.

## Example Session

**Agent:** "I understand the objective as: adding a verbose logging flag to enable debug output without rebuilding. Is that correct?"

**User:** "Yes"

**Agent:**

```typescript
question({
  questions: [
    {
      header: "Implementation Approach",
      question: "How should we implement the verbose flag?",
      options: [
        {
          label: "Command-line flag --verbose",
          description: "Add to argument parsing, pass to logger initialization",
        },
        {
          label: "Environment variable",
          description: "Check VERBOSE=1, set log level at startup",
        },
        {
          label: "Both flag and env var",
          description: "Support both methods, flag takes precedence",
        },
      ],
    },
  ],
});
```

**User:** "Command-line flag --verbose"

**Agent:**

```
## Agreed Spec

**Scope:**
- Add --verbose command-line flag
- Pass flag to Logger::initialize()
- Set log level to debug when flag is present

**Non-goals:**
- Environment variable support (can add later if needed)
- Configuration file setting
- Runtime log level changes

**Approach:**
- Modify main.cpp argument parsing
- Update Logger::initialize() signature
- Add tests for flag behavior

**Acceptance Criteria:**
- [ ] --verbose flag parsed correctly
- [ ] Debug messages appear when flag is set
- [ ] Normal behavior unchanged when flag is absent
- [ ] Tests pass

**Next Step:**
Create implementation spec for junior_dev

Ready to proceed?
```

**User:** "Yes"

(Agent proceeds with implementation planning)
