# 📦 Node.js CLI Scaffolding

## 🎯 Objective
Create a reusable Node.js CLI scaffold using Commander.js that follows best practices and includes all necessary tooling for development, testing, and distribution.

## 📋 Requirements

### 1. Directory Structure
```
cli/
├── src/
│   ├── cli.ts          # CLI entry point
│   ├── commands/       # Command implementations
│   │   ├── run.ts
│   │   └── config.ts
│   └── utils.ts        # Shared utilities
├── test/
│   ├── cli.test.ts     # CLI tests
│   └── commands/       # Command tests
├── package.json        # Project configuration
├── tsconfig.json       # TypeScript configuration
├── biome.json          # Biome (linting/formatting) config
└── README.md           # Documentation
```

### 2. Package Configuration
- Name: `@scope/cli-name`
- Type: `module`
- Bin: `dist/cli.js`
- Scripts:
  - `dev`: Watch mode for development
  - `test`: Run tests
  - `lint`: Run linter
  - `build`: Build the CLI
  - `check`: Type checking
  - `link`: Link for local development

### 3. Dependencies
- Runtime:
  - `commander`
  - `typescript`
  - `@types/node`
- Dev:
  - `vitest`
  - `biome`
  - `tsup`
  - `@types/commander`

### 4. Example Implementation
```typescript
// src/cli.ts
import { Command } from 'commander';
import { runCommand } from './commands/run';
import { configCommand } from './commands/config';

const program = new Command();

program
  .name('mycli')
  .description('A CLI tool for doing things')
  .version('1.0.0');

program
  .command('run')
  .description('Run the main task')
  .option('-f, --force', 'Force execution')
  .action(runCommand);

program
  .command('config')
  .description('Manage configuration')
  .option('-l, --list', 'List current config')
  .action(configCommand);

program.parse();
```

### 5. Test Implementation
```typescript
// test/cli.test.ts
import { describe, it, expect } from 'vitest';
import { execSync } from 'child_process';

describe('CLI', () => {
  it('should show help', () => {
    const output = execSync('node dist/cli.js --help').toString();
    expect(output).toContain('Usage: mycli');
  });
});
```

## 🔧 Implementation Steps

1. **Setup Project Structure**
   ```bash
   mkdir -p cli/{src,test}/{commands,utils}
   cd cli
   ```

2. **Initialize Package**
   ```bash
   pnpm init
   ```

3. **Install Dependencies**
   ```bash
   pnpm add commander
   pnpm add -D typescript @types/node @types/commander vitest biome tsup
   ```

4. **Create Configuration Files**
   - `tsconfig.json` with proper module and target settings
   - `biome.json` with linting rules
   - `package.json` with scripts and metadata

5. **Implement Core Files**
   - Create CLI entry point with Commander.js setup
   - Add example commands
   - Add test files
   - Add README with usage examples

6. **Add Build Configuration**
   - Configure `tsup` for building
   - Set up proper TypeScript declarations
   - Add source maps

7. **Add Documentation**
   - CLI usage documentation
   - Command reference
   - Contributing guidelines

## ✅ Success Criteria

1. **Functionality**
   - [ ] CLI can be installed globally
   - [ ] Commands work as expected
   - [ ] Help text is properly formatted
   - [ ] Tests pass
   - [ ] Linting passes

2. **Build Process**
   - [ ] CLI builds successfully
   - [ ] TypeScript declarations are generated
   - [ ] Source maps are included

3. **Documentation**
   - [ ] README is complete
   - [ ] All commands are documented
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
   
   # Link for testing
   pnpm link
   ```

2. **Integration Testing**
   - Install the CLI globally
   - Test all commands
   - Verify help text
   - Check error handling

## 📝 Notes

- Use Commander.js for CLI parsing
- Follow CLI best practices
- Provide clear error messages
- Include examples in help text
- Support both global and local installation 