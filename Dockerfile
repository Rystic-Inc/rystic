# The Rystic MCP server on stdio. The rystic CLI comes from the release
# www.rystic.ai names for this platform and is checked against a SHA-256
# before it is installed: RYSTIC_SHA256 when the build sets one, otherwise
# the value the release names. No downloaded script is run.
FROM debian:bookworm-slim

ARG TARGETARCH
# RYSTIC_VERSION picks the release. RYSTIC_SHA256, the sha256 of this
# platform's archive, pins its bytes and needs RYSTIC_VERSION set.
ARG RYSTIC_VERSION=latest
ARG RYSTIC_SHA256=

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl jq \
 && rm -rf /var/lib/apt/lists/*

RUN set -eu; \
    if [ -n "$RYSTIC_SHA256" ] && [ "$RYSTIC_VERSION" = latest ]; then \
      echo "RYSTIC_SHA256 pins one archive: set RYSTIC_VERSION too" >&2; exit 1; \
    fi; \
    arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    rel="$(curl -fsSL "https://www.rystic.ai/api/cli-release?os=linux&arch=${arch}&version=${RYSTIC_VERSION}&source=docker")"; \
    url="$(printf '%s' "$rel" | jq -er .url)"; \
    named="$(printf '%s' "$rel" | jq -er .sha256)"; \
    sum="$(printf '%s' "${RYSTIC_SHA256:-$named}" | tr 'A-Z' 'a-z')"; \
    if [ "$sum" != "$named" ]; then \
      echo "RYSTIC_SHA256 is $sum but the release names $named" >&2; exit 1; \
    fi; \
    curl -fsSL "$url" -o /tmp/rystic.tar.gz; \
    printf '%s  /tmp/rystic.tar.gz\n' "$sum" | sha256sum -c -; \
    tar -xzf /tmp/rystic.tar.gz -C /usr/local/bin rystic; \
    rm /tmp/rystic.tar.gz; \
    rystic version

RUN useradd --create-home rystic
USER rystic
WORKDIR /home/rystic

ENTRYPOINT ["rystic", "mcp"]
