# 🚀 Universal Bootstrapper Development Guide

## 📋 Overview
This document serves as the master guide for developing the Universal Bootstrapper project. It outlines the development phases, tracks progress, and links to detailed task prompts.

## 🎯 Project Goals
1. Create a modular template system for project scaffolding
2. Support multiple tech stacks (Node.js, Rust, Go)
3. Enable easy maintenance and extension
4. Ensure consistent development practices

## 🔄 Development Phases

### Phase 1: Core Template System ⏳ (In Progress)
**Goal**: Extract and modularize all scaffolding logic into a maintainable template system.

#### Tasks:
1. ✅ Create basic template structure
   - ✅ Set up templates directory
   - ✅ Implement template loading
   - ✅ Add variable replacement

2. ⏳ Node.js Templates
   - ✅ API project template
   - ⏳ UI project template
   - ⏳ Library template
   - ⏳ CLI template

3. ⏳ Rust Templates
   - ⏳ Agent template
   - ⏳ API template
   - ⏳ Library template
   - ⏳ CLI template

4. ⏳ Go Templates
   - ⏳ API template
   - ⏳ Library template
   - ⏳ CLI template
   - ⏳ Agent template

### Phase 2: Project Generation 🔜
**Goal**: Implement robust project generation with proper validation and testing.

#### Tasks:
1. Template Validation
   - Schema validation
   - Variable checking
   - File structure verification

2. Project Generation Flow
   - Directory preparation
   - Template application
   - Post-generation hooks
   - Cleanup routines

3. Testing Framework
   - Unit tests for generators
   - Integration tests
   - Template validation tests

### Phase 3: Development Tools 🔜
**Goal**: Integrate development tools and ensure consistent practices.

#### Tasks:
1. Tool Integration
   - Linting setup (per language)
   - Formatting configuration
   - Test runners
   - Build tools

2. CI/CD Setup
   - GitHub Actions
   - Release automation
   - Version management

3. Documentation
   - API documentation
   - Usage examples
   - Contributing guidelines

## 📝 Current Focus
1. Complete Node.js API template (✅ Done)
2. Implement remaining Node.js templates (✅ Done)
3. Set up template validation
4. Add comprehensive tests

## 🔍 Testing Strategy
1. Unit Tests
   - Template rendering
   - Variable replacement
   - File generation

2. Integration Tests
   - Full project generation
   - Tool chain verification
   - Cross-platform compatibility

3. Validation Tests
   - Template schema
   - Required files
   - Dependencies

## 📚 Available Prompts

### Template System
- [Template Extraction](prompts/templates/extraction.md)

### Node.js
- [UI Scaffold](prompts/node/ui-scaffold.md)
- [Library Scaffold](prompts/node/lib-scaffold.md)
- [CLI Scaffold](prompts/node/cli-scaffold.md)

### Rust
- [Agent Scaffold](prompts/rust/agent-scaffold.md)
- [API Scaffold](prompts/rust/api-scaffold.md)
- [Library Scaffold](prompts/rust/lib-scaffold.md)
- [CLI Scaffold](prompts/rust/cli-scaffold.md)

### Go
- [API Scaffold](prompts/go/api-scaffold.md)
- [Library Scaffold](prompts/go/lib-scaffold.md)
- [CLI Scaffold](prompts/go/cli-scaffold.md)
- [Agent Scaffold](prompts/go/agent-scaffold.md)

## 🛠️ Development Tools
- `just` for task running
- `pnpm` for Node.js package management
- `cargo` for Rust package management
- `go mod` for Go dependency management
- `biome` for JS/TS formatting and linting
- `vitest` for JS/TS testing
- `cargo test` for Rust testing
- `go test` for Go testing

## 📈 Success Criteria
1. All templates are properly extracted and modularized
2. Project generation is reliable and tested
3. Development tools are properly integrated
4. Documentation is comprehensive and clear

## 🤝 Contributing
1. Check the project board for available tasks
2. Follow the development workflow
3. Ensure all tests pass
4. Update documentation
5. Submit PR for review

## 📄 License
MIT License - See LICENSE file