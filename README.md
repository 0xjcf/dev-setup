# 🛠️ Dev Setup

This repository contains the setup scripts and automation tasks to bootstrap and maintain your **freelance/agency software development environment**, including:

- Global system-level tooling (`setup.sh`)
- Per-project bootstrapping (`bootstrap.sh`)
- Post-install integrity checks (`healthcheck.sh`)
- Task automation via `justfile`

---

## 📁 Directory Structure

```
dev-setup/
├── bootstrap/       # Core bootstrapping logic, templates, functions
├── docs/            # Additional documentation
├── prompts/         # Scaffold definition prompts
├── scripts/         # Main executable scripts
│   ├── setup.sh         # Installs global dev stack
│   ├── bootstrap.sh     # Bootstraps projects
│   └── healthcheck.sh   # Verifies tool installation
├── .envrc           # Direnv environment variables
├── justfile         # Task runner definitions
├── README.md        # This file
└── PROMPT.md        # (Optional: Main prompt definition?)
```

---

## ✅ Usage

### 1. Install your full dev environment (one-time setup):
```bash
./setup.sh
```

### 2. Run a system health check (optional but recommended):
```bash
./healthcheck.sh
```

### 3. Bootstrap a project:

**Primary Use:** Generate standardized test projects or bootstrap from a configuration file.

From the `dev-setup` directory using `just` (recommended for test projects):
```bash
# (Note: Recipes prefixed with 'i-' are integration tests that bootstrap a project)

# Example: Bootstrap a Node.js Next.js UI project
just i-test-node-ui-next

# Example: Bootstrap a Rust API project
just i-test-rust-api
```

**Directly (e.g., using a config file):**
```bash
# From dev-setup
./bootstrap.sh --config path/to/your/config.json
```
Example `config.json`:
```json
{
  "projects": [
    {
      "path": "../my-cool-api",
      "type": "node",
      "class": "api"
    },
    {
      "path": "../my-awesome-ui",
      "type": "node",
      "class": "ui"
      # "framework": "next" // Framework currently set via flag, not config
    },
    {
      "path": "../rust-agent-x",
      "type": "rust",
      "class": "agent"
    }
  ]
}
```

```bash
# Or specifying parameters individually
./bootstrap.sh --target-dir ../path/to/new-project --tech=node --class=api
```

**From another project root (less common):**
```bash
~/dev-setup/bootstrap.sh # May require flags like --target-dir=.
```

### 4. View Project Documentation:
```bash
# View this README using glow (if installed)
just docs 
```

---

## 🧠 Tips

- Keep `bootstrap.sh` reusable across projects by referencing it from the project's `scripts/` directory or invoking it directly.
- Add this repo to your dotfiles or workspace so new environments can be spun up easily.
- Use `healthcheck.sh` in CI pipelines or after `setup.sh` to validate tool availability.
- Customize the `justfile` with project-specific tasks (`just lint`, `just test`, etc).

---

## 🤖 Cursor AI Integration

Cursor AI agents automatically reference `.cursor/tools.mdc` to:

- Understand available CLI tools
- Follow standardized usage patterns
- Assist in task automation and command generation

---

## ✨ Key Features & Goals

| Category | Strength | Notes |
|---------|----------|-------|
| ✅ **Extensibility** | Dynamic handling for project types | Supports Node.js (API, UI-Next, UI-Vite), Rust (API, CLI, Agent). Go pending. Config file enables monorepo setup. |
| ✅ **Dev UX** | Clear, contextual prompts | Rich logging, progress messages, human & AI friendly. |
| ✅ **Dry Run Support** | Safe preview mode (`--dry-run`) | Consistent `run_or_dry` usage, vital for CI/CD and AI. |
| ✅ **Toolchain Awareness** | Smart setup hooks per language | Includes validation and messaging for Node, Rust, Go (Go setup logic pending). |
| ✅ **Context Generation** | Metadata and tool manifests | `.metadata.json` and `.cursor/tools.mdc` aid IDEs, AI agents, and future auto-docs. |
| ✅ **AI-Aware Monorepo Justfile** | Rich task definitions | Includes `audit`, `check`, `dev`, `test`, `clean`, integration tests (`i-test-*`). |
| ✅ **Scaffold Quality** | Production-ready starting points | Generates scaffolds with tests, entry points, health checks, Docker integration (Dockerfile, Compose), and clean READMEs. |
| ✅ **Docker Integration** | Containerized dev/test environments | Most scaffolds include multi-stage Dockerfiles and docker-compose setups. |

---

## 🔗 Recommended Next Steps

- Add `dev-setup/` to your dotfiles or workspace root.
- Include `bootstrap.sh` in new project README templates.
- Create project-specific `Taskfile.yml` or `justfile` wrappers.
- Use `direnv` with `.envrc` for per-project environment variables.

Let this stack power your MVPs, AI agents, and client delivery workflows 💼⚡

