//! Test fixture that passes clippy but fails thailint linters.
//!
//! This library is a test fixture for the `rust-linter` Docker image. It is
//! written to pass `cargo clippy --all-targets` in strict mode (all clippy
//! lints enabled, `clippy::nursery` excluded, any warning denied) but fail the
//! thailint linters (blocking-async, clone-abuse, unwrap-abuse).

/// Reads a configuration file inside an async function.
///
/// # Panics
///
/// Panics if the file cannot be read.
#[must_use]
pub async fn read_config(path: &str) -> String {
    let content = std::fs::read_to_string(path).unwrap();
    std::future::ready(content).await
}

/// Collects owned copies of names from a slice.
#[must_use]
pub fn collect_names(names: &[String]) -> Vec<String> {
    let mut result = Vec::new();
    for name in names {
        result.push(name.clone().clone());
    }
    result
}
