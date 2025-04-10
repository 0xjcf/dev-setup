# 🛠️ Dev Setup

This repository contains the setup scripts and automation tasks to bootstrap and maintain your **freelance/agency software development environment**, including:

- Global system-level tooling (`setup.sh`)
- Per-project bootstrapping (`bootstrap.sh`)
- Post-install integrity checks (`healthcheck.sh`)
- AI/agent-readable toolchain reference (`.cursor/tools.mdc`)
- Task automation via `justfile`

---

## 📁 Directory Structure

```
dev-setup/
├── setup.sh           # Run once to install your global dev stack
├── bootstrap.sh       # Run from any project root to configure that project
├── healthcheck.sh     # Run after setup to verify all tools are installed
├── justfile           # Task runner for setup/bootstrap/dev ops
├── .cursor/
│   └── tools.mdc      # Tool manifest for Cursor and AI agents
└── README.md          # You are here
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
From any project root:
```bash
~/dev-setup/bootstrap.sh
```

Or if you're using the `justfile`:
```bash
just bootstrap
```

### 4. View tool documentation for AI agents:
```bash
just ai-docs
```

---

## 🧠 Tips

- Keep `bootstrap.sh` reusable across projects by referencing it from the project’s `scripts/` directory or invoking it directly.
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

## 🔗 Recommended Next Steps

- Add `dev-setup/` to your dotfiles or workspace root.
- Include `bootstrap.sh` in new project README templates.
- Create project-specific `Taskfile.yml` or `justfile` wrappers.
- Use `direnv` with `.envrc` for per-project environment variables.

Let this stack power your MVPs, AI agents, and client delivery workflows 💼⚡
