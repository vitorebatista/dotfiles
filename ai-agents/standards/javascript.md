# JavaScript / TypeScript Standards

## General

- Use `const` by default, `let` only when reassignment is needed, never `var`
- Prefer arrow functions for callbacks and short functions
- Use template literals over string concatenation
- Use optional chaining (`?.`) and nullish coalescing (`??`) over manual checks
- Prefer `??` over `||` for default values (avoids falsy pitfalls)

## Arrays and Iteration

- Prefer `map`, `filter`, `reduce`, `find`, `some`, `every` over `for` loops
- Use `for...of` when you need `break` or `await` inside the loop
- Never use `for...in` for arrays

## Functions

- Use object params for functions with 3+ parameters
- Return early to avoid deep nesting
- Keep functions small and single-purpose
- Use descriptive names (`getUserById` not `getUser`)

## Naming

- `camelCase` for variables and functions
- `PascalCase` for classes, types, interfaces, React components
- `UPPER_SNAKE_CASE` for constants
- Prefix booleans with `is`, `has`, `can`, `should`
- Name files same as their default export

## TypeScript

- Use `type` over `interface` unless extending
- Use `readonly` for properties that shouldn't change
- Avoid `any` — use `unknown` if the type is truly unknown
- Use discriminated unions over optional properties when possible
- Let TypeScript infer return types for simple functions

## React

- One component per file
- Prefer function components
- Use `useReducer` for complex state logic
- Extract custom hooks for reusable logic
- Use variant/size props over boolean flags (`variant="primary"` not `isPrimary`)
- Keep components under 150 lines — extract if larger

## Imports

- Order: external libs > internal modules > relative imports > styles
- Use named exports over default exports
- Use `import type` for type-only imports
