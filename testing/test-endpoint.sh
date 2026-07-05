#!/bin/bash
#
# Test reachability to a VPC Lattice service through the proxy.
#
# Unsigned by default. Add --sign to send a SigV4-signed request, which is required
# when the VPC Lattice auth policy demands authenticated callers.
#
# Usage:
#   ./test-endpoint.sh <endpoint-url> [--sign] [--region <region>] [--profile <profile>]
#
# Examples:
#   ./test-endpoint.sh https://service.example.com
#   ./test-endpoint.sh https://service.example.com --sign --region eu-west-1
#   ./test-endpoint.sh https://service.example.com --sign --profile my-profile
#
# Credentials for --sign are resolved in this order:
#   1. --profile / the AWS credential chain (RECOMMENDED). Uses
#      `aws configure export-credentials`, which works with IAM roles, IAM Identity
#      Center (SSO), and other temporary credentials, and keeps secrets off the
#      command line. Pass --profile to choose a named profile.
#   2. AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (and optional AWS_SESSION_TOKEN)
#      environment variables, if you have already set them yourself.
#
# Security note: this script never accepts secret keys as command-line arguments,
# because arguments are visible in process listings and shell history. Prefer the
# credential chain (option 1); use environment variables only if you must.

set -euo pipefail

ENDPOINT=""
SIGN="false"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-}}"
PROFILE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --sign)
      SIGN="true"
      shift
      ;;
    --region)
      REGION="${2:-}"
      shift 2
      ;;
    --profile)
      PROFILE="${2:-}"
      shift 2
      ;;
    -h | --help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      ENDPOINT="$1"
      shift
      ;;
  esac
done

if [ -z "$ENDPOINT" ]; then
  echo "Usage: ./test-endpoint.sh <endpoint-url> [--sign] [--region <region>] [--profile <profile>]" >&2
  exit 1
fi

# ---- Unsigned request -------------------------------------------------------
if [ "$SIGN" != "true" ]; then
  echo "Unsigned request to $ENDPOINT"
  curl -4 -sS -D - "$ENDPOINT"
  exit 0
fi

# ---- Signed (SigV4) request -------------------------------------------------
if [ -z "$REGION" ]; then
  echo "ERROR: --sign requires a region. Pass --region <region> or set AWS_REGION." >&2
  exit 1
fi

# Resolve credentials: profile/credential chain first, then existing env vars.
if [ -n "$PROFILE" ]; then
  creds=$(aws configure export-credentials --format process --profile "$PROFILE" 2> /dev/null || true)
  if [ -z "$creds" ]; then
    echo "ERROR: could not export credentials for profile '$PROFILE'." >&2
    echo "       Check the profile (aws configure / aws sso login)." >&2
    exit 1
  fi
  AWS_ACCESS_KEY_ID=$(echo "$creds" | python3 -c "import sys,json;print(json.load(sys.stdin)['AccessKeyId'])")
  AWS_SECRET_ACCESS_KEY=$(echo "$creds" | python3 -c "import sys,json;print(json.load(sys.stdin)['SecretAccessKey'])")
  AWS_SESSION_TOKEN=$(echo "$creds" | python3 -c "import sys,json;print(json.load(sys.stdin).get('SessionToken',''))")
elif [ -n "${AWS_ACCESS_KEY_ID:-}" ] && [ -n "${AWS_SECRET_ACCESS_KEY:-}" ]; then
  : # use the AWS_* environment variables already set by the user
  AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN:-}"
else
  # Fall back to the default credential chain (default profile, role, etc.)
  creds=$(aws configure export-credentials --format process 2> /dev/null || true)
  if [ -z "$creds" ]; then
    echo "ERROR: no credentials found for signing." >&2
    echo "       Use --profile <profile>, run 'aws sso login', or set AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY." >&2
    exit 1
  fi
  AWS_ACCESS_KEY_ID=$(echo "$creds" | python3 -c "import sys,json;print(json.load(sys.stdin)['AccessKeyId'])")
  AWS_SECRET_ACCESS_KEY=$(echo "$creds" | python3 -c "import sys,json;print(json.load(sys.stdin)['SecretAccessKey'])")
  AWS_SESSION_TOKEN=$(echo "$creds" | python3 -c "import sys,json;print(json.load(sys.stdin).get('SessionToken',''))")
fi

# Session-token header is only needed for temporary credentials.
header_args=(--header "x-amz-content-sha256:UNSIGNED-PAYLOAD")
if [ -n "${AWS_SESSION_TOKEN:-}" ]; then
  header_args+=(--header "x-amz-security-token:${AWS_SESSION_TOKEN}")
fi

echo "Signed (SigV4) request to $ENDPOINT in $REGION"
curl -4 -sS -D - "$ENDPOINT" \
  --aws-sigv4 "aws:amz:${REGION}:vpc-lattice-svcs" \
  --user "${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}" \
  "${header_args[@]}"
