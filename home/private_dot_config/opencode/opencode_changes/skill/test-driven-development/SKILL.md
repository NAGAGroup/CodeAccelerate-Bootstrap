---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development (TDD)

## Core Principle

Write the test first. Watch it fail. Write minimal code to pass.

**If you didn't watch the test fail, you don't know if it tests the right thing.**

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

## When to Use

**Always use TDD for:**
- New features
- Bug fixes
- Refactoring
- Behavior changes

**Exceptions (ask user):**
- Throwaway prototypes
- Generated code
- Configuration files

Thinking "skip TDD just this once"? That's rationalization. Don't.

## The Red-Green-Refactor Cycle

```
RED -> Verify RED -> GREEN -> Verify GREEN -> REFACTOR -> (repeat)
```

### RED - Write Failing Test

Write one minimal test showing what should happen.

**Good example:**
```typescript
test('retries failed operations 3 times', async () => {
  let attempts = 0;
  const operation = () => {
    attempts++;
    if (attempts < 3) throw new Error('fail');
    return 'success';
  };

  const result = await retryOperation(operation);

  expect(result).toBe('success');
  expect(attempts).toBe(3);
});
```
Clear name, tests real behavior, one thing

**Bad example:**
```typescript
test('retry works', async () => {
  const mock = jest.fn()
    .mockRejectedValueOnce(new Error())
    .mockRejectedValueOnce(new Error())
    .mockResolvedValueOnce('success');
  await retryOperation(mock);
  expect(mock).toHaveBeenCalledTimes(3);
});
```
Vague name, tests mock not behavior

**Requirements:**
- One behavior per test
- Clear, descriptive name
- Real code (no mocks unless unavoidable)

### Verify RED - Watch It Fail

**MANDATORY. Never skip.**

Run the test and confirm:
- Test fails (not errors)
- Failure message is expected
- Fails because feature is missing (not typos)

**Test passes immediately?** You're testing existing behavior. Fix test.

**Test errors?** Fix error, re-run until it fails correctly.

### GREEN - Minimal Code

Write the simplest code to pass the test.

**Good example:**
```typescript
async function retryOperation<T>(fn: () => Promise<T>): Promise<T> {
  for (let i = 0; i < 3; i++) {
    try {
      return await fn();
    } catch (e) {
      if (i === 2) throw e;
    }
  }
  throw new Error('unreachable');
}
```
Just enough to pass

**Bad example:**
```typescript
async function retryOperation<T>(
  fn: () => Promise<T>,
  options?: {
    maxRetries?: number;
    backoff?: 'linear' | 'exponential';
    onRetry?: (attempt: number) => void;
  }
): Promise<T> {
  // Over-engineered - YAGNI
}
```
Adding features not in the test

Don't add features, refactor other code, or "improve" beyond what the test requires.

### Verify GREEN - Watch It Pass

**MANDATORY.**

Run the test and confirm:
- New test passes
- All other tests still pass
- No errors or warnings in output

**Test fails?** Fix code, not test.

**Other tests fail?** Fix now before proceeding.

### REFACTOR - Clean Up

Only after tests are green:
- Remove duplication
- Improve names
- Extract helpers

**Rules:**
- Keep tests green throughout
- Don't add new behavior
- Re-run tests after each change

### Repeat

Next failing test for next feature.

## Good vs Bad Tests

| Quality | Good | Bad |
|---------|------|-----|
| **Minimal** | One thing. "and" in name? Split it. | `test('validates email and domain and whitespace')` |
| **Clear** | Name describes behavior | `test('test1')` or `test('it works')` |
| **Intent** | Demonstrates desired API | Obscures what code should do |
| **Real** | Tests actual behavior | Only tests mocks |

## Why Test-First Matters

**"I'll write tests after to verify it works"**

Tests written after code pass immediately. This proves nothing:
- Might test wrong thing
- Might test implementation, not behavior
- Might miss edge cases
- You never saw it catch the bug

Test-first forces you to see the test fail, proving it actually tests something.

**"I already manually tested it"**

Manual testing is ad-hoc:
- No record of what you tested
- Can't re-run when code changes
- Easy to forget cases
- "It worked when I tried it" != comprehensive

Automated tests are systematic and repeatable.

**"Deleting code is wasteful"**

Sunk cost fallacy. Your choice:
- Delete and rewrite with TDD (high confidence, maintainable)
- Keep it and add tests after (low confidence, likely bugs)

The waste is keeping code you can't trust.

## Red Flags - STOP and Start Over

If you catch yourself:
- Writing code before test
- Writing test after implementation
- Test passes immediately
- Can't explain why test failed
- Rationalizing "just this once"
- "I already manually tested it"
- "Keep as reference" or "adapt existing code"
- "This is different because..."

**All of these mean: Delete code. Start over with TDD.**

## Bug Fix Example

**Bug:** Empty email accepted

**RED:**
```typescript
test('rejects empty email', async () => {
  const result = await submitForm({ email: '' });
  expect(result.error).toBe('Email required');
});
```

**Verify RED:**
```bash
$ npm test
FAIL: expected 'Email required', got undefined
```

**GREEN:**
```typescript
function submitForm(data: FormData) {
  if (!data.email?.trim()) {
    return { error: 'Email required' };
  }
  // existing logic...
}
```

**Verify GREEN:**
```bash
$ npm test
PASS
```

**REFACTOR:** Extract validation helper if handling multiple fields.

## Verification Checklist

Before marking work complete:

- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] No errors or warnings in output
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and errors covered

Can't check all boxes? You skipped TDD. Start over.

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write wished-for API. Write assertion first. Ask user. |
| Test too complicated | Design too complicated. Simplify interface. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup huge | Extract helpers. Still complex? Simplify design. |

## Final Rule

```
Production code -> test exists and failed first
Otherwise -> not TDD
```

Bug found? Write failing test reproducing it. Follow TDD cycle.

**Never fix bugs without a test.**
