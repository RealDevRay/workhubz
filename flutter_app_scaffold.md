# WorkHubz — Flutter App Scaffold

## Overview
A mobile-first Android application built with Flutter and Dart that connects students, remote workers, and freelancers in Nairobi with affordable, bookable workspaces. Users discover spaces via an interactive map, filter by work-critical amenities, and pay for hourly or day passes through M-Pesa integration.

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Framework | Flutter 3.x + Dart | Cross-platform UI, single codebase |
| State Management | Riverpod | Predictable async state for location, bookings, payments |
| Maps | `google_maps_flutter` | Street-level discovery with custom price-bubble markers |
| Backend & Auth | Firebase (Firestore + Authentication + Cloud Functions) | Real-time data, user auth, serverless functions |
| Payments | Safaricom Daraja API via platform channels | M-Pesa STK push for hourly/day-pass purchases |
| Local Cache | Hive | Offline persistence of listings, bookmarks, booking history |
| Images | `cached_network_image` | Aggressive caching for low-bandwidth users |
| Location | `geolocator` | GPS positioning, permission handling, distance calculations |
| Routing | `flutter_polyline_points` | Traffic-aware ETAs between user and workspace |

---

## Project Structure
```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart
│   │   ├── app_theme.dart
│   │   ├── nairobi_neighborhoods.dart    # Enum: kilimani, westlands, cbd, ngongRoad, karen, lavington
│   │   └── app_constants.dart            # Max search radius, default currency format
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_theme.dart                # Light/dark mode optimized for outdoor readability
│   └── utils/
│       ├── location_utils.dart           # Haversine distance, bearing
│       ├── time_utils.dart                # Traffic-aware ETA estimates
│       ├── currency_formatter.dart       # KES formatting: "KSh 150/hr"
│       └── validators.dart
├── data/
│   ├── models/
│   │   ├── space_model.dart              # Freezed immutable data class
│   │   ├── booking_model.dart
│   │   ├── review_model.dart
│   │   ├── user_model.dart
│   │   └── amenity_model.dart
│   ├── repositories/
│   │   ├── space_repository.dart         # Firestore CRUD, geoqueries
│   │   ├── booking_repository.dart
│   │   └── user_repository.dart
│   └── providers/
│       ├── space_providers.dart          # Riverpod StateNotifier
│       ├── booking_providers.dart
│       └── location_provider.dart
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── phone_login_screen.dart   # Firebase Phone Auth (Kenyan numbers)
│   │   │   └── otp_verification_screen.dart
│   │   ├── map_explore/
│   │   │   ├── map_explore_screen.dart
│   │   │   ├── filter_bottom_sheet.dart
│   │   │   └── price_marker.dart         # Custom Google Maps marker with KES price
│   │   ├── space_detail/
│   │   │   ├── space_detail_screen.dart
│   │   │   ├── photo_gallery.dart
│   │   │   ├── amenity_grid.dart
│   │   │   ├── booking_slot_selector.dart
│   │   │   └── review_list.dart
│   │   ├── bookings/
│   │   │   ├── bookings_screen.dart
│   │   │   ├── active_booking_card.dart
│   │   │   └── qr_checkin_view.dart
│   │   ├── search/
│   │   │   ├── search_screen.dart
│   │   │   └── search_results_list.dart
│   │   └── profile/
│   │       ├── profile_screen.dart
│   │       ├── saved_spaces_screen.dart
│   │       └── payment_history_screen.dart
│   └── widgets/
│       ├── app_bar.dart
│       ├── bottom_nav.dart
│       ├── price_chip.dart
│       ├── amenity_icon.dart
│       ├── mpesa_pay_button.dart
│       ├── loading_shimmer.dart
│       ├── offline_banner.dart
│       └── error_state_widget.dart
├── services/
│   ├── location_service.dart
│   ├── mpesa_service.dart                # Platform channel to Daraja API
│   ├── notification_service.dart         # FCM for booking reminders
│   └── connectivity_service.dart         # Monitor offline/online state
└── routes/
    └── app_router.dart                   # go_router declarative routing
```

---

## Core Dependencies (pubspec.yaml)

