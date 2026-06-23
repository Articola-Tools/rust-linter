# incorrect_thailint

Test fixture that passes clippy but fails thailint linters.

This crate is used by the `rust-linter` Docker image CI to verify that the
thailint linters (blocking-async, clone-abuse, unwrap-abuse) correctly detect
violations. It is written to pass `cargo clippy --all-targets` in strict mode
but fail the thailint linters, ensuring that thailint violations are caught
even when Clippy considers the code clean.
