"""
Simple CSV seeder for WorkHubz hubs.
Useful for initial bootstrap before the full Bing + Firecrawl pipeline is running.

CSV format expected (headers):
name,neighborhood,address,description,price_hourly,phone,whatsapp,email,website,amenities,rating

amenities column: comma-separated like "wifi,parking,quiet"
"""

import csv
import sys
import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

def seed_from_csv(csv_path: str, dry_run: bool = False):
    supabase = create_client(
        os.getenv("SUPABASE_URL"),
        os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    )

    with open(csv_path, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            hub = {
                "name": row["name"],
                "neighborhood": row["neighborhood"].lower().strip(),
                "address": row.get("address"),
                "description": row.get("description"),
                "price_hourly": float(row["price_hourly"]) if row.get("price_hourly") else None,
                "rating": float(row.get("rating", 0)) if row.get("rating") else 0,
            }

            if dry_run:
                print(f"[DRY] Would insert: {hub['name']}")
                continue

            try:
                res = supabase.table("hubs").upsert(hub, on_conflict="name,neighborhood").execute()
                hub_id = res.data[0]["id"]

                # Contacts
                contact = {
                    "hub_id": hub_id,
                    "phone": row.get("phone"),
                    "whatsapp": row.get("whatsapp"),
                    "email": row.get("email"),
                    "website": row.get("website"),
                }
                contact = {k: v for k, v in contact.items() if v}
                if contact:
                    supabase.table("hub_contacts").upsert(contact, on_conflict="hub_id").execute()

                # Amenities
                amenities_str = row.get("amenities", "")
                if amenities_str:
                    amenities = [a.strip() for a in amenities_str.split(",") if a.strip()]
                    amenity_rows = [{"hub_id": hub_id, "amenity_id": a} for a in amenities]
                    supabase.table("hub_amenities").upsert(amenity_rows, on_conflict="hub_id,amenity_id").execute()

                print(f"✓ Seeded: {hub['name']}")
            except Exception as e:
                print(f"✗ Failed {hub['name']}: {e}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python seed_from_csv.py path/to/hubs.csv [--dry-run]")
        sys.exit(1)

    csv_file = sys.argv[1]
    dry = "--dry-run" in sys.argv
    seed_from_csv(csv_file, dry_run=dry)