"""
Supabase Writer for WorkHubz Hub Pipeline
Uses service role key (bypasses RLS).
Hits Supabase REST API directly — no heavy SDK dependencies.
"""

import httpx
from typing import Optional, Dict, Any

SUPABASE_REST_URL = "{}/rest/v1/{}"

class SupabaseWriter:
    def __init__(self, url: str, service_key: str, dry_run: bool = False):
        self.headers = {
            "apikey": service_key,
            "Authorization": f"Bearer {service_key}",
            "Content-Type": "application/json",
            "Prefer": "return=representation",
        }
        self.rest_url = f"{url}/rest/v1"
        self.dry_run = dry_run

    def upsert_hub(self, hub_data: Dict[str, Any]) -> Optional[str]:
        if self.dry_run:
            print(f"[DRY RUN] Would upsert: {hub_data.get('name')}")
            return "dry-run-id"

        try:
            # 1. Upsert main hub record
            hub_payload = {
                "name": hub_data.get("name"),
                "neighborhood": hub_data.get("neighborhood"),
                "address": hub_data.get("address"),
                "description": hub_data.get("description"),
                "latitude": hub_data.get("latitude"),
                "longitude": hub_data.get("longitude"),
                "price_hourly": hub_data.get("price_hourly"),
                "price_daily": hub_data.get("price_daily"),
                "price_monthly": hub_data.get("price_monthly"),
                "rating": hub_data.get("rating"),
                "is_verified": hub_data.get("is_verified", False),
                "source": "pipeline",
                "external_id": hub_data.get("external_id"),
                "source_url": hub_data.get("source_url"),
            }
            hub_payload = {k: v for k, v in hub_payload.items() if v is not None}

            # Try upsert with on_conflict (requires unique constraint)
            resp = httpx.post(
                f"{self.rest_url}/hubs",
                headers={
                    **self.headers,
                    "Prefer": "resolution=merge-duplicates,return=representation",
                },
                params={"on_conflict": "name,neighborhood"},
                json=hub_payload,
                timeout=15,
            )

            # Fallback: if unique constraint missing or column missing, retry clean
            if resp.status_code >= 400:
                clean = {k: v for k, v in hub_payload.items() if k not in ("source_url",)}
                resp = httpx.post(
                    f"{self.rest_url}/hubs",
                    headers={k: v for k, v in self.headers.items() if "resolution" not in k},
                    json=clean,
                    timeout=15,
                )

            resp.raise_for_status()
            data = resp.json()
            if not data:
                print("[SupabaseWriter] Failed to upsert hub")
                return None
            hub_id = data[0]["id"]

            # 2. Upsert contacts
            contact_payload = {
                "hub_id": hub_id,
                "phone": hub_data.get("phone"),
                "whatsapp": hub_data.get("whatsapp"),
                "email": hub_data.get("email"),
                "website": hub_data.get("website"),
            }
            contact_payload = {k: v for k, v in contact_payload.items() if v is not None}
            if contact_payload:
                httpx.post(
                    f"{self.rest_url}/hub_contacts",
                    headers={
                        **self.headers,
                        "Prefer": "resolution=merge-duplicates,return=minimal",
                    },
                    params={"on_conflict": "hub_id"},
                    json=contact_payload,
                    timeout=15,
                )

            # 3. Upsert amenities
            amenities = hub_data.get("amenities", [])
            if amenities:
                amenity_rows = [
                    {"hub_id": hub_id, "amenity_id": a}
                    for a in amenities if isinstance(a, str)
                ]
                if amenity_rows:
                    httpx.post(
                        f"{self.rest_url}/hub_amenities",
                        headers={
                            **self.headers,
                            "Prefer": "resolution=merge-duplicates,return=minimal",
                        },
                        params={"on_conflict": "hub_id,amenity_id"},
                        json=amenity_rows,
                        timeout=15,
                    )

            return hub_id

        except Exception as e:
            print(f"[SupabaseWriter] Error: {e}")
            raise
