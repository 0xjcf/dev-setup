// src/telemetry.rs.tpl
use tracing_subscriber::{EnvFilter, fmt, layer::SubscriberExt, util::SubscriberInitExt};

/// Initializes the tracing subscriber based on verbosity level and RUST_LOG env var.
pub fn init_tracing(verbosity: u8) {
    // Determine log level based on verbosity flags
    let log_level = match verbosity {
        0 => tracing::Level::INFO, // Default
        1 => tracing::Level::DEBUG,
        _ => tracing::Level::TRACE, // -vv and higher
    };

    // Setup EnvFilter
    // Start with the level derived from verbosity flags.
    // Then, try to override with RUST_LOG environment variable if set.
    let env_filter = EnvFilter::builder()
        .with_default_directive(log_level.into())
        .from_env_lossy(); // Parses RUST_LOG, falls back to default directive if invalid

    // Setup the tracing subscriber
    tracing_subscriber::registry()
        .with(env_filter)
        .with(fmt::layer()) // Configures layers for formatting and output
        .init(); // Sets this subscriber as the global default

    tracing::debug!(level = ?log_level, verbosity, "Tracing initialized");
}