```yaml
name: workhubz
description: Find and book affordable workspaces in Nairobi with WorkHubz

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Firebase
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.0
  cloud_firestore: ^4.15.0
  firebase_messaging: ^14.7.0

  # Maps & Location
  google_maps_flutter: ^2.6.0
  geolocator: ^11.0.0
  flutter_polyline_points: ^2.0.0
  geoflutterfire2: ^2.3.15               # Geoqueries for Firestore

  # Networking
  dio: ^5.4.0
  connectivity_plus: ^5.0.0

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # UI Components
  cached_network_image: ^3.3.0
  flutter_rating_bar: ^4.0.1
  shimmer: ^3.0.0
  flutter_staggered_grid_view: ^0.7.0
  carousel_slider: ^4.2.1

  # Utilities
  intl: ^0.19.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  qr_flutter: ^4.1.0
  share_plus: ^7.2.0
  url_launcher: ^6.2.0

  # Date/Time
  table_calendar: ^3.0.9

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

---

## Data Models

### SpaceModel

```dart
@freezed
class SpaceModel with _$SpaceModel {
  const factory SpaceModel({
    required String id,
    required String name,
    required String description,
    required String address,
    required GeoPoint location,              // Firestore GeoPoint
    required String neighborhood,            // From NairobiNeighborhoods enum
    required List<String> photoUrls,
    required List<AmenityModel> amenities,
    required PricingTierModel pricing,
    required OperatingHoursModel hours,
    required double rating,
    required int reviewCount,
    required bool isVerified,
    String? phoneNumber,
    String? website,
    String? securityNotes,
    @Default(false) bool hasPowerBackup,
    @Default([]) List<String> tags,          // "quiet", "24hr", "food-allowed"
  }) = _SpaceModel;

  factory SpaceModel.fromJson(Map<String, dynamic> json) =>
      _$SpaceModelFromJson(json);
}
```

### PricingTierModel

```dart
@freezed
class PricingTierModel with _$PricingTierModel {
  const factory PricingTierModel({
    required double hourlyRate,              // KES per hour
    double? halfDayRate,                     // KES for 4-5 hours
    double? fullDayRate,                     // KES for 8+ hours
    double? weeklyRate,
    String? currency,                        // Default "KES"
    String? notes,                           // "Student discount available"
  }) = _PricingTierModel;

  factory PricingTierModel.fromJson(Map<String, dynamic> json) =>
      _$PricingTierModelFromJson(json);
}
```

### BookingModel

```dart
@freezed
class BookingModel with _$BookingModel {
  const factory BookingModel({
    required String id,
    required String userId,
    required String spaceId,
    required String spaceName,
    required DateTime startTime,
    required DateTime endTime,
    required double totalAmount,
    required String paymentStatus,           // "pending", "paid", "refunded"
    String? mpesaReceiptNumber,
    required String bookingStatus,           // "upcoming", "active", "completed", "cancelled"
    String? checkInCode,                   // QR code string
    DateTime? checkedInAt,
    DateTime? checkedOutAt,
    @Default(false) bool isRated,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);
}
```

### AmenityModel

```dart
@freezed
class AmenityModel with _$AmenityModel {
  const factory AmenityModel({
    required String id,
    required String name,                    // "Wi-Fi", "Power Outlets", "Parking"
    required String iconName,                // Maps to icon asset
    required AmenityCategory category,       // connectivity, power, comfort, security, food
    String? description,                     // "50 Mbps fiber"
    @Default(false) bool isVerified,
  }) = _AmenityModel;

