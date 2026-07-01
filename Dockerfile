FROM rust:1.96.1-trixie

RUN addgroup --system lintergroup && adduser --system --ingroup lintergroup --no-create-home linteruser \
    && mkdir /linter_workdir && chown -R linteruser:lintergroup /linter_workdir

# NOTE: setting this will allow to catch error if pipe command below fails.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN rustup component add clippy

# Install thailint for additional Rust linters (blocking-async, clone-abuse,
# unwrap-abuse).  thailint is a Python package that uses tree-sitter to parse
# Rust source files and detect anti-patterns that Clippy does not cover.
#
# A virtual environment is used to avoid conflicts with Debian-managed Python
# packages (e.g. the system `packaging` module has no RECORD file and cannot be
# upgraded or removed by pip).
#
# imagemagick and linux-libc-dev are pre-installed in the base image with known
# CVEs; pinning them to the fixed versions clears the Trivy security scan.
# All packages are version-pinned to satisfy hadolint DL3008.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        imagemagick=8:7.1.1.43+dfsg1-1+deb13u10 \
        linux-libc-dev=6.12.94-1 \
        python3-venv=3.13.5-1 \
    && python3 -m venv /opt/thailint \
    && /opt/thailint/bin/pip install --upgrade pip \
    && /opt/thailint/bin/pip install thailint \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY thailint.yaml /thailint.yaml
RUN chmod +x /entrypoint.sh

WORKDIR /linter_workdir

USER linteruser

HEALTHCHECK --timeout=1s --retries=1 CMD cargo clippy --version || exit 1

ENTRYPOINT ["/entrypoint.sh"]
