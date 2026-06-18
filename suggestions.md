# WorkHubz Codebase — Improvement Suggestions

> Generated after a full scan of the `workspace_finder_nairobi` Flutter project.  
> Organised by severity. Tackle items in the order listed for the fastest path to a stable, shippable build.

---

## 🔴 Critical — Will Cause Compile or Runtime Crashes

### 1. Duplicate `MapExploreScreen` class
**Files:** `lib/presentation/screens/map_explore/map_explore_screen.dart`, `lib/presentation/screens/map_explore/map_explore_screen_fixed.dart`

Both files declare a class named `MapExploreScreen`. Having two classes with the same name in the same package causes a compile error.

**Fix:** Delete `map_explore_screen_fixed.dart` entirely — it is a stripped-down placeholder stub that adds no value.

---

### 2. Duplicate `FilterBottomSheet` class
**Files:** `lib/presentation/screens/map_explore/filter_bottom_sheet.dart`, `lib/presentation/screens/map_explore/map_explore_screen.dart`

`map_explore_screen.dart` declares its own inline `FilterBottomSheet` class at the bottom of the file. A full-featured `FilterBottomSheet` already exists in `filter_bottom_sheet.dart`. Both will conflict when the file is compiled.

**Fix:** Remove the inline `FilterBottomSheet` (and its `_FilterBottomSheetState`) from `map_explore_screen.dart` and import the one from `filter_bottom_sheet.dart` instead. Pass the required `onApply` callback when calling `showModalBottomSheet`.

---

### 3. Duplicate `AppConstants` class
**Files:** `lib/core/constants/app_constants.dart`, `lib/core/constants/nairobi_neighborhoods.dart`

`nairobi_neighborhoods.dart` redeclares an `AppConstants` class with overlapping constants. Any file that imports both will fail to compile.

**Fix:** Delete the `AppConstants` block from `nairobi_neighborhoods.dart`. Reference `AppConstants` from `app_constants.dart` wherever needed.

---

### 4. Custom base64 encoder crashes at runtime
**File:** `lib/services/mpesa_service.dart` — `_base64Encode()` method

The method indexes a Dart `String` with an integer (`chars[index]`), which is not valid syntax in Dart — `String` does not support the `[]` operator. This throws a `TypeError` at runtime the moment a payment is initiated.

**Fix:** Replace the entire custom method with `dart:convert`:

```dart
import 'dart:convert';

String _generatePassword() {
  final timestamp = _generateTimestamp();
  const shortcode = AppConstants.mpesaShortcode;
  const passkey = String.fromEnvironment('MPESA_PASSKEY');
  final data = '$shortcode$passkey$timestamp';
  return base64Encode(utf8.encode(data));
}
```

---

### 5. Custom trigonometry functions in `SpaceRepository`
**File:** `lib/data/repositories/space_repository.dart`

The repository re-implements `sin`, `cos`, `sqrt`, and `atan2` using Taylor series and Newton's method instead of `dart:math`. The Taylor series implementations diverge for inputs outside a small range, producing incorrect distances. Additionally, `LocationUtils.calculateDistance()` in `lib/core/utils/location_utils.dart` already implements the Haversine formula correctly using `dart:math`.

**Fix:** Delete the 5 private math methods (`_taylorSin`, `_taylorCos`, `_newtonSqrt`, `_newtonAtan`, `_degreesToRadians`) and replace `_calculateDistance(...)` with a call to the shared utility:

```dart
import '../../core/utils/location_utils.dart';

// Inside getSpacesNearby:
final distance = LocationUtils.calculateDistance(lat1, lon1, lat2, lon2);
```

---

### 6. Enum values compared to String literals — always `false`
**Files:** `lib/presentation/screens/bookings/active_booking_card.dart`, `lib/presentation/screens/profile/payment_history_screen.dart`

```dart
// Wrong — BookingStatus is an enum, not a String
if (booking.bookingStatus == 'upcoming') ...
if (booking.paymentStatus == 'paid') ...
```

These comparisons always return `false`, so cancel buttons never appear and totals are always calculated as zero.

**Fix:** Use the enum constants:

