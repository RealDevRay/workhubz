class AppConstants {
  static const String appName = 'WorkHubz';
  static const String defaultCurrency = 'KES';
  static const String countryCode = 'KE';

  static const double defaultLatitude = -1.2921;
  static const double defaultLongitude = 36.8219;
  static const double defaultZoom = 14.0;

  static const double maxSearchRadiusKm = 10.0;
  static const int defaultPageSize = 20;

  static const Duration defaultCacheAge = Duration(hours: 24);
  static const Duration paymentTimeout = Duration(minutes: 5);
  static const Duration otpResendCooldown = Duration(seconds: 60);

  static const int maxReviewPhotos = 5;
  static const int maxSpacePhotos = 10;

  static const String mpesaPaybill = '174379';
  static const String mpesaShortcode = '174379';

  /// mpesaPasskey is now provided via environment variable MPESA_PASSKEY
  static String get mpesaPasskey => String.fromEnvironment('MPESA_PASSKEY');
  static const String mpesaCallbackUrl =
      'https://srrqhcltnhxdkkeqdsxh.supabase.co/functions/v1/mpesa-callback';

  static const List<String> supportedLanguages = ['en', 'sw'];
}
