# The Rystic MCP server on stdio. The rystic CLI comes from the release
# www.rystic.ai names for this platform and is checked against that release's
# SHA-256 before it is installed; no downloaded script is run.
FROM debian:bookworm-slim

ARG TARGETARCH
ARG RYSTIC_VERSION=latest

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl jq \
 && rm -rf /var/lib/apt/lists/*

RUN set -eu; \
    arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    rel="$(curl -fsSL "https://www.rystic.ai/api/cli-release?os=linux&arch=${arch}&version=${RYSTIC_VERSION}&source=docker")"; \
    url="$(printf '%s' "$rel" | jq -er .url)"; \
    sum="$(printf '%s' "$rel" | jq -er .sha256)"; \
    curl -fsSL "$url" -o /tmp/rystic.tar.gz; \
    printf '%s  /tmp/rystic.tar.gz\n' "$sum" | sha256sum -c -; \
    tar -xzf /tmp/rystic.tar.gz -C /usr/local/bin rystic; \
    rm /tmp/rystic.tar.gz; \
    rystic version

RUN useradd --create-home rystic
USER rystic
WORKDIR /home/rystic

ENTRYPOINT ["rystic", "mcp"]