```dart
if (booking.bookingStatus == BookingStatus.upcoming) ...
if (booking.paymentStatus == PaymentStatus.paid) ...
```

---

## 🟠 High — Security or Data Integrity

### 7. Safaricom Daraja passkey is hardcoded in source
**File:** `lib/services/mpesa_service.dart`

```dart
final passkey = '<REDACTED>'; // previously hardcoded sandbox key in source
```

Committing API secrets to version control is a security risk. The shortcode `'247246'` is also hardcoded in three separate places.

**Fix:**
- Store the passkey via `--dart-define=MPESA_PASSKEY=...` (for CI/CD) or the `envied` package.
- Replace all `'247246'` literals with `AppConstants.mpesaShortcode`.

```dart
const passkey = String.fromEnvironment('MPESA_PASSKEY');
const shortcode = AppConstants.mpesaShortcode;
```

---

### 8. Authentication is completely stubbed — no Firebase Auth calls
**Files:** `lib/data/providers/auth_provider.dart`, `lib/presentation/screens/auth/phone_login_screen.dart`, `lib/presentation/screens/auth/otp_verification_screen.dart`

`auth_provider.dart` is a single line: `StateProvider<bool>`. Both auth screens simply call `await Future.delayed(...)` and then set the flag to `true`. No phone number is sent to Firebase, no OTP is ever verified.

**Fix:**
1. Create a proper `AuthNotifier` backed by `FirebaseAuth.instance`.
2. Call `auth.verifyPhoneNumber(...)` in `PhoneLoginScreen`.
3. Call `auth.signInWithCredential(PhoneAuthProvider.credential(...))` in `OtpVerificationScreen`.
4. Change `authStateProvider` to `StateNotifierProvider<AuthNotifier, UserModel?>` so the user's ID is accessible everywhere.

---

### 9. Firestore queries use ISO date strings instead of Timestamps
**File:** `lib/data/repositories/booking_repository.dart`

```dart
final now = DateTime.now().toIso8601String();
query.where('startTime', isGreaterThan: now) // string comparison, not Timestamp
```

Firestore stores dates as `Timestamp` objects. Comparing against an ISO string produces lexicographic ordering, which will return incorrect results (e.g., "2025-01-01" is alphabetically less than "2024-12-31" in some cases).

**Fix:**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

