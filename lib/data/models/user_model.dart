class UserModel {
  final String id;
  final String phoneNumber;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final List<String> savedSpaceIds;
  final List<String> bookingIds;
  final String? preferredNeighborhood;
  final String languagePreference;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.displayName,
    this.email,
    this.photoUrl,
    this.savedSpaceIds = const [],
    this.bookingIds = const [],
    this.preferredNeighborhood,
    this.languagePreference = 'en',
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      savedSpaceIds:
          (json['savedSpaceIds'] as List<dynamic>?)?.cast<String>() ?? [],
      bookingIds: (json['bookingIds'] as List<dynamic>?)?.cast<String>() ?? [],
      preferredNeighborhood: json['preferredNeighborhood'] as String?,
      languagePreference: json['languagePreference'] as String? ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
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
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'savedSpaceIds': savedSpaceIds,
      'bookingIds': bookingIds,
      'preferredNeighborhood': preferredNeighborhood,
      'languagePreference': languagePreference,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? displayName,
    String? email,
    String? photoUrl,
    List<String>? savedSpaceIds,
    List<String>? bookingIds,
    String? preferredNeighborhood,
    String? languagePreference,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      savedSpaceIds: savedSpaceIds ?? this.savedSpaceIds,
      bookingIds: bookingIds ?? this.bookingIds,
      preferredNeighborhood:
          preferredNeighborhood ?? this.preferredNeighborhood,
      languagePreference: languagePreference ?? this.languagePreference,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  bool isSpaceSaved(String spaceId) => savedSpaceIds.contains(spaceId);

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return phoneNumber.substring(phoneNumber.length - 2).toUpperCase();
  }

  String get formattedPhone {
    if (phoneNumber.startsWith('+254')) {
      return '0${phoneNumber.substring(3)}';
    }
    if (phoneNumber.startsWith('254')) {
      return '0${phoneNumber.substring(2)}';
    }
    return phoneNumber;
  }
}
