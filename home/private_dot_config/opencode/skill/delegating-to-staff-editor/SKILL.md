---
name: delegating-to-staff-editor
description: Use when dispatching prose review to staff_editor
---

# Delegating to Staff Editor

## When to Delegate

Staff_editor reviews:

- Documentation you've drafted
- README files
- Technical writing
- User-facing guides
- Commit messages (for complex changes)

> [!NOTE]
> You write the initial draft, staff_editor reviews and suggests improvements.
> Staff_editor is read-only and cannot make edits.

## Anti-Patterns

- Asking staff_editor to write from scratch - you draft first
- Sending code for review - staff_editor reviews prose only
- Expecting edits - staff_editor suggests, you implement

## Example: Good Delegation

Document: [Draft README for new feature]
Verbose Logging Feature
This feature adds a --verbose flag to enable detailed debug output.
Usage
Run the application with the --verbose flag:
./app --verbose
Debug messages will now appear in the console output.
Implementation Details
The verbose flag is parsed in main.cpp and passed to the Logger initialization.
Review Focus:

- Is the usage section clear for end users?
- Should I add troubleshooting tips?
- Is the tone appropriate for this audience?

## Example: Good Delegation (Commit Message)

Document: [Draft commit message for complex change]
Add verbose logging flag
Implements --verbose command-line flag to enable debug-level
logging output. This helps developers troubleshoot issues
without rebuilding with debug symbols.
Changes:

- Added argument parsing for --verbose in main.cpp
- Modified Logger::initialize() to accept verbose parameter
- Updated tests to cover new flag behavior
  Review Focus:
- Is this clear and concise?
- Does it explain the "why" sufficiently?

## Instruction Template

### Document

[Provide the draft text or file path to review]

### Review Focus

[What aspects you want feedback on]

- Clarity, tone, structure, completeness, etc.

### Context

[Who is the audience? What is the purpose?]