final now = Timestamp.fromDate(DateTime.now());
query.where('startTime', isGreaterThan: now)
```

---

### 10. FCM tokens logged to console with `print()`
**File:** `lib/services/notification_service.dart`

```dart
print('FCM Token: $token'); // visible in device logs, easily scraped
```

Device tokens can be used to send arbitrary push notifications.

**Fix:** Replace with a conditional debug log:

```dart
import 'package:flutter/foundation.dart';
if (kDebugMode) debugPrint('FCM Token: $token');
```

In production, store the token securely to Firestore for the current user instead of printing it.

---

## 🟡 Medium — Logic Bugs

### 11. `getAvailableSlots` in `TimeUtils` is broken
**File:** `lib/core/utils/time_utils.dart`

The `existingBookings` parameter is `List<Duration>`, but the method computes both `bookingStart` and `bookingEnd` as `date.add(booking)` — they are always the same value. The overlap check will therefore never detect a conflict, returning all slots as available.

**Fix:** Change the parameter type to a list of `DateTimeRange` (or a list of `(DateTime start, DateTime end)` records) and update the overlap logic accordingly.

---

### 12. `BookingSlotSelector` allows negative total amounts
**File:** `lib/presentation/screens/space_detail/booking_slot_selector.dart`

`_calculateHoursDifference(start, end)` does not validate that `end > start`. If a user picks an end time earlier than the start time, the total becomes negative or zero, and a booking with `totalAmount: 0` could be submitted.

**Fix:**

```dart
int _calculateHoursDifference(TimeOfDay start, TimeOfDay end) {
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;
  final diff = endMinutes - startMinutes;
  if (diff <= 0) return 0; // or show validation error
  return (diff / 60).ceil();
}
```

Also add a UI validation message when `endTime <= startTime`.

---

### 13. `OfflineOverlay` always shows the offline banner
**File:** `lib/presentation/widgets/offline_banner.dart`

`OfflineOverlay` unconditionally renders the "You're Offline" bar at the bottom of every screen it wraps. It does not accept an `isOnline` parameter or observe connectivity state.

**Fix:** Accept an `isOnline` bool parameter (or consume a connectivity provider) and conditionally render the overlay, similar to how `OfflineBanner` does it.

---

### 14. `UserModel.copyWith` silently drops `createdAt` and `updatedAt`
**File:** `lib/data/models/user_model.dart`

`copyWith` does not accept `createdAt` or `updatedAt` parameters, so those fields always silently copy from `this`. This means a `copyWith` call after a server update will preserve stale timestamps. The same issue exists in `BookingModel`.

**Fix:** Add nullable `DateTime?` parameters for both fields, using the sentinel-value pattern to distinguish "keep existing" from "set to null":

```dart
// Option A — accept the values explicitly
UserModel copyWith({
  ...
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return UserModel(
    ...
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
```

Or migrate the models to `freezed` which handles this automatically.

---

### 15. `SpaceFilterState.copyWith` cannot reset `maxPrice` to `null`
**File:** `lib/data/providers/space_providers.dart`

Because `double? maxPrice` uses the standard `copyWith` pattern, a caller cannot distinguish "I want to clear this filter" from "I am not changing this filter". Both pass `null` to the parameter.

**Fix:** Use the `Optional<T>` / `Value<T>` sentinel pattern, or switch to `freezed` which generates a `copyWith` that handles nullable fields correctly out of the box.

---

### 16. `if (true)` hardcoded condition for "Verified Booking" badge
**File:** `lib/presentation/screens/space_detail/review_list.dart`

```dart
if (true) // ← always shows "Verified Booking" on every review
  Container(...)
```

**Fix:** Replace with the appropriate condition. Most likely:

```dart
if (review.userId.isNotEmpty) // or a dedicated `isVerifiedBooking` field
```

---

### 17. `_resendOtp` countdown uses a raw `for` loop with `Future.delayed`
**File:** `lib/presentation/screens/auth/otp_verification_screen.dart`

The loop fires 60 `Future.delayed` calls in a tight sequence. If the widget is disposed mid-countdown, the `setState` calls inside will trigger `mounted` checks but the awaits continue running, holding resources unnecessarily.

**Fix:** Use `Timer.periodic` and cancel it in `dispose()`:

```dart
Timer? _resendTimer;

void _startResendCooldown() {
  setState(() => _resendCooldown = 60);
  _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (!mounted) { timer.cancel(); return; }
    setState(() {
      _resendCooldown--;
      if (_resendCooldown <= 0) timer.cancel();
    });
  });
}

@override
void dispose() {
  _resendTimer?.cancel();
  _otpController.dispose();
  super.dispose();
}
```

---

## 🔵 Architecture & Maintainability

### 18. Screens use mock data — providers are never called
**Files:** `lib/presentation/screens/bookings/bookings_screen.dart`, `lib/presentation/screens/search/search_screen.dart`, `lib/presentation/screens/map_explore/map_explore_screen.dart`, `lib/presentation/screens/space_detail/space_detail_screen.dart`

Every screen defines private `_getMockSpaces()` / `_getMockUpcomingBookings()` helpers instead of reading from the Riverpod providers and Firestore repositories that are already built.

**Fix:**

```dart
// In BookingsScreen:
final userId = ref.watch(authStateProvider)?.id ?? '';
final upcomingAsync = ref.watch(upcomingBookingsProvider(userId));

return upcomingAsync.when(
  data: (bookings) => _buildBookingsList(bookings),
  loading: () => const ListShimmer(),
  error: (e, _) => ErrorStateWidget(title: 'Error', message: e.toString()),
);
```

Apply the same pattern to all other screens.

---

### 19. `authStateProvider` is `bool`, not `UserModel?`
**File:** `lib/data/providers/auth_provider.dart`

Storing a bare `bool` means no screen can access `userId`, `phoneNumber`, or any other user property. Every provider that needs the current user's ID (bookings, saved spaces, etc.) has no way to get it.

**Fix:** Change to:

```dart
final authStateProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});
```

`AuthNotifier` wraps `FirebaseAuth.instance.authStateChanges()` and maps `User` → `UserModel`.

---

### 20. `HomeScreen` duplicates `WorkHubzBottomNav`
**File:** `lib/routes/app_router.dart`

`HomeScreen` builds its own inline `BottomNavigationBar` with the same 4 items that `WorkHubzBottomNav` in `lib/presentation/widgets/bottom_nav.dart` already defines. The widget is never used anywhere.

**Fix:** Replace the inline bar in `HomeScreen` with `WorkHubzBottomNav`:

```dart
bottomNavigationBar: WorkHubzBottomNav(
  currentIndex: _currentIndex,
  onIndexChanged: (i) => setState(() => _currentIndex = i),
),
```

---

### 21. `WorkHubzAppBar` uses `Navigator` instead of GoRouter APIs
**File:** `lib/presentation/widgets/app_bar.dart`

```dart
Navigator.canPop(context)  // ← may give wrong result with GoRouter
Navigator.pop(context)     // ← bypasses GoRouter's navigation stack
```

**Fix:**

```dart
import 'package:go_router/go_router.dart';

