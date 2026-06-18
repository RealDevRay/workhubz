import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

final userBookingsProvider = FutureProvider.family<List<BookingModel>, String>((ref, userId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUserBookings(userId);
});

final upcomingBookingsProvider = FutureProvider.family<List<BookingModel>, String>((ref, userId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUpcomingBookings(userId);
});

final activeBookingsProvider = FutureProvider.family<List<BookingModel>, String>((ref, userId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getActiveBookings(userId);
});

final pastBookingsProvider = FutureProvider.family<List<BookingModel>, String>((ref, userId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getPastBookings(userId);
});

final bookingByIdProvider = FutureProvider.family<BookingModel?, String>((ref, id) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBookingById(id);
});

final selectedBookingProvider = StateProvider<BookingModel?>((ref) => null);

class BookingState {
  final List<BookingModel> bookings;
  final bool isLoading;
  final String? error;

  const BookingState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  BookingState copyWith({
    List<BookingModel>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository _repository;
  final String userId;

  BookingNotifier(this._repository, this.userId) : super(const BookingState()) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bookings = await _repository.getUserBookings(userId);
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createBooking(BookingModel booking) async {
    try {
      await _repository.createBooking(booking);
      await loadBookings();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _repository.cancelBooking(bookingId);
      await loadBookings();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> checkIn(String bookingId) async {
    try {
      await _repository.checkIn(bookingId);
      await loadBookings();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> checkOut(String bookingId) async {
    try {
      await _repository.checkOut(bookingId);
      await loadBookings();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updatePaymentStatus(
    String bookingId,
    PaymentStatus status, {
    String? mpesaReceiptNumber,
  }) async {
    try {
      await _repository.updatePaymentStatus(
        bookingId,
        status,
        mpesaReceiptNumber: mpesaReceiptNumber,
      );
      await loadBookings();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final bookingNotifierProvider = StateNotifierProvider.family<BookingNotifier, BookingState, String>(
  (ref, userId) {
    final repository = ref.watch(bookingRepositoryProvider);
    return BookingNotifier(repository, userId);
  },
);

class PendingBookingState {
  final String? spaceId;
  final String? spaceName;
  final DateTime? selectedDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final int durationHours;
  final double totalAmount;

  const PendingBookingState({
    this.spaceId,
    this.spaceName,
    this.selectedDate,
    this.startTime,
    this.endTime,
    this.durationHours = 1,
    this.totalAmount = 0,
  });

  PendingBookingState copyWith({
    String? spaceId,
    String? spaceName,
    DateTime? selectedDate,
    DateTime? startTime,
    DateTime? endTime,
    int? durationHours,
    double? totalAmount,
  }) {
    return PendingBookingState(
      spaceId: spaceId ?? this.spaceId,
      spaceName: spaceName ?? this.spaceName,
      selectedDate: selectedDate ?? this.selectedDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

final pendingBookingProvider = StateProvider<PendingBookingState>((ref) => const PendingBookingState());
