# Build stage
FROM --platform=${TARGETPLATFORM:-linux/amd64} node:20-slim AS builder

# Define build argument with default value
ARG PORT=3000
ENV PORT=$PORT

# Install specific version of pnpm
RUN corepack enable && corepack prepare pnpm@8.15.4 --activate

# Set working directory
WORKDIR /app

# Copy package files and lockfile
COPY package.json pnpm-lock.yaml ./

# Install dependencies with frozen lockfile
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build TypeScript
RUN pnpm build

# Production stage
FROM --platform=${TARGETPLATFORM:-linux/amd64} node:20-slim AS production

# Define build argument with default value
ARG PORT=3000
ENV PORT=$PORT

# Install specific version of pnpm
RUN corepack enable && corepack prepare pnpm@8.15.4 --activate

# Set working directory
WORKDIR /app

# Copy package files and lockfile from builder
COPY --from=builder /app/package.json /app/pnpm-lock.yaml ./

# Install production dependencies
RUN pnpm install --prod --frozen-lockfile

# Copy built files from builder
COPY --from=builder /app/dist ./dist

# Expose port
EXPOSE $PORT

# Start the application
CMD ["node", "dist/index.js"]

# Development stage
FROM --platform=${TARGETPLATFORM:-linux/amd64} node:20-slim AS development

# Define build argument with default value
ARG PORT=3000
ENV PORT=$PORT

# Install specific version of pnpm
RUN corepack enable && corepack prepare pnpm@8.15.4 --activate

# Set working directory
WORKDIR /app

# Copy package files and lockfile from builder
COPY --from=builder /app/package.json /app/pnpm-lock.yaml ./

# Install all dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Expose port
EXPOSE $PORT

# Start development server
CMD ["pnpm", "dev"]

# Test stage
FROM --platform=${TARGETPLATFORM:-linux/amd64} node:20-slim AS test

# Define build argument with default value
ARG PORT=3000
ENV PORT=$PORT

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install specific version of pnpm
RUN corepack enable && corepack prepare pnpm@8.15.4 --activate

# Set working directory
WORKDIR /app

# Copy package files and lockfile
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install

# Copy source and test files
COPY . .

# Run tests
CMD ["pnpm", "test"] 