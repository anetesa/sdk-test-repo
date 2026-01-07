# TypeScript & Pre-commit Hook Setup

## Overview

This project now includes comprehensive TypeScript type checking and pre-commit hooks to ensure code quality and prevent type errors in builds.

## TypeScript Configuration

### Main Config (`tsconfig.json`)

- **Strict type checking** enabled with additional safety checks
- **Path aliases** configured for clean imports (`@/` -> `src/`)
- **Balanced strictness** - strict enough to catch real issues, practical for React Native

### Test Config (`tsconfig.test.json`)

- **Extends main config** with more lenient rules for test files
- **Allows** `noImplicitAny: false` for easier test writing
- **Includes** Jest and React Native Testing Library types

## Available Scripts

### Type Checking

```bash
# Run type checking on all source files
yarn type-check

# Run type checking in watch mode
yarn type-check:watch

# Run type checking on test files only
yarn type-check:test

# Run pre-commit checks manually
yarn pre-commit

# Auto-fix linting issues
yarn fix
```

### Build Process

- **Pre-build**: Automatically runs type checking before builds
- **Type errors will prevent builds** - ensuring type safety

## Pre-commit Hook

### What it does

The pre-commit hook runs automatically before each commit and:

1. **Type checking** - Ensures no TypeScript errors
2. **Linting** - Runs ESLint to check code style
3. **Blocks commits** if any checks fail

### Bypassing the hook

In urgent situations, you can bypass the hook:

```bash
git commit --no-verify -m "urgent fix"
```

### Manual testing

You can run the pre-commit checks manually:

```bash
yarn pre-commit
```

## Current Type Issues

The system currently detects **39 type errors** in **18 files** that should be addressed:

### High Priority Issues

- **Missing store properties** in `TransactionState` (setPaymentType, status, response, etc.)
- **Undefined value handling** in forms and user input
- **SVG component props** - xmlns not allowed in react-native-svg

### Lower Priority Issues

- **Unused imports** and variables
- **Implicit any types** in callback parameters
- **Missing return values** in some functions

## Workflow

### Development

1. Use `yarn type-check:watch` during development for real-time feedback
2. Fix type errors as they appear
3. Use `yarn fix` to auto-fix linting issues

### Committing

1. Pre-commit hook runs automatically
2. If type/lint errors exist, commit is blocked
3. Fix errors and try again
4. Use `--no-verify` only for urgent situations

### Building

1. `yarn prebuild` runs type checking automatically
2. Builds fail if type errors exist
3. Fix errors before building

## Benefits

✅ **Prevents type errors** in production builds  
✅ **Catches bugs early** in development  
✅ **Enforces code quality** standards  
✅ **Consistent codebase** across team  
✅ **Better IDE support** with accurate types

## Migration Notes

If you encounter type errors after this setup:

1. **These are real issues** that existed before but were ignored
2. **Fix them gradually** - start with high-priority errors
3. **Use `--no-verify`** sparingly for urgent fixes
4. **Ask for help** if you're unsure about type fixes

## Support

For questions about TypeScript setup or type errors:

- Check this documentation first
- Use `yarn type-check` to see current issues
- Ask the team for help with complex type issues
