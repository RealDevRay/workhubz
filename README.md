# WorkHubz

Find and book affordable workspaces in Nairobi.

## Security-first setup

This repository is configured to keep secrets out of version control.

### 1) App runtime config

1. Copy `.env.example` to `.env`
2. Fill in real values:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - Optional: `GROQ_API_KEY`, `MPESA_CONSUMER_KEY`, `MPESA_CONSUMER_SECRET`, `MPESA_PASSKEY`

> `.env` is gitignored.

### 2) Android Google Maps key

1. Copy `android/local.properties.example` into `android/local.properties`
2. Set:
   - `MAPS_API_KEY=...`

`android/local.properties` is gitignored and used to inject `${MAPS_API_KEY}` at build time.

## Run and build

### PowerShell helper (recommended)

```powershell
# Run on device/emulator (debug)
.\scripts\build.ps1 -Run

# Build debug APK
.\scripts\build.ps1

# Build release APK
.\scripts\build.ps1 -Release
```

### Manual flutter command

```bash
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

## CI/CD (GitHub Actions)

This repo includes:

- `.github/workflows/ci.yml`
  - Secret scan (gitleaks)
  - Format check
  - Static analysis
  - Tests
- `.github/workflows/android-build.yml`
  - Builds release APK
  - Uploads APK artifact

### Configure repository secrets

In **GitHub → Settings → Secrets and variables → Actions**, set:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `MAPS_API_KEY`
- `GROQ_API_KEY` (optional)
- `MPESA_CONSUMER_KEY` (optional)
- `MPESA_CONSUMER_SECRET` (optional)
- `MPESA_PASSKEY` (optional)

If optional secrets are not set, CI still runs and Android build uses placeholders.

## Production deployment checklist

- Do not commit `.env`, `android/local.properties`, or any key files.
- Restrict Google Maps API key by package name and SHA-1/SHA-256.
- Use least-privilege Supabase keys (app uses anon key only).
- Keep M-Pesa credentials in CI/CD secrets or local env.
- Rotate any key that was previously committed.
