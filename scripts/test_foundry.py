#!/usr/bin/env python3
import sys
import os
import pathlib
import argparse
import azure_foundry

from dotenv import load_dotenv

# Prefer loading sources from `src/` during development; fall back to `dist/` for packaged copies
ROOT = str(pathlib.Path(__file__).resolve().parents[1])
SRC_DIR = str(pathlib.Path(ROOT) / 'src')
if os.path.isdir(SRC_DIR):
    if SRC_DIR not in sys.path:
        sys.path.insert(0, SRC_DIR)



def main():
    load_dotenv()
    p = argparse.ArgumentParser(description='Call Foundry image generation using env from .env')
    p.add_argument('--endpoint', '-e', help='Endpoint URL (overrides FOUNDRY_ENDPOINT)')
    p.add_argument('--api-key', '-k', help='API key (overrides FOUNDRY_API_KEY)')
    p.add_argument('--prompt', '-p', default='A photorealistic red fox portrait')
    p.add_argument('--out', '-o', default='out.png')
    p.add_argument('--size', '-s', default=None)
    args = p.parse_args()

    endpoint = args.endpoint or os.getenv('FOUNDRY_ENDPOINT')
    api_key = args.api_key or os.getenv('FOUNDRY_API_KEY')
    deployment = os.getenv('FOUNDRY_DEPLOYMENT')
    size = args.size or os.getenv('FOUNDRY_SIZE') or '1024x1024'

    if not endpoint or not api_key or not deployment:
        print('Missing endpoint, api key, or deployment. Set FOUNDRY_ENDPOINT, FOUNDRY_API_KEY and FOUNDRY_DEPLOYMENT in .env or pass via flags.')
        sys.exit(2)

    try:
        res = azure_foundry.generate_image(prompt=args.prompt, endpoint=endpoint, api_key=api_key, deployment=deployment, size=size)
    except Exception as e:
        print('Request failed:', e)
        # If the exception has a requests.Response, show status and body for debugging
        resp = getattr(e, 'response', None)
        if resp is not None:
            try:
                print('Status:', resp.status_code)
                print('Body:', resp.text)
            except Exception:
                pass
        sys.exit(2)

    if isinstance(res, bytes):
        with open(args.out, 'wb') as f:
            f.write(res)
        print('Wrote image to', args.out)
        return

    if isinstance(res, str):
        print('Image URL:', res)
        return

    import json
    print(json.dumps(res, indent=2))


if __name__ == '__main__':
    import os
    main()
