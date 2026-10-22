FROM rust:1.99.0-trixie

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
# upgraded or removed by pip).  pip is only needed at build time and is removed
# afterwards; its vendored dependencies (msgpack, urllib3, setuptools) otherwise
# show up as vulnerable packages in the Trivy scan.
#
# Several packages are pre-installed in the base image with known CVEs; pinning
# them to the fixed versions clears the Trivy security scan.  The base image is
# not rebuilt for every Debian point release, so these upgrades must be applied
# explicitly here.
# All packages are version-pinned to satisfy hadolint DL3008.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        imagemagick=8:7.1.1.43+dfsg1-1+deb13u12 \
        linux-libc-dev=6.12.113-1 \
        python3-venv=3.13.5-1 \
        curl=8.14.1-2+deb13u7 \
        libcurl3t64-gnutls=8.14.1-2+deb13u7 \
        libcurl4-openssl-dev=8.14.1-2+deb13u7 \
        libcurl4t64=8.14.1-2+deb13u7 \
        gir1.2-rsvg-2.0=2.60.0+dfsg-1+deb13u1 \
        librsvg2-2=2.60.0+dfsg-1+deb13u1 \
        librsvg2-common=2.60.0+dfsg-1+deb13u1 \
        librsvg2-dev=2.60.0+dfsg-1+deb13u1 \
        libexpat1=2.9.0-1~deb13u1 \
        libexpat1-dev=2.9.0-1~deb13u1 \
        libheif-plugin-dav1d=1.23.4-1~deb13u1 \
        libheif-plugin-libde265=1.23.4-1~deb13u1 \
        libheif1=1.23.4-1~deb13u1 \
        libpcre2-16-0=10.46-1~deb13u3 \
        libpcre2-32-0=10.46-1~deb13u3 \
        libpcre2-8-0=10.46-1~deb13u3 \
        libpcre2-dev=10.46-1~deb13u3 \
        libpcre2-posix3=10.46-1~deb13u3 \
        libpng-dev=1.6.48-1+deb13u6 \
        libpng16-16t64=1.6.48-1+deb13u6 \
        libssl-dev=3.5.7-1~deb13u3 \
        libssl3t64=3.5.7-1~deb13u3 \
        openssl=3.5.7-1~deb13u3 \
        openssl-provider-legacy=3.5.7-1~deb13u3 \
        libunbound8=1.26.1-0+deb13u1 \
    && python3 -m venv /opt/thailint \
    && /opt/thailint/bin/pip install --upgrade pip \
    && /opt/thailint/bin/pip install thailint \
    && /opt/thailint/bin/pip uninstall -y pip \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY thailint.yaml /thailint.yaml
RUN chmod +x /entrypoint.sh

WORKDIR /linter_workdir

USER linteruser

HEALTHCHECK --timeout=1s --retries=1 CMD cargo clippy --version || exit 1

ENTRYPOINT ["/entrypoint.sh"]
