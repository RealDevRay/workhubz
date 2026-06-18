import 'geo_point.dart';

enum BookingStatus { upcoming, active, completed, cancelled, noShow, pending }

enum PaymentStatus { pending, paid, refunded }

class BookingModel {
  final String id;
  final String userId;
  final String spaceId;
  final String spaceName;
  final String spaceAddress;
  final DateTime startTime;
  final DateTime endTime;
  final double totalAmount;
  final PaymentStatus paymentStatus;
  final BookingStatus bookingStatus;
  final String? mpesaReceiptNumber;
  final String? checkInCode;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final bool isRated;
  final int durationHours;
  final GeoPoint? spaceLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.spaceId,
    required this.spaceName,
    required this.spaceAddress,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.paymentStatus,
    required this.bookingStatus,
    this.mpesaReceiptNumber,
    this.checkInCode,
    this.checkedInAt,
    this.checkedOutAt,
    this.isRated = false,
    required this.durationHours,
    this.spaceLocation,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      spaceId: json['spaceId'] as String,
      spaceName: json['spaceName'] as String,
      spaceAddress: json['spaceAddress'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      bookingStatus: BookingStatus.values.firstWhere(
        (e) => e.name == json['bookingStatus'],
        orElse: () => BookingStatus.upcoming,
      ),
      mpesaReceiptNumber: json['mpesaReceiptNumber'] as String?,
      checkInCode: json['checkInCode'] as String?,
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'] as String)
          : null,
      checkedOutAt: json['checkedOutAt'] != null
          ? DateTime.parse(json['checkedOutAt'] as String)
          : null,
      isRated: json['isRated'] as bool? ?? false,
      durationHours: json['durationHours'] as int? ?? 1,
      spaceLocation: json['spaceLocation'] != null
          ? GeoPoint(
              json['spaceLocation']['latitude'] as double,
              json['spaceLocation']['longitude'] as double,
            )
          : null,
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
      'userId': userId,
      'spaceId': spaceId,
      'spaceName': spaceName,
      'spaceAddress': spaceAddress,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus.name,
      'bookingStatus': bookingStatus.name,
      'mpesaReceiptNumber': mpesaReceiptNumber,
      'checkInCode': checkInCode,
      'checkedInAt': checkedInAt?.toIso8601String(),
      'checkedOutAt': checkedOutAt?.toIso8601String(),
      'isRated': isRated,
      'durationHours': durationHours,
      'spaceLocation': spaceLocation != null
          ? {
              'latitude': spaceLocation!.latitude,
              'longitude': spaceLocation!.longitude,
            }
          : null,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? spaceId,
    String? spaceName,
    String? spaceAddress,
    DateTime? startTime,
    DateTime? endTime,
    double? totalAmount,
    PaymentStatus? paymentStatus,
    BookingStatus? bookingStatus,
    String? mpesaReceiptNumber,
    String? checkInCode,
    DateTime? checkedInAt,
    DateTime? checkedOutAt,
    bool? isRated,
    int? durationHours,
    GeoPoint? spaceLocation,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      spaceId: spaceId ?? this.spaceId,
      spaceName: spaceName ?? this.spaceName,
      spaceAddress: spaceAddress ?? this.spaceAddress,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      mpesaReceiptNumber: mpesaReceiptNumber ?? this.mpesaReceiptNumber,
      checkInCode: checkInCode ?? this.checkInCode,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedOutAt: checkedOutAt ?? this.checkedOutAt,
      isRated: isRated ?? this.isRated,
      durationHours: durationHours ?? this.durationHours,
      spaceLocation: spaceLocation ?? this.spaceLocation,
    );
  }

  bool get canCheckIn {
    final now = DateTime.now();
    final fifteenMinutesBefore = startTime.subtract(
      const Duration(minutes: 15),
    );
    final thirtyMinutesAfter = startTime.add(const Duration(minutes: 30));
    return bookingStatus == BookingStatus.upcoming &&
        paymentStatus == PaymentStatus.paid &&
        now.isAfter(fifteenMinutesBefore) &&
        now.isBefore(thirtyMinutesAfter);
  }

  bool get canCancel {
    final now = DateTime.now();
    return bookingStatus == BookingStatus.upcoming &&
        paymentStatus == PaymentStatus.pending &&
        startTime.isAfter(now);
  }

  bool get isExpired {
    final now = DateTime.now();
    return endTime.isBefore(now) && bookingStatus == BookingStatus.completed;
  }

  String get statusDisplay {
    switch (bookingStatus) {
      case BookingStatus.upcoming:
        return 'Upcoming';
      case BookingStatus.active:
        return 'Active';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.noShow:
        return 'No Show';
      case BookingStatus.pending:
        return 'Pending';
    }
  }
}
