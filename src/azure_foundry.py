import os
import base64
from typing import Optional, Union

def _scan_for_base64(obj):
    if isinstance(obj, str):
        s = obj.strip()
        if s.startswith('iVBOR') or s.startswith('/9j/'):
            try:
                return base64.b64decode(s)
            except Exception:
                return None
        return None
    if isinstance(obj, dict):
        for v in obj.values():
            r = _scan_for_base64(v)
            if r:
                return r
    if isinstance(obj, list):
        for v in obj:
            r = _scan_for_base64(v)
            if r:
                return r
    return None

def generate_image(prompt: str,
                   deployment: Optional[str] = None,
                   endpoint: Optional[str] = None,
                   api_key: Optional[str] = None,
                   size: str = "1024x1024",
                   timeout: int = 60) -> Union[bytes, str, dict]:
    endpoint = endpoint or os.getenv("FOUNDRY_ENDPOINT")
    api_key = api_key or os.getenv("FOUNDRY_API_KEY")
    deployment = deployment or os.getenv("FOUNDRY_DEPLOYMENT")

    if not endpoint or not api_key or not deployment:
        raise ValueError("FOUNDRY_ENDPOINT, FOUNDRY_API_KEY and FOUNDRY_DEPLOYMENT are required")

    api_version = os.getenv("FOUNDRY_API_VERSION", "2025-04-01-preview")
    url = endpoint.rstrip('/') + f'/openai/deployments/{deployment}/images/generations?api-version={api_version}'

    import requests

    headers = {'Content-Type': 'application/json', 'api-key': api_key}
    payload = {'prompt': prompt, 'size': size}

    resp = requests.post(url, headers=headers, json=payload, timeout=timeout)
    resp.raise_for_status()

    content_type = resp.headers.get('Content-Type', '')
    if content_type.startswith('image/'):
        return resp.content

    try:
        j = resp.json()
    except ValueError:
        return resp.content

    if isinstance(j, dict):
        data = j.get('data') or j.get('images') or j.get('result') or j.get('results')
        if isinstance(data, list) and data:
            first = data[0]
            if isinstance(first, dict):
                b64 = first.get('b64_json') or first.get('b64') or first.get('b64_image') or first.get('image_base64')
                if b64:
                    return base64.b64decode(b64)
                url_field = first.get('url') or first.get('image_url') or first.get('image')
                if url_field:
                    return url_field

        found = _scan_for_base64(j)
        if found:
            return found

        if 'url' in j:
            return j['url']

    return j
