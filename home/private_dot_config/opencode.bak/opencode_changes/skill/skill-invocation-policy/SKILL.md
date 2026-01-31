---
name: skill-invocation-policy
description: Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
---

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Mandatory Startup Skills (file-accessing agents)

If the agent will read/write files or run workspace commands, it MUST load, in order:

1. `skill-invocation-policy`

Then load any task-specific skills.

## Delegation Gate (mandatory)

Before any `background_task()` or agent delegation:

1. Load any process skill that might apply to the delegated work
2. Include "Invoked skills:" line in your delegation message for accountability

This is not optional. Delegation without loading relevant skills causes incorrect guidance.

## Default Read-Only Principle

- Default posture is **read-only**
- Do not create or modify files unless:
  - User explicitly requested file changes, OR
  - Your role explicitly authorizes edits (e.g., junior_dev executing a spec)
- When in doubt, report what changes are needed rather than making them

## ASCII-Only Status Tags (no Unicode symbols)

When writing checklists, status lines, or "traffic light" indicators, **do not use Unicode symbols** (including emojis and typographic bullets). Use these ASCII tags instead:

- [OK] for correct/acceptable
- [ISSUE] for problems
- [PASS] for passing tests/checks
- [FAIL] for failing tests/checks

## How to Access Skills

Use the `skill` tool. When you invoke a skill, its content is loaded and presented to you—follow it directly.

# Using Skills

## The Rule

Invoke relevant or requested skills BEFORE any response or action. Even a 1% chance a skill might apply means you should invoke the skill to check.

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought                             | Reality                                        |
| ----------------------------------- | ---------------------------------------------- |
| "This is just a simple question"    | Questions are tasks. Check for skills.         |
| "I need more context first"         | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first.   |
| "I can check git/files quickly"     | Check for skills first.                        |
| "I remember this skill"             | Skills evolve. Read current version.           |

## Skill Priority

When multiple skills could apply, use this order:

1. Process skills
2. Execution/workflow skills

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip required workflows.
