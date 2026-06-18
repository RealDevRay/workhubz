class PricingTierModel {
  final double hourlyRate;
  final double? halfDayRate;
  final double? fullDayRate;
  final double? weeklyRate;
  final String currency;
  final String? notes;
  final bool studentDiscountAvailable;

  const PricingTierModel({
    required this.hourlyRate,
    this.halfDayRate,
    this.fullDayRate,
    this.weeklyRate,
    this.currency = 'KES',
    this.notes,
    this.studentDiscountAvailable = false,
  });

  factory PricingTierModel.fromJson(Map<String, dynamic> json) {
    return PricingTierModel(
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      halfDayRate: json['halfDayRate'] != null
          ? (json['halfDayRate'] as num).toDouble()
          : null,
      fullDayRate: json['fullDayRate'] != null
          ? (json['fullDayRate'] as num).toDouble()
          : null,
      weeklyRate: json['weeklyRate'] != null
          ? (json['weeklyRate'] as num).toDouble()
          : null,
      currency: json['currency'] as String? ?? 'KES',
      notes: json['notes'] as String?,
      studentDiscountAvailable: json['studentDiscountAvailable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hourlyRate': hourlyRate,
      'halfDayRate': halfDayRate,
      'fullDayRate': fullDayRate,
      'weeklyRate': weeklyRate,
      'currency': currency,
      'notes': notes,
      'studentDiscountAvailable': studentDiscountAvailable,
    };
  }

  PricingTierModel copyWith({
    double? hourlyRate,
    double? halfDayRate,
    double? fullDayRate,
    double? weeklyRate,
    String? currency,
    String? notes,
    bool? studentDiscountAvailable,
  }) {
    return PricingTierModel(
      hourlyRate: hourlyRate ?? this.hourlyRate,
      halfDayRate: halfDayRate ?? this.halfDayRate,
      fullDayRate: fullDayRate ?? this.fullDayRate,
      weeklyRate: weeklyRate ?? this.weeklyRate,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      studentDiscountAvailable:
          studentDiscountAvailable ?? this.studentDiscountAvailable,
    );
  }

  double calculateTotal(int hours) {
    if (hours >= 8 && fullDayRate != null) {
      return fullDayRate!;
    } else if (hours >= 4 && halfDayRate != null) {
      return halfDayRate!;
    }
    return hourlyRate * hours;
  }

  String get priceCategory {
    if (hourlyRate < 100) return 'budget';
    if (hourlyRate < 250) return 'moderate';
    return 'premium';
  }
}
