#!/usr/bin/env bash
set -euo pipefail

# Creates a Python virtualenv in `.venv` and installs dependencies.
# Prefers `requirements.txt` in the repo root, falls back to `dist/requirements.txt`.

ROOT="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$ROOT/.venv"

REQ_FILE="$ROOT/requirements.txt"

if [ ! -f "$REQ_FILE" ]; then
  echo "No requirements.txt found in root" >&2
  exit 1
fi

echo "Creating virtualenv at $VENV_DIR"
python3 -m venv "$VENV_DIR"

echo "Upgrading pip and installing wheels..."
"$VENV_DIR/bin/python" -m pip install --upgrade pip setuptools wheel

echo "Installing dependencies from $REQ_FILE"
"$VENV_DIR/bin/python" -m pip install -r "$REQ_FILE"

echo "Done. Activate with: source $VENV_DIR/bin/activate"
