# WorkHubz Website

Landing page for WorkHubz early access.

## Deploying to Vercel from this monorepo

1. Import repo in Vercel.
2. Set **Root Directory** to `website`.
3. Framework preset: **Other** (static site).
4. Build command: leave empty.
5. Output directory: leave empty.
6. Deploy.

The page automatically fetches the latest GitHub release and links the newest `.apk` asset.

## Local preview

Any static server works. Example with Python:

```bash
cd website
python -m http.server 8080
```

Open http://localhost:8080
