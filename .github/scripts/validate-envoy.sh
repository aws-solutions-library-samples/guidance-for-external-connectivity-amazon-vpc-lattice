#!/bin/bash
#
# Validate proxies/envoy/envoy.yaml against the exact Envoy image version that the
# Dockerfile pins, using `envoy --mode validate`. Run by pre-commit and CI.
#
# The Envoy base image is on Docker Hub (no ECR Public mirror), which can hit
# anonymous pull-rate limits, so the pull is retried a few times.
#
# Requires Docker.

set -euo pipefail

cd "$(dirname "$0")/../.." # repo root

DOCKERFILE=proxies/envoy/Dockerfile
CONF=proxies/envoy/envoy.yaml

# Read the pinned version from the Dockerfile's ARG ENVOY_VERSION=... line.
VERSION=$(grep -E '^ARG ENVOY_VERSION=' "$DOCKERFILE" | head -1 | cut -d= -f2)
IMAGE="envoyproxy/envoy:${VERSION}"

# Pull with retries to tolerate Docker Hub rate limiting.
pull_ok=false
for attempt in 1 2 3 4 5; do
  if docker pull "$IMAGE"; then
    pull_ok=true
    break
  fi
  echo "docker pull failed (attempt $attempt). Likely a Docker Hub rate limit; retrying in $((attempt * 15))s..."
  sleep $((attempt * 15))
done
if [ "$pull_ok" != "true" ]; then
  echo "ERROR: could not pull $IMAGE after retries (Docker Hub rate limit?)."
  exit 1
fi

echo "Validating $CONF against $IMAGE ..."
docker run --rm -v "$(pwd)/${CONF}:/etc/envoy/envoy.yaml:ro" "$IMAGE" \
  envoy -c /etc/envoy/envoy.yaml --mode validate
