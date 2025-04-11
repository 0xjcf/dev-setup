# 📦 Rust CLI Scaffolding

## 🎯 Objective
Create a reusable Rust CLI scaffold using Clap that follows best practices and includes all necessary tooling for development, testing, and distribution.

## 📋 Requirements

### 1. Directory Structure
```
cli/
├── src/
│   ├── main.rs         # CLI entry point
│   ├── commands/       # Command implementations
│   │   ├── run.rs
│   │   └── config.rs
│   └── utils.rs        # Shared utilities
├── tests/
│   └── integration.rs  # Integration tests
├── examples/
│   └── basic.rs        # Example usage
├── Cargo.toml          # Project configuration
├── .rustfmt.toml       # Rustfmt configuration
├── .clippy.toml        # Clippy configuration
└── README.md           # Documentation
```

### 2. Cargo Configuration
```toml
[package]
name = "cli-name"
version = "0.1.0"
edition = "2021"
authors = ["Your Name <your.email@example.com>"]
description = "A CLI tool for doing things"
license = "MIT"
repository = "https://github.com/yourusername/cli-name"

[dependencies]
clap = { version = "4.4", features = ["derive"] }
anyhow = "1.0"
thiserror = "1.0"
tracing = "0.1"
tracing-subscriber = "0.3"

[dev-dependencies]
assert_cmd = "2.0"
predicates = "3.0"
```

### 3. Dependencies
- Runtime:
  - `clap` (for CLI parsing)
  - `anyhow` (for error handling)
  - `thiserror` (for custom errors)
  - `tracing` (for logging)
- Dev:
  - `assert_cmd` (for testing)
  - `predicates` (for test assertions)

### 4. Example Implementation
```rust
// src/main.rs
use clap::Parser;
use anyhow::Result;

#[derive(Parser)]
#[command(name = "mycli")]
#[command(about = "A CLI tool for doing things", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(clap::Subcommand)]
enum Commands {
    /// Run the main task
    Run {
        /// Force execution
        #[arg(short, long)]
        force: bool,
    },
    /// Manage configuration
    Config {
        /// List current config
        #[arg(short, long)]
        list: bool,
    },
}

fn main() -> Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt::init();

    let cli = Cli::parse();

    match cli.command {
        Commands::Run { force } => {
            if force {
                println!("Running with force...");
            } else {
                println!("Running...");
            }
        }
        Commands::Config { list } => {
            if list {
                println!("Listing config...");
            } else {
                println!("Configuring...");
            }
        }
    }

    Ok(())
}
```

### 5. Test Implementation
```rust
// tests/integration.rs
use assert_cmd::Command;
use predicates::prelude::*;

#[test]
fn test_help() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = Command::cargo_bin("mycli")?;
    cmd.arg("--help");
    cmd.assert()
        .success()
        .stdout(predicate::str::contains("A CLI tool for doing things"));

    Ok(())
}

#[test]
fn test_run() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = Command::cargo_bin("mycli")?;
    cmd.arg("run");
    cmd.assert()
        .success()
        .stdout(predicate::str::contains("Running..."));

    Ok(())
}
```

## 🔧 Implementation Steps

1. **Setup Project Structure**
   ```bash
   cargo new cli-name
   cd cli-name
   ```

2. **Initialize Cargo**
   ```bash
   cargo init
   ```

3. **Install Dependencies**
   ```bash
   cargo add clap --features derive
   cargo add anyhow thiserror tracing tracing-subscriber
   cargo add --dev assert_cmd predicates
   ```

4. **Create Configuration Files**
   - `.rustfmt.toml` with formatting rules
   - `.clippy.toml` with linting rules
   - Update `Cargo.toml` with metadata

5. **Implement Core Files**
   - Create CLI entry point with Clap setup
   - Add command implementations
   - Add test files
   - Add README with usage examples

6. **Add Documentation**
   - Add doc comments
   - Add examples
   - Add README with usage examples

## ✅ Success Criteria

1. **Functionality**
   - [ ] CLI can be installed
   - [ ] Commands work as expected
   - [ ] Help text is properly formatted
   - [ ] Tests pass
   - [ ] Linting passes

2. **Quality**
   - [ ] Code is properly formatted
   - [ ] Clippy passes
   - [ ] Documentation is complete
   - [ ] Examples are provided

3. **Documentation**
   - [ ] README is complete
   - [ ] All commands are documented
   - [ ] Examples are provided
   - [ ] Contributing guidelines are included

4. **Tooling**
   - [ ] All cargo commands work
   - [ ] Formatting is configured
   - [ ] Linting is configured
   - [ ] Tests are configured

## 🔍 Testing

1. **Manual Testing**
   ```bash
   # Format
   cargo fmt --check
   
   # Lint
   cargo clippy
   
   # Test
   cargo test
   
   # Build
   cargo build --release
   
   # Run
   cargo run -- --help
   ```

2. **Integration Testing**
   - Install the CLI
   - Test all commands
   - Verify help text
   - Check error handling

## 📝 Notes

- Use Clap for CLI parsing
- Follow CLI best practices
- Provide clear error messages
- Include examples in help text
- Use proper error handling
- Add logging support
- Support both global and local installation 