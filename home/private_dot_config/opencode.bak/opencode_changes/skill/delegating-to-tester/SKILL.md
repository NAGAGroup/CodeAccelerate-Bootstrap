---
name: delegating-to-tester
description: Use when delegating verification, testing, and build validation tasks
---

# Delegating to Tester

## When to Delegate

Tester handles:

- Building the project after implementation
- Running test suites
- Executing specific verification commands
- Exploring test failures and build errors
- Checking build artifacts exist
- Verifying specific console output or log patterns
- Verifying implementation against spec

> [!WARNING]
> Tester executes commands but doesn't fix issues. They report results, you decide next steps.

## Anti-Patterns

- Asking tester to fix code - tester is read-only, send fixes to junior_dev
- Vague commands - "run the tests" instead of specific test commands
- No failure diagnostics - always specify what to check if tests fail
- Asking to install dependencies - tester works with existing environment
- Expecting interpretation - tester reports facts, you analyze them

## Example: Good Delegation

Task: Verify the verbose logging implementation works correctly

Context: Implemented --verbose flag in main.cpp and updated Logger::initialize() signature

Build Commands:
```bash
pixi run build
```

Test Commands:
```bash
pixi run test
./build/app --verbose
./build/app --help
```

Expected Results:
- Build completes without errors
- All tests pass
- Running with --verbose shows debug messages
- Running with --help shows the --verbose flag in usage text

On Failure:
If build fails:
```bash
cat build/compile_commands.json | grep verbose
pixi run build 2>&1 | tail -20
```

If tests fail:
```bash
pixi run test -- --verbose
ls -la build/
```

## Example: Good Delegation (Test-Specific)

Task: Run the logging module tests and verify new test cases pass

Context: Added 3 new test cases for verbose flag behavior in test/logger_test.cpp

Test Commands:
```bash
pixi run test -- --filter=LoggerTest
pixi run test -- --filter=VerboseFlagTest
```

Expected Results:
- All LoggerTest cases pass (should be 8 total)
- VerboseFlagTest cases pass (should be 3 new tests)

On Failure:
```bash
pixi run test -- --filter=LoggerTest --verbose
pixi run test -- --filter=VerboseFlagTest --gtest_print_time=1
```

## Example: Poor Delegation (Too Vague)

Task: Check if the code works
Commands: Run the tests
Expected: Tests pass

## Instruction Template

### Task
[Single sentence: what to verify]

### Context
[Brief summary of what was implemented - helps tester understand what they're verifying]

### Build Commands
[Exact commands to build the project, if needed]
```bash
pixi run build
```

### Test Commands
[Exact commands to run - be specific]
```bash
pixi run test
./build/app [specific flags]
```

### Expected Results
[What success looks like]
- Build status
- Test counts
- Output patterns
- Artifact locations

### On Failure
[Diagnostic commands to run if verification fails]
```bash
# Commands to gather more information if the above fails
# If build fails: cat logs/build.log or tail -n 20
# If tests fail: run test --verbose or ls -R build/artifacts
```
