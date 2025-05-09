[package]
name = "${project_name}"
version = "${version}"
edition = "2024"
authors = [] # Add authors
description = "${description}"

[dependencies]
tokio = { version = "1", features = ["rt-multi-thread", "macros", "time"] }
serde = { version = "1.0", features = ["derive"] }
anyhow = "1.0"
thiserror = "1.0"
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }

# Optional dependencies based on features
# clap = { version = "4", features = ["derive"], optional = true }
# axum = { version = "0.7", optional = true }

[dev-dependencies]
cargo-nextest = "0.9"
once_cell = "1.19" # Useful for test setup
# Add other test-specific dependencies

[features]
default = []
# cli = ["dep:clap"]
# api = ["dep:axum"]

[profile.release]
lto = true
codegen-units = 1
strip = true 