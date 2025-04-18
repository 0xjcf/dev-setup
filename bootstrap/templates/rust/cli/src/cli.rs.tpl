// src/cli.rs.tpl
use clap::{Parser, Subcommand};

/// A CLI application built with Rust and Clap.
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
pub struct Cli {
    /// The command to execute.
    #[command(subcommand)]
    pub command: Commands,

    /// Enable verbose logging. Repeat for more detail (e.g., -vv)
    #[arg(short, long, global = true, action = clap::ArgAction::Count)]
    pub verbose: u8,
}

/// Defines the available subcommands.
#[derive(Subcommand, Debug)]
pub enum Commands {
    /// Prints a greeting message.
    Greet {
        /// The name to greet.
        #[arg(short, long)]
        name: Option<String>,
    },
    // Add other subcommands for your CLI here
    // Example:
    // /// Runs a specific task.
    // Run {
    //     /// The task identifier.
    //     task_id: String,
    //     /// Optional configuration file.
    //     #[arg(short, long)]
    //     config: Option<std::path::PathBuf>,
    // },
} 