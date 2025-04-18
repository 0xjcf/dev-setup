[package]
name = "${project_name}"
version = "${version}"
edition = "2024"
authors = [] # Add authors
description = "${description}"

[dependencies]
axum = "0.7" # Check for latest Axum version
tokio = { version = "1", features = ["full"] } # Full features for async runtime
serde = { version = "1.0", features = ["derive"] }
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter", "fmt"] }

# Optional dependencies
# dotenv = "0.15" # For loading .env files
# anyhow = "1.0" # For error handling
# thiserror = "1.0" # For custom errors
# tower-http = { version = "0.5", features = ["trace", "cors"] } # For tracing and CORS middleware

[dev-dependencies]
cargo-nextest = "0.9"
reqwest = { version = "0.12", features = ["json"] } # For integration tests
once_cell = "1.19" # For shared test runtime
# httpc-test = "0.1" # Alternative test client

[profile.release]
lto = true
codegen-units = 1
strip = true 