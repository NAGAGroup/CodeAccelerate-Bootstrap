---
name: delegating-to-explore
description: Use when dispatching file discovery or structure analysis to explore
---

# Delegating to Explore

## When to Delegate

Explore handles:

- Finding files matching patterns
- Locating functions, classes, or symbols
- Summarizing directory structure
- Discovering where functionality is implemented
- Quick read-only analysis

> [!NOTE]
> Explore is fast and read-only. Use it liberally for discovery before planning implementation.

## Anti-Patterns

- Asking explore to edit files - explore is read-only
- Asking for external documentation - use librarian instead
- Overly broad requests - "explain the entire codebase"
- Asking for implementation advice - that's your job

## Example: Good Delegation

Goal: Understand how command-line argument parsing is currently implemented
Search Scope: src/ directory, focus on .cpp and .h files containing "main" or "arg"
Specific Questions:

- Which file contains the main() function?
- Where are command-line arguments parsed?
- Are there existing flag definitions I should follow?
- Is there a dedicated argument parser class or is it inline?

## Example: Good Delegation (Finding Files)

Goal: Locate all test files related to the logging module
Search Scope: test/ directory
Specific Questions:

- What test files mention "log" or "logging"?
- What is the naming convention for test files?
- Are there existing tests for command-line flag handling?

## Instruction Template

### Goal

[What you're trying to find or understand]

### Search Scope

[Where to look - directories, file patterns, or "entire codebase"]

### Specific Questions

[Concrete questions you need answered]

- Where is X implemented?
- What files contain Y?
- How is Z structured?
