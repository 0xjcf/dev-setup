services:
  dev:
    build:
      context: .
      target: development
      args:
        # Pass port from environment or use default 5173
        - port=${port:-5173}
    ports:
      # Map host port to container port (Vite default 5173)
      - "${port:-5173}:5173"
    volumes:
      # Mount host code into /app for hot-reloading
      - .:/app
      # Use anonymous volume to keep node_modules isolated in container
      # Prevents host node_modules interfering with container's
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - PORT=${port:-5173}
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
      target: production # Target the production Nginx stage
    ports:
      # Map host port (e.g., 8080) to container Nginx port (80)
      - "${port:-8080}:80"
    # No volumes needed for previewing the static build
    # Command is defined by the Dockerfile's CMD instruction for the production stage

# Optional service to preview the production build (requires Stage 2 in Dockerfile)
# preview:
#   build:
#     context: .
#     target: production
#   ports:
#     - "8080:80" # Map host 8080 to container Nginx port 80 