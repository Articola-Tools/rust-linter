# correct_rust

Test fixture that passes strict clippy and thailint lints.

This crate is used by the `rust-linter` Docker image CI to verify that the linter
accepts clean Rust code. It is mounted into the linter container at
`/linter_workdir` and `cargo clippy --all-targets` followed by the three thailint
linters (blocking-async, clone-abuse, unwrap-abuse) is expected to exit with
status code 0.
