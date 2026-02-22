import json
import base64
from typing import Any, Dict

import azure_foundry


def handle_request(payload: Dict[str, Any]) -> Dict[str, Any]:
    prompt = payload.get('prompt') or payload.get('text')
    if not prompt:
        return {'error': 'missing prompt'}

    result = azure_foundry.generate_image(prompt)

    if isinstance(result, bytes):
        return {'image_base64': base64.b64encode(result).decode('utf-8')}
    if isinstance(result, str):
        return {'image_url': result}
    return {'result': result}