leading: context.canPop()
    ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? context.pop,
      )
    : null,
```

---

### 22. `SplashScreen` is never shown — no route exists
**File:** `lib/routes/app_router.dart`

`SplashScreen` is fully implemented in `lib/presentation/screens/splash_screen.dart` but there is no `/` or `/splash` route. The app starts at `/home` and the splash is unreachable.

**Fix:** Add a `/` route that shows `SplashScreen` with an `onComplete` callback that navigates to `/home` (or the auth flow if the user is not signed in):

```dart
GoRoute(
  path: '/',
  builder: (context, state) => SplashScreen(
    onComplete: () => context.go('/home'),
  ),
),
```

Change `initialLocation` to `'/'`.

---

### 23. `booking/:id` route ignores the `id` parameter
**File:** `lib/routes/app_router.dart`

```dart
GoRoute(
  path: '/booking/:id',
  builder: (context, state) {
    final id = state.pathParameters['id'] ?? ''; // captured but unused
    return const BookingsScreen();               // id is never passed
  },
),
```

**Fix:** Either pass `id` to `BookingsScreen` to scroll to/highlight the specific booking, or change this route to navigate directly to a `BookingDetailScreen`.

---

### 24. Phone normalisation logic duplicated in two places
**Files:** `lib/data/repositories/user_repository.dart` → `_normalizePhoneNumber()`, `lib/services/mpesa_service.dart` → `_normalizePhone()`

Both methods contain identical logic for stripping `+254`, `254`, and leading `0` prefixes.

**Fix:** Extract to a static method in `Validators` or a new `PhoneUtils` class and call it from both places:

```dart
class PhoneUtils {
  static String normalise(String phone) {
    String n = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (n.startsWith('+254')) return n.substring(1);
    if (n.startsWith('254')) return n;
    if (n.startsWith('0'))   return '254${n.substring(1)}';
    return n;
  }
}
```

---

### 25. Geo-location search downloads all spaces and filters client-side
**File:** `lib/data/repositories/space_repository.dart` — `getSpacesNearby()`

The method fetches up to 100 documents from Firestore and then filters by distance in Dart. At scale this wastes bandwidth, costs unnecessary Firestore reads, and will miss spaces beyond the 100-document limit.

The project already has `geoflutterfire2` in `pubspec.yaml`.

**Fix:** Use `GeoFlutterFire` to do a proper geohash-based radius query:

```dart
final geo = GeoFlutterFire();
final center = geo.point(latitude: latitude, longitude: longitude);
final stream = geo
    .collection(collectionRef: _spacesCollection)
    .within(center: center, radius: radiusKm, field: 'location');
