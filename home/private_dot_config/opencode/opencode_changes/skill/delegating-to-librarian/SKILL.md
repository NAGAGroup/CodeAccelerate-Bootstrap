---
name: delegating-to-librarian
description: Use when dispatching external research to librarian
---

# Delegating to Librarian

## When to Delegate

Librarian handles:

- External API documentation lookups
- Researching library usage patterns
- Finding official specs or standards
- Narrow, specific queries about external technologies

> [!WARNING]
> Keep queries narrow and specific. Librarian cannot access local files.

## Anti-Patterns

- Broad research requests - "learn about X technology"
- Questions about your codebase - use explore instead
- Asking for architectural decisions - that's your job
- Implementation questions - librarian provides reference material, you decide how to apply it

## Example: Good Delegation

Question: What are the valid flags for ze_event_desc_t in Level Zero API?
Context: Implementing event creation and need to know which flags are available and what they mean.
Desired Output: List of flag constants with brief descriptions, plus link to official documentation.

## Example: Good Delegation

Question: What is the recommended way to parse command-line arguments in modern C++?
Context: Adding new flags to a C++17 project, want to follow current best practices.
Desired Output: Brief overview of 2-3 common approaches with links to documentation or examples.

## Example: Poor Delegation (Too Broad)

Question: Explain everything about Level Zero

## Example: Poor Delegation (Local Codebase)

Question: How does our project handle command-line arguments?
(This should go to explore, not librarian)

## Instruction Template

### Question

[Specific, narrow question about external documentation]

### Context

[Why you need this - helps librarian focus the search]

### Desired Output

[What format you want: links, code examples, specific API details]
