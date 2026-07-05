#!/bin/bash
#
# Validate proxies/nginx/nginx.conf against the exact NGINX image version that the
# Dockerfile pins, using `nginx -t`. Run by pre-commit and CI.
#
# Requires Docker.

set -euo pipefail

cd "$(dirname "$0")/../.." # repo root

DOCKERFILE=proxies/nginx/Dockerfile
CONF=proxies/nginx/nginx.conf

# Read the pinned version from the Dockerfile's ARG NGINX_VERSION=... line.
VERSION=$(grep -E '^ARG NGINX_VERSION=' "$DOCKERFILE" | head -1 | cut -d= -f2)
IMAGE="public.ecr.aws/nginx/nginx:${VERSION}-alpine"

echo "Validating $CONF against $IMAGE ..."

# Pull with retries to tolerate registry rate limiting.
pull_ok=false
for attempt in 1 2 3 4 5; do
  if docker pull "$IMAGE"; then
    pull_ok=true
    break
  fi
  echo "docker pull failed (attempt $attempt). Likely a registry rate limit; retrying in $((attempt * 15))s..."
  sleep $((attempt * 15))
done
if [ "$pull_ok" != "true" ]; then
  echo "ERROR: could not pull $IMAGE after retries."
  exit 1
fi

# Mount the config and run nginx -t. The stream module is built into the image, so
# this also confirms the config (which uses stream) loads without load_module.
docker run --rm -v "$(pwd)/${CONF}:/etc/nginx/nginx.conf:ro" "$IMAGE" nginx -t