```

Store each space's `location` as a GeoFirePoint in Firestore when creating documents.

---

### 26. Amenity icon/colour mapping is duplicated across three files
**Files:** `lib/presentation/widgets/amenity_icon.dart`, `lib/presentation/screens/space_detail/amenity_grid.dart`, `lib/presentation/widgets/amenity_icon.dart` (AmenityBadge)

All three repeat the same `if (name.contains('wifi')) return Icons.wifi` chains independently.

**Fix:** Add a static method to `AmenityModel` or `AmenityDefaults`:

```dart
// In amenity_model.dart
IconData get icon {
  switch (id) {
    case 'wifi':        return Icons.wifi;
    case 'power_outlets': return Icons.power;
    case 'parking':     return Icons.local_parking;
    case 'quiet':       return Icons.volume_off;
    case 'backup':      return Icons.battery_charging_full;
    case 'ac':          return Icons.ac_unit;
    case 'food':        return Icons.restaurant;
    case 'cctv':        return Icons.videocam;
    default:            return Icons.check_circle;
  }
}
```

---

### 27. Repositories are not mockable — hard to test
**Files:** All three repositories in `lib/data/repositories/`

When providers create repositories (e.g., `Provider((ref) => BookingRepository())`), `FirebaseFirestore.instance` is used as the default. Tests that want to inject a mock Firestore instance can't do so without the optional constructor parameter, which none of the providers pass.

**Fix:** Thread the Firestore instance through the provider:

```dart
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(firestore: ref.watch(firestoreProvider));
});
```

Override `firestoreProvider` in tests with a `FakeFirebaseFirestore` instance.

---

### 28. `LocationQuery` and `FilterQuery` lack `==` and `hashCode`
**File:** `lib/data/providers/space_providers.dart`

Riverpod `FutureProvider.family` uses the family argument as a cache key. Without `==` and `hashCode`, every call with a `LocationQuery(...)` or `FilterQuery(...)` creates a new object that is never equal to the previous one, causing unnecessary refetches on every rebuild.

**Fix:** Implement `==` and `hashCode` (or annotate with `@freezed`):

```dart
@immutable
class LocationQuery {
  ...
  @override
  bool operator ==(Object other) =>
      other is LocationQuery &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.radiusKm == radiusKm;

