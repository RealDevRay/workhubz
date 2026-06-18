"""
Firecrawl Client for WorkHubz Pipeline
"""

from firecrawl import FirecrawlApp
from typing import Optional

class FirecrawlClient:
    def __init__(self, api_key: str):
        self.app = FirecrawlApp(api_key=api_key)

    def scrape(self, url: str) -> Optional[str]:
        """
        Scrape a URL and return clean Markdown.
        """
        try:
            result = self.app.scrape_url(
                url,
                formats=['markdown'],
                only_main_content=True,
            )
            if isinstance(result, dict):
                return result.get('markdown', '')
            return str(result) if result else None
        except Exception as e:
            print(f"[Firecrawl] Failed to scrape {url}: {e}")
            return None