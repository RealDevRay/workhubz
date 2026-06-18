# WorkHubz Hub Ingestion Pipeline

This pipeline discovers, scrapes, extracts, and loads coworking / hub data for Nairobi into Supabase.

## Stack (as specified)
- Bing Web Search API (discovery)
- Firecrawl (JS rendering + clean Markdown)
- Groq (Llama 3.1 70B or Llama 4) for structured extraction
- Supabase (Postgres + PostGIS + Storage)

## Setup

1. Copy environment file:
   ```bash
   cp .env.example .env
   ```

2. Fill in the keys in `.env` (never commit this file):
   - `BING_API_KEY`
   - `FIRECRAWL_API_KEY` (provided)
   - `GROQ_API_KEY`
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY` (use service role for writes)

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

## Running

### Dry run (no writes)
```bash
python main.py --neighborhood kilimani,westlands --dry-run
```

### Real run (writes to Supabase)
```bash
python main.py --neighborhood kilimani,westlands,cbd
```

### One-time seed from CSV (fallback)
```bash
python seed/seed_from_csv.py path/to/hubs.csv
```

## Recommended First Run (v1)
Run for the top 5 neighborhoods to get 30-80 high-quality records.

## Model Choice (Groq)
We strongly recommend **`llama-3.1-70b-versatile`** (or `llama-3.3-70b-versatile` if available) for this extraction task.

It currently offers the best combination of speed + reliable structured JSON output on Groq.

Llama 4 models can be used if you have access — just set `GROQ_MODEL` in `.env`.

You can also pass `--model` when running the script.

## Re-seeding for Better Geo/Prices
Prompts and normalization in groq_extractor.py have been improved to extract better lat/lng (for map markers) and prices (for display).

Re-run with `python main.py --neighborhood all` (or specific) after changes to upsert improved data. Use --dry-run first. See SUPABASE_AND_PIPELINE_SETUP.md for details.

## Safety Notes
- This pipeline uses the **service role key** — it bypasses RLS.
- The Flutter app only ever uses the **anon key**.
- Do not run this from the mobile app.

## Next Improvements (after v1)
- GitHub Actions scheduled job
- Deduplication + freshness logic
- Better error handling + logging to `hub_scrape_logs` table
- Owner claim flow in the app (future)