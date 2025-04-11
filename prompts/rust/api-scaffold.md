# 🚀 Rust API Project Scaffolding

## 🎯 Objective
Create a reusable Rust API project scaffold using Axum that follows best practices and includes all necessary tooling for development, testing, and deployment.

## 📋 Requirements

### 1. Directory Structure
```
api/
├── src/
│   ├── main.rs        # Entry point
│   ├── routes/        # API routes
│   │   ├── mod.rs
│   │   ├── health.rs
│   │   └── api.rs
│   ├── handlers/      # Request handlers
│   ├── models/        # Data models
│   ├── errors/        # Error handling
│   └── utils/         # Utility functions
├── tests/            # Integration tests
├── Cargo.toml        # Project configuration
├── .cargo/          # Cargo configuration
│   └── config.toml
├── .rustfmt.toml    # Rustfmt config
├── .clippy.toml     # Clippy config
└── README.md        # Documentation
```

### 2. Cargo Configuration
- Name: `api-name`
- Edition: `2021`
- Type: `bin`
- Features:
  - `default`: Basic API functionality
  - `sqlite`: SQLite database support
  - `test`: Testing utilities

### 3. Dependencies
- Runtime:
  - `axum`
  - `tokio`
  - `serde`
  - `anyhow`
  - `thiserror`
  - `tracing`
  - `rusqlite` (optional)
- Dev:
  - `cargo-nextest`
  - `cargo-watch`
  - `cargo-edit`
  - `cargo-audit`

### 4. Example Implementation
```rust
// src/routes/health.rs
use axum::{
    routing::get,
    Router,
    response::IntoResponse,
};

pub fn router() -> Router {
    Router::new()
        .route("/health", get(health_check))
}

async fn health_check() -> impl IntoResponse {
    "OK"
}
```

### 5. Test Implementation
```rust
// tests/health_test.rs
use axum::Router;
use tower::ServiceExt;
use super::*;

#[tokio::test]
async fn test_health_check() {
    let app = Router::new()
        .merge(health::router());

    let response = app
        .oneshot(
            Request::builder()
                .uri("/health")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
}
```

## 🔧 Implementation Steps

1. **Setup Project Structure**
   ```bash
   cargo generate --git https://github.com/rust-lang-ja/cargo-generate-template
   cd api
   ```

2. **Install Dependencies**
   ```bash
   cargo add axum tokio serde anyhow thiserror tracing
   cargo add -D cargo-nextest cargo-watch cargo-edit cargo-audit
   ```

3. **Create Configuration Files**
   - `Cargo.toml` with proper settings
   - `.rustfmt.toml` with formatting rules
   - `.clippy.toml` with linting rules
   - `.cargo/config.toml` with build settings

4. **Implement Core Files**
   - Create API structure
   - Add error handling
   - Set up routing
   - Add test files

5. **Add Build Configuration**
   - Configure CI/CD
   - Set up release automation
   - Add performance monitoring
   - Configure security scanning

6. **Add Documentation**
   - API documentation
   - Usage examples
   - Contributing guidelines

## ✅ Success Criteria

1. **Functionality**
   - [ ] API builds successfully
   - [ ] Routes work as expected
   - [ ] Tests pass
   - [ ] Linting passes

2. **Performance**
   - [ ] Low latency
   - [ ] High throughput
   - [ ] Efficient resource usage
   - [ ] Proper error handling

3. **Documentation**
   - [ ] README is complete
   - [ ] API is documented
   - [ ] Examples are provided

4. **Tooling**
   - [ ] All cargo commands work
   - [ ] Linting is configured
   - [ ] Tests are configured
   - [ ] CI/CD is set up

## 🔍 Testing

1. **Manual Testing**
   ```bash
   # Development
   cargo run
   
   # Build
   cargo build --release
   
   # Test
   cargo nextest run
   
   # Lint
   cargo clippy
   
   # Audit
   cargo audit
   ```

2. **Integration Testing**
   - Test API endpoints
   - Verify error handling
   - Check performance
   - Validate security

## 📝 Notes

- Use async/await for I/O
- Follow Rust best practices
- Implement proper error handling
- Add logging and monitoring
- Optimize for performance
- Include security features
- Add performance monitoring 