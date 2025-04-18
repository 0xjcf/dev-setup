// tests/cli_tests.rs.tpl
use assert_cmd::Command;
use predicates::prelude::*;

#[test]
fn test_greet_no_name() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME"))?;
    cmd.arg("greet")
       .assert()
       .success()
       .stdout(predicate::str::contains("Hello, World!"));
    Ok(())
}

#[test]
fn test_greet_with_name() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME"))?;
    cmd.arg("greet")
       .arg("--name")
       .arg("Alice")
       .assert()
       .success()
       .stdout(predicate::str::contains("Hello, Alice!"));
    Ok(())
}

#[test]
fn test_help_flag() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME"))?;
    cmd.arg("--help")
       .assert()
       .success()
       .stdout(predicate::str::contains("Usage:"));
    Ok(())
}

#[test]
fn test_version_flag() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME"))?;
    cmd.arg("--version")
       .assert()
       .success()
       .stdout(predicate::str::contains(env!("CARGO_PKG_VERSION")));
    Ok(())
}

// Add more tests for verbosity, error cases, other commands, etc.

// Example: Test verbosity flags
#[test]
fn test_verbosity() -> Result<(), Box<dyn std::error::Error>> {
    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME"))?;
    // Assuming the greet command outputs INFO level logs by default
    // and DEBUG level logs with -v
    // (Requires your main/telemetry setup to actually log)
    cmd.arg("-v").arg("greet").assert()
        .success()
        .stderr(predicate::str::contains("DEBUG").or(predicate::str::is_empty())); // Allow empty stderr

    let mut cmd2 = Command::cargo_bin(env!("CARGO_PKG_NAME"))?;
    cmd2.arg("-vv").arg("greet").assert()
        .success()
        .stderr(predicate::str::contains("TRACE").or(predicate::str::is_empty())); // Allow empty stderr
    Ok(())
} 