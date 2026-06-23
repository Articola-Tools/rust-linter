# Articola Tools' Rust linter

[![image size](https://ghcr-badge.egpl.dev/articola-tools/rust-linter/size?color=dodgerblue)](https://ghcr-badge.egpl.dev/articola-tools/rust-linter/size?color=dodgerblue)

This repo contains Dockerfile with preconfigured [Clippy](https://github.com/rust-lang/rust-clippy)
linter and [thailint](https://thai-lint.readthedocs.io/) additional Rust linters. This linter
is used in Articola Tools organization's repositories to lint Rust code.

## Configuration

### Clippy

The linter runs Clippy in strict mode with the following settings:

- All default Clippy lints (`clippy::all` - `style`, `complexity`, `perf`, `correctness`, `suspicious`)
  are enabled and any violation fails the linter.
- `clippy::pedantic` and `clippy::cargo` lint groups are explicitly set to `deny` (these
  groups default to `allow`, so they must be overridden to be enforced).
- All other Rust warnings (e.g. unused variables) are also treated as errors via `-D warnings`.
- `clippy::nursery` is the only lint group that is excluded from the check, as requested.

### thailint

After Clippy passes, the linter runs three additional Rust-specific linters from the
[thailint](https://thai-lint.readthedocs.io/) package. These linters use tree-sitter to parse
Rust source files and detect anti-patterns that Clippy does not cover:

- **[blocking-async](https://thai-lint.readthedocs.io/en/latest/blocking-async-linter/)** —
  Detects blocking calls (`std::fs`, `std::thread::sleep`, `std::net`) inside `async`
  functions. All three sub-rules are enabled: `fs-in-async`, `sleep-in-async`, `net-in-async`.
- **[clone-abuse](https://thai-lint.readthedocs.io/en/latest/clone-abuse-linter/)** —
  Detects `.clone()` abuse: clones inside loops (`clone-in-loop`), chained
  `.clone().clone()` (`clone-chain`), and unnecessary clones where the original is unused
  (`unnecessary-clone`).
- **[unwrap-abuse](https://thai-lint.readthedocs.io/en/latest/unwrap-abuse-linter/)** —
  Detects `.unwrap()` and `.expect()` calls that can panic at runtime. Both methods are
  flagged (`allow_expect: false`).

All three linters allow violations inside `#[test]` functions and `#[cfg(test)]` modules
(`allow_in_tests: true`). The thailint configuration is baked into the Docker image at
`/thailint.yaml` (see [`thailint.yaml`](thailint.yaml) in this repository).

The linter fails if any single rule is not satisfied.

## Usage

Use `ghcr.io/articola-tools/rust-linter` Docker image with `-v ./:/linter_workdir`
parameter, where `./` - is a path to a folder with a Rust project (containing `Cargo.toml`)
you want to lint.

Example command to use this linter -

`docker run --rm -v ./:/linter_workdir ghcr.io/articola-tools/rust-linter`

The command above runs `cargo clippy --all-targets` on the mounted Rust project, followed by
the three thailint linters on the `src/` directory. It exits with a non-zero status code if
any Clippy lint, Rust warning, or thailint rule is violated.
