"""
WorkHubz Hub Ingestion Pipeline
Usage examples:
    python main.py --neighborhood kilimani,westlands --dry-run
    python main.py --neighborhood all
"""
import os
import argparse
import sys
from pathlib import Path
from dotenv import load_dotenv

# Ensure local clients package is importable when running main.py directly
sys.path.insert(0, str(Path(__file__).parent.resolve()))

from clients.firecrawl import FirecrawlClient
from clients.groq_extractor import GroqExtractor
from clients.supabase_writer import SupabaseWriter
from clients.bing_search import BingSearchClient

load_dotenv()

NAIROBI_NEIGHBORHOODS = [
    "kilimani", "westlands", "cbd", "ngongRoad", "karen",
    "lavington", "ridgeways", "muthaiga", "hurlingham", "upperHill"
]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--neighborhood", type=str, default="kilimani",
                        help="Comma-separated neighborhoods or 'all'")
    parser.add_argument("--dry-run", action="store_true",
                        help="Do not write to Supabase")
    parser.add_argument("--limit", type=int, default=15,
                        help="Max results per neighborhood")
    args = parser.parse_args()

    neighborhoods = NAIROBI_NEIGHBORHOODS if args.neighborhood == "all" else args.neighborhood.split(",")

    print(f"Starting hub ingestion for: {neighborhoods}")

    # Initialize clients (keys come from .env)
    # Note: Using SerpAPI (via the BingSearchClient wrapper for historical naming)
    bing = BingSearchClient(os.getenv("SERPAPI_API_KEY"))
    firecrawl = FirecrawlClient(os.getenv("FIRECRAWL_API_KEY"))
    extractor = GroqExtractor(
        api_key=os.getenv("GROQ_API_KEY"),
        model=os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile")
    )
    writer = SupabaseWriter(
        url=os.getenv("SUPABASE_URL"),
        service_key=os.getenv("SUPABASE_SERVICE_ROLE_KEY"),
        dry_run=args.dry_run
    )

    total_inserted = 0

    for neighborhood in neighborhoods:
        print(f"\n=== Processing: {neighborhood} ===")
        query = f"coworking spaces OR hubs OR shared office {neighborhood} Nairobi"
        urls = bing.search(query, count=args.limit)

        for url in urls:
            try:
                markdown = firecrawl.scrape(url)
                hub_data = extractor.extract(markdown, neighborhood=neighborhood, source_url=url)

                if hub_data:
                    writer.upsert_hub(hub_data)
                    total_inserted += 1
                    print(f"  [OK] {hub_data.get('name')}")
            except Exception as e:
                print(f"  [ERR] Error on {url}: {e}")

    print(f"\nDone. Total hubs processed this run: {total_inserted}")
    if args.dry_run:
        print("   (dry-run mode - nothing written to Supabase)")


if __name__ == "__main__":
    main()