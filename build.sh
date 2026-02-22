#!/usr/bin/env bash
set -euo pipefail

# Build script: activate .venv, run the test script to generate an image into /output,
# then copy python sources from src/ into dist/.

ROOT="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$ROOT/.venv" ]; then
  echo ".venv not found. Run ./install.sh first." >&2
  exit 1
fi

echo "Activating .venv..."
# shellcheck source=/dev/null
source "$ROOT/.venv/bin/activate"

OUTDIR="$ROOT/output"
mkdir -p "$OUTDIR"

echo "Copying python sources from src/ to dist/"
mkdir -p "$ROOT/dist"
cp -v "$ROOT/src"/*.py "$ROOT/dist/" || true

# Copy manifest and SKILL.md from src if present
if [ -f "$ROOT/src/manifest.json" ]; then
  cp -v "$ROOT/src/manifest.json" "$ROOT/dist/"
fi
if [ -f "$ROOT/src/SKILL.md" ]; then
  cp -v "$ROOT/src/SKILL.md" "$ROOT/dist/"
fi

PROMPT=${1:-"A test image from build.sh"}
OUTFILE="$OUTDIR/skill_output.png"

echo "Running test script to generate image into $OUTFILE"
python3 scripts/test_foundry.py --prompt "$PROMPT" --out "$OUTFILE"

echo "Build complete. Output saved to $OUTFILE"
