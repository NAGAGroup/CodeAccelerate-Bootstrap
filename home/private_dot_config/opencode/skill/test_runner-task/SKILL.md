---
name: test_runner-task
description: Template for delegating verification, testing, and build validation to test_runner agent
---

```jinja2
{# task: Single sentence describing what to verify #}
{# context: Brief summary of what was implemented - helps test_runner understand what they're verifying #}
{# build_commands: Optional - exact bash commands to build the project #}
{# test_commands: Exact bash commands to run for testing #}
{# expected_results: What success looks like (build status, test counts, output patterns, artifact locations) #}
{# failure_diagnostics: Optional - bash commands to gather more information if tests fail #}

**Task:** {{task|required}}

**Context:** {{context|required}}

**Build Commands:**
{{build_commands|optional}}

**Test Commands:**
{{test_commands|required}}

**Expected Results:**
{{expected_results|required|multiline}}

**On Failure:**
{{failure_diagnostics|optional}}

**Important Guidelines:**
- Test_runner executes commands but doesn't fix issues - they report results only
- Be specific with test commands (not vague like "run the tests")
- Always specify what to check if tests fail
- Test_runner is read-only - send fixes to junior_dev
- Test_runner works with existing environment (cannot install dependencies)
```
