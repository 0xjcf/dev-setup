// src/main.rs.tpl
use clap::Parser;

// Project modules
mod cli;
// mod commands; // Uncomment if you have subcommands in separate files
// mod config;   // Uncomment if you have config logic
// mod errors;   // Uncomment if you have custom errors
mod telemetry;

// External crates
// use anyhow::Result; // Uncomment if using anyhow

fn main() -> Result<(), Box<dyn std::error::Error>> { // Replace with anyhow::Result if using anyhow
    // Parse command line arguments
    let cli_args = cli::Cli::parse();

    // Initialize telemetry (logging/tracing)
    telemetry::init_tracing(cli_args.verbose);

    tracing::debug!(args = ?cli_args, "Parsed CLI arguments");

    // Execute the command
    match cli_args.command {
        cli::Commands::Greet { name } => {
            tracing::info!(name = ?name, "Executing greet command");
            let target = name.as_deref().unwrap_or("World");
            println!("Hello, {}!", target);
            // Example: Call a handler function from a subcommand module
            // commands::greet::run(name)?;
        }
        // Match other commands here
        // cli::Commands::Run { task_id, config } => {
        //     tracing::info!(task = task_id, config = ?config, "Executing run command");
        //     commands::run::run_task(&task_id, config.as_deref())?;
        // }
    }

    tracing::info!("Command finished successfully");
    Ok(())
} 