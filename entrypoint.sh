#!/bin/bash
set -euo pipefail

# The mounted /linter_workdir is owned by the host user and is not writable by
# the container's non-root linteruser. Copy the project to a temporary directory
# where cargo can freely create Cargo.lock and build artifacts.
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

cp -a /linter_workdir/. "$WORKDIR/"

# Remove any pre-existing target directory so cargo does not reuse stale
# build artifacts from the host.
rm -rf "$WORKDIR/target"

cd "$WORKDIR"

# --- Clippy (Rust compiler lints) -------------------------------------------
cargo clippy --all-targets -- \
    -D clippy::pedantic \
    -D clippy::cargo \
    -D warnings \
    -A clippy::nursery

# --- thailint (additional Rust linters) -------------------------------------
# thailint uses tree-sitter to parse Rust source files and detects anti-patterns
# that Clippy does not cover: blocking calls in async functions, .clone() abuse,
# and .unwrap()/.expect() abuse.  The configuration is baked into the image at
# /thailint.yaml.  thailint is installed in an isolated virtual environment at
# /opt/thailint to avoid conflicts with Debian-managed Python packages.
#
# thailint exits with code 1 when violations are found, so the script (running
# under `set -e`) will fail immediately if any thailint linter reports issues.
/opt/thailint/bin/thailint blocking-async --config /thailint.yaml "$WORKDIR/src/"
/opt/thailint/bin/thailint clone-abuse --config /thailint.yaml "$WORKDIR/src/"
/opt/thailint/bin/thailint unwrap-abuse --config /thailint.yaml "$WORKDIR/src/"
