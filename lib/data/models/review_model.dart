class ReviewModel {
  final String id;
  final String spaceId;
  final String userId;
  final String userName;
  final double overallRating;
  final double wifiRating;
  final double powerRating;
  final double noiseRating;
  final double valueRating;
  final String? comment;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.id,
    required this.spaceId,
    required this.userId,
    required this.userName,
    required this.overallRating,
    required this.wifiRating,
    required this.powerRating,
    required this.noiseRating,
    required this.valueRating,
    this.comment,
    this.photoUrls = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      spaceId: json['spaceId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'Anonymous',
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
      wifiRating: (json['wifiRating'] as num?)?.toDouble() ?? 0.0,
      powerRating: (json['powerRating'] as num?)?.toDouble() ?? 0.0,
      noiseRating: (json['noiseRating'] as num?)?.toDouble() ?? 0.0,
      valueRating: (json['valueRating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spaceId': spaceId,
      'userId': userId,
      'userName': userName,
      'overallRating': overallRating,
      'wifiRating': wifiRating,
      'powerRating': powerRating,
      'noiseRating': noiseRating,
      'valueRating': valueRating,
      'comment': comment,
      'photoUrls': photoUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? spaceId,
    String? userId,
    String? userName,
    double? overallRating,
    double? wifiRating,
    double? powerRating,
    double? noiseRating,
    double? valueRating,
    String? comment,
    List<String>? photoUrls,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      overallRating: overallRating ?? this.overallRating,
      wifiRating: wifiRating ?? this.wifiRating,
      powerRating: powerRating ?? this.powerRating,
      noiseRating: noiseRating ?? this.noiseRating,
      valueRating: valueRating ?? this.valueRating,
      comment: comment ?? this.comment,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  double get averageCategoryRating =>
      (wifiRating + powerRating + noiseRating + valueRating) / 4;

  String get ratingBreakdown {
    return 'Wi-Fi: ${wifiRating.toStringAsFixed(1)} · Power: ${powerRating.toStringAsFixed(1)} · Noise: ${noiseRating.toStringAsFixed(1)} · Value: ${valueRating.toStringAsFixed(1)}';
  }
}
