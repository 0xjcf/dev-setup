// src/main.rs.tpl
use axum::{routing::get, Router};
use std::net::SocketAddr;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

// Placeholder for potential modules
// mod config;
// mod errors;
// mod models;
// mod routes;
// mod services;
// mod telemetry;

#[tokio::main]
async fn main() {
    // Initialize tracing subscriber for logging
    // Uses RUST_LOG environment variable (e.g., `export RUST_LOG=info` or `info,tower_http=debug`)
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::try_from_default_env().unwrap_or_else(|_| "info".into()))
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Load configuration (using simple environment variable for port)
    let port = std::env::var("PORT").unwrap_or_else(|_| "3000".to_string());
    let addr_str = format!("0.0.0.0:{}", port);
    let addr: SocketAddr = addr_str.parse().expect("Invalid listen address");

    tracing::info!("Starting server...");

    // Build application router
    // Add routes from your route modules here
    let app = Router::new()
        .route("/", get(|| async { "Hello, World!" })) // Basic root route
        .route("/health", get(health_check)); // Health check route
        // Example: .nest("/api/v1/items", routes::item_routes())

    tracing::info!(address = %addr, "Server listening");

    // Run the server
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app.into_make_service())
        .await
        .unwrap();
}

/// Basic health check handler
async fn health_check() -> &'static str {
    "OK"
} 