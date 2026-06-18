import 'dart:math' as math;

class LocationUtils {
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double lat1Rad = _degreesToRadians(lat1);
    final double lat2Rad = _degreesToRadians(lat2);

    final double x = math.sin(dLon) * math.cos(lat2Rad);
    final double y =
        math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    final double bearing = math.atan2(x, y);
    return (_radiansToDegrees(bearing) + 360) % 360;
  }

  static double _radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  static bool isWithinRadius(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radiusKm,
  ) {
    final distance = calculateDistance(lat1, lon1, lat2, lon2);
    return distance <= radiusKm;
  }

  static String formatCoordinates(double lat, double lng) {
    final String latDir = lat >= 0 ? 'N' : 'S';
    final String lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}$latDir, ${lng.abs().toStringAsFixed(4)}$lngDir';
  }

  static bool isValidCoordinates(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  static double normalizeLatitude(double lat) {
    return lat.clamp(-90.0, 90.0);
  }

  static double normalizeLongitude(double lng) {
    return lng.clamp(-180.0, 180.0);
  }
}
