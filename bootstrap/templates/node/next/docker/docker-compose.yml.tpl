services:
  dev:
    build:
      context: .
      target: development
    ports:
      # Map host port to container port (Next.js default 3000)
      # Allow overriding with environment variable 'port'
      - "${port:-3000}:3000"
    volumes:
      # Mount host code into /app for hot-reloading
      # NOTE: Exclude node_modules and .next from the host mount
      #       to prevent conflicts with the container's versions.
      #       This is often handled by the default .dockerignore
      - .:/app
      # Use anonymous volume to keep node_modules isolated in container
      - /app/node_modules
      # Use anonymous volume to keep build artifacts isolated in container
      - /app/.next
    environment:
      - NODE_ENV=development
      - PORT=${port:-3000}
    # Command is defined by the Dockerfile's CMD instruction for the development stage

  test:
    build:
      context: .
      target: test
    environment:
      - NODE_ENV=test
    # No ports needed for testing
    # No volumes needed - tests run against code built into the image
    # Command is defined by the Dockerfile's CMD instruction for the test stage

  preview:
    build:
      context: .
      target: runner # The production stage in our Dockerfile
    ports:
      # Map host port (e.g., 8080) to container port (Next.js default 3000)
      # Allow overriding with environment variable 'port'
      - "${port:-3000}:3000"
    environment:
      - NODE_ENV=production
      - PORT=${port:-3000}
    # Command is defined by the Dockerfile's CMD instruction for the runner stage