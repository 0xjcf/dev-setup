# 📦 Rust Library Scaffolding

## 🎯 Objective
Create a reusable Rust library scaffold that follows best practices and includes all necessary tooling for development, testing, and publishing to crates.io.

## 📋 Requirements

### 1. Directory Structure
```
lib/
├── src/
│   ├── lib.rs          # Main library code
│   └── utils.rs        # Utility functions
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
name = "lib-name"
version = "0.1.0"
edition = "2021"
authors = ["Your Name <your.email@example.com>"]
description = "A Rust library for doing things"
license = "MIT"
repository = "https://github.com/yourusername/lib-name"
documentation = "https://docs.rs/lib-name"

[dependencies]
# Add your dependencies here

[dev-dependencies]
# Add your dev dependencies here
```

### 3. Dependencies
- Runtime:
  - `anyhow` (for error handling)
  - `thiserror` (for custom errors)
- Dev:
  - `criterion` (for benchmarking)
  - `doc-comment` (for documentation tests)

### 4. Example Implementation
```rust
// src/lib.rs
use thiserror::Error;

#[derive(Error, Debug)]
pub enum LibError {
    #[error("Invalid input: {0}")]
    InvalidInput(String),
}

/// A function that does something useful
///
/// # Examples
///
/// ```
/// use lib_name::do_something;
///
/// assert_eq!(do_something(2, 3), 5);
/// ```
pub fn do_something(a: i32, b: i32) -> i32 {
    a + b
}

/// A function that might fail
pub fn might_fail(input: &str) -> Result<String, LibError> {
    if input.is_empty() {
        Err(LibError::InvalidInput("Input cannot be empty".to_string()))
    } else {
        Ok(input.to_uppercase())
    }
}
```

### 5. Test Implementation
```rust
// src/lib.rs (continued)
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_do_something() {
        assert_eq!(do_something(2, 3), 5);
    }

    #[test]
    fn test_might_fail() {
        assert!(might_fail("hello").is_ok());
        assert!(might_fail("").is_err());
    }
}
```

## 🔧 Implementation Steps

1. **Setup Project Structure**
   ```bash
   cargo new --lib lib-name
   cd lib-name
   ```

2. **Initialize Cargo**
   ```bash
   cargo init --lib
   ```

3. **Install Dependencies**
   ```bash
   cargo add anyhow thiserror
   cargo add --dev criterion doc-comment
   ```

4. **Create Configuration Files**
   - `.rustfmt.toml` with formatting rules
   - `.clippy.toml` with linting rules
   - Update `Cargo.toml` with metadata

5. **Implement Core Files**
   - Create library code with example functions
   - Add test modules
   - Add example usage
   - Add README with usage examples

6. **Add Documentation**
   - Add doc comments
   - Add examples in doc tests
   - Add README with usage examples

## ✅ Success Criteria

1. **Functionality**
   - [ ] Library can be imported and used
   - [ ] All tests pass
   - [ ] Documentation builds
   - [ ] Examples work

2. **Quality**
   - [ ] Code is properly formatted
   - [ ] Clippy passes
   - [ ] Documentation is complete
   - [ ] Examples are provided

3. **Documentation**
   - [ ] README is complete
   - [ ] API is documented
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
   
   # Doc test
   cargo test --doc
   
   # Build docs
   cargo doc --open
   ```

2. **Integration Testing**
   - Create a test project
   - Import and use the library
   - Verify functionality

## 📝 Notes

- Follow Rust best practices
- Use proper error handling
- Document all public APIs
- Include examples in doc tests
- Use proper module organization
- Follow semantic versioning 