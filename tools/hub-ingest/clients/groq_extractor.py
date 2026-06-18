"""
Groq LLM Extractor for WorkHubz Hub Pipeline
"""

import json
from groq import Groq
from pydantic import ValidationError
from schemas.hub_schema import HubExtracted
from typing import Optional

SYSTEM_PROMPT = """You are an expert data extraction assistant for coworking spaces and hubs in Nairobi.

Extract structured data from the markdown content. Return ONLY a JSON object with these exact fields:
{
  "name": "string (required: official name of the coworking space)",
  "description": "string or null",
  "address": "string or null",
  "latitude": "number or null (extract from page content, maps, footer, or address if possible; prioritize explicit coords)",
  "longitude": "number or null (extract from page content, maps, footer, or address if possible; prioritize explicit coords)",
  "price_hourly": "number or null (in KES; parse from rates, pricing sections, or descriptions; convert if needed)",
  "price_daily": "number or null (in KES; parse from rates, pricing sections, or descriptions; convert if needed)",
  "price_monthly": "number or null (in KES; parse from rates, pricing sections, or descriptions; convert if needed)",
  "phone": "string or null",
  "whatsapp": "string or null",
  "email": "string or null",
  "website": "string or null",
  "rating": "number (0-5) or null",
  "amenities": ["array of amenity ids from: wifi, power_outlets, parking, ac, quiet, backup, food, cctv, meeting_rooms, printing, kitchen, lounge"],
  "external_id": "string or null"
}

Rules:
- name is REQUIRED - every coworking space has a name
- If the page lists MULTIPLE spaces, return only the MOST PROMINENT one
- amenities must be an array of strings, NOT an object/dict
- Be aggressive but accurate on latitude/longitude and prices: look in text, JSON-LD, addresses, contact sections; if address given, note it but prefer coords; prices often listed as 'KES X per hour' etc.
- Be conservative: omit uncertain fields (use null)
- Return ONLY valid JSON, no markdown, no explanation"""

USER_PROMPT_TEMPLATE = """Extract coworking/hub information from the following Markdown.

Source URL: {source_url}

Markdown Content:
{markdown}
"""

class GroqExtractor:
    def __init__(self, api_key: str, model: str = "llama-3.3-70b-versatile"):
        self.client = Groq(api_key=api_key)
        self.model = model

    def _normalize(self, data: dict) -> dict:
        """Handle common LLM output variations."""
        # If model nested data under a key like 'coworking_spaces', extract first item
        for key in ("coworking_spaces", "spaces", "hubs", "results", "items"):
            if key in data and isinstance(data[key], list) and len(data[key]) > 0:
                data = data[key][0]
                break

        # Normalize amenities: dict -> list of enabled keys
        if isinstance(data.get("amenities"), dict):
            data["amenities"] = [k for k, v in data["amenities"].items() if v]

        # Normalize prices if they came as strings or ranges (take first number)
        for pkey in ("price_hourly", "price_daily", "price_monthly"):
            val = data.get(pkey)
            if isinstance(val, str):
                import re
                nums = re.findall(r"[\d.]+", val)
                if nums:
                    try:
                        data[pkey] = float(nums[0])
                    except:
                        data[pkey] = None
            elif isinstance(val, (int, float)) and val > 100000:  # cap obvious errors
                data[pkey] = None

        return data

    def extract(
        self, 
        markdown: str, 
        neighborhood: str, 
        source_url: Optional[str] = None
    ) -> Optional[dict]:
        prompt = USER_PROMPT_TEMPLATE.format(
            markdown=markdown[:12000],
            source_url=source_url or "unknown"
        )

        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.1,
                max_tokens=1500,
                response_format={"type": "json_object"},
            )

            data = json.loads(response.choices[0].message.content)
            data = self._normalize(data)
            data["neighborhood"] = neighborhood
            data["source_url"] = source_url

            hub = HubExtracted.model_validate(data)
            return hub.model_dump(exclude_none=True)

        except (json.JSONDecodeError, ValidationError, Exception) as e:
            print(f"[GroqExtractor] Extraction failed: {e}")
            return None


if __name__ == "__main__":
    import os
    from dotenv import load_dotenv
    load_dotenv()

    extractor = GroqExtractor(
        api_key=os.getenv("GROQ_API_KEY"),
        model=os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile")
    )

    sample = """
    # WeWork Westlands
    Beautiful coworking space in the heart of Westlands.
    Fast WiFi, meeting rooms, 24/7 access.
    Contact: +254 712 345 678 | hello@wework.co.ke
    Rates: KSh 1,200 per day
    """

    result = extractor.extract(markdown=sample, neighborhood="westlands", source_url="https://example.com")
    print(result)
