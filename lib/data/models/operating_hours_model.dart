class OperatingHoursModel {
  final int openHour;
  final int closeHour;
  final bool is24Hours;
  final Map<int, DayHours?> weeklySchedule;

  const OperatingHoursModel({
    required this.openHour,
    required this.closeHour,
    this.is24Hours = false,
    weeklySchedule,
  }) : weeklySchedule = weeklySchedule ?? const {};

  factory OperatingHoursModel.fromJson(Map<String, dynamic> json) {
    return OperatingHoursModel(
      openHour: json['openHour'] as int,
      closeHour: json['closeHour'] as int,
      is24Hours: json['is24Hours'] as bool? ?? false,
      weeklySchedule: (json['weeklySchedule'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(int.parse(key), value != null ? DayHours.fromJson(value as Map<String, dynamic>) : null),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openHour': openHour,
      'closeHour': closeHour,
      'is24Hours': is24Hours,
      'weeklySchedule': weeklySchedule.map(
        (key, value) => MapEntry(key.toString(), value?.toJson()),
      ),
    };
  }

  bool isOpenNow() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final weekday = now.weekday;

    final dayHours = weeklySchedule[weekday];
    if (dayHours != null && dayHours.closed) {
      return false;
    }

    if (is24Hours) return true;

    if (dayHours != null) {
      return currentHour >= dayHours.openHour && currentHour < dayHours.closeHour;
    }

    return currentHour >= openHour && currentHour < closeHour;
  }

  String getFormattedHours() {
    if (is24Hours) return '24 Hours';

    final openTime = _formatHour(openHour);
    final closeTime = _formatHour(closeHour);
    return '$openTime - $closeTime';
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  OperatingHoursModel copyWith({
    int? openHour,
    int? closeHour,
    bool? is24Hours,
    Map<int, DayHours?>? weeklySchedule,
  }) {
    return OperatingHoursModel(
      openHour: openHour ?? this.openHour,
      closeHour: closeHour ?? this.closeHour,
      is24Hours: is24Hours ?? this.is24Hours,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
    );
  }
}

class DayHours {
  final int openHour;
  final int closeHour;
  final bool closed;

  const DayHours({
    required this.openHour,
    required this.closeHour,
    this.closed = false,
  });

  factory DayHours.fromJson(Map<String, dynamic> json) {
    return DayHours(
      openHour: json['openHour'] as int,
      closeHour: json['closeHour'] as int,
      closed: json['closed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openHour': openHour,
      'closeHour': closeHour,
      'closed': closed,
    };
  }
}
