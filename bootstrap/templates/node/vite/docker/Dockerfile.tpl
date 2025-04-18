# Stage 1: Build the application
FROM node:22-slim AS builder

WORKDIR /app

# Install specific version of pnpm
RUN corepack enable && corepack prepare pnpm@10.8.1 --activate

# Copy package files and lockfile
COPY package.json pnpm-lock.yaml ./

# Install all dependencies (needed for build and potential type checking)
RUN pnpm install --frozen-lockfile

# Copy the rest of the application source code
COPY . .

# Build the Vite application
RUN pnpm build

# --- 

# Stage 2: Production stage using Nginx
FROM nginx:1.25-alpine AS production

# Copy built assets from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx configuration (Note: source path matches the 'path' in metadata.json)
COPY ./docker/nginx.conf /etc/nginx/conf.d/default.conf 

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

# --- 

# Stage 3: Development stage
FROM node:22-slim AS development

ARG port=5173
ENV PORT=$port

WORKDIR /app

# Install specific version of pnpm
RUN corepack enable && corepack prepare pnpm@10.8.1 --activate

# Copy package files and lockfile first
COPY package.json pnpm-lock.yaml ./

# Install all dependencies 
# Use regular install, not frozen, to allow for changes via mounted volumes
RUN pnpm install

# Copy the rest of the application source code (can be overwritten by volume mount)
COPY . .

# Expose the Vite development port
EXPOSE $port

# Start the Vite development server, listening on all interfaces
# --host is crucial for accessing the server from outside the container
CMD ["pnpm", "run", "dev", "--", "--host"]

# --- 

# Stage 4: Test stage
FROM node:22-slim AS test

WORKDIR /app

# Install specific version of pnpm
RUN corepack enable && corepack prepare pnpm@10.8.1 --activate

# Copy package files and lockfile first
COPY package.json pnpm-lock.yaml ./

# Install all dependencies (including devDependencies)
RUN pnpm install --frozen-lockfile

# Copy the rest of the application source code
COPY . .

# Set environment variable for testing
ENV NODE_ENV=test

# Run the tests
CMD ["pnpm", "run", "test"] 