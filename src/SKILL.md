# OpenClaw Skill: Azure Foundry Image Generation

Short description
- Generates images using a Microsoft Foundry / Azure-hosted image model (example: FLUX-1.1-pro).

Entry point
- `skill.handle_request` — accepts a JSON object with `prompt` (string) and returns either:
  - `{ "image_base64": "..." }` when image bytes are embedded, or
  - `{ "image_url": "https://..." }` when a hosted URL is returned, or
  - raw JSON from the provider for other shapes.

Runtime
- Python 3.10+ (the repository uses a small virtualenv in `.venv` for local testing).

Environment variables (required)
- `FOUNDRY_ENDPOINT` — Azure base URI, for example `https://<name>.cognitiveservices.azure.com/`
- `FOUNDRY_API_KEY` — API key to include in the `api-key` header
- `FOUNDRY_DEPLOYMENT` — deployment name (for example `FLUX-1.1-pro`)
- `FOUNDRY_API_VERSION` (optional) — API version to use; default `2025-04-01-preview`

Local test
1. Create and activate a virtualenv and install deps:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

2. Populate `.env` (or set env vars). Example values are included in `.env.example`.

3. Run the test script to call your deployment and save output:

```bash
python3 scripts/test_foundry.py --prompt "A red fox portrait" --out fox.png
```

Packaging notes
- The `dist` folder contains this `SKILL.md` for ClawHub publishing. Ensure `manifest.json` is present at repository root and contains the `entrypoint` and `env` fields.

License & attribution
- Add a `LICENSE` file in the repository before publishing if required by your organization.
