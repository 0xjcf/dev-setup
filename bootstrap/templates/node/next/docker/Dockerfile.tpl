# dev-setup/bootstrap/templates/node/next/docker/Dockerfile.tpl

# ---- Base Stage ----
FROM node:22-slim AS base
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@8.15.4 --activate

# ---- Dependencies Stage ----
FROM base AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
# RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile --prod=false

# ---- Builder Stage ----
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Ensure NEXT_TELEMETRY_DISABLED is set to 1 to avoid prompts during build
ENV NEXT_TELEMETRY_DISABLED 1
RUN pnpm build

# ---- Runner Stage (Production) ----
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
# Ensure NEXT_TELEMETRY_DISABLED is set to 1
ENV NEXT_TELEMETRY_DISABLED 1

# Next.js automatically collects dependencies needed for standalone mode.
# https://nextjs.org/docs/pages/api-reference/next-config-js/output
COPY --from=builder /app/public ./public
# Next.js collects files required for standalone mode into .next/standalone
COPY --from=builder --chown=node:node /app/.next/standalone ./
# Next.js collects static files required for standalone mode into .next/static
COPY --from=builder --chown=node:node /app/.next/static ./.next/static

# Use node user provided by base image
USER node

# Default port for Next.js production server
EXPOSE 3000
ENV PORT 3000

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/next-config-js/output#automatically-copying-traced-files
CMD ["node", "server.js"]


# ---- Development Stage ----
FROM base AS development
WORKDIR /app
ENV NODE_ENV=development
# Install all dependencies, including dev
COPY . .
RUN pnpm install --prod=false
# Default port for Next.js dev server
EXPOSE 3000
ENV PORT=3000
# Run development server, listening on all interfaces
CMD ["pnpm", "run", "dev"]

# ---- Test Stage ----
FROM base AS test
WORKDIR /app
ENV NODE_ENV=test
# Copy only package manifests first
COPY package.json pnpm-lock.yaml* ./
# Explicitly remove node_modules if it exists (belt-and-suspenders)
RUN rm -rf node_modules
# Install all dependencies based on the lockfile for the container's architecture
RUN pnpm install --frozen-lockfile --prod=false

# Copy the rest of the application code
COPY . .

# Command to run tests (adjust if your test script is different)
CMD ["pnpm", "run", "test"]