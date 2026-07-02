FROM mcr.microsoft.com/devcontainers/base:bookworm

ARG ZIG_VERSION=0.15.2

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "${arch}" in \
      amd64) zig_arch=x86_64 ;; \
      arm64) zig_arch=aarch64 ;; \
      *) echo "unsupported architecture: ${arch}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${zig_arch}-${ZIG_VERSION}.tar.xz" -o /tmp/zig.tar.xz; \
    tar -xJf /tmp/zig.tar.xz -C /usr/local; \
    mv "/usr/local/zig-linux-${zig_arch}-${ZIG_VERSION}" /usr/local/zig; \
    ln -sf /usr/local/zig/zig /usr/local/bin/zig; \
    rm /tmp/zig.tar.xz; \
    zig version

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
      elixir \
      lua5.4 \
      r-base \
    && rm -rf /var/lib/apt/lists/*
