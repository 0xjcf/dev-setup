# Build stage
FROM node:22-slim AS builder

# Define build argument with default value
ARG PORT=3000
ENV PORT=$PORT

# Install specific version of pnpm
RUN corepack enable && corepack prepare pnpm@10.8.1 --activate
# Force download during build to prevent runtime prompts
RUN pnpm --version

# Set working directory
WORKDIR /app

# Copy ONLY package.json from host build context
COPY package.json ./

# Install dependencies and GENERATE lockfile based ONLY on package.json
RUN pnpm install

# Copy source code (after install to leverage cache)
COPY . .

# Build TypeScript
RUN pnpm build

# Production stage
FROM node:22-slim AS production

# Define build argument with default value
ARG PORT=3000
ENV PORT=$PORT

# Install specific version of pnpm
RUN corepack enable && corepack prepare pnpm@10.8.1 --activate
# Force download during build
RUN pnpm --version

# Set working directory
WORKDIR /app

# Copy package files and lockfile from builder
COPY --from=builder /app/package.json /app/pnpm-lock.yaml ./

# Install production dependencies
RUN pnpm install --prod --frozen-lockfile

# Copy built files from builder
COPY --from=builder /app/dist ./dist

# Expose port
EXPOSE 3000

# Start the application
CMD ["node", "dist/index.js"]

# Development stage
FROM node:22-slim AS development

# Define build argument with default value
ARG PORT=3000
ENV PORT=$PORT

# Install specific version of pnpm
RUN corepack enable && corepack prepare pnpm@10.8.1 --activate
# Force download during build
RUN pnpm --version

# Set working directory
WORKDIR /app

# Copy package files and lockfile from builder
COPY --from=builder /app/package.json /app/pnpm-lock.yaml ./

# Install all dependencies (using lockfile from builder)
# Remove --frozen-lockfile to avoid config mismatch error
RUN pnpm install

# Copy source code (after install to leverage cache)
COPY . .

# Expose port
EXPOSE 3000

# Start development server
CMD ["pnpm", "dev"]

# Test stage (Simplified & Self-Contained)
FROM node:22-slim AS test

# Define build argument (optional, keep if needed for tests)
ARG PORT=3000
ENV PORT=$PORT

# Install system dependencies needed for potential native modules
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install specific version of pnpm
RUN corepack enable && corepack prepare pnpm@10.8.1 --activate
# Force download during build
RUN pnpm --version

# Set working directory
WORKDIR /app

# Copy ONLY package.json from host build context
COPY package.json ./

# Install dependencies based *only* on the copied package.json
# This generates a clean lockfile and node_modules within this stage
RUN pnpm install

# Copy necessary source, test, and config files
COPY src ./src
COPY test ./test
COPY tsconfig.json ./
# Add other necessary config files if needed (e.g., COPY .env ./)

# Expose port (optional for test stage)
EXPOSE 3000

# Run tests using the command from package.json
# Ensure NODE_ENV is set if not already in the script
# CMD ["pnpm", "run", "test"] 
# Alternative: Run directly if CMD needs to be simpler
CMD ["sh", "-c", "NODE_ENV=test pnpm exec tsx --test test/*.test.ts"]
