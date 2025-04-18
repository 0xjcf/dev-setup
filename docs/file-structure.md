# 🗂 Workspace Structure

## 📁 Root Directory
```
.
├── justfile              # Workspace-level task runner
├── .cursor/             # Cursor IDE configuration
├── dev-setup/           # Development setup and templates
├── MVP_Kit/            # Main project monorepo
├── port8080folio/      # Portfolio website
└── file-structure.md   # This documentation
```

## 🔧 dev-setup/
Development setup and template system for project scaffolding.

```
dev-setup/
├── bootstrap.sh        # Project bootstrap script
├── setup.sh           # Initial setup script
├── healthcheck.sh     # System health check
├── PROMPT.md          # Development guide
├── README.md          # Project documentation
├── .git/              # Git repository
├── .gitignore         # Git ignore rules
├── .cursor/           # Cursor IDE tools
├── templates/         # Project templates
│   ├── node/         # Node.js templates
│   ├── rust/         # Rust templates
│   └── go/           # Go templates
└── prompts/          # AI agent prompts
    ├── node/         # Node.js prompts
    ├── rust/         # Rust prompts
    ├── go/           # Go prompts
```

## 🚀 MVP_Kit/
Main project monorepo for client MVP development.

```
MVP_Kit/
├── .git/              # Git repository
├── PROMPT.md          # Project overview
└── client-intake-system/  # Node backend
    ├── .cursor/          # Cursor IDE tools
    ├── .github/          # GitHub workflows
    ├── .git/             # Git repository
    ├── .gitignore        # Git ignore rules
    ├── .DS_Store        # macOS directory metadata
    ├── coverage/         # Test coverage reports
    ├── docs/            # Documentation
    ├── forms/           # Form templates
    ├── intake-submissions/ # Form submissions
    ├── node_modules/    # Node dependencies
    ├── project-briefs/  # Generated project briefs
    ├── scripts/         # Automation scripts
    ├── src/            # Source code
    │   ├── server.ts   # Main server file
    │   ├── server.unit.test.ts # Server tests
    │   ├── test-utils/ # Testing utilities
    │   ├── types/      # TypeScript types
    │   └── scripts/    # Source scripts
    ├── Dockerfile      # Production Dockerfile
    ├── Dockerfile.test # Test Dockerfile
    ├── README.md       # Project documentation
    ├── docker-compose.test.yml # Test compose file
    ├── docker-compose.yml # Production compose file
    ├── eslint.config.js # ESLint configuration
    ├── jest.config.js  # Jest configuration
    ├── package.json    # Node dependencies
    ├── pnpm-lock.yaml  # PNPM lock file
    ├── server.js       # Server entry point
    └── tsconfig.json   # TypeScript configuration
```

## 🌐 port8080folio/
Portfolio website with intake form.

```
port8080folio/
├── .git/              # Git repository
├── .DS_Store         # macOS directory metadata
├── intake/           # Intake form
│   ├── Project Name: TBD.md  # Project brief template
│   ├── intake.html   # Form HTML
│   ├── intake.css    # Form styles
│   └── intake.js     # Form logic
├── wftmb.avif        # Image asset
├── me.jpeg           # Profile image
├── privacy-policy.css # Privacy policy styles
├── privacy-policy.html # Privacy policy page
├── robots.txt        # SEO config
├── sitemap.xml       # Site structure
├── styles.css        # Global styles
├── index.html        # Main page
└── index.js          # Main script
```

## 🛠️ Development Tools

### Core CLI Tools
- `just` - Task runner
- `pnpm` - Package manager
- `cargo` - Rust package manager
- `go` - Go toolchain

### Code Quality
- `biome` - JS/TS formatting & linting
- `rustfmt` - Rust formatting
- `clippy` - Rust linting

### Testing
- `vitest` - JS/TS testing
- `cargo test` - Rust testing
- `playwright` - E2E testing

### AI Development
- `ollama` - Local LLM server
- `candle` - ML framework
- `llama.cpp` - Inference engine

## 📋 Usage Guidelines

1. **Project Setup**
   ```bash
   just setup        # Initial setup
   just bootstrap    # Bootstrap projects
   ```

2. **Development**
   ```bash
   just mvp-kit <task>    # Run MVP_Kit tasks
   just portfolio <task>  # Run portfolio tasks
   ```

3. **Code Quality**
   ```bash
   just lint        # Run linters
   just format      # Format code
   just test        # Run tests
   ```

4. **Documentation**
   ```bash
   just docs        # View documentation
   just status      # Check project status
   ```

## 🔄 Workflow

1. Use `dev-setup` to scaffold new projects
2. Bootstrap projects with `just bootstrap`
3. Develop using project-specific tasks
4. Maintain code quality with workspace tools
5. Deploy using project-specific workflows

## 📝 Notes

- All projects use `just` for task running
- Environment variables managed via `.envrc`
- AI development tools integrated across projects
- Consistent tooling and practices maintained 