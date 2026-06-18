enum AmenityCategory {
  connectivity,
  power,
  comfort,
  security,
  food,
  accessibility,
}

class AmenityModel {
  final String id;
  final String name;
  final String iconName;
  final AmenityCategory category;
  final String? description;
  final bool isVerified;

  const AmenityModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.category,
    this.description,
    this.isVerified = false,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String,
      category: AmenityCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AmenityCategory.comfort,
      ),
      description: json['description'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'category': category.name,
      'description': description,
      'isVerified': isVerified,
    };
  }

  AmenityModel copyWith({
    String? id,
    String? name,
    String? iconName,
    AmenityCategory? category,
    String? description,
    bool? isVerified,
  }) {
    return AmenityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      description: description ?? this.description,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AmenityModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class AmenityDefaults {
  static const wifi = AmenityModel(
    id: 'wifi',
    name: 'Wi-Fi',
    iconName: 'wifi',
    category: AmenityCategory.connectivity,
    description: 'High-speed fiber internet',
    isVerified: true,
  );

  static const powerOutlets = AmenityModel(
    id: 'power_outlets',
    name: 'Power Outlets',
    iconName: 'power',
    category: AmenityCategory.power,
    description: 'Adequate charging points',
    isVerified: true,
  );

  static const parking = AmenityModel(
    id: 'parking',
    name: 'Parking',
    iconName: 'local_parking',
    category: AmenityCategory.security,
    description: 'Secure parking available',
    isVerified: true,
  );

  static const airConditioning = AmenityModel(
    id: 'ac',
    name: 'Air Conditioning',
    iconName: 'ac_unit',
    category: AmenityCategory.comfort,
    description: 'Climate controlled',
    isVerified: true,
  );

  static const quietSpace = AmenityModel(
    id: 'quiet',
    name: 'Quiet Zone',
    iconName: 'volume_off',
    category: AmenityCategory.comfort,
    description: 'Silent workspace',
    isVerified: true,
  );

  static const foodAllowed = AmenityModel(
    id: 'food',
    name: 'Food Allowed',
    iconName: 'restaurant',
    category: AmenityCategory.food,
    description: 'Food and drinks permitted',
    isVerified: true,
  );

  static const powerBackup = AmenityModel(
    id: 'backup',
    name: 'Power Backup',
    iconName: 'battery_charging_full',
    category: AmenityCategory.power,
    description: 'Generator/inverter backup',
    isVerified: true,
  );

  static const cctv = AmenityModel(
    id: 'cctv',
    name: 'CCTV',
    iconName: 'videocam',
    category: AmenityCategory.security,
    description: '24/7 surveillance',
    isVerified: true,
  );

  static const List<AmenityModel> all = [
    wifi,
    powerOutlets,
    parking,
    airConditioning,
    quietSpace,
    foodAllowed,
    powerBackup,
    cctv,
  ];
}
