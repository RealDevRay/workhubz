"""
SerpAPI Search Client (replaces retired Bing Search API)
"""

import requests
from typing import List

class BingSearchClient:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.endpoint = "https://serpapi.com/search"

    def search(self, query: str, count: int = 15) -> List[str]:
        if not self.api_key or self.api_key == "YOUR_SERPAPI_KEY_HERE":
            print("[Search] No valid SerpAPI key. Returning demo URLs.")
            return self._demo_urls(query)

        params = {
            "q": query,
            "api_key": self.api_key,
            "num": min(count, 20),
            "location": "Nairobi,Kenya",
            "hl": "en",
            "gl": "ke",
            "engine": "google",
        }

        try:
            resp = requests.get(self.endpoint, params=params, timeout=15)
            resp.raise_for_status()
            data = resp.json()
            return [item["link"] for item in data.get("organic_results", []) if "link" in item]
        except Exception as e:
            print(f"[Search] SerpAPI failed: {e}")
            return self._demo_urls(query)

    def _demo_urls(self, query: str) -> List[str]:
        return [
            "https://example.com/wework-westlands",
            "https://example.com/kilimani-hub",
            "https://example.com/nairobi-coworking-cbd",
        ]
