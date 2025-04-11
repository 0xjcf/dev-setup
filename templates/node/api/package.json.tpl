{
  "name": "{{project_name}}",
  "version": "{{version}}",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "test": "vitest",
    "lint": "biome check --apply .",
    "build": "tsc",
    "start": "node dist/index.js",
    "check": "tsc --noEmit",
    "audit": "pnpm audit",
    "update-deps": "./scripts/update-deps.sh"
  },
  "dependencies": {
    "express": "{{dependencies.express}}"
  },
  "devDependencies": {
    "@types/express": "{{devDependencies.@types/express}}",
    "@types/node": "{{devDependencies.@types/node}}",
    "typescript": "{{devDependencies.typescript}}",
    "tsx": "{{devDependencies.tsx}}",
    "vitest": "{{devDependencies.vitest}}",
    "@biomejs/biome": "{{devDependencies.biome}}"
  }
} 