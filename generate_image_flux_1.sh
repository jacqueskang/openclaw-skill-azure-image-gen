#!/usr/bin/env bash
set -euo pipefail

# generate_image.sh — implementation matching SKILL.md
# Usage: ./generate_image.sh "a red fox" [output.png]
# Requires: curl, jq, base64 and env vars FOUNDRY_ENDPOINT, FOUNDRY_API_KEY, FOUNDRY_DEPLOYMENT

# If a `.env` file exists in the repo root, export its values so the script
# picks up `FOUNDRY_*` automatically.
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1090
  source .env
  set +a
fi

# Prompt precedence: CLI arg -> env `PROMPT` -> default
PROMPT="${1:-${PROMPT:-a red fox}}"
OUT_FILE="output/${2:-generated_image.png}"

FOUNDRY_NAME="${FOUNDRY_NAME:-}"
FOUNDRY_API_KEY="${FOUNDRY_API_KEY:-}"
FOUNDRY_DEPLOYMENT="${FOUNDRY_DEPLOYMENT:-FLUX-1.1-pro}"
FOUNDRY_API_VERSION="${FOUNDRY_API_VERSION:-2025-04-01-preview}"
FOUNDRY_ENDPOINT="https://${FOUNDRY_NAME}.cognitiveservices.azure.com/"

err() { echo "$@" >&2; exit 1; }

for cmd in curl jq base64; do
  command -v "$cmd" >/dev/null 2>&1 || err "missing required command: $cmd"
done


if [ -z "$PROMPT" ]; then
  if [ -t 0 ]; then
    echo "Usage: $0 \"prompt text\" [output.png]" >&2
    exit 2
  else
    PROMPT=$(cat -)
  fi
fi

if ! printf '%s' "${FOUNDRY_ENDPOINT}" | grep -Eq '^https?://[A-Za-z0-9._:-]+/?$'; then
  err "FOUNDRY_ENDPOINT looks unsafe or is not set"
fi
[ -n "${FOUNDRY_API_KEY}" ] || err "FOUNDRY_API_KEY is not set"
[ -n "${FOUNDRY_DEPLOYMENT}" ] || err "FOUNDRY_DEPLOYMENT is not set"

url="${FOUNDRY_ENDPOINT%/}/openai/deployments/${FOUNDRY_DEPLOYMENT}/images/generations?api-version=${FOUNDRY_API_VERSION}"

# Build JSON payload and POST (exactly as in SKILL.md)
jq -n --arg prompt "$PROMPT" '{prompt:$prompt, n:1, size:"1024x1024", output_format:"png"}' | \
  curl --fail --show-error --silent \
    --url "$url" \
    -H 'Content-Type: application/json' \
    -H "api-key: ${FOUNDRY_API_KEY}" \
    --data-binary @- -o output/generation_result.json

# Stream base64 payload to avoid storing large values in shell variables
jq -r '.data[0].b64_json' output/generation_result.json | base64 --decode > "$OUT_FILE"
echo "Image saved to: $OUT_FILE"
