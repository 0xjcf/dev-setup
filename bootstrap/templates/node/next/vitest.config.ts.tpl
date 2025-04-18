/// <reference types="vitest/globals" />

import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'node:path'

// https://vitest.dev/config/
export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './tests/setup.ts', // Points to our setup file
    // Add aliases for imports (e.g., @/*) if needed for tests
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
}) 