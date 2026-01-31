---
name: delegating-to-junior-dev
description: Use when dispatching implementation work to junior_dev
---

# Delegating to Junior Dev

## When to Delegate

Junior_dev handles:

- Code implementation (.cpp, .h, .py, etc.)
- Config file changes (CMake, JSON, YAML)
- Test writing
- Any file editing/creation work
  > [!WARNING]
  > Junior_dev gets ONE attempt per spec. They cannot debug, improvise, or ask questions.
  > If they fail, YOU must write a completely new spec.

## Anti-Patterns

- "Try again" or "debug this" - Write a NEW spec instead
- Missing file paths - Always provide absolute paths
- Vague locations - "somewhere in main.cpp" won't work
- No verification steps - How will you know it worked?
- Parallel dispatch - Never send multiple junior_dev tasks to same workspace at once

## Example: Good Delegation

Task: Add a new command-line flag --verbose to enable debug logging
Files:

- /home/user/project/src/main.cpp
- /home/user/project/src/logger.h

Spec:

1. In src/main.cpp, locate the argument parsing section (around line 45, look for "Parse command line arguments")
2. Add a new boolean flag `verbose_mode` initialized to false
3. Add handling for --verbose flag that sets verbose_mode to true
4. Pass verbose_mode to Logger::initialize() call (around line 78)
5. In src/logger.h, modify Logger::initialize() signature to accept bool verbose parameter
6. Update the implementation to set log level based on verbose flag

Verify:

- Build succeeds: `pixi run build`
- Run with flag: `./build/app --verbose`
- Confirm debug messages appear in output
  Constraints:
- Do not modify existing log levels for non-verbose mode
- Follow existing error handling patterns in argument parsing
- Use consistent naming: verbose_mode (not debug_mode or verbose_flag)

## Example: Poor Delegation (Too Vague)

Task: Add verbose logging
Files: main.cpp
Spec: Add a flag for verbose mode and make logging work

## Instruction Template

### Task

[Single sentence: what to accomplish]

### Files

[Absolute paths only - list all files to be created/modified]

### Spec

[Numbered steps with exact locations]

- Use function names, class names, line numbers, or code anchors
- Include code blocks showing expected structure
- Be explicit about where to add/modify/remove code

### Verify

[Exact commands to run after implementation]

- Expected output or success criteria
- How to confirm the change works

### Constraints

[What NOT to do]

- Style rules, naming conventions
- APIs to avoid
- Patterns to follow
