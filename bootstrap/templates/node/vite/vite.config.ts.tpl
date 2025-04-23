/// <reference types="vitest/globals" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: { // Add server configuration
    host: true, // Listen on all addresses, including 0.0.0.0
    port: 5173, // Default port
  },
}) 