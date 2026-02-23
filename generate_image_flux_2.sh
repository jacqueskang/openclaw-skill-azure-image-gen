#!/usr/bin/env bash
set -euo pipefail

# generate_image_flux_2.sh
# Usage: ./generate_image_flux_2.sh "a prompt" [output.png]
# Targets Flux 2 provider URL shape documented by the user:
# https://${FOUNDRY_NAME}.services.ai.azure.com/providers/blackforestlabs/v1/flux-2-pro?api-version=preview

# If a `.env` file exists in the repo root, export its values so the script picks up `FOUNDRY_*` automatically.
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1090
  source .env
  set +a
fi

PROMPT="${1:-${PROMPT:-a red fox}}"
OUT_FILE="${2:-generated_image.png}"

FOUNDRY_NAME="${FOUNDRY_NAME:-}"
FOUNDRY_API_KEY="${FOUNDRY_API_KEY:-}"
FOUNDRY_DEPLOYMENT="${FOUNDRY_DEPLOYMENT:-FLUX.2-pro}"

err() { echo "$@" >&2; exit 1; }

for cmd in curl jq base64; do
  command -v "$cmd" >/dev/null 2>&1 || err "missing required command: $cmd"
done

[ -n "$FOUNDRY_NAME" ] || err "FOUNDRY_NAME is not set (used to build .services.ai.azure.com URL)"
[ -n "$FOUNDRY_API_KEY" ] || err "FOUNDRY_API_KEY is not set"

FOUNDRY_HOST="https://${FOUNDRY_NAME}.services.ai.azure.com"
URL="$FOUNDRY_HOST/providers/blackforestlabs/v1/flux-2-pro?api-version=preview"
echo "Using URL: $URL"

mkdir -p output

# Build payload and POST
jq -n --arg prompt "$PROMPT" "{prompt:\$prompt, n:1, size:\"1024x1024\", output_format:\"png\", model:\"${FOUNDRY_DEPLOYMENT}\"}" | \
  curl --fail --show-error --silent \
    --url "$URL" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer ${FOUNDRY_API_KEY}" \
    --data-binary @- -o output/generation_result_flux2.json

# Extract base64 image and write
jq -r '.data[0].b64_json' output/generation_result_flux2.json | base64 --decode > "$OUT_FILE"
echo "Image saved to: $OUT_FILE"
