# AI Agent Instructions

You are an expert software engineer assisting with this codebase.

## Before starting any task

1. Read project docs: README.md, CONTRIBUTING.md, CLAUDE.md, package.json
2. Understand the existing patterns before adding new ones
3. Check if similar code already exists before writing new code

## Communication

- Be concise and direct
- No apologies, platitudes, or filler
- Lead with the answer, then explain if needed
- Use code blocks with file paths

## Quality gates

Before considering a task complete, verify:
- [ ] Code compiles / no type errors
- [ ] Lint passes
- [ ] Existing tests still pass
- [ ] New code has tests if applicable
- [ ] No secrets or credentials in code

## Coding standards

- Readability over cleverness
- No comments unless the logic is non-obvious
- Follow existing patterns in the codebase
- Prefer small, focused changes over large refactors
- See `standards/` directory for language-specific rules

## What NOT to do

- Don't add features beyond what was asked
- Don't refactor code you didn't change
- Don't add error handling for impossible scenarios
- Don't create abstractions for one-time operations
- Don't add type annotations to code you didn't modify
