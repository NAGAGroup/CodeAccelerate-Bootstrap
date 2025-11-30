# Global Agent Instructions

This document provides global guidance for all agents. These instructions establish the tool priority hierarchy and best practices for efficient, semantic-aware operations.

## Tool Priority Hierarchy

Always select tools in this order of preference:

### 0. Superpowers Skills (HIGHEST PRIORITY - Check First!)

**BEFORE any task**, check if a skill applies:

1. Run `find_skills` to see available skills
2. If ANY skill matches your current task, use `use_skill` to load it
3. Follow the skill exactly - skills encode proven workflows

**Common skill triggers:**
- Starting new feature/design work → `brainstorming`
- Writing code → `test-driven-development`
- Debugging/fixing errors → `systematic-debugging`
- About to claim "done" → `verification-before-completion`
- Completing a branch → `finishing-a-development-branch`

**You cannot skip this step.** Even "simple" tasks may have applicable skills.

### 1. Specialized MCP Tools

**Serena** - Semantic code operations (ALWAYS TRY SERENA FIRST):
- Symbol navigation: `serena_find_symbol`, `serena_find_referencing_symbols`
- File structure: `serena_get_symbols_overview`
- Search: `serena_search_for_pattern`
- File operations: `serena_list_dir`, `serena_find_file`, `serena_read_file`
- Semantic editing: `serena_replace_symbol_body`, `serena_insert_after_symbol`, `serena_insert_before_symbol`, `serena_replace_content`, `serena_create_text_file`
- Refactoring: `serena_rename_symbol`
- Memory: `serena_write_memory`, `serena_read_memory`, `serena_edit_memory`

**Context7** - Library documentation and API references:
- `context7_resolve-library-id` - Resolve library/package names to Context7-compatible IDs
- `context7_get-library-docs` - Fetch up-to-date documentation, setup guides, code examples, and API references
- **Auto-use rule**: When tasks involve code generation, setup/configuration steps, or library/API documentation, **automatically** use Context7 tools without waiting for explicit user requests. First resolve the library ID, then fetch relevant documentation and examples.

**GitHub** - Repository operations:
- Use `github_*` tools for all GitHub interactions

**Other MCP Tools**:
- Always prefer specialized MCP tools over generic approaches
- Check available tools before resorting to shell commands

### 2. OpenCode Built-in Specialized Tools

- `webfetch` - Fetch and analyze web content
- `todowrite`, `todoread` - Task management and progress tracking
- `task` - Delegate to specialized subagents

### 3. Shell Commands (ONLY When Serena Cannot Help)

Use shell **ONLY** for operations that Serena cannot perform:
- **Build tools**: cargo, npm, make, gradle, etc.
- **Version control**: git operations and commits
- **Process management**: starting/stopping services
- **External tools**: running formatters, linters, test runners
- **System operations**: commands requiring shell access (package managers, system info, etc.)

**NEVER use shell for file operations - Serena can do all of these**:
- File reading → use `serena_read_file`
- File searching → use `serena_search_for_pattern` or `serena_find_file`
- File creation/editing → use `serena_create_text_file`, `serena_replace_symbol_body`, `serena_replace_content`, `serena_insert_before_symbol`, or `serena_insert_after_symbol`
- Directory listing → use `serena_list_dir`
- Refactoring → use `serena_rename_symbol`
- Library/API documentation → use `context7_resolve-library-id` and `context7_get-library-docs`

## Serena Mode Synchronization

**IMPORTANT**: When your operational mode changes (Plan to Build), synchronize Serena:

- **Entering Build/Edit Mode**: Call `serena_switch_modes` with modes `["editing", "interactive"]`
- **Entering Plan/Read-Only Mode**: Call `serena_switch_modes` with modes `["planning"]`

If `serena_switch_modes` is not available, Serena editing tools are still usable - they are not gated by modes, modes just optimize the toolset and prompts.

## Serena Best Practices

### Intelligent Code Reading

- Always use `serena_get_symbols_overview` BEFORE reading full files
- Use `serena_find_symbol` with `include_body=True` only when you need implementation details
- Never read the same content multiple times

### File Creation and Editing

For creating or modifying files, always use Serena:

1. **New files**: Use `serena_create_text_file` with the full content
2. **Symbol replacement**: Use `serena_replace_symbol_body` for functions/classes/methods
3. **Arbitrary edits**: Use `serena_replace_content` with regex or literal matching
4. **Insertions**: Use `serena_insert_before_symbol` or `serena_insert_after_symbol`
5. **Refactoring**: Use `serena_rename_symbol` for codebase-wide changes

### Context7 Integration for Documentation

When implementing features that require external libraries or APIs:

1. **Identify the library/package** - Understand what you need (e.g., "react hooks", "postgresql driver")
2. **Resolve the library ID** - Use `context7_resolve-library-id` to find the best match
3. **Fetch documentation** - Use `context7_get-library-docs` with appropriate mode:
   - `mode='code'` (default) for API references and code examples
   - `mode='info'` for conceptual guides and setup instructions
4. **Integrate examples** - Use fetched code examples to generate or configure implementation

This approach ensures current, accurate documentation without relying on potentially outdated training data.

### Memory Management

- Document architectural insights with `serena_write_memory`
- Reference memory files across tasks to avoid re-reading
- Update memory with `serena_edit_memory` as you learn more

## Token Efficiency Mindset

- Symbol-based navigation = fewer tokens than full file reads
- Pattern matching = precise targeting vs. broad searches
- Semantic understanding = accurate results without trial-and-error
- Context7 docs = current, authoritative information vs. stale training data
- Serena tools = minimal file access vs. shell commands with full text parsing

Always choose the tool that reads the minimum necessary code and provides the most accurate, current information.
