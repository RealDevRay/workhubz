# WorkHubz

Find and book affordable workspaces in Nairobi.

---

## What this project includes

- Flutter mobile app for workspace discovery and booking
- Supabase-backed data access
- Google Maps integration
- CI/CD with GitHub Actions
- Signed Android release pipeline (`.apk` + `.aab`)

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

## CI/CD

### Workflows

- **CI**: `.github/workflows/ci.yml`
  - Gitleaks secret scan
  - Format check
  - Static analysis
  - Tests

- **Android Build**: `.github/workflows/android-build.yml`
  - Builds release APK
  - Uploads artifact

- **Release**: `.github/workflows/release.yml`
  - Builds signed release APK + AAB
  - Publishes GitHub Release
  - Trigger: `v*` tag push or manual dispatch

### Branch protection

`main` should require:

- `Secret Scan`
- `Flutter Quality`

See `docs/branch-protection.md` for full policy and CLI setup.

---

## GitHub Actions secrets

Set these in **GitHub → Settings → Secrets and variables → Actions**.

### Required (app/runtime)

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `MAPS_API_KEY`

### Required (signed release)

- `ANDROID_KEYSTORE_BASE64` (base64-encoded keystore)
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

### Optional

- `GROQ_API_KEY`
- `MPESA_CONSUMER_KEY`
- `MPESA_CONSUMER_SECRET`
- `MPESA_PASSKEY`

---

## Creating a signed release

### Option A: Tag push

```bash
git tag v1.0.3
git push origin v1.0.3
```

### Option B: Manual dispatch

```bash
gh workflow run Release -R RealDevRay/workhubz -f tag=v1.0.3 -f target_commitish=main -f prerelease=true
```

Release workflow outputs:

- `workhubz-vX.Y.Z.apk`
- `workhubz-vX.Y.Z.aab`

attached to a GitHub Release.

---

## Release troubleshooting

### 1) `validateSigningRelease` keystore not found

- Ensure workflow writes `android/key.properties` with:
  - `storeFile=release-keystore.jks`
- Ensure keystore is decoded to:
  - `android/app/release-keystore.jks`

### 2) Missing asset directories from `pubspec.yaml`

The following must exist in repo:

- `assets/images/`
- `assets/icons/`
- `assets/branding/`

(Placeholder `.gitkeep` files are valid.)

### 3) Duplicate manual release runs for same tag

Running workflow twice with same tag can cause one run to fail/skip release creation behavior. Prefer one run per tag.

### 4) Branch protection blocks direct push to `main`

Open a PR and merge after required checks pass.

---

## Security checklist

- Never commit `.env`, keystore, or key files.
- Restrict Maps API key by package + SHA fingerprints.
- Use Supabase anon key in app (not service role).
- Store all secrets only in GitHub Actions Secrets or local secure environment.
- Rotate any key exposed accidentally.

---

## Automated merge + release workflow (no manual GitHub UI)

### A) Auto PR + auto-merge

```powershell
.\scripts\auto-merge.ps1
```

What it does:

- Creates a PR from current branch to `main` (or reuses existing one)
- Enables **auto-merge (squash)**
- Deletes feature branch after merge

Optional args:

```powershell
.\scripts\auto-merge.ps1 -Repo "RealDevRay/workhubz" -Base "main" -Head "feature/your-branch" -Title "Your PR title"
```

### B) Auto PR + auto-merge + auto-release tag trigger (PowerShell)

```powershell
.\scripts\auto-merge-and-release.ps1
```

What it does:

1. Runs auto-merge flow (`auto-merge.ps1`)
2. Waits for PR merge completion
3. Computes next semantic tag by scanning remote tags (patch bump), e.g. `v1.0.2 -> v1.0.3`
4. Triggers `Release` workflow for the new tag

Useful flags:

```powershell
# Watch release run until done
.\scripts\auto-merge-and-release.ps1 -WatchRelease

# Mark release as stable (not prerelease)
.\scripts\auto-merge-and-release.ps1 -Prerelease:$false

# Custom repo/base/head
.\scripts\auto-merge-and-release.ps1 -Repo "RealDevRay/workhubz" -Base "main" -Head "feature/your-branch"
```

### C) One-click GitHub Action orchestration (`workflow_dispatch`)

Use workflow: `.github/workflows/orchestrate-merge-release.yml`

From GitHub UI:

1. Open **Actions** → **Orchestrate Merge and Release**
2. Click **Run workflow**
3. Provide:
   - `head_branch` (required)
   - `base_branch` (default `main`)
   - `prerelease` (`true`/`false`)
   - `tag_prefix` (default `v`)
   - `timeout_minutes`
   - `watch_release`

This performs PR creation/reuse, auto-merge enablement, merge wait, tag bump, and release trigger in one run.

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

## License

Add your preferred license (MIT, Apache-2.0, proprietary, etc.).
