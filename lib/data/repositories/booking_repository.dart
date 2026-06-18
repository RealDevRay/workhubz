import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final SupabaseClient _supabase;

  BookingRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<List<BookingModel>> getUserBookings(String userId) async {
    final response = await _supabase
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .order('start_time', ascending: false);
    return (response as List).map((json) => _fromJson(json)).toList();
  }

  Future<List<BookingModel>> getUpcomingBookings(String userId) async {
    final response = await _supabase
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .eq('booking_status', 'upcoming')
        .gte('start_time', DateTime.now().toIso8601String())
        .order('start_time');
    return (response as List).map((json) => _fromJson(json)).toList();
  }

  Future<List<BookingModel>> getActiveBookings(String userId) async {
    final response = await _supabase
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .eq('booking_status', 'active')
        .order('start_time');
    return (response as List).map((json) => _fromJson(json)).toList();
  }

  Future<List<BookingModel>> getPastBookings(String userId) async {
    final response = await _supabase
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .neq('booking_status', 'upcoming')
        .neq('booking_status', 'active')
        .order('end_time', ascending: false);
    return (response as List).map((json) => _fromJson(json)).toList();
  }

  Future<BookingModel?> getBookingById(String id) async {
    final response = await _supabase
        .from('bookings')
        .select()
        .eq('id', id)
        .single();
    return _fromJson(response);
  }

  Future<void> createBooking(BookingModel booking) async {
    await _supabase.from('bookings').insert({
      'id': booking.id,
      'user_id': booking.userId,
      'space_id': booking.spaceId,
      'space_name': booking.spaceName,
      'space_address': booking.spaceAddress,
      'start_time': booking.startTime.toIso8601String(),
      'end_time': booking.endTime.toIso8601String(),
      'total_amount': booking.totalAmount,
      'payment_status': booking.paymentStatus.name,
      'booking_status': booking.bookingStatus.name,
      'mpesa_receipt_number': booking.mpesaReceiptNumber,
      'check_in_code': booking.checkInCode,
      'duration_hours': booking.durationHours,
    });
  }

  Future<void> updateBooking(BookingModel booking) async {
    await _supabase
        .from('bookings')
        .update({
          'payment_status': booking.paymentStatus.name,
          'booking_status': booking.bookingStatus.name,
          'mpesa_receipt_number': booking.mpesaReceiptNumber,
          'checked_in_at': booking.checkedInAt?.toIso8601String(),
          'checked_out_at': booking.checkedOutAt?.toIso8601String(),
        })
        .eq('id', booking.id);
  }

  Future<void> updatePaymentStatus(
    String bookingId,
    PaymentStatus status, {
    String? mpesaReceiptNumber,
  }) async {
    await _supabase
        .from('bookings')
        .update({
          'payment_status': status.name,
          'mpesa_receipt_number': mpesaReceiptNumber,
        })
        .eq('id', bookingId);
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    await _supabase
        .from('bookings')
        .update({'booking_status': status.name})
        .eq('id', bookingId);
  }

  Future<void> checkIn(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({
          'checked_in_at': DateTime.now().toIso8601String(),
          'booking_status': BookingStatus.active.name,
        })
        .eq('id', bookingId);
  }

  Future<void> checkOut(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({
          'checked_out_at': DateTime.now().toIso8601String(),
          'booking_status': BookingStatus.completed.name,
        })
        .eq('id', bookingId);
  }

  Future<void> cancelBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'booking_status': BookingStatus.cancelled.name})
        .eq('id', bookingId);
  }

  Future<void> deleteBooking(String id) async {
    await _supabase.from('bookings').delete().eq('id', id);
  }

  BookingModel _fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      spaceId: json['space_id'] as String,
      spaceName: json['space_name'] as String,
      spaceAddress: json['space_address'] as String? ?? '',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      bookingStatus: BookingStatus.values.firstWhere(
        (e) => e.name == json['booking_status'],
        orElse: () => BookingStatus.upcoming,
      ),
      mpesaReceiptNumber: json['mpesa_receipt_number'] as String?,
      checkInCode: json['check_in_code'] as String?,
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'] as String)
          : null,
      checkedOutAt: json['checked_out_at'] != null
          ? DateTime.parse(json['checked_out_at'] as String)
          : null,
      isRated: json['is_rated'] as bool? ?? false,
      durationHours: json['duration_hours'] as int? ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
