# WorkHubz - Supabase + Data Pipeline Setup (First Delivery)

This document explains how to get the new branded Discover experience + real data pipeline working.

## 1. Publish the Supabase Schema

1. Go to your Supabase project: https://srrqhcltnhxdkkeqdsxh.supabase.co
2. Open the SQL Editor.
3. Copy the entire content of `supabase/schema/001_hubs.sql` and run it.
4. Verify the tables `hubs`, `hub_contacts`, `hub_amenities`, etc. were created.

## 2. Set Up the Python Pipeline (Inside the Repo)

```bash
cd tools/hub-ingest
cp .env.example .env
```

Edit `.env` and add:
- Your Groq API key
- Supabase Service Role Key (for writing data)

Install dependencies:
```bash
pip install -r requirements.txt
```

## 3. Seed Some Data (Recommended First Step)

**Option A - Quick manual seed (recommended to start)**
Create a small CSV and run:
```bash
python seed/seed_from_csv.py path/to/your-seed.csv
```

**Option B - Try the full pipeline**
```bash
python main.py --neighborhood kilimani,westlands,cbd --dry-run
```

Once you're happy, remove `--dry-run` to actually write to Supabase.

### Re-seed for better geo/prices (recommended after prompt improvements)
The Groq extraction prompt has been enhanced to better pull latitude/longitude (from content, addresses, etc.) and accurate prices.

To re-seed with improved data:
```bash
# Dry run first to inspect
python main.py --neighborhood all --dry-run --limit 10

# Then full re-seed (will upsert, dedup by name+neighborhood)
python main.py --neighborhood all
```

This will improve map markers (geo) and pricing display in Discover/Map. Run selectively if you want to preserve some data.

## 4. Run the Flutter App

```bash
flutter pub get
flutter run
```

You should now experience:
- Branded location chooser on first launch
- Beautiful neighborhood grid
- Discover screen as the main home (with real data once seeded)
- "Change area" button in the app bar
- Map demoted to "Locator" tab

## Important Security Notes

- Never commit real keys (the `.env` file is gitignored in the pipeline folder).
- The Flutter app only uses the **anon** key.
- The Python pipeline uses the **service role** key (keep it secret).

## Recommended Model on Groq
`llama-3.1-70b-versatile` (already default in the code).

## Next Milestones (after this first delivery)
- Better LLM prompt engineering + deduplication
- Scheduled runs (GitHub Actions)
- Richer Discover UI with images, filters, etc.
- Owner claim flow using Supabase Auth

Good luck! This gives you a strong foundation for a premium, data-driven WorkHubz experience.