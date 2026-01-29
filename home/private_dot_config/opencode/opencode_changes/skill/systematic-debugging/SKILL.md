---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

## Core Principle

**Find root cause before attempting fixes.** Symptom fixes waste time and create new bugs.

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION
```

## When to Use

Use for ANY technical issue:
- Test failures
- Unexpected behavior
- Build failures
- Performance problems
- Integration issues

**Especially when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- You don't fully understand the issue

## The Four Phases

Complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Completely**
   - Don't skip errors or warnings
   - Read stack traces completely
   - Note line numbers, file paths, error codes

2. **Reproduce Consistently**
   - Can you trigger it reliably?
   - What are the exact steps?
   - If not reproducible → gather more data, don't guess

3. **Check Recent Changes**
   - What changed that could cause this?
   - Git diff, recent commits
   - New dependencies, config changes

4. **Gather Evidence in Multi-Component Systems**
   
   For systems with multiple components (CI → build → deploy, API → service → database):
   
   - Add diagnostic logging at each component boundary
   - Log what enters and exits each component
   - Verify environment/config propagation
   - Run once to see WHERE it breaks
   - THEN investigate that specific component

5. **Trace Data Flow**
   
   When error is deep in call stack:
   - Where does the bad value originate?
   - What called this with the bad value?
   - Trace backward until you find the source
   - Fix at source, not at symptom

### Phase 2: Pattern Analysis

**Find patterns before fixing:**

1. **Find Working Examples**
   - Locate similar working code in the same codebase
   - What works that's similar to what's broken?

2. **Compare Against References**
   - If implementing a pattern, read reference implementation completely
   - Don't skim - understand the pattern fully

3. **Identify Differences**
   - What's different between working and broken?
   - List every difference, however small

### Phase 3: Hypothesis and Testing

**Scientific method:**

1. **Form Single Hypothesis**
   - State clearly: "I think X is the root cause because Y"
   - Be specific, not vague

2. **Test Minimally**
   - Make the SMALLEST possible change to test hypothesis
   - One variable at a time
   - Don't fix multiple things at once

3. **Verify Before Continuing**
   - Did it work? Yes → Phase 4
   - Didn't work? Form NEW hypothesis
   - DON'T add more fixes on top

### Phase 4: Implementation

**Fix the root cause, not the symptom:**

1. **Create Failing Test Case**
   - Simplest possible reproduction
   - Automated test if possible
   - MUST have before fixing

2. **Implement Single Fix**
   - Address the root cause identified
   - ONE change at a time
   - No "while I'm here" improvements

3. **Verify Fix**
   - Test passes now?
   - No other tests broken?
   - Issue actually resolved?

4. **If Fix Doesn't Work**
   - Count: How many fixes have you tried?
   - If < 3: Return to Phase 1 with new information
   - If ≥ 3: STOP and escalate
   
   **After 3 failed fixes:** Something is fundamentally wrong
   - Question the architecture
   - Discuss with user before attempting more fixes
   - Pattern may need rethinking, not more patches

## Red Flags - Return to Phase 1

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- Proposing solutions before investigating
- "One more fix attempt" (after 2+ failures)

**ALL of these mean: STOP. Return to Phase 1.**

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare differences | Identify what's different |
| **3. Hypothesis** | Form theory, test minimally, verify | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix once, verify | Bug resolved, tests pass |
