# 📦 Node.js UI Scaffolding (Next.js Focus)

## 🎯 Objective
Create a modern Node.js UI project using Next.js, bootstrapped via our script which leverages the official Next.js CLI, applies standardized configurations, and includes Docker support.

## 📝 Purpose in MVP_Kit
This scaffold provides one of the potential **blueprints for the `mvp-prototyping-system`**. It enables rapid development of:
- Interactive web application prototypes for client MVPs using the Next.js App Router.
- Server-side rendered (SSR) or statically generated (SSG) applications.
- PWAs (Progressive Web Apps) with local storage capabilities (e.g., IndexedDB).

**Note:** Only `--framework=next` is currently supported.

## 📋 Requirements

### 1. Project Initialization (Handled by `bootstrap.sh`)
```bash
# The bootstrap script executes the following steps for Next.js:
# 1. Runs `pnpm create next-app@latest . --ts --no-tailwind --no-eslint --app --src-dir --import-alias "@/*" --no-git`
# 2. Installs additional deps: `tailwindcss@^3 postcss@^8 autoprefixer@^10`
# 3. Installs dev dependencies: `@biomejs/biome vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom @vitejs/plugin-react`
# 4. Removes default ESLint config (`.eslintrc*`).
# 5. Copies shared templates (`.gitignore`, `biome.json.tpl`).
# 6. Copies Next.js-specific templates from `templates/node/next/` (e.g., test files, Vitest config, Tailwind config, PostCSS config, Dockerfile, docker-compose.yml, next.config.mjs) - overwrites if needed.
# 7. Processes templates using `envsubst` (if variables are defined in metadata).
# 8. Updates `package.json` scripts (format, lint, test, build, dev, start).
```

### 2. Directory Structure (Generated by Next.js + Templates)
```
ui/ # Example project root name
├── public/
│   └── # Static assets
├── src/
│   ├── app/
│   │   ├── globals.css   # Global styles (template)
│   │   ├── layout.tsx    # Root layout (generated)
│   │   ├── page.tsx      # Root page (generated)
│   │   └── page.test.tsx # Example test (template)
│   ├── components/       # (Optional) Shared React components
│   └── lib/              # (Optional) Utility functions, etc.
├── tests/
│   └── setup.ts          # Vitest setup (template)
├── biome.json            # Biome configuration (template)
├── Dockerfile            # Docker configuration (template)
├── docker-compose.yml    # Docker Compose configuration (template)
├── next.config.mjs       # Next.js configuration (template, sets output: 'standalone')
├── package.json          # Project configuration (modified by bootstrap script)
├── postcss.config.mjs    # PostCSS config (template)
├── tailwind.config.ts    # Tailwind CSS config (template)
├── tsconfig.json         # TypeScript configuration (generated by create-next-app)
└── vitest.config.ts      # Vitest configuration (template)
# Note: node_modules/, .next/, pnpm-lock.yaml are generated.
```

### 3. Configuration Files

- **`package.json`**: Modified by `bootstrap.sh` to add/update scripts (`format`, `lint`, `test`, `build`, `dev`, `start`).
- **`Dockerfile`**: Copied from `templates/node/next/docker/Dockerfile.tpl`. Defines multi-stage builds for development, testing, and production (`standalone`).
- **`docker-compose.yml`**: Copied from `templates/node/next/docker/docker-compose.yml.tpl`. Defines `dev`, `test`, and `preview` services using the Dockerfile stages. Uses `${port}` variable.
- **`next.config.mjs`**: Copied from `templates/node/next/next.config.mjs.tpl`, includes `output: 'standalone'`.
- **`tailwind.config.ts`**: Copied from `templates/node/next/tailwind.config.ts.tpl`.
- **`postcss.config.mjs`**: Copied from `templates/node/next/postcss.config.mjs.tpl`.
- **`vitest.config.ts`**: Copied from `templates/node/next/vitest.config.ts.tpl`, integrates with React Testing Library.
- **`biome.json`**: Copied from `templates/node/shared/biome.json.tpl`.
- **`tsconfig.json`**: Generated by `create-next-app`.

### 4. Example Implementation (Generated + Templates)
See generated `src/app/page.tsx`, `src/app/layout.tsx`, and template `src/app/globals.css.tpl`.

