//! Test fixture that passes strict clippy and thailint lints.
//!
//! This library is a test fixture for the `rust-linter` Docker image and is
//! expected to be accepted by `cargo clippy --all-targets` running in strict
//! mode (all clippy lints enabled, `clippy::nursery` excluded, any warning
//! denied) and by the three thailint linters (blocking-async, clone-abuse,
//! unwrap-abuse) running with strict configuration.

/// Adds two numbers together using wrapping arithmetic to avoid overflow.
#[must_use]
pub const fn add(left: u64, right: u64) -> u64 {
    left.wrapping_add(right)
}

/// Multiplies two numbers together using wrapping arithmetic to avoid overflow.
#[must_use]
pub const fn multiply(left: u64, right: u64) -> u64 {
    left.wrapping_mul(right)
}
