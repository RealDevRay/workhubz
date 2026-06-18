import 'package:intl/intl.dart';

class TimeSlot {
  final DateTime start;
  final DateTime end;
  const TimeSlot({required this.start, required this.end});
}

class TimeUtils {
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  static String formatETA(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }

  static String formatOperatingHours({
    required int openHour,
    required int closeHour,
  }) {
    final openTime = DateTime(2024, 1, 1, openHour);
    final closeTime = DateTime(2024, 1, 1, closeHour);
    return '${formatTime(openTime)} - ${formatTime(closeTime)}';
  }

  static bool isOpen(DateTime now, int openHour, int closeHour) {
    final currentHour = now.hour;
    if (closeHour > openHour) {
      return currentHour >= openHour && currentHour < closeHour;
    } else {
      return currentHour >= openHour || currentHour < closeHour;
    }
  }

  static String getDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static List<DateTime> getAvailableSlots(
    DateTime date,
    int slotDurationMinutes, {
    required int openHour,
    required int closeHour,
    List<TimeSlot> existingBookings = const [],
  }) {
    final slots = <DateTime>[];
    var currentSlot = DateTime(date.year, date.month, date.day, openHour);
    final endTime = DateTime(date.year, date.month, date.day, closeHour);

    while (currentSlot.isBefore(endTime)) {
      final slotEnd = currentSlot.add(Duration(minutes: slotDurationMinutes));

      final isAvailable = !existingBookings.any((booking) {
        return currentSlot.isBefore(booking.end) && slotEnd.isAfter(booking.start);
      });

      if (isAvailable) {
        slots.add(currentSlot);
      }
      currentSlot = slotEnd;
    }

    return slots;
  }
}