### 5. Test Implementation (Templates)
See `templates/node/next/src/app/page.test.tsx.tpl` and `templates/node/next/tests/setup.ts.tpl`.

### 6. Docker Configuration (Included)
```dockerfile
# See templates/node/next/docker/Dockerfile.tpl
# Multi-stage: deps -> builder -> runner (production) -> development -> test
```
```yaml
# See templates/node/next/docker/docker-compose.yml.tpl
# Defines services: dev, test, preview (maps to runner stage)
```

## 🔧 Implementation Steps

1.  **Bootstrap Project**
    ```bash
    # From workspace root, run the specific just task:
    just bootstrap-ui-next
    ```

2.  **Post-Processing (Handled by `just` task and `bootstrap.sh`)**
    - Project directory created (`bootstrap-test/node/test-ui-next`).
    - `create-next-app` executed.
    - Additional dependencies installed.
    - Shared & Next.js-specific template files copied (incl. Dockerfiles, configs, test files - overwriting defaults where applicable).
    - `package.json` scripts updated.
    - Biome formatting and fixes applied (`biome format --write`, `biome check --write`).

3.  **Development**
    ```bash
    # Navigate to project directory
    cd bootstrap-test/node/test-ui-next

    # Start development server (local)
    pnpm dev

    # Start development server (Docker)
    # Ensure port 3000 (or custom via env var 'port') is free on host
    just docker-next-dev # From workspace root

    # Start production preview server (Docker)
    # Ensure port 3000 (or custom via env var 'port') is free on host
    just docker-next-preview # From workspace root

    # Run tests (local)
    pnpm test

    # Run tests (Docker)
    just docker-next-test # From workspace root

    # Format code (local)
    pnpm format
    ```

## ✅ Success Criteria (Verified)

1.  **Functionality**
    - [x] Next.js development server starts successfully (local: `pnpm dev` | Docker: `just docker-next-dev`).
    - [x] Hot module replacement works during development (local & Docker).
    - [x] Tests pass (local: `just test-ui-next` | Docker: `just docker-next-test`).
    - [x] Linting passes (`pnpm biome check .`).
    - [x] Production preview starts and serves correctly (`just docker-next-preview`).

2.  **Build Process**
    - [x] Project builds successfully (`pnpm build`).
    - [x] TypeScript declarations check passes during build.
    - [x] Docker image builds successfully (`just docker-next-build`).

3.  **Configuration**
    - [x] `biome.json` is present and correctly configured.
    - [x] `package.json` includes necessary scripts (dev, build, start, test, lint, format).
    - [x] `next.config.mjs` includes `output: 'standalone'`.
    - [x] `Dockerfile` and `docker-compose.yml` are present and configured for dev/test/preview.
    - [x] Path aliases (`@/*`) work correctly.

4.  **Dependencies**
    - [x] Core Next.js dependencies are installed.
    - [x] Biome, Vitest, and Testing Library are installed.
    - [x] Tailwind, PostCSS, Autoprefixer are installed.
    - [x] No major dependency conflicts apparent.

## 🔍 Testing

1.  **Local Testing**
    ```bash
    # From workspace root
    just test-ui-next
    # Or from project directory
    # cd bootstrap-test/node/test-ui-next && pnpm test
    ```

2.  **Docker Testing**
    ```bash
    # From workspace root
    just docker-next-build
    just docker-next-test
    ```

3.  **Manual Integration Testing**
    - Run `pnpm dev` in the project directory OR `just docker-next-dev` from root.
    - Access the site in a browser (localhost:3000 by default).
    - Make changes to components/pages and verify hot reload.
    - Run `just docker-next-preview` from root.
    - Access the preview site in a browser (localhost:3000 by default).
    - Run `pnpm build` and `pnpm start` (local) to test local production build serving.

## 📝 Notes

- This scaffold uses **Next.js** with the App Router.
- Testing is set up with **Vitest** and **React Testing Library**.
- **Biome** is used for linting and formatting (ESLint is removed).
- **Docker support is included** for development, testing, and production preview.
- Relies on **template files** in `templates/node/next/` and `templates/node/shared/` for configuration and core files. 