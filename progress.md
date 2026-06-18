# WorkHubz — Progress Report

*Last updated: June 3, 2026*

---

## ✅ Completed

### Infrastructure
- **Supabase** set up as sole backend (auth + database)
- **40+ hubs** originally ingested across 6 neighborhoods (kilimani, westlands, cbd, ngongRoad, karen, lavington)
- **40 more hubs** added across 7 more neighborhoods: ridgeways (5), muthaiga (5), hurlingham (1), upperHill (8), kitengela (9), mlolongo (6), thikaRoad (6)
- **Total: 80 hubs across 13 neighborhoods**
- Pipeline tooling: SerpAPI → Firecrawl → Groq (llama-3.1-8b-instant) → Supabase

### Database Schema (Supabase)
- `001_hubs.sql` — hubs, hub_contacts, hub_amenities, hub_photos, hub_scrape_logs, bookings + RLS + indexes + PostGIS
- `002_users.sql` — profiles, saved_spaces, reviews, payments + auto-create profile on signup trigger
- Public read access for anon key, service role only for writes

### Flutter App — Code Changes

#### Backend Migration
- Removed all Firebase dependencies (cloud_firestore, firebase_auth, firebase_messaging)
- Replaced Firestore `GeoPoint` with custom local `geo_point.dart` class (same API)
- `notification_service.dart` rewritten as Firebase-free stub
- Removed 49 unused packages from pubspec.yaml

#### Auth
- Switched from phone OTP to Google Sign-In (`signInWithOAuth(OAuthProvider.google)`)
- Deep link intent filter added: `io.supabase.flutter://callback`
- `phone_login_screen.dart` updated with Google Sign-In button

#### Navigation & Screens
- Onboarding routes to `/home` (bottom nav) instead of standalone `/discover`
- `HomeScreen` uses `IndexedStack` (preserves tab state) + Riverpod `tabIndexProvider`
- All 5 tabs functional: Discover, Locator, Search, Bookings, Profile
- `app_router.dart` — `/space/:id`, `/home`, `/phone-login`, `/onboarding-location`, `/booking-payment/:id` routes
- **Discover** — "Open Locator" switches to Map tab; hub tiles navigate to space detail
- **Search** — wired to real `searchSpacesProvider` with 300ms debounce (no more hardcoded mock data)
- **Bookings** — "Browse Spaces" navigates to Discover; Check In / Review / Rebook navigate to space detail
- **Profile** — Saved Spaces & Payment History wired to login flow

#### Data Layer
- **Pricing** — `price_daily` → `fullDayRate`, `price_monthly` → `weeklyRate`, `currency` all read from DB
- **Photos** — `hub_photos` join added to all space queries (hub_photos.url → photoUrls)
- `SpaceRepository` — all 5 query methods updated to include `hub_photos`

#### API & Services
- **M-Pesa** — Daraja STK Push fully integrated with proper OAuth token flow (`consumer_key:consumer_secret` → Basic Auth → Bearer token). Sandbox configuration included.
- `BookingPaymentScreen` built to collect phone, call STK push, poll for result, and create booking in Supabase.
- Supabase URL and anon key now loaded via `--dart-define`/`.env` only (no hardcoded runtime keys)

#### Build & Configuration
- **App icon** generated from branding assets (flutter_launcher_icons)
- **Google Maps API key** injected from `android/local.properties` (not committed)
- Script `scripts/build.ps1` with all `--dart-define` flags
- Build command: `flutter build apk --debug --android-skip-build-dependency-validation`

#### Code Quality
- 25 dart warnings fixed (unused imports, unreachable switch defaults)
- 0 analysis errors remaining.
- APK builds successfully with no errors

### Google Cloud Platform
- Maps SDK for Android enabled
- API key restricted to app + SHA-1 fingerprint
- OAuth 2.0 credentials created for Google Sign-In
- Supabase Google OAuth provider configured with Client ID + Secret

---

## 🚧 In Progress / Needs Attention

### Move to Production (M-Pesa)
- Switch `darajaBaseUrl` from `sandbox.safaricom.co.ke` to `api.safaricom.co.ke`
- Set up a real callback endpoint (Supabase Edge Function or webhook) instead of relying solely on client-side polling
- Obtain and configure production shortcode and passkey from Safaricom Daraja portal

---

## 📋 How to Run

```bash
# Debug (install & test)
.\scripts\build.ps1 -Run

# Debug APK (just build)
.\scripts\build.ps1

# Release APK
.\scripts\build.ps1 -Release
```

## 📊 Data Summary

| Neighborhood | Hubs |
|-------------|------|
| kitengela | 9 |
| karen | 8 |
| upperHill | 8 |
| cbd | 7 |
| kilimani | 7 |
| westlands | 7 |
| mlolongo | 6 |
| ngongRoad | 6 |
| thikaRoad | 6 |
| lavington | 5 |
| muthaiga | 5 |
| ridgeways | 5 |
| hurlingham | 1 |
| **Total** | **80** |

## 🔑 Key Configs

| Item | Value |
|------|-------|
| Supabase URL | `https://srrqhcltnhxdkkeqdsxh.supabase.co` |
| Anon Key | Injected via `.env` / `--dart-define` |
| Maps API Key | Injected via `android/local.properties` placeholder |
| OAuth Redirect | `io.supabase.flutter://callback` |
| Maps SHA-1 | `49:87:FA:6C:B1:45:2A:16:FD:9F:25:C8:23:69:67:6F:3F:64:B1:72` |
