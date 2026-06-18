import 'amenity_model.dart';
import 'pricing_tier_model.dart';
import 'operating_hours_model.dart';
import 'geo_point.dart';

class SpaceModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final GeoPoint location;
  final String neighborhood;
  final List<String> photoUrls;
  final List<AmenityModel> amenities;
  final PricingTierModel pricing;
  final OperatingHoursModel hours;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final String? phoneNumber;
  final String? website;
  final String? securityNotes;
  final bool hasPowerBackup;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SpaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.location,
    required this.neighborhood,
    required this.photoUrls,
    required this.amenities,
    required this.pricing,
    required this.hours,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    this.phoneNumber,
    this.website,
    this.securityNotes,
    this.hasPowerBackup = false,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    return SpaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      location: json['location'] is GeoPoint
          ? json['location'] as GeoPoint
          : GeoPoint(
              json['location']['latitude'] as double,
              json['location']['longitude'] as double,
            ),
      neighborhood: json['neighborhood'] as String,
      photoUrls: (json['photoUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => AmenityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pricing: PricingTierModel.fromJson(
          json['pricing'] as Map<String, dynamic>? ?? {}),
      hours: OperatingHoursModel.fromJson(
          json['hours'] as Map<String, dynamic>? ?? {}),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      securityNotes: json['securityNotes'] as String?,
      hasPowerBackup: json['hasPowerBackup'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'location': location,
      'neighborhood': neighborhood,
      'photoUrls': photoUrls,
      'amenities': amenities.map((e) => e.toJson()).toList(),
      'pricing': pricing.toJson(),
      'hours': hours.toJson(),
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'phoneNumber': phoneNumber,
      'website': website,
      'securityNotes': securityNotes,
      'hasPowerBackup': hasPowerBackup,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  SpaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    GeoPoint? location,
    String? neighborhood,
    List<String>? photoUrls,
    List<AmenityModel>? amenities,
    PricingTierModel? pricing,
    OperatingHoursModel? hours,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    String? phoneNumber,
    String? website,
    String? securityNotes,
    bool? hasPowerBackup,
    List<String>? tags,
  }) {
    return SpaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      location: location ?? this.location,
      neighborhood: neighborhood ?? this.neighborhood,
      photoUrls: photoUrls ?? this.photoUrls,
      amenities: amenities ?? this.amenities,
      pricing: pricing ?? this.pricing,
      hours: hours ?? this.hours,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      securityNotes: securityNotes ?? this.securityNotes,
      hasPowerBackup: hasPowerBackup ?? this.hasPowerBackup,
      tags: tags ?? this.tags,
    );
  }

  double get latitude => location.latitude;
  double get longitude => location.longitude;

  bool get hasWifi =>
      amenities.any((a) => a.id == 'wifi' || a.name.toLowerCase().contains('wifi'));
  bool get hasParking =>
      amenities.any((a) => a.id == 'parking' || a.name.toLowerCase().contains('parking'));
  bool get hasQuietZone =>
      amenities.any((a) => a.id == 'quiet' || a.name.toLowerCase().contains('quiet'));
  bool get hasFood =>
      amenities.any((a) => a.id == 'food' || a.name.toLowerCase().contains('food'));

  String get priceDisplay => 'KSh ${pricing.hourlyRate.toInt()}/hr';

  String get ratingDisplay => rating > 0 ? rating.toStringAsFixed(1) : 'New';
}
