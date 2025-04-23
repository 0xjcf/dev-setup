/// <reference types="vitest" />
import { defineConfig, mergeConfig } from "vite";
import viteConfig from "./vite.config"; // Import the default config

export default mergeConfig(
  viteConfig, // Merge the base config
  defineConfig({
    // Vitest specific config
    test: {
      globals: true, // Use global APIs like describe, it, expect
      environment: "jsdom", // Simulate DOM environment
      setupFiles: "./src/tests/setup.ts", // Run setup file before tests
      // Add other test-specific options here if needed
      // e.g., coverage: { reporter: ['text', 'json', 'html'] }
    },
  }),
); 