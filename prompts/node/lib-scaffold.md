# 📦 Node.js Library Scaffolding

## 🎯 Objective
Create a reusable Node.js library scaffold that follows best practices and includes all necessary tooling for development, testing, and publishing.

## 📋 Requirements

### 1. Directory Structure
```
lib/
├── src/
│   ├── index.ts        # Main entry point
│   └── utils.ts        # Utility functions
├── test/
│   ├── index.test.ts   # Main test file
│   └── utils.test.ts   # Utility tests
├── package.json        # Project configuration
├── tsconfig.json       # TypeScript configuration
├── biome.json          # Biome (linting/formatting) config
└── README.md           # Documentation
```

### 2. Package Configuration
- Name: `@scope/lib-name`
- Type: `module`
- Main: `dist/index.js`
- Types: `dist/index.d.ts`
- Scripts:
  - `dev`: Watch mode for development
  - `test`: Run tests
  - `lint`: Run linter
  - `build`: Build the library
  - `publish`: Publish to npm
  - `check`: Type checking

### 3. Dependencies
- Runtime:
  - `typescript`
  - `@types/node`
- Dev:
  - `vitest`
  - `biome`
  - `tsup` (for building)

### 4. Example Implementation
```typescript
// src/index.ts
export function greet(name: string): string {
  return `Hello, ${name}!`;
}

// src/utils.ts
export function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1);
}
```

### 5. Test Implementation
```typescript
// test/index.test.ts
import { describe, it, expect } from 'vitest';
import { greet } from '../src';

describe('greet', () => {
  it('should return greeting with name', () => {
    expect(greet('World')).toBe('Hello, World!');
  });
});
```

## 🔧 Implementation Steps

1. **Setup Project Structure**
   ```bash
   mkdir -p lib/{src,test}
   cd lib
   ```

2. **Initialize Package**
   ```bash
   pnpm init
   ```

3. **Install Dependencies**
   ```bash
   pnpm add -D typescript @types/node vitest biome tsup
   ```

4. **Create Configuration Files**
   - `tsconfig.json` with proper module and target settings
   - `biome.json` with linting rules
   - `package.json` with scripts and metadata

5. **Implement Core Files**
   - Create entry point with example functions
   - Add test files
   - Add README with usage examples

6. **Add Build Configuration**
   - Configure `tsup` for building
   - Set up proper TypeScript declarations
   - Add source maps

7. **Add Documentation**
   - API documentation
   - Usage examples
   - Contributing guidelines

## ✅ Success Criteria

1. **Functionality**
   - [ ] Library can be imported and used
   - [ ] TypeScript types are properly exported
   - [ ] Tests pass
   - [ ] Linting passes

2. **Build Process**
   - [ ] Library builds successfully
   - [ ] TypeScript declarations are generated
   - [ ] Source maps are included

3. **Documentation**
   - [ ] README is complete
   - [ ] API is documented
   - [ ] Examples are provided

4. **Tooling**
   - [ ] All scripts work
   - [ ] Linting is configured
   - [ ] Tests are configured

## 🔍 Testing

1. **Manual Testing**
   ```bash
   # Build
   pnpm build
   
   # Test
   pnpm test
   
   # Lint
   pnpm lint
   
   # Type check
   pnpm check
   ```

2. **Integration Testing**
   - Create a test project
   - Import and use the library
   - Verify types and functionality

## 📝 Notes

- Keep the library focused and minimal
- Follow TypeScript best practices
- Use proper error handling
- Document all public APIs
- Include examples in tests 