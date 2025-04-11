# 📦 Node.js UI Project Scaffolding

## 🎯 Objective
Create a reusable Node.js UI project scaffold using SvelteKit that follows best practices and includes all necessary tooling for development, testing, and deployment.

## 📋 Requirements

### 1. Directory Structure
```
ui/
├── src/
│   ├── app.html        # Main HTML template
│   ├── app.d.ts        # TypeScript declarations
│   ├── routes/         # Page routes
│   │   ├── +page.svelte
│   │   ├── +page.ts
│   │   └── +layout.svelte
│   ├── lib/           # Shared components
│   │   ├── components/
│   │   └── utils.ts
│   └── styles/        # Global styles
├── static/            # Static assets
├── tests/            # Test files
├── package.json      # Project configuration
├── svelte.config.js  # SvelteKit config
├── tsconfig.json     # TypeScript config
├── biome.json        # Biome config
└── README.md         # Documentation
```

### 2. Package Configuration
- Name: `@scope/ui-name`
- Type: `module`
- Scripts:
  - `dev`: Development server
  - `build`: Production build
  - `preview`: Preview production build
  - `test`: Run tests
  - `lint`: Run linter
  - `check`: Type checking
  - `audit`: Security audit

### 3. Dependencies
- Runtime:
  - `@sveltejs/kit`
  - `svelte`
  - `typescript`
- Dev:
  - `@playwright/test`
  - `@biomejs/biome`
  - `@lhci/cli`
  - `workbox-cli`
  - `npm-check-updates`

### 4. Example Implementation
```svelte
<!-- src/routes/+page.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import { Button } from '$lib/components';

  let count = 0;

  function increment() {
    count += 1;
  }
</script>

<main>
  <h1>Welcome to {name}</h1>
  <Button on:click={increment}>
    Count: {count}
  </Button>
</main>

<style>
  main {
    padding: 2rem;
    text-align: center;
  }
</style>
```

### 5. Test Implementation
```typescript
// tests/home.test.ts
import { test, expect } from '@playwright/test';

test('home page has correct title', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle('{{project_name}}');
});
```

## 🔧 Implementation Steps

1. **Setup Project Structure**
   ```bash
   pnpm create svelte@latest ui
   cd ui
   ```

2. **Install Dependencies**
   ```bash
   pnpm install
   pnpm add -D @playwright/test @biomejs/biome @lhci/cli workbox-cli npm-check-updates
   ```

3. **Create Configuration Files**
   - `svelte.config.js` with proper settings
   - `tsconfig.json` with strict mode
   - `biome.json` with linting rules
   - `package.json` with scripts

4. **Implement Core Files**
   - Create basic layout
   - Add example components
   - Set up routing
   - Add test files

5. **Add Build Configuration**
   - Configure SvelteKit
   - Set up PWA support
   - Add performance monitoring
   - Configure CI/CD

6. **Add Documentation**
   - Component documentation
   - Usage examples
   - Contributing guidelines

## ✅ Success Criteria

1. **Functionality**
   - [ ] UI builds successfully
   - [ ] Components work as expected
   - [ ] Tests pass
   - [ ] Linting passes

2. **Performance**
   - [ ] Lighthouse score > 90
   - [ ] PWA support
   - [ ] Optimized assets
   - [ ] Fast loading

3. **Documentation**
   - [ ] README is complete
   - [ ] Components are documented
   - [ ] Examples are provided

4. **Tooling**
   - [ ] All scripts work
   - [ ] Linting is configured
   - [ ] Tests are configured
   - [ ] CI/CD is set up

## 🔍 Testing

1. **Manual Testing**
   ```bash
   # Development
   pnpm dev
   
   # Build
   pnpm build
   
   # Preview
   pnpm preview
   
   # Test
   pnpm test
   
   # Lint
   pnpm lint
   
   # Audit
   pnpm audit
   ```

2. **Integration Testing**
   - Test component interactions
   - Verify routing
   - Check PWA functionality
   - Validate performance

## 📝 Notes

- Use SvelteKit for routing
- Follow Svelte best practices
- Implement proper error handling
- Add accessibility features
- Optimize for performance
- Include PWA support
- Add performance monitoring 