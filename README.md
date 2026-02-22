# OpenClaw Azure Foundry Image Skill

This repository contains a minimal OpenClaw skill scaffold to generate images using a Microsoft Foundry-deployed model.

Setup

- Create a virtualenv and install dependencies:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

- Configure environment variables (see `.env.example`):

  - `FOUNDRY_ENDPOINT` — base URL for your Foundry deployment
  - `FOUNDRY_API_KEY` — API key / bearer token
  - `FOUNDRY_DEPLOYMENT` — deployment name to call

Usage

- Quick CLI test:

```bash
FOUNDRY_ENDPOINT=https://your-foundry.example.com \
FOUNDRY_API_KEY=xxxx FOUNDRY_DEPLOYMENT=some-deployment \
python skill.py "A photorealistic painting of a red fox"
```

The CLI prints JSON. If an image is returned as base64, the `image_base64` field will be present. If the service returns a hosted URL, `image_url` will be present.
