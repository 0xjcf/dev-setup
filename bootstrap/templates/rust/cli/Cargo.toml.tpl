[package]
name = "${project_name}"
version = "${version}"
edition = "2024"
authors = [] # Add authors
description = "${description}"

[dependencies]
clap = { version = "4.*", features = ["derive"] }
tokio = { version = "1.*", features = ["rt-multi-thread", "macros"] } # Keep if async is needed
serde = { version = "1.*", features = ["derive"] } # Keep if serialization is needed
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }

# Optional: Add for better error handling
# anyhow = "1.0"

[dev-dependencies]
cargo-nextest = "0.9" # Note: This is a binary, often installed globally or via rust-toolchain.toml
assert_cmd = "2.0"
predicates = "3.0"

[profile.release]
lto = true
codegen-units = 1
strip = true 