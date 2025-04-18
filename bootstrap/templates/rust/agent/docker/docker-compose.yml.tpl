services:
  # Development service using cargo-watch for hot reloading
  dev:
    # Build using the main Dockerfile
    build:
      context: .
      dockerfile: Dockerfile
      # No specific target needed, relies on ENTRYPOINT/CMD override
    # Service name (used for linking if needed)
    container_name: ${project_name}_dev
    # Environment variables (can load from .env file)
    env_file:
      - .env # Load variables from .env file if present
    environment:
      - RUST_LOG=${RUST_LOG:-debug} # Default to debug for dev
      - PORT=${PORT:-3000}        # Ensure PORT is set
    ports:
      - "${PORT:-3000}:${PORT:-3000}" # Map host port to container port
    volumes:
      # Mount source code for hot reloading
      - ./src:/app/src
      # Keep target directory in a volume to avoid overwriting host
      - cargo-cache:/app/target 
      - cargo-registry:/usr/local/cargo/registry
    # Override entrypoint for hot reloading with cargo-watch
    # Assumes cargo-watch is installed in the base image or added here
    # Alternatively, run cargo watch on the host and connect to the container
    command: |
      bash -c "
        # Ensure cargo-watch is available
        if ! command -v cargo-watch &> /dev/null; then 
          echo 'Installing cargo-watch...'; 
          cargo install cargo-watch; 
        fi && \
        # Run the application with hot-reloading
        cargo watch -q -x 'run --bin ${project_name}' 
      "

  # Test service - runs cargo nextest inside the container
  test:
    # Build using the main Dockerfile, specifically the 'test' stage
    build:
      context: .
      dockerfile: Dockerfile
      target: test # Specify the test stage
    container_name: ${project_name}_test
    env_file:
      - .env
    environment:
      - RUST_LOG=debug # Or specific test level
      - PORT=0 # Use random port for tests if app starts
    volumes:
      # Mount source for tests
      - ./src:/app/src
      - ./tests:/app/tests
      - ./Cargo.toml:/app/Cargo.toml
      - ./Cargo.lock:/app/Cargo.lock
      - cargo-cache:/app/target 
      - cargo-registry:/usr/local/cargo/registry
    # Command to run tests
    command: cargo nextest run

volumes:
  cargo-cache:
  cargo-registry: 