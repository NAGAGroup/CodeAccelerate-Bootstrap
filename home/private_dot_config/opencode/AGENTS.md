# Global Rules

## Skills

You have access to a skills system via `find_skills` and `use_skill` tools.

**BEFORE starting any non-trivial task, you MUST:**

1. Run `find_skills` to see available skills
2. Check if any skill matches the task (look at skill descriptions)
3. If a skill applies, use `use_skill` to load it and follow its guidance

**What counts as non-trivial:**
- Tasks involving code changes
- Multi-step tasks
- Setup, configuration, or architecture decisions
- Debugging, testing, or refactoring
- Migrations or major changes

**Skip skill check only for:**
- Direct factual questions
- Single-command operations
- Clarifying questions

**Automatic triggers** - When you see these patterns, ALWAYS check for skills:
- "debug", "fix bug", "not working", "error" → check for debugging skills
- "implement", "add feature", "build", "create" → check for implementation skills
- "plan", "design", "architect" → check for planning skills
- "refactor", "clean up" → check for refactoring skills
- "set up", "configure", "CI/CD", "pipeline" → check for setup skills
- "migrate", "convert", "upgrade" → check for migration skills
- "test", "testing" → check for testing skills

## Serena (LSP-powered code intelligence)

You have access to Serena tools for semantic code operations. Prefer these over text-based search/replace when working with code symbols:

| Task | Use | Instead of |
|------|-----|------------|
| Find a class/function/method by name | `serena_find_symbol` | grep/glob |
| Find all usages of a symbol | `serena_find_referencing_symbols` | grep |
| Rename a variable/function/class | `serena_rename_symbol` | find-and-replace |
| Understand a file's structure | `serena_get_symbols_overview` | reading the whole file |
| Replace a function/method body | `serena_replace_symbol_body` | manual edit |
| Add code after a symbol | `serena_insert_after_symbol` | manual edit |
| Add code before a symbol | `serena_insert_before_symbol` | manual edit |

**Why:** Serena uses LSP for language-aware operations - it understands scope, handles edge cases, and won't accidentally match text in strings/comments.
