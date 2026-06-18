import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/space_model.dart';
import '../models/geo_point.dart';
import '../models/amenity_model.dart';
import '../models/pricing_tier_model.dart';
import '../models/operating_hours_model.dart';
import '../../core/utils/location_utils.dart';

class SpaceRepository {
  final SupabaseClient _supabase;

  SpaceRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<List<SpaceModel>> getAllSpaces({
    int limit = 20,
    String? neighborhood,
  }) async {
    var query = _supabase.from('hubs').select('''
      *,
      hub_contacts(*),
      hub_amenities(amenity_id),
      hub_photos(url, is_primary)
    ''');

    if (neighborhood != null &&
        neighborhood.isNotEmpty &&
        neighborhood != 'All Nairobi' &&
        neighborhood != 'current') {
      query = query.eq('neighborhood', neighborhood);
    }

    final response = await query.order('rating', ascending: false).limit(limit);
    return (response as List)
        .map((json) => _hubJsonToSpaceModel(json))
        .toList();
  }

  Future<SpaceModel?> getSpaceById(String id) async {
    final response = await _supabase
        .from('hubs')
        .select('''
          *,
          hub_contacts(*),
          hub_amenities(amenity_id),
      hub_photos(url, is_primary)
        ''')
        .eq('id', id)
        .single();

    return _hubJsonToSpaceModel(response);
  }

  Future<List<SpaceModel>> getSpacesNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 20,
  }) async {
    final response = await _supabase
        .from('hubs')
        .select('''
          *,
          hub_contacts(*),
          hub_amenities(amenity_id),
      hub_photos(url, is_primary)
        ''')
        .not('latitude', 'is', null)
        .not('longitude', 'is', null)
        .limit(100);

    final hubs = response as List;
    final spaces = <_HubWithDistance>[];

    for (final hub in hubs) {
      final lat = (hub['latitude'] as num).toDouble();
      final lng = (hub['longitude'] as num).toDouble();
      final distance = LocationUtils.calculateDistance(
        latitude,
        longitude,
        lat,
        lng,
      );
      if (distance <= radiusKm) {
        spaces.add(_HubWithDistance(hub: hub, distance: distance));
      }
    }

    spaces.sort((a, b) => a.distance.compareTo(b.distance));
    return spaces.take(limit).map((e) => _hubJsonToSpaceModel(e.hub)).toList();
  }

  Future<List<SpaceModel>> searchSpaces({
    required String query,
    int limit = 20,
  }) async {
    final searchTerm = query.toLowerCase();
    final response = await _supabase
        .from('hubs')
        .select('''
          *,
          hub_contacts(*),
          hub_amenities(amenity_id),
      hub_photos(url, is_primary)
        ''')
        .or(
          'name.ilike.%$searchTerm%,description.ilike.%$searchTerm%,neighborhood.ilike.%$searchTerm%',
        )
        .limit(limit);

    return (response as List)
        .map((json) => _hubJsonToSpaceModel(json))
        .toList();
  }

  Future<List<SpaceModel>> getSpacesByNeighborhood(String neighborhood) async {
    final response = await _supabase
        .from('hubs')
        .select('''
          *,
          hub_contacts(*),
          hub_amenities(amenity_id),
      hub_photos(url, is_primary)
        ''')
        .eq('neighborhood', neighborhood.toLowerCase());

    return (response as List)
        .map((json) => _hubJsonToSpaceModel(json))
        .toList();
  }

  Future<List<SpaceModel>> filterSpaces({
    double? maxPrice,
    bool? hasWifi,
    bool? hasParking,
    bool? hasQuietZone,
    bool? hasPowerBackup,
    List<String>? neighborhoods,
    int limit = 20,
  }) async {
    var query = _supabase.from('hubs').select('''
          *,
          hub_contacts(*),
          hub_amenities(amenity_id),
      hub_photos(url, is_primary)
        ''');

    if (neighborhoods != null && neighborhoods.isNotEmpty) {
      final nList = neighborhoods.map((n) => n.toLowerCase()).toList();
      query = query.filter('neighborhood', 'in', '(${nList.join(',')})');
    }
    if (maxPrice != null) {
      query = query.lte('price_hourly', maxPrice);
    }

    final response = await query.limit(limit);
    var spaces = (response as List)
        .map((json) => _hubJsonToSpaceModel(json))
        .toList();

    if (hasWifi == true) spaces = spaces.where((s) => s.hasWifi).toList();
    if (hasParking == true) spaces = spaces.where((s) => s.hasParking).toList();
    if (hasQuietZone == true)
      spaces = spaces.where((s) => s.hasQuietZone).toList();
    if (hasPowerBackup == true)
      spaces = spaces.where((s) => s.hasPowerBackup).toList();

    return spaces.take(limit).toList();
  }

  SpaceModel _hubJsonToSpaceModel(Map<String, dynamic> json) {
    final amenityIds =
        (json['hub_amenities'] as List?)
            ?.map((a) => a['amenity_id'] as String)
            .toList() ??
        [];

    final amenities = amenityIds.map((id) {
      return AmenityDefaults.all.firstWhere(
        (a) => a.id == id,
        orElse: () => AmenityModel(
          id: id,
          name: id.replaceAll('_', ' '),
          iconName: 'check_circle',
          category: AmenityCategory.comfort,
        ),
      );
    }).toList();

    // Enhance mapper to pull contact info from joined hub_contacts for better compatibility
    final contacts = json['hub_contacts'];
    String? phoneNumber;
    String? website;
    if (contacts is List && contacts.isNotEmpty) {
      final c = contacts.first as Map<String, dynamic>;
      phoneNumber = c['phone'] as String?;
      website = c['website'] as String?;
    } else if (contacts is Map) {
      phoneNumber = contacts['phone'] as String?;
      website = contacts['website'] as String?;
    }

    return SpaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      location: GeoPoint(
        (json['latitude'] as num?)?.toDouble() ?? 0,
        (json['longitude'] as num?)?.toDouble() ?? 0,
      ),
      neighborhood: json['neighborhood'] as String,
      photoUrls: _extractPhotoUrls(json),
      amenities: amenities,
      pricing: PricingTierModel(
        hourlyRate: (json['price_hourly'] as num?)?.toDouble() ?? 0,
        fullDayRate: (json['price_daily'] as num?)?.toDouble(),
        weeklyRate: (json['price_monthly'] as num?)?.toDouble(),
        currency: json['currency'] as String? ?? 'KES',
      ),
      hours: const OperatingHoursModel(openHour: 8, closeHour: 18),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as int?) ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      phoneNumber: phoneNumber,
      website: website,
    );
  }

  List<String> _extractPhotoUrls(Map<String, dynamic> json) {
    if (json['hub_photos'] != null && (json['hub_photos'] as List).isNotEmpty) {
      return (json['hub_photos'] as List)
          .map((p) => p['url'] as String)
          .toList();
    }
    if (json['photo_urls'] != null) {
      return (json['photo_urls'] as List).cast<String>();
    }
    return [];
  }
}

class _HubWithDistance {
  final Map<String, dynamic> hub;
  final double distance;
  _HubWithDistance({required this.hub, required this.distance});
}
