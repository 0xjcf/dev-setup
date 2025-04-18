services:
  api:
    build:
      context: .
      target: development
    ports:
      - "${port}:${port}"
    volumes:
      # Mount host code for development hot-reloading
      - .:/app
      # Use anonymous volume to avoid host node_modules overwriting container's
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - PORT=${port}
    command: pnpm dev

  test:
    build:
      context: .
      target: test
    # No volumes needed - use code copied into the image during build
    environment:
      - NODE_ENV=test
      - PORT=${port}
    # Explicitly run the test command, overriding Dockerfile CMD if necessary
    # Also print Node version first for debugging
    # Use YAML folded style (>) for multi-line command clarity
    command: >
      sh -c "echo '--- Running tests with Node version: ---' && \
             node -v && \
             echo '---' && \
             NODE_ENV=test pnpm exec tsx --test test/*.test.ts"

  test-watch:
    build:
      context: .
      target: test # Reuse test stage build
    volumes:
      # Mount host code for watching changes
      - ./src:/app/src
      - ./test:/app/test
      # Keep node_modules isolated in container
      - /app/node_modules
    environment:
      - NODE_ENV=test
      - PORT=${port}
    # Explicitly run the watch command from package.json
    command: pnpm run test:watch

  debug:
    build:
      context: .
      target: test
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=test
      - DEBUG=*
    command: sh -c "echo '=== Debug Info ===' && ls -la && cat package.json && echo '=== Node Modules ===' && ls -la node_modules/.bin && echo '=== Dependency Tree ===' && pnpm why esbuild && echo '=== Installed Version ===' && pnpm list esbuild" 