  factory AmenityModel.fromJson(Map<String, dynamic> json) =>
      _$AmenityModelFromJson(json);
}

enum AmenityCategory { connectivity, power, comfort, security, food, accessibility }
```

---

## Core Screens Specification

### 1. Map Explore Screen
Full-screen Google Map centered on user's GPS location or default Nairobi CBD (-1.2921, 36.8219)

Custom markers: Circular bubbles showing price (e.g., "KSh 100") with color coding:
- **Green**: Under KSh 100/hr
- **Amber**: KSh 100-250/hr
- **Red**: Above KSh 250/hr

Floating Action Buttons: Recenter GPS, filter toggle, list-view toggle

**Filter Bottom Sheet (slide up)**:
- Price range slider (KSh 0 - 1000)
- Amenity toggles: Wi-Fi, Power Outlets, Quiet, 24-Hour, Food Available, Parking, Power Backup
- Neighborhood multi-select chips
- Opening time filter: "Open Now", "Open Late", "Weekends"
- Sort: Nearest, Cheapest, Highest Rated

**Space Preview Card (tap marker)**: Photo, name, price, rating, distance, "Book Now" CTA

---

### 2. Space Detail Screen
- **Hero image carousel** (swipeable, pinch-to-zoom)
- **Header**: Name, verified badge, rating with review count, favorite toggle
- **Quick Info Row**: Price/hr, distance, open/closed status, estimated travel time with traffic
- **Amenities Grid**: 3-column grid of icons with labels; tap for detail
- **Pricing Section**: Hourly / Half-day / Full-day cards with "Select" action
- **Description**: Full text, house rules, security notes
- **Location Mini-Map**: Static map with "Get Directions" (opens Google Maps app)
- **Reviews Section**: Average breakdown by category (Wi-Fi, Power, Noise, Value), sorted by recent
- **Sticky Bottom Bar**: Selected slot summary + "Proceed to Pay" M-Pesa button

---

### 3. Booking Flow
1. User selects date (calendar picker) and time slot
2. System shows available slots (fetched from Firestore)
3. User confirms duration; app calculates total (e.g., 3 hrs × KSh 150 = KSh 450)
4. Tap "Pay with M-Pesa" → triggers STK push to user's phone number
5. Poll payment status via Cloud Function
6. On success: generate QR check-in code, show confirmation screen, add to "My Bookings"
7. FCM notification 15 mins before slot start

---

### 4. My Bookings Screen
- **Tab 1: Upcoming** — Active and future bookings with QR code, cancel option
- **Tab 2: History** — Past bookings with "Rebook" and "Leave Review" CTAs

**Booking Card**: Space photo, name, date/time, amount, status badge, QR thumbnail

---

### 5. Profile Screen
- Phone number (from Firebase Auth, non-editable)
- Saved spaces list
- Payment history with M-Pesa receipts
- App settings: notifications, dark mode, language (English/Swahili)
- "Report an Issue" → Firestore feedback collection

---

## M-Pesa Integration Architecture

```
[User taps "Pay"]
    ↓
[Flutter App] → calls [Cloud Function: initiatePayment]
    ↓
[Cloud Function] → Safaricom Daraja API (STK Push)
    ↓
[User receives M-Pesa prompt on phone] → enters PIN
    ↓
[Safaricom sends callback to Cloud Function]
    ↓
[Cloud Function updates Firestore: booking.paymentStatus = "paid"]
    ↓
[Flutter app listens to Firestore stream] → shows success + generates QR
```

**Security**: Never store M-Pesa credentials client-side. All Daraja secrets live in Cloud Function environment variables.

---

## Nairobi-Specific UX Considerations

| Concern | Implementation |
|--------|----------------|
| Traffic-aware ETAs | Integrate Google Distance Matrix API; display "45 mins from Westlands (heavy traffic)" |
| Security context | Per-space security badge: "Gated compound", "CCTV", "Night guard", "Well-lit street" |
| Power reliability | "Power backup" filter + badge for spaces with generators/inverters |
| Neighborhood guides | Subtle color coding on map for area character (CBD = busy/commercial, Karen = quiet/suburban) |
| Low bandwidth | Image compression via Firebase Storage transforms; lazy loading; offline banner |
| M-Pesa first | Primary CTA is always M-Pesa; card payments hidden in secondary menu |
| KES only | No currency switcher; all prices hardcoded in Kenyan Shillings |

---

## Firebase Security Rules (Starter)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Spaces: public read, admin write
    match /spaces/{spaceId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Bookings: users read own, create if authenticated, update via Cloud Function only
    match /bookings/{bookingId} {
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update: if false; // Only Cloud Functions
    }
    
    // Reviews: authenticated users, one per user per space
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null 
        && request.auth.uid == request.resource.data.userId
        && !exists(/databases/$(database)/documents/reviews/$(reviewId));
    }
    
    // Users: self-managed
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Build & Release Checklist

- [ ] `flutter build apk --release` (test on low-end Android device)
- [ ] ProGuard rules for Firebase, Maps, Dio
- [ ] App signing keystore configured
- [ ] Play Store listing: screenshots for 5.5", 6.7", 10" devices
- [ ] Nairobi-specific Play Store description with neighborhood keywords
- [ ] Privacy policy (GDPR + Kenya Data Protection Act compliant)
- [ ] Firebase App Check enabled to prevent abuse
- [ ] Crashlytics integration for production monitoring