  @override
  int get hashCode => Object.hash(latitude, longitude, radiusKm);
}
```

---

### 29. `NotificationService` has empty/unimplemented methods
**File:** `lib/services/notification_service.dart`

`showLocalNotification()`, `cancelAllNotifications()`, and `cancelNotification()` are empty stubs with no implementation and no TODO comments. `onBackgroundMessage` throws `UnimplementedError`.

**Fix:** 
- Add `flutter_local_notifications` to `pubspec.yaml` and implement local notification display.
- Remove `onBackgroundMessage` getter and register the top-level `firebaseMessagingBackgroundHandler` directly via `FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler)` in `main()`.

---

### 30. `GeoPoint` is ambiguous — custom model vs Firestore type
**Files:** `lib/data/models/geo_point.dart`, `lib/data/models/space_model.dart`, `lib/presentation/screens/map_explore/map_explore_screen.dart`

A custom `GeoPoint` class exists at `lib/data/models/geo_point.dart`, but `space_model.dart` imports `GeoPoint` from `cloud_firestore`. Some screens import Firestore's `GeoPoint` directly. This inconsistency will cause type mismatch errors at runtime.

**Fix:** Remove the custom `lib/data/models/geo_point.dart` and use Firestore's `GeoPoint` everywhere, or (preferably) use a plain `LatLng` from `google_maps_flutter` for model coordinates and a Firestore `GeoPoint` only at the persistence layer.

---

## ⚪ Minor / Style

| # | Issue | File(s) | Fix |
|---|---|---|---|
| 31 | `const` missing on `RoundedRectangleBorder` with `BorderRadius.only` | `app_bar.dart` | Add `const` to `BorderRadius.only(...)` |
| 32 | Mix of old `Key? key` + `super(key: key)` and new `super.key` style | Widgets throughout | Standardise on `super.key` (new style) |
| 33 | Raw `Colors.grey[600]`, `Colors.red[400]!` used instead of `AppColors` tokens | Many screens & widgets | Replace with `AppColors.onSurfaceVariant`, defined `AppColors` constants |
| 34 | `Image.asset('assets/branding/promo_banner.png')` in `ProfileScreen` — asset not declared in `pubspec.yaml` | `profile_screen.dart` | Add the asset path to `pubspec.yaml` or use a placeholder |
| 35 | `'https://via.placeholder.com/400x200'` hardcoded fallback URLs | `search_results_list.dart`, `saved_spaces_screen.dart` | Use a local bundled placeholder image from the `assets/` folder |
| 36 | `import 'dart:math'` in `splash_screen.dart` but only `sin` is used | `splash_screen.dart` | Alias as `import 'dart:math' as math` and use `math.sin(...)` |
| 37 | Unused variable `now` in `getActiveBookings` and `getPastBookings` | `booking_repository.dart` | Remove the unused `final now = ...` line |
| 38 | Unused import `permission_handler` | `location_provider.dart` | Remove the import — Geolocator handles permissions internally |
| 39 | `PhoneLoginScreen` validation only checks `length < 10`, not format | `phone_login_screen.dart` | Use `Validators.validatePhoneNumber()` from `core/utils/validators.dart` |
| 40 | `darkTheme` in `AppTheme` is incomplete — only sets `AppBarTheme`, missing card, button, input styles | `app_theme.dart` | Mirror the light theme configuration for all component themes |
| 41 | `PriceChip` shows raw KES amount without `/hr` unit | `price_chip.dart` | Append `/hr` or accept a `unit` parameter |
| 42 | `ThemeMode` is hardcoded to `ThemeMode.light` — ignores `darkModeEnabled` user preference | `main.dart` | Watch a theme provider that reads `UserModel.darkModeEnabled` |
| 43 | `_buildStat` in `ProfileScreen` uses hardcoded strings `'12'`, `'7'`, `'3'` | `profile_screen.dart` | Drive from real `UserModel` data once auth is connected |
| 44 | `review_list.dart` hardcodes category ratings (`4.5`, `4.2`, `3.8`, `4.3`) instead of reading from `ReviewModel` | `review_list.dart` | Aggregate from `reviews.map((r) => r.wifiRating).average` etc. |
| 45 | `OperatingHoursModel.fromJson` casts `value` directly to `DayHours?` without calling `DayHours.fromJson` | `operating_hours_model.dart` | Change to `value != null ? DayHours.fromJson(value as Map<String, dynamic>) : null` |

---

## Recommended Fix Order

```
Phase 1 — Get it compiling
  ├── Delete map_explore_screen_fixed.dart                   (#1)
  ├── Remove inline FilterBottomSheet from map_explore_screen (#2)
  └── Remove duplicate AppConstants from nairobi_neighborhoods (#3)

Phase 2 — Fix crashes & incorrect runtime behaviour
  ├── Fix base64 encoder in MpesaService                     (#4)
  ├── Replace custom math in SpaceRepository                 (#5)
  ├── Fix enum-vs-string comparisons in booking widgets      (#6)
  ├── Fix OperatingHoursModel.fromJson DayHours cast         (#45)
  └── Resolve GeoPoint ambiguity                             (#30)

Phase 3 — Security
  ├── Move Daraja passkey to environment variable            (#7)
  └── Replace print() with conditional debugPrint            (#10)

Phase 4 — Connect real data
  ├── Implement Firebase Auth in auth screens                (#8)
  ├── Change authStateProvider to UserModel?                 (#19)
  ├── Fix Firestore date queries (ISO → Timestamp)           (#9)
  └── Replace mock data in all screens with Riverpod providers (#18)

Phase 5 — Architecture hardening
  ├── Fix getAvailableSlots signature                        (#11)
  ├── Add == / hashCode to LocationQuery & FilterQuery       (#28)
  ├── Make repositories injectable                           (#27)
  ├── Use geoflutterfire2 for geo queries                    (#25)
  └── Wire SplashScreen into routing                         (#22)

Phase 6 — Polish & cleanup
  └── All items in the Minor / Style table                   (#31–#45)
```

---

*Last updated: 2026-05-29*

---

**Note:** A much more recent and comprehensive full scan was performed on 2026-05-28.  
The authoritative persistent memory + complete improvement plan lives in:

- `SCAN_MEMORY.md` (quick reference)
- `PREMIUM_READINESS_REPORT.md` (detailed findings + phased plan)

Most items from this older document are still relevant and are incorporated into the newer report.
