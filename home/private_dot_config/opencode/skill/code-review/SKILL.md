---
name: code-review
description: Use when reviewing code changes for a PR or before committing
---

# Code Review

## When to Use

Use when reviewing code changes for a PR or before committing.

## Workflow

### Step 1: Fresh Reviewer Context
Start with a fresh tech_lead session (no prior context about the implementation). The reviewer should see the code as an external reviewer would.

### Step 2: Gather Context
Before reviewing code, gather:
1. **JIRA ticket** (if referenced): Understand the original intent/requirements
2. **PR description** (if exists): Author's summary of changes
3. **Diff scope**: Use `git diff <base>...<head>` excluding merge commits

To exclude merge commits from diff:
```bash
git log --no-merges --format=%H <base>...<head> | xargs git diff-tree --no-commit-id -p
```

Or simpler: `git diff $(git merge-base <base> <head>)..<head>`

### Step 3: Review Checklist

1. **Intention Check**: Do the changes match what JIRA/PR description says they should do?
2. **Scope Alignment**: Are changes limited to what's needed, or is there scope creep?
3. **Code Quality**: Standard review (readability, error handling, edge cases)
4. **Test Coverage Heuristic**: 
   - Look for corresponding test file changes
   - If production code changed but no test changes, flag for discussion
   - Not a hard rule, but a signal to investigate

### Step 4: Output Format

Structure review as:
- **Summary**: 1-2 sentence overview
- **[PASS]/[ISSUE]** tags for each finding
- **Recommendations**: Prioritized list (blocking vs nice-to-have)
