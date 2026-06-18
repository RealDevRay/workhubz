# WorkHubz

Find and book affordable workspaces in Nairobi.

---

## What this project includes

- Flutter mobile app for workspace discovery and booking
- Supabase-backed data access
- Google Maps integration
- Static marketing website for early access (`website/`)

---

## Tech stack

- **Flutter** `3.44.2`
- **Dart** `3.12.x`
- **State management:** Riverpod
- **Backend:** Supabase
- **Networking:** Dio
- **Maps:** google_maps_flutter

---

## Prerequisites

- Flutter SDK installed
- Android SDK / Android Studio
- Java 17
- PowerShell (for helper script on Windows)

---

## Local setup

### 1) Clone

```bash
git clone https://github.com/RealDevRay/workhubz.git
cd workhubz
```

### 2) App runtime config

Copy `.env.example` to `.env` and fill values:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- Optional: `GROQ_API_KEY`, `MPESA_CONSUMER_KEY`, `MPESA_CONSUMER_SECRET`, `MPESA_PASSKEY`

> `.env` is gitignored.

### 3) Android Maps key

Copy `android/local.properties.example` to `android/local.properties` and set:

```properties
MAPS_API_KEY=your_google_maps_api_key
```

`android/local.properties` is gitignored and used via manifest placeholder.

### 4) Install dependencies

```bash
flutter pub get
```

---

## Run and build

### PowerShell helper (recommended)

```powershell
# Run app (debug)
.\scripts\build.ps1 -Run

# Build debug APK
.\scripts\build.ps1

# Build release APK
.\scripts\build.ps1 -Release
```

### Manual

```bash
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

---

## Website / Marketing page

A public landing page is included in this repo at `website/`.

It includes:

- Product overview
- Android early-access CTA
- Automatic latest-APK linking from GitHub Releases
- iOS waitlist CTA

### Deploy to Vercel

1. Import this GitHub repo in Vercel.
2. Set **Root Directory** to `website`.
3. Framework preset: **Other**.
4. Build command: empty.
5. Output directory: empty.
6. Deploy.

See `website/README.md` for details.

---

## Notes

- Repository CI/CD workflows were intentionally removed.
- If you want automated checks/releases again later, we can reintroduce them in a simplified form.

---

## License

Add your preferred license (MIT, Apache-2.0, proprietary, etc.).
