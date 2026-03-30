# Testing Standards

## General

- Write tests in plain English — they are documentation
- One expectation per `it` block
- Do not start descriptions with "should" — just state the behavior
  - Bad: `it('should return null when user not found')`
  - Good: `it('returns null when user not found')`
- Test behavior, not implementation
- Cover edge cases: empty inputs, null, boundaries, error states

## Structure

- Use `describe` to group related tests
- Use `beforeEach` for shared setup, but keep it minimal
- Prefer factory functions over complex `beforeEach` blocks
- Keep tests DRY but readable — some duplication is OK for clarity

## Mocking

- Mock only external dependencies (APIs, databases, file system)
- Do not mock the module under test
- Prefer dependency injection over module mocking
- Reset mocks between tests

## Naming

- Test files: `*.test.ts` or `*.spec.ts` next to the source file
- Describe blocks: name of the function or component
- It blocks: describe the expected behavior

## React Components

- Test user interactions, not component internals
- Use `@testing-library/react` — query by role, label, text
- Avoid testing implementation details (state, refs, lifecycle)
- Test accessibility: ensure elements have proper roles and labels
