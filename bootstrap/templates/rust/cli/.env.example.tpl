# Example environment variables for the Rust CLI application

# Set the log level. Overrides the default inferred from -v flags.
# Valid levels: trace, debug, info, warn, error
# Example: RUST_LOG=trace
# Example: RUST_LOG=info,my_crate=debug
RUST_LOG=info

# Other potential configuration via environment variables
# API_KEY=your_api_key_here
# CONFIG_PATH=/path/to/custom/config.toml 