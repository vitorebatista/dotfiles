# Code Review

Review the current changes following these phases. Output a structured markdown report.

## Phases

### 1. Architecture
- Component structure and separation of concerns
- Import organization and dependency direction
- State management approach

### 2. Functionality
- Edge cases and error handling
- Input validation
- Correct use of async/await and promises

### 3. Security
- Input sanitization
- Authentication/authorization checks
- No secrets or credentials in code
- SQL injection, XSS, CSRF prevention

### 4. Maintainability
- Naming clarity (variables, functions, files)
- Code duplication
- Function length and complexity
- Type safety

### 5. Testing
- Test coverage for new/changed code
- Edge case coverage
- Test readability

### 6. Performance
- Unnecessary re-renders (React)
- N+1 queries
- Missing indexes
- Large bundle imports

### 7. Dependencies
- Unnecessary new dependencies
- Outdated or vulnerable packages
- License compatibility

## Output Format

For each finding use:

```
**[SEVERITY]** Category — Description
File: path/to/file.ts:line
Suggestion: how to fix
```

Severities: `CRITICAL` (must fix), `IMPROVEMENT` (should fix), `NIT` (nice to have)
